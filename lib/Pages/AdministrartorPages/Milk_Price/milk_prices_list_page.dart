import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:molokosbor/DataBase/models/milk_prices.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



enum GroupBy { allTime, year, month, week }

class MilkPriceHistoryPage extends StatefulWidget {
  const MilkPriceHistoryPage({Key? key}) : super(key: key);

  @override
  _MilkPriceHistoryPageState createState() => _MilkPriceHistoryPageState();
}

class _MilkPriceHistoryPageState extends State<MilkPriceHistoryPage> {
  final _supabase = Supabase.instance.client;
  late Future<List<MilkPrice>> _pricesFuture;
  GroupBy _groupBy = GroupBy.allTime;

  @override
  void initState() {
    super.initState();
    _pricesFuture = _fetchPrices();
  }

  Future<List<MilkPrice>> _fetchPrices() async {
    final res = await _supabase
        .from('milk_prices')
        .select()
        .order('start_date', ascending: true)
        ;
 
    return res.map((e) => MilkPrice.fromJson(e)).toList();
  }

  Map<String, num> _aggregate(List<MilkPrice> prices) {
    final map = <String, List<num>>{};
    for (var p in prices) {
      String key;
      switch (_groupBy) {
        case GroupBy.year:
          key = p.startDate.year.toString();
          break;
        case GroupBy.month:
          key = '${p.startDate.year}-${p.startDate.month.toString().padLeft(2, '0')}';
          break;
        case GroupBy.week:
          final weekOfYear = ((p.startDate.difference(DateTime(p.startDate.year)).inDays) / 7).floor() + 1;
          key = '${p.startDate.year}-W$weekOfYear';
          break;
        case GroupBy.allTime:
        default:
          key = p.startDate.year.toString();
      }
      map.putIfAbsent(key, () => []).add(p.price);
    }
    final result = <String, num>{};
    map.forEach((k, list) {
      result[k] = list.last; // take last price in period
    });
    return result;
  }

  void _onAddPrice() async {
    final _formKey = GlobalKey<FormState>();
    num? _enteredPrice;
    DateTime _selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить цену'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Цена'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  final v = num.tryParse(val ?? '');
                  if (v == null || v <= 0) return 'Введите положительное число';
                  return null;
                },
                onSaved: (val) => _enteredPrice = num.parse(val!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Дата: '),
                  TextButton(
                    child: Text('${_selectedDate.toLocal()}'.split(' ')[0]),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _selectedDate = date);
                      }
                    },
                  )
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                await _supabase.from('milk_prices').insert({
                  'price': _enteredPrice,
                  'start_date': _selectedDate.toIso8601String(),
                });
                setState(() {
                  _pricesFuture = _fetchPrices();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История цен на молоко'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _onAddPrice,
            tooltip: 'Добавить цену',
          )
        ],
      ),
      body: FutureBuilder<List<MilkPrice>>(
        future: _pricesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: \${snapshot.error}'));
          }
          final prices = snapshot.data!;
          final dataMap = _aggregate(prices);
          final spots = dataMap.entries.mapIndexed((i, e) => FlSpot(i.toDouble(), e.value.toDouble())).toList();
          final labels = dataMap.keys.toList();

          return Column(
            children: [
              // График
              SizedBox(
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LineChart(
                    LineChartData(
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (val, meta) {
                              final idx = val.toInt();
                              if (idx < 0 || idx >= labels.length) return const SizedBox();
                              return Text(labels[idx], style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(spots: spots, isCurved: true),
                      ],
                    ),
                  ),
                ),
              ),
              // Период группировки
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButton<GroupBy>(
                  value: _groupBy,
                  isExpanded: true,
                  items: GroupBy.values.map((g) {
                    return DropdownMenuItem(
                      value: g,
                      child: Text(g.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (g) {
                    setState(() => _groupBy = g!);
                  },
                ),
              ),
              const Divider(),
              // Список изменений
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(8),
                  children: prices.reversed.map((p) {
                    return ListTile(
                      title: Text('\${p.price}'),
                      subtitle: Text(DateFormat('dd.MM.yyyy').format(p.startDate)),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}