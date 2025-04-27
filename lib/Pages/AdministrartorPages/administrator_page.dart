import 'package:flutter/material.dart';

import 'package:molokosbor/Themes/ThemeProvider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class AdministratorPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    return Scaffold(
      appBar: AppBar(
        title: Text('Администратор'),
        actions: [ IconButton(
                onPressed: () =>
                    Provider.of<ThemeProvider>(context, listen: false)
                        .toggleTheme(),
                icon: const Icon(Icons.brightness_4_outlined),
              ),
              IconButton( icon: const Icon(Icons.logout_outlined),
                onPressed: () async {
                  await supabase.auth.signOut();
                 
                  Navigator.pushReplacementNamed(context, '/login');})],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildButton(context, Icons.people, 'Клиенты', '/clients'),
            _buildButton(context, Icons.person, 'Сборщики', '/collectors'),
            _buildButton(context, Icons.location_city, 'Поселения', '/settlements'),
            _buildButton(context, Icons.currency_ruble, 'Цена за молоко','/milk_prices'),  
            _buildButton(context, Icons.message, 'Сообщения', '/message_administrator'),
            _buildButton(context, Icons.assignment, 'Заявки', '/'),
            _buildButton(context, Icons.bar_chart, 'Отчёты', '/'),
            _buildButton(context, Icons.settings, 'Настройки', '/'),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, IconData icon, String label, String router) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      onPressed: () {
        Navigator.pushNamed(context, router);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48.0),
          SizedBox(height: 8.0),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}
