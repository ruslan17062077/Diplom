import 'package:flutter/material.dart';
import 'package:molokosbor/DataBase/models/message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatPage extends StatefulWidget {
  final String myProfileId;
  final String otherProfileId;

  const ChatPage({
    Key? key,
    required this.myProfileId,
    required this.otherProfileId,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _supabase = Supabase.instance.client;
  final _controller = TextEditingController();

  /// Отправка нового сообщения
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await _supabase.from('messages').insert({
      'profile_id': widget.myProfileId,
      'profile_to': widget.otherProfileId,
      'content': text,
      'created_at': DateTime.now().toIso8601String(),
    });

    _controller.clear();
  }

  /// Стрим сообщений между двумя пользователями
 Stream<List<Message>> get _messageStream {
  final p1 = widget.myProfileId;
  final p2 = widget.otherProfileId;



  return _supabase
    .from('messages')
    .stream(primaryKey: ['id'])                    // 1) realtime-стрим по PK
    .order('created_at', ascending: true)          // 2) сразу сортируем
    .map((rows) {
      // 3) фильтруем: либо от меня к нему, либо от него ко мне
      final dialog = rows.where((m) {
        final from = m['profile_id'] as String;
        final to   = m['profile_to'] as String;
        return (from == p1 && to == p2) ||
               (from == p2 && to == p1);
      });

      // 4) конвертим каждую Map в Message и возвращаем List
      return dialog
        .map((m) => Message.fromMap(map: m, myUserId: p1))
        .toList();
    });


}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Чат'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _messageStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Ошибка: \${snapshot.error}'));
                }
                final messages = snapshot.data ?? [];

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final align = msg.isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start;
                    final color = msg.isMine ? Colors.blue[100] : Colors.grey[200];

                    return Column(
                      crossAxisAlignment: align,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(msg.content),
                        ),
                        Text(
                          TimeOfDay.fromDateTime(msg.createdAt).format(context),
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Напишите сообщение...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
