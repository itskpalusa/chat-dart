import 'package:chat/services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wiredash/wiredash.dart';

import 'authentication_screen.dart';


class SettingsScreen extends StatefulWidget {
  final String userName;
  final String email;

  SettingsScreen({this.userName, this.email});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _auth = AuthService();
  String profilePicUrl = " ";

  // initState
  @override
  void initState() {
    super.initState();
    _getUserAuth();
  }

  // functions
  _getUserAuth() async {
    var firebaseUser = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection("users")
        .doc(firebaseUser.uid)
        .get()
        .then((value) {
      profilePicUrl = value.data()['profilePic'];
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget display;
    if (profilePicUrl == null) {
      display =
          Icon(Icons.account_circle, size: 200.0, color: Colors.grey[700]);
    } else {
      display = CircleAvatar(
        backgroundImage: NetworkImage(profilePicUrl),
        onBackgroundImageError: null,
        radius: 100,
      );
    }

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
          child: ListView(
            children: <Widget>[
              display,
              SizedBox(height: 15.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Full Name', style: TextStyle(fontSize: 17.0)),
                  Text(widget.userName, style: TextStyle(fontSize: 17.0)),
                ],
              ),
              Divider(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Email', style: TextStyle(fontSize: 17.0)),
                  Text(widget.email, style: TextStyle(fontSize: 17.0)),
                ],
              ),
              SizedBox(height: 15.0),
              ElevatedButton(
                onPressed: () => Wiredash.of(context).show(),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed))
                      return Colors.blue;
                    return null; // Use the component's default.
                  },
                )),
                child: Text(
                  'Give Feedback',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 15.0),
              ElevatedButton(
                onPressed: () async {
                  await _auth.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => AuthenticatePage()),
                      (Route<dynamic> route) => false);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // background
                  onPrimary: Colors.white, // foreground
                ),
                child: Text(
                  'Logout',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
