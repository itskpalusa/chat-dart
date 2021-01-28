import 'dart:io';
import 'package:chat/helper/helper_functions.dart';
import 'package:chat/screens/push_screen.dart';
import 'package:chat/screens/report_screen.dart';
import 'package:chat/services/db_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ChatSettings extends StatefulWidget {
  final String groupId;
  final String groupName;
  final bool private;
  final String admin;

  ChatSettings({this.groupId, this.groupName, this.private, this.admin});

  @override
  _ChatSettingsState createState() => _ChatSettingsState();
}

class _ChatSettingsState extends State<ChatSettings> {
  User _user;
  String _userName = '';
  bool _isJoined = true;
  bool _isPrivate = false;
  String groupPicUrl;
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  String imageUrl;

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

  uploadGroupIconImage() async {
    final _firebaseStorage = FirebaseStorage.instance;
    final _imagePicker = ImagePicker();
    PickedFile image;
    User firebaseUser = FirebaseAuth.instance.currentUser;
    String groupId = widget.groupId;
    //Select Image
    image = await _imagePicker.getImage(
        source: ImageSource.gallery, imageQuality: 75);

    var file = File(image.path);

    if (image != null) {
      //Upload to Firebase
      var snapshot = await _firebaseStorage
          .ref()
          .child('groupIcons/$groupId')
          .putFile(await file);
      var downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        imageUrl = downloadUrl;
      });
    } else {
      print('No Image Path Received');
    }
    firebaseUser = FirebaseAuth.instance.currentUser;

    FirebaseFirestore.instance
        .collection("groups")
        .doc(widget.groupId)
        .update(<String, dynamic>{'groupIcon': imageUrl});
  }

  Future<String> getGroupPicUrl() async {
    await FirebaseFirestore.instance
        .collection("groups")
        .doc(widget.groupId)
        .get()
        .then((value) {
      groupPicUrl = value.data()['groupIcon'];
    });
    return groupPicUrl;
  }

  showIfAdmin() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return new Text("Loading");
          }

          var userDocument = snapshot.data;
          if (_userName == userDocument['admin']) {
            return Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  SizedBox(height: 15.0),
                  InkWell(
                    onTap: () async {
                      await DBService(uid: _user.uid).toggleGroupPrivacy(
                          userDocument['groupId'], _isPrivate);
                      if (_isPrivate) {
                        setState(() {
                          _isPrivate = !_isPrivate;
                        });
                      } else {
                        setState(() {
                          _isPrivate = !_isPrivate;
                        });
                      }
                    },
                    child: _isPrivate
                        ? Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.black87,
                                border: Border.all(
                                    color: Colors.white, width: 1.0)),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10.0),
                            child: Text('Make Private',
                                style: TextStyle(color: Colors.white)),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.blueAccent,
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10.0),
                            child: Text('Make Public',
                                style: TextStyle(color: Colors.white)),
                          ),
                  ),
                  SizedBox(height: 25),
                ],
              ),
            );
          } else {
            return Container(
              child: Column(
                children: [
                  SizedBox(height: 25),
                  InkWell(
                    onTap: () async {
                      await DBService(uid: _user.uid).togglingGroupJoin(
                          widget.groupId, widget.groupName, _userName);
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
                                color: Colors.red,
                                border: Border.all(
                                    color: Colors.white, width: 1.0)),
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
            );
          }
        });
  }

  Widget group(BuildContext context) {
    Widget displayGroupIcon;
    displayGroupIcon = new FutureBuilder<String>(
        future: getGroupPicUrl(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return new CircleAvatar(
              backgroundImage: NetworkImage(groupPicUrl),
              onBackgroundImageError: null,
              radius: 100,
            );
          } else if (snapshot.hasError) {
            return new Text("${snapshot.error}");
          }
          // By default, show a loading spinner
          return new CircularProgressIndicator();
        });

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
          resizeToAvoidBottomPadding: false,
          body: SafeArea(
            child: ListView(
              children: <Widget>[
                displayGroupIcon,
                GestureDetector(
                  child: Container(
                    child: Text(
                      'Key: $groupId',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  onTap: () {
                    Clipboard.setData(new ClipboardData(text: "$groupId"));
                    print('$groupId');
                  },
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
                        'Admin: ${userDocument['admin']}',
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          uploadGroupIconImage();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.lightBlue,
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          child: Text(
                            'Change Group Icon',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Chat Privacy: ${_isPrivate ? "Public" : "Private"}',
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5.0),
                      GestureDetector(
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReportScreen(),
                            ),
                          )
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.red,
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          child: Text('Report a Message?',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
                showIfAdmin(),
                SizedBox(height: 15.0),
                Text(
                  'Members:',
                  textAlign: TextAlign.center,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          members[index]
                              .substring(members[index].indexOf("_") + 1),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                )
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
