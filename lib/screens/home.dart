import 'dart:io';
import 'package:chat/helper/helper_functions.dart';
import 'package:chat/screens/contacts_screen.dart';
import 'package:chat/screens/conversations_home_screen.dart';
import 'package:chat/screens/search_screen.dart';
import 'package:chat/screens/settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:chat/services/auth_services.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static FirebaseAnalytics analytics = FirebaseAnalytics();

  // ignore: unused_field
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  // ignore: unused_field
  final AuthService _auth = AuthService();

  // ignore: unused_field
  User _user;
  String _userName = '';
  String _email = '';
  String _phone = '';
String _uid = '';
  // initState
  @override
  void initState() {
    super.initState();
    _getUserAuth();
    analytics.setCurrentScreen(screenName: "/nav");
  }

  // functions
  _getUserAuth() async {
    // ignore: await_only_futures
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

    await HelperFunctions.getUserPhoneSharedPreference().then((value) {
      setState(() {
        if (value != null) {
          _phone = value;
        } else {
          _phone = "No Phone Number Given";
        }
      });
    });
    await HelperFunctions.getUIDSharedPreference().then((value) {
      setState(() {
        if (value != null) {
          _uid = value;
        } else {
          _uid = "UID #";
        }
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
      ConversationHomeScreen(),
      SearchScreen(),
      ContactsScreen(),
      SettingsScreen(userName: _userName, email: _email, phone: _phone),
    ];
    if (Platform.isIOS) {
      return CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: [
              new BottomNavigationBarItem(
                icon: Platform.isIOS
                    ? Icon(CupertinoIcons.group)
                    : Icon(Icons.group),
                label: 'Groups',
              ),
              new BottomNavigationBarItem(
                icon: Platform.isIOS
                    ? Icon(CupertinoIcons.person)
                    : Icon(Icons.person),
                label: 'Conversations',
              ),
              new BottomNavigationBarItem(
                icon: Platform.isIOS
                    ? Icon(CupertinoIcons.search)
                    : Icon(Icons.search),
                label: 'Search',
              ),
              new BottomNavigationBarItem(
                icon: Platform.isIOS
                    ? Icon(CupertinoIcons.book)
                    : Icon(Icons.contacts),
                label: 'Contact',
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
                return ConversationHomeScreen();
                break;
              case 2:
                return SearchScreen();
                break;
              case 3:
                return ContactsScreen();
                break;
              case 4:
                return SettingsScreen(
                  userName: _userName,
                  email: _email,
                  phone: _phone,
                );
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
          backgroundColor: Colors.white, onTap: onTabTapped, // new
          currentIndex: _currentIndex, // new
          items: [
            new BottomNavigationBarItem(
              icon: Icon(Icons.group),
              backgroundColor: Colors.black,
              label: 'Groups',
            ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.person),
              backgroundColor: Colors.black,
              label: 'Conversations',
            ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.contacts),
              label: 'Contacts',
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
