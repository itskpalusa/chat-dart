import 'package:chat/helper/helper_functions.dart';
import 'package:chat/screens/push_screen.dart';
import 'package:chat/services/db_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class ChatSettings extends StatefulWidget {
  final String groupId;
  final String groupName;

  ChatSettings({this.groupId, this.groupName});

  @override
  _ChatSettingsState createState() => _ChatSettingsState();
}

class _ChatSettingsState extends State<ChatSettings> {
  User _user;
  String _userName = '';
  bool _isJoined = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // initState
  @override
  void initState() {
    super.initState();
    _getUserAuth();
    PushScreen(groupId: widget.groupId, groupName: widget.groupName);
  }

  _getUserAuth() async {
    _user = await FirebaseAuth.instance.currentUser;
    await HelperFunctions.getUserNameSharedPreference().then((value) {
      setState(() {
        _userName = value;
      });
    });
  }

  Widget group(BuildContext context) {
    return new StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return new Text("Loading");
        }
        var userDocument = snapshot.data;
        List<String> members = List.from(userDocument['members']);

        final groupId = userDocument["groupId"];
        return Scaffold(
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Text(
                    'Key: $groupId',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 20,
                  width: 150,
                  child: Divider(
                    color: Colors.teal.shade100,
                  ),
                ),
                Container(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Members:',
                      textAlign: TextAlign.center,
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        return Text(
                          members[index]
                              .substring(members[index].indexOf("_") + 1),
                          textAlign: TextAlign.center,
                        );
                      },
                    )
                  ],
                )),
                SizedBox(height: 15.0),
                InkWell(
                  onTap: () async {
                    await DBService(uid: _user.uid).togglingGroupJoin(
                        groupId, widget.groupName, _userName);
                    if (_isJoined) {
                      setState(() {
                        _isJoined = !_isJoined;
                      });
                    } else {
                      setState(() {
                        _isJoined = !_isJoined;
                      });
                    }
                  },
                  child: _isJoined
                      ? Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.black87,
                              border:
                                  Border.all(color: Colors.white, width: 1.0)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          child: Text('Leave',
                              style: TextStyle(color: Colors.white)),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.blueAccent,
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          child: Text('Join',
                              style: TextStyle(color: Colors.white)),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    PushScreen(groupId: widget.groupId, groupName: widget.groupName);
    final groupNameFromWidget = widget.groupName;
    return Scaffold(
      appBar: AppBar(
        title: Text("$groupNameFromWidget Settings"),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: group(context),
    );
  }
}
