import 'package:chat/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:wiredash/wiredash.dart';

import 'authentication_screen.dart';

class SettingsScreen extends StatelessWidget {
  final String userName;
  final String email;
  final AuthService _auth = AuthService();

  SettingsScreen({this.userName, this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings',
            style: TextStyle(
                color: Colors.white,
                fontSize: 27.0,
                fontWeight: FontWeight.bold)),
        elevation: 0.0,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 100.0),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.account_circle, size: 200.0, color: Colors.grey[700]),
              SizedBox(height: 15.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Full Name', style: TextStyle(fontSize: 17.0)),
                  Text(userName, style: TextStyle(fontSize: 17.0)),
                ],
              ),
              Divider(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Email', style: TextStyle(fontSize: 17.0)),
                  Text(email, style: TextStyle(fontSize: 17.0)),
                ],
              ),
              SizedBox(height: 15.0),
              ElevatedButton(
                // launch wiredash where appropriate in your App
                onPressed: () => Wiredash.of(context).show(),
                child: Text('Give Feedback'),
              ),
              SizedBox(height: 15.0),
              GestureDetector(
                onTap: () async {
                  await _auth.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => AuthenticatePage()),
                      (Route<dynamic> route) => false);
                },
                // The custom button
                child: Container(
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
