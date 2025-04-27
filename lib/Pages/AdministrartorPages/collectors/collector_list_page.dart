import 'package:flutter/material.dart';
import 'package:molokosbor/DataBase/models/profiles.dart';
import 'package:molokosbor/DataBase/services/collectors_service.dart';
import 'package:url_launcher/url_launcher.dart';

class CollectorListPage extends StatefulWidget {
  const CollectorListPage({super.key});

  @override
  State<CollectorListPage> createState() => _CollectorListPageState();
}

class _CollectorListPageState extends State<CollectorListPage> {
  late List<Profile> collectors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    getAllCollectors();
  }

  Future getAllCollectors() async {
    collectors = await CollectorsService().getAllCollectors();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> editCollector(Profile client, int index) async {
    final updated = await Navigator.pushNamed(
      context,
      '/edit_collector',
      arguments: client,
    ) as Profile?;
    if (updated != null) {
      setState(() {
        collectors[index] = updated;
      });
    }
  }

  Future<void> addCollector() async {
    final updated = await Navigator.pushNamed(context, '/add_collector');
    if (updated != null) {
      setState(() {
        // Обновляем в обоих списках
        collectors.add(updated as Profile);
      });
    }
  }

  

  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
          appBar: AppBar(
            title: Text('Список сборщиков'),
            actions: [
              IconButton(
                  onPressed: () {
                    addCollector();
                  },
                  icon: Icon(Icons.add))
            ],
          ),
          body: Center(child: CircularProgressIndicator()));
    }
    if (collectors == null) {
      return Scaffold(
          appBar: AppBar(
            title: Text('Список сборщиков'),
            actions: [
              IconButton(
                  onPressed: () {
                    addCollector();
                  },
                  icon: Icon(Icons.add))
            ],
          ),
          body: Center(child: Text('Список сборщиков пуст')));
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Список сборщиков'),
          actions: [
            IconButton(
                onPressed: () {
                  addCollector();
                },
                icon: Icon(Icons.add))
          ],
        ),
        body: ListView.builder(
          itemCount: collectors.length,
          itemBuilder: (context, index) {
            final collector = collectors[index];
            return Dismissible(
              key: Key(collector.id.toString()),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                // Действие при свайпе (например, удаление)
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    '${collector.first_name ?? ''} ${collector.name ?? ''} ${collector.last_name ?? ''}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text(
                        collector.phone != null
                            ? 'Телефон: ${collector.phone}'
                            : 'Без телефона',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Собирает в ${collector.drop_point == null ? 'нет точек сбора' : collector.drop_point!.settlement!.name ?? ''}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  trailing: collector.phone != null
                      ? IconButton(
                          icon: Icon(Icons.phone, color: Colors.green),
                          onPressed: () {
                            launchUrl(Uri.parse('tel:${collector.phone}'));
                          },
                        )
                      : null,
                  onTap: () {
                    editCollector(collector, index);
                  },
                ),
              ),
            );
          },
        ));
  }
}
