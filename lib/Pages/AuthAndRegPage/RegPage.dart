// ignore_for_file: prefer_const_constructors, file_names

import 'package:flutter/material.dart';
import 'package:molokosbor/DataBase/models/drop_point.dart';
import 'package:molokosbor/DataBase/models/profiles.dart';
import 'package:molokosbor/DataBase/models/settlements.dart';
import 'package:molokosbor/DataBase/services/auth_service.dart';
import 'package:molokosbor/DataBase/services/settlement_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toast/toast.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController email = TextEditingController();
  final TextEditingController passwordOne = TextEditingController();
  final TextEditingController passwordTwo = TextEditingController();
  final TextEditingController firstName = TextEditingController();
  final TextEditingController middleName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController phone = TextEditingController();

  Settlement? selectedSettlement;
  DropPoint? selectedDropPoint;
  bool visable1 = true;
  bool visable2 = true;

  
  late Future<List<Settlement>> futureSettlements;

  @override
  void initState() {
    super.initState();
    futureSettlements = SettlementService().getSettlementsOnce();

  }



  Future<void> signUp() async {
    if (firstName.text.isEmpty ||
        lastName.text.isEmpty ||
        email.text.isEmpty ||
        phone.text.isEmpty ||
        passwordOne.text.isEmpty ||
        passwordTwo.text.isEmpty ||
        selectedSettlement == null) {
      Toast.show("Заполните все поля, включая выбор поселения");
      return;
    }

    if (passwordOne.text.length < 6) {
      Toast.show("Пароль должен быть не менее 6 символов");
      return;
    }

    if (passwordOne.text != passwordTwo.text) {
      Toast.show("Пароли не совпадают");
      return;
    }

    final profile = Profile(
      id: 'null',
      first_name: lastName.text,
      name: firstName.text,
      last_name: middleName.text,
      email: email.text,
      role: 'client',
      phone: phone.text,
      createdAt: DateTime.now(),
      drop_point: selectedDropPoint!,
    );

    final user =
        await AuthService().createAccountClient(profile, passwordOne.text);

    if (user == null) {
      Toast.show("Ошибка при регистрации");
    } else {
      Toast.show("Регистрация успешна!");
      Navigator.pushNamed(context, "/regSave");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ToastContext().init(context);
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text("Регистрация")),
      body: FutureBuilder<List<Settlement>>(
        future: futureSettlements,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text("Ошибка загрузки поселений"));
          }

          final settlements = snapshot.data!;
              print(settlements);
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Column(
              children: [
                SizedBox(height: height * 0.04),
                Text("Создать аккаунт",
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
                SizedBox(height: height * 0.04),
                DropdownButtonFormField<Settlement>(
                  decoration: InputDecoration(
                    labelText: "Выберите поселение",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  value: selectedSettlement,
                  items: settlements.map((settlement) {
                    return DropdownMenuItem<Settlement>(
                      value: settlement,
                      child: Text(settlement.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {

                      selectedSettlement = value;
                      selectedDropPoint = null ;
                    });
                  },
                ),
                SizedBox(height: height * 0.015),
                DropdownButtonFormField<DropPoint>(
  decoration: InputDecoration(
    labelText: "Выберите место сдачи",
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  ),
  value: selectedDropPoint,
  items: (selectedSettlement?.dropPoint ?? [])
    .map((dp) => DropdownMenuItem<DropPoint>(
          value: dp,
          child: Text(dp.adress),
        ))
    .toList(),

  onChanged: (value) {
    setState(() {
      selectedDropPoint = value;
    });
  },
),

                
                buildTextField(
                    controller: lastName, label: "Фамилия", icon: Icons.person),
                buildTextField(
                    controller: firstName, label: "Имя", icon: Icons.person),
                buildTextField(
                    controller: middleName,
                    label: "Отчество",
                    icon: Icons.person),
                buildTextField(
                    controller: phone, label: "Телефон", icon: Icons.person),
                buildTextField(
                    controller: email, label: "Email", icon: Icons.email),
                SizedBox(height: height * 0.02),
                buildPasswordField(
                  controller: passwordOne,
                  label: "Пароль",
                  visible: visable1,
                  onToggle: () => setState(() => visable1 = !visable1),
                ),
                SizedBox(height: height * 0.02),
                buildPasswordField(
                  controller: passwordTwo,
                  label: "Повторите пароль",
                  visible: visable2,
                  onToggle: () => setState(() => visable2 = !visable2),
                ),
                SizedBox(height: height * 0.04),
                SizedBox(
                  width: width * 0.55,
                  height: height * 0.06,
                  child: ElevatedButton(
                    onPressed: signUp,
                    child: Text("Зарегистрироваться"),
                  ),
                ),
                SizedBox(height: height * 0.02),
                InkWell(
                  child: Text("Уже есть аккаунт? Войти"),
                  onTap: () => Navigator.popAndPushNamed(context, "/"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildTextField(
      {required TextEditingController controller,
      required String label,
      required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }

  Widget buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool visible,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: visible,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
