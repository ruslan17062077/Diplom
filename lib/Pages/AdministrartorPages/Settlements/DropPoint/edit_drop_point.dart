import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:molokosbor/DataBase/models/drop_point.dart';
import 'package:molokosbor/DataBase/models/profiles.dart';
import 'package:molokosbor/DataBase/services/collectors_service.dart';
import 'package:molokosbor/DataBase/services/drop_point_service.dart';

class EditDropPointPage extends StatefulWidget {
  const EditDropPointPage({super.key, required this.point});
  final DropPoint point;

  @override
  State<EditDropPointPage> createState() => _EditDropPointPageState();
}

class _EditDropPointPageState extends State<EditDropPointPage> {
  late TextEditingController _addressCtrl;
  bool _isLoading = true;
  List<Profile> collectors = [];
  Profile? _selectedCollector;

  @override
  void initState() {
    super.initState();
    _addressCtrl = TextEditingController(text: widget.point.adress);
    _fetchCollectors();
  }

  Future<void> _fetchCollectors() async {
    try {
      final list = await CollectorsService().getAllCollectors();
      Profile? initial;
      if (widget.point.profile != null) {
        // Найти соответствующий объект из списка по id
        initial = list.firstWhere(
          (p) => p.id == widget.point.profile!.id,
          orElse: () => widget.point.profile!,
        );
      }
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
      id: widget.point.id,
      settlement: widget.point.settlement,
      profile: _selectedCollector,
      adress: _addressCtrl.text.trim(),
      createdAt: widget.point.createdAt,
    );
    try {
      print(updated.profile);
      print(updated.settlement);
     await DropPointService().updateDropPoint(updated);

      Navigator.pop(context,updated );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при сохранении: ${e}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать точку сбора'),
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