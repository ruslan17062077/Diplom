import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:molokosbor/DataBase/models/drop_point.dart';
import 'package:molokosbor/DataBase/models/profiles.dart';
import 'package:molokosbor/DataBase/models/settlements.dart';
import 'package:molokosbor/DataBase/services/collectors_service.dart';
import 'package:molokosbor/DataBase/services/drop_point_service.dart';

class AddDropPointPage extends StatefulWidget {
  const AddDropPointPage({super.key, required this.settlement});
  final Settlement settlement;

  @override
  State<AddDropPointPage> createState() => _AddDropPointPageState();
}

class _AddDropPointPageState extends State<AddDropPointPage> {
  late TextEditingController _addressCtrl = new TextEditingController();
  bool _isLoading = true;
  List<Profile> collectors = [];
  Profile? _selectedCollector;

  @override
  void initState() {
    super.initState();
    _fetchCollectors();
  }

  Future<void> _fetchCollectors() async {
    try {
      final list = await CollectorsService().getAllCollectors();
      Profile? initial;
      setState(() {
        collectors = list;
        _selectedCollector = initial;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось загрузить сборщиков: \$e')),
      );
    }
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final updated = DropPoint(
      id: null,
      settlement: widget.settlement,
      profile: _selectedCollector,
      adress: _addressCtrl.text.trim(),
      createdAt: DateTime.now(),
    );
    
    final drop_point = await DropPointService().addDropPoint(updated);
      Navigator.pop(context, drop_point);
   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать точку сбора'),
        actions: [
          IconButton(onPressed: _save, icon: const Icon(Icons.save)),
        ],
      ),
      body: Builder(builder: (context) {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (collectors.isEmpty) {
          return const Center(child: Text('Список сборщиков пуст'));
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Адрес'),
              ),
              const SizedBox(height: 24),
              DropdownButton<Profile>(
                value: _selectedCollector,
                isExpanded: true,
                hint: const Text('Выберите сборщика'),
                items: collectors
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text('${p.first_name} ${p.last_name}'),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedCollector = value);
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}