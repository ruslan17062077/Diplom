import 'package:flutter/material.dart';
import 'package:molokosbor/Pages/AdministrartorPages/administrator_page.dart';
import 'package:molokosbor/Pages/AdministrartorPages/home_administrtor.dart';
import 'package:molokosbor/Pages/AuthAndRegPage/AuthPage.dart';
import 'package:molokosbor/Pages/ClientPages/home_client.dart';
import 'package:molokosbor/Pages/CollectorPages/home_collector_page.dart';
import 'package:molokosbor/Pages/FirstPages/FirstPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthStateChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Если есть активный пользователь, перенаправляем на HomePage, иначе на AuthPage
        if (snapshot.hasData && snapshot.data!.session != null) {
          return AdministratorPage();
        } else {
          return AutorizationPage();
        }
      },
    );
  }
}
