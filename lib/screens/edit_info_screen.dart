import 'package:chat/helper/helper_functions.dart';
import 'package:chat/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';

class EditInformationScreen extends StatefulWidget {
  final String userName;
  final String userId;

  const EditInformationScreen({this.userName, this.userId});

  @override
  _EditInformationScreenState createState() => _EditInformationScreenState();
}

class _EditInformationScreenState extends State<EditInformationScreen> {
  String phone;
  User _user;

  // initState
  @override
  void initState() {
    super.initState();
    imageCache.clear();
    _getCurrentUserNameAndUid();
  }

  // functions
  _getCurrentUserNameAndUid() async {
    // ignore: await_only_futures
    _user = await FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Edit User Info'), centerTitle: true, elevation: 0.0),
      body: SafeArea(
        child: Container(
          child: Center(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 80.0),
              children: <Widget>[
                SizedBox(height: 20.0),
                TextFormField(
                  decoration:
                      ktextInputDecoration.copyWith(labelText: 'Phone Number'),
                  onChanged: (val) {
                    setState(() {
                      phone = val;
                    });
                  },
                ),
                SizedBox(height: 15.0),
                ElevatedButton(
                  onPressed: () async {
                    // Save to server
                    DBService(uid: _user.uid).setUserPhoneNumber(phone);
                    // Save locally
                    await HelperFunctions.saveUserPhoneSharePreference(phone);

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: kSteelBlue, // background
                    onPrimary: Colors.white, // foreground
                  ),
                  child: Text(
                    'Save Information',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
