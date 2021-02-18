import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

Future<void> saveTokenToDatabase(String token) async {
  // Assume user is logged in for this example
  String userId = FirebaseAuth.instance.currentUser.uid;

  await FirebaseFirestore.instance.collection('users').doc(userId).update({
    'tokens': FieldValue.arrayUnion([token]),
  });
}

class PushScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  PushScreen({this.groupId, this.groupName});

  @override
  _PushScreenState createState() => _PushScreenState();
}

class _PushScreenState extends State<PushScreen> {
  String _homeScreenText = "Waiting for token...";
  // ignore: unused_field
  String _messageText = "Waiting for message...";
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  Future<void> getTokenAndSaveAsync() async {
    String token = await FirebaseMessaging().getToken();
    await saveTokenToDatabase(token);
    fcmSubscribe();
  }

  void fcmSubscribe() {
    _firebaseMessaging.subscribeToTopic('${widget.groupId}');

    print('subbed');
  }

  @override
  void initState() {
    super.initState();

    // Any time the token refreshes, store this in the database too.
    FirebaseMessaging().onTokenRefresh.listen(saveTokenToDatabase);
    getTokenAndSaveAsync();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        setState(() {
          _messageText = "Push Messaging message: $message";
        });
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        setState(() {
          _messageText = "Push Messaging message: $message";
        });
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        setState(() {
          _messageText = "Push Messaging message: $message";
        });
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      setState(() {
        _homeScreenText = "Push Messaging token: $token";
      });
      print(_homeScreenText);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
