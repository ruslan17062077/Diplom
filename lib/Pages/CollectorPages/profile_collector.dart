import 'package:flutter/material.dart';
import 'package:molokosbor/DataBase/models/profiles.dart';
import 'package:molokosbor/DataBase/services/deliveries_service.dart';
import 'package:molokosbor/DataBase/services/location_phone_service.dart';
import 'package:molokosbor/DataBase/services/user.dart';
import 'package:molokosbor/Themes/ThemeProvider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';



class ProfileCollectorPage extends StatefulWidget {
  const ProfileCollectorPage({super.key});

  @override
  State<ProfileCollectorPage> createState() => _ProfileCollectorPageState();
}

class _ProfileCollectorPageState extends State<ProfileCollectorPage> {
  final supabase = Supabase.instance.client;
  Profile? user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final _user = await ProfileService().getUser();
      setState(() {
        user = _user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _editClient(Profile client) async {
    final updated = await Navigator.pushNamed(
      context,
      '/edit_collector',
      arguments: client,
    ) as Profile?;
    if (updated != null) {
      setState(() => user = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Профиль'),
          actions: _appActions(),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: _appActions(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileCard(),
           
          ],
        ),
      ),
    );
  }

  List<Widget> _appActions() => [
        IconButton(
          onPressed: () =>
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
          icon: const Icon(Icons.brightness_4_outlined),
        ),
        IconButton(
          onPressed: () async {
            await supabase.auth.signOut();
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, '/login');
          },
          icon: const Icon(Icons.logout_outlined),
        ),
      ];

  Widget _buildProfileCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              "${user!.first_name ?? ''} ${user!.name} ${user!.last_name ?? ''}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(user!.email, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Телефон: ${user!.phone}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Настройки профиля'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _editClient(user!),
            ),
          ],
        ),
      ),
    );
  }
}