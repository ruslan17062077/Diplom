import 'package:flutter/material.dart';
import 'package:molokosbor/DataBase/models/profiles.dart';
import 'package:molokosbor/DataBase/services/user.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: FutureBuilder<List<Profile>>(
        future: ProfileService().getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user.name),
                subtitle: Text('${user.email} • ${user.role}  ${user.drop_point?.adress}'),
                trailing: user.phone != null ? Text(user.phone!) : null,
              );
            },
          );
        },
      ),
    );
  }
}
