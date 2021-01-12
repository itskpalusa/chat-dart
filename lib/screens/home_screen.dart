import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat/helper/helper_functions.dart';
import 'package:chat/services/auth_services.dart';
import 'package:chat/services/db_service.dart';
import 'package:chat/components/group_tile.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // data
  final AuthService _auth = AuthService();
  User _user;
  String _groupName;
  String _groupKey;
  String _userName = '';
  String _email = '';
  Stream _groups;

  // initState
  @override
  void initState() {
    super.initState();
    _getUserAuthAndJoinedGroups();
  }

  // widgets
  Widget noGroupWidget() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
                onTap: () {
                  _popupDialog(context);
                },
                child: Icon(Icons.add_circle,
                    color: Colors.grey[700], size: 75.0)),
            SizedBox(height: 20.0),
            Text(
                "You've not joined any group, tap on the 'add' icon to create a group or search for groups by tapping on the search button below."),
          ],
        ));
  }

  Widget groupsList() {
    return StreamBuilder(
      stream: _groups,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            // print(snapshot.data['groups'].length);
            if (snapshot.data['groups'].length != 0) {
              return ListView.builder(
                  itemCount: snapshot.data['groups'].length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    int reqIndex = snapshot.data['groups'].length - index - 1;
                    return GroupTile(
                        userName: snapshot.data['fullName'],
                        groupId:
                            _destructureId(snapshot.data['groups'][reqIndex]),
                        groupName: _destructureName(
                            snapshot.data['groups'][reqIndex]));
                  });
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
    await HelperFunctions.getUserNameSharedPreference().then((value) {
      setState(() {
        _userName = value;
      });
    });
    DBService(uid: _user.uid).getUserGroups().then((snapshots) {
      // print(snapshots);
      setState(() {
        _groups = snapshots;
      });
    });
    await HelperFunctions.getUserEmailSharedPreference().then((value) {
      setState(() {
        _email = value;
      });
    });
  }

  String _destructureId(String res) {
    // print(res.substring(0, res.indexOf('_')));
    return res.substring(0, res.indexOf('_'));
  }

  String _destructureName(String res) {
    // print(res.substring(res.indexOf('_') + 1));
    return res.substring(res.indexOf('_') + 1);
  }

  void _popupDialog(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget createButton = FlatButton(
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
    dynamic alert;
    if (!Platform.isIOS) {
      alert = AlertDialog(
        title: Text("Create a group"),
        content: TextField(
            onChanged: (val) {
              _groupName = val;
            },
            style: TextStyle(fontSize: 15.0, height: 2.0)),
        actions: [
          cancelButton,
          createButton,
        ],
      );
    }
    {
      alert = CupertinoAlertDialog(
        title: Text("Create a group"),
        content: CupertinoTextField(
            onChanged: (val) {
              _groupKey = val;
            },
            style: TextStyle(fontSize: 15.0, height: 2.0)),
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

  // Join Group Popup
  void _joinPopupDialog(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget joinButton = FlatButton(
      child: Text("Join"),
      onPressed: () async {
        if (_groupKey != null) {
          await HelperFunctions.getUserNameSharedPreference().then((val) {
            DBService(uid: _user.uid)
                .addToGroup(_groupKey, _userName, _user.uid);
          });
          Navigator.of(context).pop();
        }
      },
    );

    dynamic alert;
    if (!Platform.isIOS) {
      alert = AlertDialog(
        title: Text("Join a group"),
        content: TextField(
            onChanged: (val) {
              _groupKey = val;
            },
            style: TextStyle(
              fontSize: 15.0,
              height: 2.0,
            )),
        actions: [
          cancelButton,
          joinButton,
        ],
      );
    } else {
      alert = CupertinoAlertDialog(
        title: Text("Join a group"),
        content: CupertinoTextField(
            onChanged: (val) {
              _groupKey = val;
            },
            style: TextStyle(fontSize: 15.0, height: 2.0)),
        actions: [
          cancelButton,
          joinButton,
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
        title: Text('Groups',
            style: TextStyle(fontSize: 27.0, fontWeight: FontWeight.bold)),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            icon: Icon(Icons.create, size: 25.0),
            onPressed: () {
              _popupDialog(context);
            },
          ),
          IconButton(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            icon: Icon(Icons.add, size: 25.0),
            onPressed: () {
              _joinPopupDialog(context);
            },
          )
        ],
      ),
      body: groupsList(),
    );
  }
}
