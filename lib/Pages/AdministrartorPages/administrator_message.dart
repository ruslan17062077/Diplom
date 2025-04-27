// chat_list_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Модель для превью диалога
class ChatConversation {
  final String otherProfileId;
  final String otherName;
  final String lastMessage;
  final DateTime lastMessageAt;

  ChatConversation({
    required this.otherProfileId,
    required this.otherName,
    required this.lastMessage,
    required this.lastMessageAt,
  });
}

class ChatListAdministratorPage extends StatefulWidget {
  const ChatListAdministratorPage({Key? key}) : super(key: key);
  @override
  _ChatListAdministratorPageState createState() => _ChatListAdministratorPageState();
}

class _ChatListAdministratorPageState extends State<ChatListAdministratorPage> {
  final _supabase = Supabase.instance.client;
  late final String _myId;
  late Future<List<ChatConversation>> _chatsFuture;

  @override
  void initState() {
    super.initState();
    _myId = _supabase.auth.currentUser!.id;
    _chatsFuture = _fetchChatList();
  }

  Future<List<ChatConversation>> _fetchChatList() async {
    final userId = _myId;
    // 1) Берём последние сообщения, где участвует пользователь
    final res = await _supabase
        .from('messages')
        .select('profile_id, profile_to, content, created_at')
        .or('profile_id.eq.$userId,profile_to.eq.$userId')
        .order('created_at', ascending: false)
        ;

    if ( res == null) return [];
    final rows = List<Map<String, dynamic>>.from(res);

    // 2) Группируем по собеседнику, оставляя последнее сообщение
    final chatMap = <String, Map<String, dynamic>>{};
    for (var row in rows) {
      final from = row['profile_id'] as String;
      final to   = row['profile_to'] as String;
      final otherId = from == userId ? to : from;
      chatMap.putIfAbsent(otherId, () => row);
    }

    if (chatMap.isEmpty) return [];

    // 3) Подтягиваем имена
    final otherIds = chatMap.keys.toList();
    final profiles = await _supabase
        .from('profiles')
        .select('id, name')
        .inFilter('id', otherIds);
    final nameMap = <String, String>{};
    if (profiles != null) {
      for (var p in profiles as List) {
        nameMap[p['id'] as String] = p['name'] as String;
      }
    }

    // 4) Собираем итог
    return chatMap.entries.map((e) {
      final row = e.value;
      return ChatConversation(
        otherProfileId: e.key,
        otherName:      nameMap[e.key] ?? 'Без имени',
        lastMessage:    row['content'] as String,
        lastMessageAt:  DateTime.parse(row['created_at'] as String),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Чаты')),
      body: FutureBuilder<List<ChatConversation>>(
        future: _chatsFuture,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Ошибка: ${snap.error}'));
          }
          final chats = snap.data!;
          if (chats.isEmpty) {
            return const Center(child: Text('Нет активных чатов'));
          }
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (ctx, i) {
              final chat = chats[i];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  title: Text(
                    chat.otherName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    TimeOfDay.fromDateTime(chat.lastMessageAt)
                        .format(context),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/chat',
                      arguments: {
                        'myProfileId': _myId,
                        'otherProfileId': chat.otherProfileId,
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
