// chat_list_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:molokosbor/Pages/MessagePages/message.dart';
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

class ChatListPage extends StatefulWidget {
  const ChatListPage({Key? key}) : super(key: key);
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
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
    final excludedId = '0091314f-879a-46bb-a26e-f7f97ca19ab5';
    final res = await _supabase
        .from('messages')
        .select('profile_id, profile_to, content, created_at')
        .or('profile_id.eq.$userId,profile_to.eq.$userId')
        .neq('profile_id', excludedId) // исключаем, когда отправитель – этот ID
        .neq('profile_to', excludedId) // исключаем, когда получатель – этот ID
        .order('created_at', ascending: false);

    if (res == null) return [];
    final rows = List<Map<String, dynamic>>.from(res);

    // 2) Группируем по собеседнику, оставляя последнее сообщение
    final chatMap = <String, Map<String, dynamic>>{};
    for (var row in rows) {
      final from = row['profile_id'] as String;
      final to = row['profile_to'] as String;
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
        otherName: nameMap[e.key] ?? 'Без имени',
        lastMessage: row['content'] as String,
        lastMessageAt: DateTime.parse(row['created_at'] as String),
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

          return Column(
            children: [
              SizedBox(
                child: ChatTile(
                  title: "Написать администратору",
                  subtitle: "Задать вопрос или сообщить о проблеме",
                  icon: Icons.admin_panel_settings,
                  color: Colors.blueAccent,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      "/chat",
                      arguments: {
                        'myProfileId': _myId,
                        'otherProfileId':
                            '0091314f-879a-46bb-a26e-f7f97ca19ab5',
                      },
                    );
                  },
                ),
              ),
                 Padding(
                   padding: const EdgeInsets.fromLTRB(20 ,0 ,0 ,0),
                   child: const SizedBox(
                    
                     width: double.infinity,                // растягиваем на всю ширину
                     child: Text(
                       'Клиенты :',
                       textAlign: TextAlign.left, 
                                 // выравниваем по левому краю
                       style: TextStyle(fontSize: 24),
                     ),
                   ),
                 ),

              Expanded(
                child: ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (ctx, i) {
                    final chat = chats[i];
                    return Container(
  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  decoration: BoxDecoration(
    color: Theme.of(context).cardColor, // фон карточки
    borderRadius: BorderRadius.circular(30), // большой радиус
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: ListTile(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30), // тот же радиус для ListTile
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    leading: CircleAvatar(
      radius: 24,
      backgroundColor:
          Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Icon(
        Icons.person,
        color: Theme.of(context).colorScheme.primary,
        size: 28,
      ),
    ),
    title: Text(
      chat.otherName,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
    subtitle: Text(
      chat.lastMessage,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    trailing: Text(
      DateFormat('HH:mm').format(chat.lastMessageAt),
      style: const TextStyle(fontSize: 12, color: Colors.grey),
    ),
    onTap: () => Navigator.pushNamed(
      context,
      '/chat',
      arguments: {
        'myProfileId': _myId,
        'otherProfileId': chat.otherProfileId,
      },
    ),
  ),
);

                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
