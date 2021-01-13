import 'dart:io';

import 'package:chat/helper/helper_functions.dart';
import 'package:chat/screens/search_screen.dart';
import 'package:chat/screens/settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:chat/services/auth_services.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  User _user;
  String _userName = '';
  String _email = '';

  // initState
  @override
  void initState() {
    super.initState();
    _getUserAuth();
  }

  // functions
  _getUserAuth() async {
    _user = await FirebaseAuth.instance.currentUser;
    await HelperFunctions.getUserNameSharedPreference().then((value) {
      setState(() {
        _userName = value;
      });
    });

    await HelperFunctions.getUserEmailSharedPreference().then((value) {
      setState(() {
        _email = value;
      });
    });
  }

  int _currentIndex = 0;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  var platform = Platform.isIOS ? CupertinoTabScaffold : Scaffold;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _children = [
      HomeScreen(),
      SearchScreen(),
      SettingsScreen(userName: _userName, email: _email),
    ];
    if (Platform.isIOS) {
      return CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: [
              new BottomNavigationBarItem(
                icon: Platform.isIOS
                    ? Icon(CupertinoIcons.home)
                    : Icon(Icons.home),
                label: 'Home',
              ),
              new BottomNavigationBarItem(
                icon: Platform.isIOS
                    ? Icon(CupertinoIcons.search)
                    : Icon(Icons.search),
                label: 'Search',
              ),
              new BottomNavigationBarItem(
                  icon: Platform.isIOS
                      ? Icon(CupertinoIcons.settings)
                      : Icon(Icons.app_settings_alt_sharp),
                  label: 'Settings')
            ],
          ),
          tabBuilder: (context, index) {
            switch (index) {
              case 0:
                return HomeScreen();
                break;
              case 1:
                return SearchScreen();
                break;
              case 2:
                return SettingsScreen(userName: _userName, email: _email);
                break;
              default:
                return HomeScreen();
                break;
            }
          });
    } else {
      return Scaffold(
        body: _children[_currentIndex], // new
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped, // new
          currentIndex: _currentIndex, // new
          items: [
            new BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.app_settings_alt_sharp),
              label: 'Settings',
            )
          ],
        ),
      );
    }
  }
}
