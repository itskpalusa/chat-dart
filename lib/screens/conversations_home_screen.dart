import 'dart:io';
import 'package:chat/components/conversation_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat/helper/helper_functions.dart';
import 'package:chat/services/auth_services.dart';
import 'package:chat/services/db_service.dart';

import '../constants.dart';

class ConversationHomeScreen extends StatefulWidget {
  @override
  _ConversationHomeScreenState createState() => _ConversationHomeScreenState();
}

class _ConversationHomeScreenState extends State<ConversationHomeScreen> {
  // data
  final AuthService _auth = AuthService();
  User _user;
  String _groupName;
  String _userName = '';
  String _email = '';
  Stream _conversations;
  static FirebaseAnalytics analytics = FirebaseAnalytics();

  // initState
  @override
  void initState() {
    super.initState();
    analytics.setCurrentScreen(screenName: "/conversations");
    _getUserAuthAndJoinedGroups();
    final fbm = FirebaseMessaging();
    fbm.requestNotificationPermissions();
  }

  // widgets
  Widget noConversationsWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("¯\\_(ツ)_/¯", style: TextStyle(fontSize: 40)),
          SizedBox(height: 20),
          Text(
            "You don't have any active conversations! \n\nGo join a group, and then find someone you'd like to talk to by clicking on their name!",
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget groupsList() {
    return StreamBuilder(
      stream: _conversations,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['conversations'] != null) {
            if (snapshot.data['conversations'].length != 0) {
              return Column(children: [
                ListView.builder(
                    itemCount: snapshot.data['conversations'].length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      int reqIndex =
                          snapshot.data['conversations'].length - index - 1;
                      return Container(
                          child: ConversationTile(
                              userName: snapshot.data['fullName'],
                              conversationId: _destructureId(
                                  snapshot.data['conversations'][reqIndex]),
                              otherUser: _destructureName(
                                  snapshot.data['conversations'][reqIndex])));
                    })
              ]);
            } else {
              return noConversationsWidget();
            }
          } else {
            FirebaseFirestore.instance
                .collection("users")
                .doc(_user.uid)
                .update({"conversations": []});
            return noConversationsWidget();
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  // functions
  _getUserAuthAndJoinedGroups() async {
    _user = await FirebaseAuth.instance.currentUser;
    await HelperFunctions.getUserNameSharedPreference().then(
      (value) {
        setState(() {
          _userName = value;
        });
      },
    );
    DBService(uid: _user.uid).getUserGroups().then(
      (snapshots) {
        setState(() {
          _conversations = snapshots;
        });
      },
    );
    await HelperFunctions.getUserEmailSharedPreference().then(
      (value) {
        setState(() {
          _email = value;
        });
      },
    );
  }

  String _destructureId(String res) {
    return res.substring(0, res.indexOf('_'));
  }

  String _destructureName(String res) {
    return res.substring(res.indexOf('_') + 1);
  }

  // Building the HomePage widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Conversations',
          style: TextStyle(fontSize: 27.0, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kPortGoreBackground,
        elevation: 0.0,
      ),
      body: groupsList(),
    );
  }
}
