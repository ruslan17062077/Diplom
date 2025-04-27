import 'package:flutter/material.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Чаты'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ChatTile(
              title: "Написать администратору",
              subtitle: "Задать вопрос или сообщить о проблеме",
              icon: Icons.admin_panel_settings,
              color: Colors.blueAccent,
              onTap: () {
                Navigator.pushNamed(context, "/chatAdmin");
              },
            ),
            SizedBox(height: 16),
            ChatTile(
              title: "Написать сборщику",
              subtitle: "Связаться по поводу сбора молока",
              icon: Icons.person_pin_circle,
              color: Colors.green,
              onTap: () {
                Navigator.pushNamed(context, "/chatCollector");
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                radius: 30,
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
