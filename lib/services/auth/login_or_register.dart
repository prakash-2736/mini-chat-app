import 'package:flutter/material.dart';
import '../../pages/register_page.dart';
import '../../pages/login_page.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  //initiallu ,show login page
  bool showLoginPage = true;

  //toggel btwn login and register
  void toggelPages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        onTap: toggelPages,
      );
    } else {
      return RegisterPage(
        onTap: toggelPages,
      );
    }
  }
}
