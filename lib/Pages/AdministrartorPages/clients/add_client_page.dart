
import 'package:flutter/material.dart';
import 'package:molokosbor/DataBase/models/drop_point.dart';
import 'package:molokosbor/DataBase/models/profiles.dart';
import 'package:molokosbor/DataBase/models/settlements.dart';
import 'package:molokosbor/DataBase/services/client_service.dart';
import 'package:molokosbor/DataBase/services/settlement_service.dart';

class AddClientPage extends StatefulWidget {


  const AddClientPage({Key? key,}) : super(key: key);

  @override
  State<AddClientPage> createState() => _AddClientPageState();
}

class _AddClientPageState extends State<AddClientPage> {
  final _formKey = GlobalKey<FormState>();

   TextEditingController _firstNameController = new TextEditingController();
   TextEditingController _nameController = new TextEditingController();
   TextEditingController _lastNameController = new TextEditingController();
   TextEditingController _emailController = new TextEditingController();
    TextEditingController _passwordController = new TextEditingController();
   TextEditingController _phoneController = new TextEditingController();

  List<Settlement> _settlements = [];
  Settlement? selectedSettlement;
  DropPoint? selectedDropPoint;

  @override
  void initState() {
    super.initState();
    // Load all settlements
    _loadSettlements();
  }

  Future<void> _loadSettlements() async {
    final allSettlements = await SettlementService().getSettlementsOnce();
    setState(() {
      _settlements = allSettlements;
      // Ensure dropdown reflects existing profile values
      if (selectedSettlement != null) {
        selectedSettlement = _settlements.firstWhere(
          (s) => s.id == selectedSettlement!.id,
          orElse: () => _settlements.first,
        );
        selectedDropPoint = selectedSettlement!.dropPoint!.firstWhere(
          (dp) => dp.id == selectedDropPoint?.id,
          orElse: () => selectedSettlement!.dropPoint!.first,
        );
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = Profile(
        first_name: _firstNameController.text.isEmpty ? null : _firstNameController.text,
        name: _nameController.text,
        last_name: _lastNameController.text.isEmpty ? null : _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        role: 'client',
        createdAt: DateTime.now(),
        drop_point: selectedDropPoint,
      );

      await ClientService().signUpClient(updatedProfile, _passwordController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Профиль создан")),
      );

      Navigator.of(context).pop(updatedProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Создание профиль")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: "Имя"),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Фамилия"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Поле не может быть пустым";
                  }
                  return null;
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: "Отчество"),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Поле не может быть пустым";
                  }
                  if (!value.contains('@')) {
                    return "Некорректный email";
                  }
                  return null;
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Пароль"),
              
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Телефон"),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              DropdownButtonFormField<Settlement>(
                decoration: InputDecoration(
                  labelText: "Выберите поселение",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: _settlements.map((settlement) {
                  return DropdownMenuItem<Settlement>(
                    value: settlement,
                    child: Text(settlement.name),
                  );
                }).toList(),
                value: selectedSettlement,
                onChanged: (value) {
                  setState(() {
                    selectedSettlement = value;
                    selectedDropPoint = null;
                  });
                },
                validator: (value) => value == null ? 'Выберите поселение' : null,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              DropdownButtonFormField<DropPoint>(
                decoration: InputDecoration(
                  labelText: "Выберите место сдачи",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: (selectedSettlement?.dropPoint ?? []).map((dp) {
                  return DropdownMenuItem<DropPoint>(
                    value: dp,
                    child: Text(dp.adress),
                  );
                }).toList(),
                value: selectedDropPoint,
                onChanged: (value) {
                  setState(() {
                    selectedDropPoint = value;
                  });
                },
                validator: (value) => value == null ? 'Выберите место сдачи' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text("Сохранить"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}