import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

class ChatSettings extends StatefulWidget {
  final String groupId;
  final String groupName;

  ChatSettings({this.groupId, this.groupName});

  @override
  _ChatSettingsState createState() => _ChatSettingsState();
}

class _ChatSettingsState extends State<ChatSettings> {
  // initState
  @override
  void initState() {
    super.initState();
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
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
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
