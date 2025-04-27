import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:molokosbor/DataBase/models/deliveries.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeAdministrtorPage extends StatefulWidget {
  const HomeAdministrtorPage({super.key});

  @override
  State<HomeAdministrtorPage> createState() => _HomeAdministrtorPageState();
}

class _HomeAdministrtorPageState extends State<HomeAdministrtorPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(children: [ Center(child: Text("Количество сдачь", style: TextStyle(fontSize: 25 ),)),
        MilkCollectionCards(),
        Center(child: Text("Работники", style: TextStyle(fontSize: 25 ),))
        ],) ,
        
    );
  }
}


/// Модель данных о сборе молока за неделю по поселению
class MilkCollectionData {
  final String settlementName;
  final double total_milk; // общий объём молока (л)
  final int countDelivered; // количество сдавших
  final List<double> dailyMilk; // данные за 7 дней (л/день)

  MilkCollectionData({
    required this.settlementName,
    required this.total_milk,
    required this.countDelivered,
    required this.dailyMilk,
  });

  factory MilkCollectionData.fromJson(Map<String, dynamic> json)  {
    return MilkCollectionData(
      settlementName: json['settlement_name'] as String,
      total_milk: (json['total_milk'] as num).toDouble(),
      countDelivered: json['count_delivered'] as int,
      dailyMilk: List<double>.from(
        (json['daily_milk'] as List).map((e) => (e as num).toDouble()),
      ),
    );
  }
}
  Future<List<Delivery>> getDeliveriesForLastWeek() async {
  final supabase = Supabase.instance.client;
  final now = DateTime.now();
  final oneWeekAgo = now.subtract(Duration(days: 7));

  // Используем новый синтаксис Supabase 2.8.4: select() возвращает данные напрямую.
  final data = await supabase
      .from('deliveries')
      .select()
      .gte('deliveryTime', oneWeekAgo.toIso8601String())
      .lte('deliveryTime', now.toIso8601String());

  if (data == null) {
    throw Exception("Нет данных");
  }
  final List list = data as List;
  return list.map((json) => Delivery.fromJson(json as Map<String, dynamic>)).toList();
}
/// Эмуляция получения данных через поток (в реальном проекте заменить на запрос к Supabase)
Future<List<MilkCollectionData>> aggregateWeeklyData() async {
  final deliveries = await getDeliveriesForLastWeek();
  final now = DateTime.now();
  final oneWeekAgo = now.subtract(Duration(days: 7));

  // Группируем по settlementName; здесь формируем название как "Поселение {clientId}"
  Map<String, List<Delivery>> grouped = {};
  for (var delivery in deliveries) {
    // Пример преобразования: меняем clientId в settlementName
    final settlementName = "Поселение ${delivery.clientId}";
    if (!grouped.containsKey(settlementName)) {
      grouped[settlementName] = [];
    }
    grouped[settlementName]!.add(delivery);
  }

  List<MilkCollectionData> result = [];
  grouped.forEach((settlementName, deliveryList) {
    double totalVolume = 0;
    int countDelivered = deliveryList.length;
    // Инициализируем массив для 7 дней
    List<double> dailyMilk = List.filled(7, 0);

    // Для каждой доставки
    for (var delivery in deliveryList) {
      totalVolume += delivery.volume;
      // Определяем индекс дня: разница между датой доставки и oneWeekAgo (в днях)
      int dayIndex = delivery.deliveryTime.difference(oneWeekAgo).inDays;
      if (dayIndex >= 0 && dayIndex < 7) {
        dailyMilk[dayIndex] += delivery.volume;
      }
    }
    result.add(MilkCollectionData(
      settlementName: settlementName,
      total_milk: totalVolume,
      countDelivered: countDelivered,
      dailyMilk: dailyMilk,
    ));
  });
  print(result);
  return result;
  
}

Stream<List<MilkCollectionData>> getWeeklyMilkDataStream() async* {
  while (true) {
    try {
      final data = await aggregateWeeklyData();
      yield data;
    } catch (error) {
      yield [];
    }
    await Future.delayed(Duration(seconds: 10));
  }
}


/// Функция построения столбчатой диаграммы (bar-chart) для данных за неделю
Widget buildBarChart(List<double> dailyMilk) {
  // Формируем группы столбцов для каждого дня недели (7 дней)
  final List<BarChartGroupData> barGroups = List.generate(7, (i) {
    return BarChartGroupData(
      x: i,
      barRods: [
        BarChartRodData(
          toY: dailyMilk[i],
          width: 16,
          borderRadius: BorderRadius.circular(4),
          color: Colors.lightBlue,
        ),
      ],
    );
  });

  // Определяем максимально возможное значение Y с небольшим запасом
  final double maxY = dailyMilk.reduce((a, b) => a > b ? a : b) + 20;

  return SizedBox(
    height: 150,
    child: BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
  bottomTitles: AxisTitles(
    sideTitles: SideTitles(
      showTitles: true,
      reservedSize: 32,
      getTitlesWidget: (double value, TitleMeta meta) {
        const days = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"];
        final text = (value.toInt() >= 0 && value.toInt() < days.length)
            ? days[value.toInt()]
            : "";
        return SideTitleWidget(
          meta: meta,
          space: 4,
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    ),
  ),
  leftTitles: AxisTitles(
    sideTitles: SideTitles(showTitles: false),
  ),
  topTitles: AxisTitles(
    sideTitles: SideTitles(showTitles: false),
  ),
  rightTitles: AxisTitles(
    sideTitles: SideTitles(showTitles: false),
  ),
),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    ),
  );
}

class MilkCollectionCards extends StatelessWidget {
  const MilkCollectionCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MilkCollectionData>>(
      stream: getWeeklyMilkDataStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text("Ошибка: ${snapshot.error}"));
        }
        final List<MilkCollectionData>? data = snapshot.data;
        if (data == null || data.isEmpty) {
          return Center(child: Text("Нет пока данных"));
        }
        // Оборачиваем ListView.builder в SizedBox с заданной высотой и шириной
        return SizedBox(
          height: 350,
          width: MediaQuery.of(context).size.width, // добавляем ограничение по ширине
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: data.length,
            itemBuilder: (context, index) {
              final MilkCollectionData item = data[index];
              return Container(
                width: 300,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.settlementName,
                      style: const TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    Text("Общий объём молока: ${item.total_milk.toStringAsFixed(0)} л"),
                    Text("Количество сдавших: ${item.countDelivered} чел."),
                    const SizedBox(height: 12),
                    buildBarChart(item.dailyMilk),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}