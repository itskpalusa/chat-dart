import 'package:chat/screens/apple_sign_in.dart';
import 'package:chat/screens/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chat/helper/helper_functions.dart';
import 'package:chat/screens/authentication_screen.dart';
import 'package:provider/provider.dart';
import 'package:wiredash/wiredash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final appleSignInAvailable = await AppleSignInAvailable.check();
  runApp(Provider<AppleSignInAvailable>.value(
    value: appleSignInAvailable,
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _getUserLoggedInStatus();
  }

  _getUserLoggedInStatus() async {
    await HelperFunctions.getUserLoggedInSharedPreference().then(
      (value) {
        if (value != null) {
          setState(() {
            _isLoggedIn = value;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wiredash(
      navigatorKey: _navigatorKey,
      projectId: 'dashchat-etg4vit',
      secret: 'eh2d6oo7ovmpnlijd7rzaxr1fvi4lkj2unh8k0d2coc2uwmg',
      child: MaterialApp(
          navigatorKey: _navigatorKey,
          title: 'Chats',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: _isLoggedIn != null
              ? _isLoggedIn
                  ? Home()
                  : AuthenticatePage()
              : Center(child: CircularProgressIndicator())),
    );
  }
}
