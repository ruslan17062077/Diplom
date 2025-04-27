import 'package:flutter/material.dart';
import 'package:molokosbor/DataBase/models/settlements.dart';
import 'package:molokosbor/DataBase/services/settlement_service.dart';

class SettlementsListPage extends StatefulWidget {
  const SettlementsListPage({super.key});

  @override
  State<SettlementsListPage> createState() => _SettlementsListPageState();
}

class _SettlementsListPageState extends State<SettlementsListPage> {

List<Settlement> settlements =[];
bool _isLoading = true;


 @override
  void initState() {
    super.initState();
    
    getAllSettlemens();
  }

    Future getAllSettlemens() async{
    settlements = await SettlementService().getSettlementsOnce();
    setState(() {
        _isLoading = false;
    });
   
  }
Future<void> editSettlemens(Settlement settlement, int index) async {
    final updated = await Navigator.pushNamed(
      context,
      '/edit_settlement',
      arguments: settlement,
    ) as Settlement?;
    if (updated != null) {
      setState(() {
       
        settlements[index] = updated;
        
      });
      
    }
  }

  Future<void> addSettlemens() async {
    final updated = await Navigator.pushNamed(
      context,
      '/add_collector') ;
    if (updated != null) {
      setState(() {
        // Обновляем в обоих списках
        settlements.add(updated as Settlement);
       
      });
   
    }
  }

Future<void> _showAddSettlementDialog() async {
  final TextEditingController _controller = TextEditingController();
  // showDialog возвращает то, что мы передали в Navigator.pop — здесь это новое Settlement
  final newSettlement = await showDialog<Settlement>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Добавить поселение'),
        content: TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Название поселения',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // просто закроем диалог
            child: Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = _controller.text.trim();
              if (name.isEmpty) return;
              // здесь вызываем ваш сервис для сохранения в БД
              // final settlement = await SettlementService().addSettlement(
              //   Settlement(name: name),
              // );
              // возвращаем созданный объект
              // Navigator.of(context).pop(settlement);
            },
            child: Text('Добавить'),
          ),
        ],
      );
    },
  );

  // если пользователь добавил новое — обновляем локальный список и перерисовываем
  if (newSettlement != null) {
    setState(() {
      settlements.add(newSettlement);
      // при необходимости сразу выберем его в дропдауне
      // _selectedSettlement = newSettlement;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    if (_isLoading ) {
            return Scaffold(
      appBar: AppBar(
        title: Text('Список поселений'),
          actions: [IconButton(onPressed: (){addSettlemens();}, icon: Icon(Icons.add))],
      ),
      body: 
            Center(child: CircularProgressIndicator()));
          }
          if (settlements == null) {
            return Scaffold(
      appBar: AppBar(
        title: Text('Список поселений'),
        actions: [IconButton(onPressed: (){addSettlemens();}, icon: Icon(Icons.add))],
      ),
      body: 
            Center(child: Text('Список поселений пуст')));
          }

          return Scaffold(
      appBar: AppBar(
        title: Text('Список поселений'),
          actions: [IconButton(onPressed: (){addSettlemens();}, icon: Icon(Icons.add))],
      ),
          body:  ListView.builder(
            itemCount: settlements.length,
            itemBuilder: (context, index) {
              final settlement = settlements[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  title: Text(
                    settlement.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Точки сбора: ${(settlement.dropPoint ?? []).map((e) => e.adress.toString()).join(', ')}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    
                     editSettlemens(settlement, index);
                  
                  },
                ),
              );
            },)
          );
        }
      
    
  }
