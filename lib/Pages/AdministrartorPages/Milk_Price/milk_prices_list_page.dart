import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:molokosbor/DataBase/models/milk_prices.dart';

enum GroupBy { allTime, year, month, week }

extension GroupByExtension on GroupBy {
  String get label {
    switch (this) {
      case GroupBy.allTime:
        return 'Всё время';
      case GroupBy.year:
        return 'Год';
      case GroupBy.month:
        return 'Месяц';
      case GroupBy.week:
        return 'Неделя';
    }
  }
}

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
    final data = await _supabase
        .from('milk_prices')
        .select()
        .order('start_date', ascending: true);
    return (data as List)
        .map((e) => MilkPrice.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, num> _aggregate(List<MilkPrice> prices) {
    final map = <String, List<MilkPrice>>{};
    for (var p in prices) {
      String key;
      switch (_groupBy) {
        case GroupBy.year:
          key = p.startDate.year.toString();
          break;
        case GroupBy.month:
          key = DateFormat('yyyy-MM').format(p.startDate);
          break;
        case GroupBy.week:
          final weekOfYear = ((p.startDate
                      .difference(DateTime(p.startDate.year))
                      .inDays) ~/
                  7) +
              1;
          key = '${p.startDate.year}-W$weekOfYear';
          break;
        case GroupBy.allTime:
        default:
          key = 'Все время';
      }
      map.putIfAbsent(key, () => []).add(p);
    }
    final result = <String, num>{};
    map.forEach((period, list) {
      // берем последнюю цену в период
      result[period] = list.last.price;
    });
    return result;
  }

  void _onAddPrice() async {
    final _formKey = GlobalKey<FormState>();
    num? _enteredPrice;
    DateTime _selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Добавить цену'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Цена, ₽'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  final v = num.tryParse(val ?? '');
                  if (v == null || v <= 0) {
                    return 'Введите положительное число';
                  }
                  return null;
                },
                onSaved: (val) => _enteredPrice = num.parse(val!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Дата: '),
                  TextButton(
                    child: Text(DateFormat('dd.MM.yyyy').format(_selectedDate)),
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
            tooltip: 'Добавить цену',
            onPressed: _onAddPrice,
          )
        ],
      ),
      body: FutureBuilder<List<MilkPrice>>(
        future: _pricesFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          final prices = snapshot.data!;
          final dataMap = _aggregate(prices);
          final labels = dataMap.keys.toList();
          final spots = dataMap.values
              .toList()
              .asMap()
              .entries
              .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
              .toList();

          return Column(
            children: [
              // Выбор периода
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButton<GroupBy>(
                  value: _groupBy,
                  isExpanded: true,
                  items: GroupBy.values.map((g) {
                    return DropdownMenuItem(
                      value: g,
                      child: Text(g.label),
                    );
                  }).toList(),
                  onChanged: (g) {
                    setState(() => _groupBy = g!);
                  },
                ),
              ),

              // График
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget: (val, meta) {
                              final idx = val.toInt();
                              if (idx < 0 || idx >= labels.length) {
                                return const SizedBox();
                              }
                              return Text(
                                labels[idx],
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          bottom: BorderSide(color: Theme.of(context).dividerColor),
                          left: BorderSide(color: Theme.of(context).dividerColor),
                          right: BorderSide(color: Colors.transparent),
                          top: BorderSide(color: Colors.transparent),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              const Divider(),

              // Список изменений
              Expanded(
                child: ListView.builder(
                  itemCount: prices.length,
                  itemBuilder: (ctx, i) {
                    final p = prices[prices.length - 1 - i];
                    return ListTile(
                      title: Text('${p.price} ₽/л'),
                      subtitle: Text(
                        DateFormat('dd.MM.yyyy').format(p.startDate),
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
