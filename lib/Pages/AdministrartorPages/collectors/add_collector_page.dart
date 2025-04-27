import 'package:flutter/material.dart';
import 'package:molokosbor/DataBase/models/drop_point.dart';
import 'package:molokosbor/DataBase/models/profiles.dart';
import 'package:molokosbor/DataBase/models/settlements.dart';
import 'package:molokosbor/DataBase/services/client_service.dart';
import 'package:molokosbor/DataBase/services/collectors_service.dart';
import 'package:molokosbor/DataBase/services/settlement_service.dart';

class AddCollectorPage extends StatefulWidget {
  

  const AddCollectorPage({Key? key, }) : super(key: key);

  @override
  State<AddCollectorPage> createState() => _AddCollectorPageState();
}

class _AddCollectorPageState extends State<AddCollectorPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController = new TextEditingController();
  late TextEditingController _nameController= new TextEditingController();
  late TextEditingController _lastNameController= new TextEditingController();
  late TextEditingController _emailController= new TextEditingController();
  late TextEditingController _passwordController= new TextEditingController();
  late TextEditingController _phoneController= new TextEditingController();

  List<Settlement> _settlements = [];
  Settlement? selectedSettlement;
  DropPoint? selectedDropPoint;

  @override
  void initState() {
    super.initState();
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
      final newProfile = Profile(
        id: 'asd',
        first_name: _firstNameController.text.isEmpty ? null : _firstNameController.text,
        name: _nameController.text,
        last_name: _lastNameController.text.isEmpty ? null : _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        role: 'collector',
        createdAt: DateTime.now(),
        drop_point: selectedDropPoint,
      );

      await CollectorsService().signUpCollector(newProfile, _passwordController.text);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Сборщик добавлен")),
      );

      Navigator.of(context).pop(newProfile);
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
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Пароль"),
validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Поле не может быть пустым";
                  }
                  if (value.length < 6) {
                    return "Некорректный пароль, должно быть больше 6 символов ";
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