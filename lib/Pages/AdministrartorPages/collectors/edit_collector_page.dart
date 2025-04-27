import 'package:flutter/material.dart';
import 'package:molokosbor/DataBase/models/drop_point.dart';
import 'package:molokosbor/DataBase/models/profiles.dart';
import 'package:molokosbor/DataBase/models/settlements.dart';
import 'package:molokosbor/DataBase/services/client_service.dart';
import 'package:molokosbor/DataBase/services/settlement_service.dart';

class EditCollectorPage extends StatefulWidget {
  final Profile profile;

  const EditCollectorPage({Key? key, required this.profile}) : super(key: key);

  @override
  State<EditCollectorPage> createState() => _EditCollectorPageState();
}

class _EditCollectorPageState extends State<EditCollectorPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _nameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  List<Settlement> _settlements = [];
  Settlement? selectedSettlement;
  DropPoint? selectedDropPoint;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.profile.first_name);
    _nameController = TextEditingController(text: widget.profile.name);
    _lastNameController = TextEditingController(text: widget.profile.last_name);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phone);

    // Initialize selected values
    selectedSettlement = widget.profile.drop_point?.settlement;
    selectedDropPoint = widget.profile.drop_point;

    // Load all settlements
  
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
        id: widget.profile.id,
        first_name: _firstNameController.text.isEmpty ? null : _firstNameController.text,
        name: _nameController.text,
        last_name: _lastNameController.text.isEmpty ? null : _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        role: widget.profile.role,
        createdAt: widget.profile.createdAt,
        drop_point: selectedDropPoint,
      );

      await ClientService().updateClient(updatedProfile);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Профиль обновлён")),
      );

      Navigator.of(context).pop(updatedProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Редактировать профиль")),
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
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Телефон"),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          SizedBox(height: 20),
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