import 'dart:io';
import 'package:chat/components/conversation_tile.dart';
import 'package:chat/screens/search_private_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat/helper/helper_functions.dart';
import 'package:chat/services/auth_services.dart';
import 'package:chat/services/db_service.dart';

class ConversationHomeScreen extends StatefulWidget {
  @override
  _ConversationHomeScreenState createState() => _ConversationHomeScreenState();
}

class _ConversationHomeScreenState extends State<ConversationHomeScreen> {
  // data
  final AuthService _auth = AuthService();
  User _user;
  String _groupName;
  String _groupKey;
  String _userName = '';
  String _email = '';
  Stream _conversations;
  static FirebaseAnalytics analytics = FirebaseAnalytics();

  // initState
  @override
  void initState() {
    super.initState();
    analytics.setCurrentScreen(screenName: "/conversationshome");

    _getUserAuthAndJoinedGroups();
    final fbm = FirebaseMessaging();
    fbm.requestNotificationPermissions();
  }

  // widgets
  Widget noGroupWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 20.0),
          Text(
              "You've not joined any group, go join a group, and then find someone you'd like to talk to!"),
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
            // print(snapshot.data['groups'].length);
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
                            snapshot.data['conversations'][reqIndex]),
                      ),
                    );
                  },
                )
              ]);
            } else {
              return noGroupWidget();
            }
          } else {
            return noGroupWidget();
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

  void _popupDialog(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;

    Widget cancelButton;
    Widget createButton;
    if (!Platform.isIOS) {
      cancelButton = FlatButton(
        child: Text("Cancel"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
      createButton = FlatButton(
        child: Text("Create"),
        onPressed: () async {
          if (_groupName != null) {
            await HelperFunctions.getUserNameSharedPreference().then((val) {
              DBService(uid: _user.uid).createGroup(val, _groupName);
            });
            Navigator.of(context).pop();
          }
        },
      );
    } else {
      cancelButton = CupertinoDialogAction(
        child: Text("Cancel"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
      createButton = CupertinoDialogAction(
        child: Text("Create"),
        isDefaultAction: true,
        onPressed: () async {
          await HelperFunctions.getUserNameSharedPreference().then((val) {
            DBService(uid: _user.uid).createGroup(val, _groupName);
          });
          Navigator.of(context).pop();
        },
      );
    }
    dynamic alert;
    if (!Platform.isIOS) {
      alert = AlertDialog(
        title: Text("Create a Conversation"),
        content: TextField(
            onChanged: (val) {
              _groupName = val.trimRight();
            },
            style: TextStyle(fontSize: 15.0, height: 2.0)),
        actions: [
          cancelButton,
          createButton,
        ],
      );
    } else {
      alert = CupertinoAlertDialog(
        title: Text("Create a group"),
        content: CupertinoTextField(
          onChanged: (val) {
            _groupName = val.trimRight();
          },
          style: TextStyle(
              fontSize: 15.0,
              height: 2.0,
              color: darkModeOn ? Colors.white : Colors.black),
        ),
        actions: [
          cancelButton,
          createButton,
        ],
      );
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // Building the HomePage widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversations',
            style: TextStyle(fontSize: 27.0, fontWeight: FontWeight.bold)),
        elevation: 0.0,
      ),
      body: groupsList(),
    );
  }
}
