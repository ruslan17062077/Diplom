import 'package:flutter/material.dart';
import 'package:molokosbor/DataBase/models/profiles.dart';
import 'package:molokosbor/DataBase/services/client_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Экран списка клиентов с возможностью поиска и сортировки
class ClientListPage extends StatefulWidget {
  const ClientListPage({super.key});

  @override
  State<ClientListPage> createState() => _ClientListPageState();
}

class _ClientListPageState extends State<ClientListPage> {
  /// Полный список клиентов
  late List<Profile> _allClients;

  late List<Profile> _displayedClients;

  /// Контроллер для поля поиска
  final TextEditingController _searchController = TextEditingController();

  /// Флаг сортировки по поселению: true — по возрастанию, false — по убыванию
  bool _sortAscending = true;

  /// Флаги состояния загрузки и ошибки
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Подписываемся на изменения текста в поле поиска
    _searchController.addListener(_applyFilter);
    // Загружаем клиентов
    _loadClients();
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilter);
    _searchController.dispose();
    super.dispose();
  }

  /// Загрузка всех клиентов из сервиса
  Future<void> _loadClients() async {
    try {
      final clients = await ClientService().getAllClients();
      setState(() {
        _allClients = clients;
        _displayedClients = List.from(_allClients);
        _isLoading = false;
      });
      // Применяем сразу сортировку и фильтр по умолчанию
      _sortClients();
      _applyFilter();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Применить фильтрацию по полям first_name, name, last_name и phone
  void _applyFilter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _displayedClients = _allClients.where((client) {
        return (client.first_name ?? '').toLowerCase().contains(query) ||
            (client.name ?? '').toLowerCase().contains(query) ||
            (client.last_name ?? '').toLowerCase().contains(query) ||
            (client.phone ?? '').toLowerCase().contains(query);
      }).toList();
      // После фильтрации применяем текущую сортировку
      _sortClients();
    });
  }

  /// Сортировка списка по имени поселения
  void _sortClients() {
    _displayedClients.sort((a, b) {
      final nameA = a.drop_point?.settlement?.name ?? '';
      final nameB = b.drop_point?.settlement?.name ?? '';
      // Сравниваем строки по алфавиту
      final cmp = nameA.compareTo(nameB);
      return _sortAscending ? cmp : -cmp;
    });
  }

  /// Обработка нажатия на кнопку сортировки: меняем направление и перезапускаем сортировку
  void _toggleSortOrder() {
    setState(() {
      _sortAscending = !_sortAscending;
      _sortClients();
    });
  }

  /// Навигация на страницу редактирования и обновление данных при возврате
  Future<void> _editClient(Profile client, int index) async {
    final updated = await Navigator.pushNamed(
      context,
      '/edit_client',
      arguments: client,
    ) as Profile?;
    if (updated != null) {
      setState(() {
        // Обновляем в обоих списках
        _allClients[index] = updated;
        _applyFilter();
      });
    }
  }
   Future<void> _addClient() async {
    final updated = await Navigator.pushNamed(
      context,
      '/add_client',
    ) as Profile?;
    if (updated != null) {
      setState(() {
        // Обновляем в обоих списках
        _allClients.add(updated);
        _applyFilter();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Показ прогресс-индикатора при загрузке
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Список клиентов'), actions: [IconButton(onPressed: (){_addClient();}, icon: Icon(Icons.add))],),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    // Показ ошибки, если она есть
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Список клиентов'),actions: [IconButton(onPressed: (){_addClient();}, icon: Icon(Icons.add))]),
        body: Center(child: Text('Ошибка: $_error')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Список клиентов'),
        actions: [
          // Кнопка сортировки
          IconButton(
            icon: Icon(
              _sortAscending
                  ? Icons.sort_by_alpha
                  : Icons.sort_by_alpha_outlined,
            ),
            tooltip: 'Сортировать по поселению',
            onPressed: _toggleSortOrder,
          ),
        IconButton(onPressed: (){_addClient();}, icon: Icon(Icons.add))
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск по имени или телефону...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _displayedClients.length,
        itemBuilder: (context, index) {
          final client = _displayedClients[index];
          return Dismissible(
            key: Key(client.id.toString()),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) async {
              // await ClientService().deleteClient(client.id);
              setState(() {
                _allClients.removeWhere((c) => c.id == client.id);
                _applyFilter();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${client.name} удалён')),
              );
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              elevation: 3,
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(
                  '${client.first_name ?? ''} '
                  '${client.name ?? ''} '
                  '${client.last_name ?? ''}',
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Сдает ${client.drop_point?.settlement?.name ?? ''} '
                      '${client.drop_point?.adress ?? ''}',
                    ),
                    Text('Телефон: ${client.phone ?? 'Не указан'}'),
                  ],
                ),
                trailing: client.phone != null
                    ? IconButton(
                        icon: const Icon(Icons.phone, color: Colors.green),
                        onPressed: () => launchUrl(
                          Uri.parse('tel:${client.phone}'),
                        ),
                      )
                    : null,
                onTap: () => _editClient(client, index),
              ),
            ),
          );
        },
      ),
      
    );
  }
}
