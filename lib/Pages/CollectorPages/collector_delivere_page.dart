import 'package:flutter/material.dart';
import 'package:molokosbor/DataBase/models/deliveries.dart';
import 'package:molokosbor/DataBase/models/profiles.dart';
import 'package:molokosbor/DataBase/services/deliveries_service.dart';

class CollectorDeliveryPage extends StatefulWidget {
  final Profile client;

  const CollectorDeliveryPage({Key? key, required this.client}) : super(key: key);

  @override
  _CollectorDeliveryPageState createState() => _CollectorDeliveryPageState();
}

class _CollectorDeliveryPageState extends State<CollectorDeliveryPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final delivery = Delivery( clientId: widget.client.id, deliveryTime: DateTime.now(), volume: int.parse(_amountController.text), status: 'сдано', createdAt: DateTime.now());
      DeliveryService().addDelivery(delivery);
      widget.client!.delivery!.add(delivery);
      Navigator.pop(context, widget.client);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сдача молока'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Информация о клиенте
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(widget.client.name ?? 'Без имени'),
                  subtitle: widget.client.phone != null
                      ? Text('Телефон: ${widget.client.phone}')
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              // Поле ввода объёма
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Объём молока (литры)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите объём';
                  }
                  final v = double.tryParse(value.replaceAll(',', '.'));
                  if (v == null || v <= 0) {
                    return 'Неверный объём';
                  }
                  return null;
                },
              ),
              const Spacer(),
              // Кнопка сохранить
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Сохранить'),
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
