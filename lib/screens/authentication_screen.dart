import 'package:chat/screens/login_screen.dart';
import 'package:chat/screens/registration_screen.dart';
import 'package:flutter/material.dart';

class AuthenticatePage extends StatefulWidget {
  @override
  _AuthenticatePageState createState() => _AuthenticatePageState();
}

class _AuthenticatePageState extends State<AuthenticatePage> {

  bool _showSignIn = true;

  void _toggleView() {
    setState(() {
      _showSignIn = !_showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(_showSignIn) {
      return LoginScreen(toggleView: _toggleView);
    }
    else {
      return RegistrationScreen(toggleView: _toggleView);
    }
  }
}