import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:molokosbor/Pages/AuthAndRegPage/AuthPage.dart';
import 'package:molokosbor/Pages/AdministrartorPages/administrator_page.dart';
import 'package:molokosbor/Pages/CollectorPages/home_collector_page.dart';
import 'package:molokosbor/Pages/ClientPages/home_client.dart';

class AuthStateChecker extends StatefulWidget {
  const AuthStateChecker({Key? key}) : super(key: key);
  @override
  _AuthStateCheckerState createState() => _AuthStateCheckerState();
}

class _AuthStateCheckerState extends State<AuthStateChecker> {
  final supabase = Supabase.instance.client;
  /// сюда запишем роль после первого запроса
  String? _role;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (ctx, authSnap) {
        final session = authSnap.data?.session;
        if (session == null) {
          // нет сессии — авторизация
          return const AutorizationPage();
        }

        // есть сессия
        final userId = session.user.id;

        // если роль ещё не загружена — грузим один раз
        if (_role == null) {
          return FutureBuilder<Map<String, dynamic>?>(
            future: supabase
                .from('profiles')
                .select('role')
                .eq('id', userId)
                .maybeSingle(),  // выгрузка одного объекта без execute() :contentReference[oaicite:0]{index=0}
            builder: (ctx2, profSnap) {
              if (profSnap.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (profSnap.hasError || profSnap.data == null) {
                // ошибка или профиль не найден — разлогиниваем
                supabase.auth.signOut();
                return const Scaffold(
                  body: Center(child: Text('Ошибка профиля, выход')),
                );
              }
              // сохраняем роль и пересоздаём StatefulWidget
              _role = profSnap.data!['role'] as String;
              // вызываем rebuild
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {});
              });
              return const SizedBox(); // пока ждём rebuild
            },
          );
        }

        // если роль уже есть — сразу навигируем по ней
        switch (_role) {
          case 'admin':
            return  AdministratorPage();
          case 'collector':
            return  CollectorHomePage();
          case 'client':
            return const HomeClientPage();
          default:
            return Scaffold(
              body: Center(child: Text('Неизвестная роль: $_role')),
            );
        }
      },
    );
  }
}
