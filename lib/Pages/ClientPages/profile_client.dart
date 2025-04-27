import 'package:flutter/material.dart';
import 'package:molokosbor/DataBase/models/profiles.dart';
import 'package:molokosbor/DataBase/services/deliveries_service.dart';
import 'package:molokosbor/DataBase/services/location_phone_service.dart';
import 'package:molokosbor/DataBase/services/user.dart';
import 'package:molokosbor/Themes/ThemeProvider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';



class ProfileClientPage extends StatefulWidget {
  const ProfileClientPage({super.key});

  @override
  State<ProfileClientPage> createState() => _ProfileClientPageState();
}

class _ProfileClientPageState extends State<ProfileClientPage> {
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
      '/edit_client',
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
            _buildDeliveryCard(),
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
            if (user!.drop_point != null)
              Text('Место сдачи: ${user!.drop_point!.adress}',
                  style: const TextStyle(fontSize: 16)),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('История операций'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.monetization_on),
              title: const Text('Запросить выплату'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
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

  Widget _buildDeliveryCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<DateTime>(
              future: DeliveryService().getNextDeliveryDate(user!.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Text(
                    'Ошибка: ${snapshot.error}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  );
                }
                final date = snapshot.requireData;
                final today = DateTime.now();
                final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
                final display = isToday
                    ? 'Следующая сдача: Сегодня'
                    : 'Следующая сдача: ${_formatDate(date)}';
                return Text(
                  display,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                );
              },
            ),
            const SizedBox(height: 8),
            if (user!.drop_point != null) ...[
              _infoRow(Icons.person_outline,
                  'Сборщик: ${user!.drop_point!.profile?.name ?? '—'}'),
              const SizedBox(height: 8),
              _infoRow(Icons.phone, 'Номер: ${user!.drop_point!.profile?.phone ?? 'Скрыт'}'),
              const SizedBox(height: 16),
            ],
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _cancelDelivery,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Отменить сдачу'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                ),
                _mapButton(),
                _callCollectorButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Row(
        children: [Icon(icon, color: Colors.grey), const SizedBox(width: 8), Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
      ]);

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  Future<void> _cancelDelivery() async {
    await DeliveryService().cancelDelivery(clientId: user!.id, collectorId: user!.drop_point?.profile?.id, notes: 'Отменено пользователем');
    setState(() {});
  }

  Widget _mapButton() {
    return ElevatedButton.icon(
      onPressed: () async {await LocationPhoneService().map(user!.drop_point!);},
      icon: const Icon(Icons.map_outlined),
      label: const Text('Открыть маршрут'),
    );
  }

  Widget _callCollectorButton() {
    return ElevatedButton.icon(
      onPressed: () async {final phone = user!.drop_point!.profile?.phone;
      if (phone != null && phone.isNotEmpty) {
        final uri = Uri.parse('tel:$phone');
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          throw Exception('Не удалось позвонить: \$uri');
        }
      }},
      icon: const Icon(Icons.phone),
      label: const Text('Позвонить сборщику'),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
    );
  }
}
