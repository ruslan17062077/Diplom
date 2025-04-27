import 'package:flutter/material.dart';
import 'package:molokosbor/Pages/ClientPages/profile_client.dart';
import 'package:molokosbor/Pages/FirstPages/FirstPage.dart';
import 'package:molokosbor/Pages/MessagePages/message.dart';

class HomeClientPage extends StatefulWidget {
  const HomeClientPage({super.key});

  @override
  State<HomeClientPage> createState() => _HomeClientPageState();
}

class _HomeClientPageState extends State<HomeClientPage> {
  @override
  int currentPageIndex = 0;
  List pages =[
    HomePage(),
    ProfileClientPage(),
    MessagePage()
  ];

  

  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: 
      const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.account_box)),
            label: 'Профиль',
          ),
          NavigationDestination(
            icon: Badge(label: Text('2'), child: Icon(Icons.message)),
            label: 'Сообщения',
          ),
        ],),
    );
  }
}