import 'package:flutter/material.dart';
import 'package:molokosbor/DataBase/models/drop_point.dart';
import 'package:molokosbor/DataBase/models/settlements.dart';
import 'package:molokosbor/DataBase/models/profiles.dart';
import 'package:molokosbor/DataBase/services/collectors_service.dart';
import 'package:molokosbor/DataBase/services/settlement_service.dart';


class EditSettlementPage extends StatefulWidget {
  const EditSettlementPage({super.key, required this.settlement});
  final Settlement settlement;

  @override
  State<EditSettlementPage> createState() => _EditSettlementPageState();
}

class _EditSettlementPageState extends State<EditSettlementPage> {
  late TextEditingController _nameController;
  late List<DropPoint> dropPoints;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.settlement.name);
    dropPoints = List.from(widget.settlement.dropPoint ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveSettlement() async {
    final updatedSettlement = Settlement(id: widget.settlement.id, name:  _nameController.text, createdAt: widget.settlement.createdAt, dropPoint: dropPoints);
    // Обновляем название поселения
    await SettlementService().updateSettlement(updatedSettlement);
    Navigator.pop(context, updatedSettlement);
  }

  

  void _deletePoint(int index) async {
    final removed = dropPoints[index];
    setState(() => dropPoints.removeAt(index));
    // Удаляем из БД
    // await DropPointsService().deleteDropPoint(removed.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Точка "${removed.adress}" удалена'),
        action: SnackBarAction(
          label: 'Отмена',
          onPressed: () async {
            // Восстанавливаем локально и в БД
            setState(() => dropPoints.insert(index, removed));
            // await DropPointsService().createDropPoint(removed);
          },
        ),
      ),
    );
  }

  Future<void> _openEditPage(DropPoint point, int index) async {
  final updated = await Navigator.pushNamed(context, '/edit_drop_point', arguments: point);
    
    if (updated != null) {
       setState(() => dropPoints[index] = updated as DropPoint) ;
    }
  }

  Future<void> _AddEditPage() async {
  final updated = await Navigator.pushNamed(context, '/add_drop_point', arguments: widget.settlement);
    if (updated != null) {
       setState(() => dropPoints.add(updated as DropPoint) ) ;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать поселение'),
        actions: [
            IconButton(
            icon: const Icon(Icons.add),
            onPressed: (){_AddEditPage();},
            tooltip: 'Добавить точку сбора',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: (){_saveSettlement();},
            tooltip: 'Сохранить изменения',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название поселения',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Точки сбора:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: dropPoints.length,
                itemBuilder: (ctx, i) {
                  final dp = dropPoints[i];
                  return Dismissible(
                    key: ValueKey(dp.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => _deletePoint(i),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                            "Сборщик: ${dp.profile?.first_name ?? ''} ${dp.profile?.name ?? ''} ${dp.profile?.last_name ?? ''}"),
                        subtitle: Text('Адрес: ${dp.adress}'),
                        trailing: const Icon(Icons.edit),
                        onTap: () => _openEditPage(dp,i),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    
    );
  }
}
