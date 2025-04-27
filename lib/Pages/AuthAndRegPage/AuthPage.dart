import 'package:flutter/material.dart';
import 'package:molokosbor/Pages/AuthAndRegPage/RegPage.dart';
import 'package:molokosbor/Themes/ThemeProvider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toast/toast.dart'; // Если используете этот пакет для уведомлений

class AutorizationPage extends StatefulWidget {
  const AutorizationPage({Key? key}) : super(key: key);

  @override
  State<AutorizationPage> createState() => _AutorizationPageState();
}

class _AutorizationPageState extends State<AutorizationPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool visable = true;
  final supabase = Supabase.instance.client;

  Future<void> signIn() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Toast.show("Введите корректные данные");
      return;
    }
    final response = await supabase.auth.signInWithPassword(
      email: emailController.text,
      password: passwordController.text,
    );

    if (response != null) {
      Toast.show("Ошибка: ${response!}");
    } else if (response.user != null) {
      Toast.show("Успешно");
      // Например, получение профиля пользователя можно реализовать здесь, если нужно:
      // final profileResponse = await supabase
      //     .from('profiles')
      //     .select()
      //     .eq('id', response.user!.id)
      //     .single()
      //     .execute();
      Navigator.pushReplacementNamed(context, "/ladingPage");
    }
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      appBar: AppBar(actions: [IconButton(onPressed: (){Provider.of<ThemeProvider>(context, listen: false).toggleTheme();}, icon: Icon(Icons.theater_comedy))],),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Добро пожаловать",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.15,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.95,
                child: TextField(
                  controller: emailController,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    hintText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.elliptical(10, 10)),
                    ),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.95,
                child: TextField(
                  controller: passwordController,
                  obscureText: visable,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Password",
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.elliptical(10, 10)),
                    ),
                    prefixIcon: const Icon(Icons.password),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          visable = !visable;
                        });
                      },
                      icon: Icon(
                        visable ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.55,
                height: MediaQuery.of(context).size.height * 0.06,
                child: ElevatedButton(
                  onPressed: () async {
                    await signIn();
                  },
                  child: const Text("Войти"),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              InkWell(
                child: const Text("Нет аккаунта? Регистрация"),
                onTap: () {
          Navigator.push(
  context, 
  MaterialPageRoute(builder: (_) => RegistrationPage())
);

                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
