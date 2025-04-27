import 'package:flutter/material.dart';
import 'package:molokosbor/DataBase/models/drop_point.dart';
import 'package:molokosbor/DataBase/models/profiles.dart';
import 'package:molokosbor/DataBase/services/collector_service.dart';
import 'package:molokosbor/DataBase/services/location_phone_service.dart';
import 'package:molokosbor/Pages/CollectorPages/collector_message.dart';
import 'package:molokosbor/Pages/CollectorPages/profile_collector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// TODO: Подключите ваши модели Profile, Request и сервисы ClientsService и RequestsService
// import 'package:molokosbor/DataBase/models/profiles.dart';
// import 'package:molokosbor/DataBase/services/clients_service.dart';
// import 'package:molokosbor/DataBase/services/requests_service.dart';

class CollectorHomePage extends StatefulWidget {
  @override
  _CollectorHomePageState createState() => _CollectorHomePageState();
}

class _CollectorHomePageState extends State<CollectorHomePage> {
  int _selectedIndex = 0;


  final _pages = <Widget>[
    RoutePage(),
    RoutePage(),
    ChatListPage(),
    ProfileCollectorPage()
  ];

  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.map, size: 28), label: 'Маршрут'),
          BottomNavigationBarItem(
              icon: Icon(Icons.build, size: 28), label: 'Заявки'),
          BottomNavigationBarItem(
              icon: Icon(Icons.message, size: 28), label: 'Сообщения'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 28), label: 'Профиль'),
        ],
      ),
    );
  }
}

// ===== Страница «Маршрут» =====
class RoutePage extends StatefulWidget {
  @override
  _RoutePageState createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  List<DropPoint> drop_point = [];
  String? id;

  @override
  void initState() {
    super.initState();
    id = Supabase.instance.client.auth.currentUser!.id;
    _loadClients();
  }

  Future<void> _loadClients() async {
    drop_point = await CollectorService().getAllDropPointCollector(id!)
        as List<DropPoint>;
    setState(() {});
  }

  Future<Profile> addDelivery(Profile client, int index) async {
    final update = await Navigator.pushNamed(context, '/collector_delivery',
        arguments: client);
    if (update != null) {
      return update as Profile;
    }
    return client;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Маршрут'),
          actions: [],
        ),
        body: drop_point.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: drop_point.length,
                itemBuilder: (context, index) {
                  final dp = drop_point[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    elevation: 4,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child:
                            const Icon(Icons.location_on, color: Colors.white),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              dp.adress,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.directions),
                            tooltip: 'Открыть маршрут',
                            onPressed: () {
                              LocationPhoneService().map(dp);
                            },
                          ),
                        ],
                      ),
                      childrenPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      children: (dp.clients != null && dp.clients!.isNotEmpty)
                          ? dp.clients!.map((client) {
                              final today = DateTime.now();
                              final hadDeliveryToday =
                                  client?.delivery?.any((d) {
                                        final dt = d!.deliveryTime;
                                        return dt.year == today.year &&
                                            dt.month == today.month &&
                                            dt.day == today.day &&
                                            d.status != 'Отмена';
                                      }) ??
                                      false;
                              final canceledToday = client?.delivery?.any((d) {
                                    final dt = d!.deliveryTime;
                                    return dt.year == today.year &&
                                        dt.month == today.month &&
                                        dt.day == today.day &&
                                        d.status == 'Отмена';
                                  }) ??
                                  false;
                              final tileColor =
                                  (!hadDeliveryToday && !canceledToday)
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.red.withOpacity(0.2);

                              return ListTile(
                                  tileColor: tileColor,
                                  contentPadding: EdgeInsets.zero,
                                  leading: const CircleAvatar(
                                      child: Icon(Icons.person)),
                                  title: Text(client?.name ?? 'Без имени'),
                                  subtitle: client?.phone != null
                                      ? Text(client!.phone!)
                                      : null,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.message),
                                        tooltip: 'Позвонить',
                                        onPressed: () async {
                                          Navigator.pushNamed(context, '/chat',
                                              arguments: {
                                                'myProfileId': id,
                                                'otherProfileId': client!.id,
                                              });
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.phone),
                                        tooltip: 'Позвонить',
                                        onPressed: () async {
                                          final phone = client!.phone;
                                          if (phone != null &&
                                              phone.isNotEmpty) {
                                            final uri = Uri.parse('tel:$phone');
                                            if (!await launchUrl(uri,
                                                mode: LaunchMode
                                                    .externalApplication)) {
                                              throw Exception(
                                                  'Не удалось позвонить: \$uri');
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  onTap: () async {
                                    if (tileColor ==
                                        Colors.green.withOpacity(0.2)) {
                                      final _client = await addDelivery(
                                          client as Profile, index);
                                      setState(() {
                                        client == _client;
                                      });
                                    }
                                  });
                            }).toList()
                          : [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Center(
                                  child: Text(
                                    'Клиенты отсутствуют',
                                    style:
                                        TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                ),
                              )
                            ],
                    ),
                  );
                },
              ));
  }
}
