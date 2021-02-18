import 'package:chat/helper/helper_functions.dart';
import 'package:chat/screens/conversations_home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat/services/db_service.dart';

import '../constants.dart';

class UserProfileScreen extends StatefulWidget {
  final String userName;
  final String userId;

  const UserProfileScreen({this.userName, this.userId});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String userProfilePicUrl;
  User _user;
  String _userName = '';

  // initState
  @override
  void initState() {
    super.initState();
    imageCache.clear();
    _getCurrentUserNameAndUid();
  }

  // functions
  _getCurrentUserNameAndUid() async {
    await HelperFunctions.getUserNameSharedPreference().then((value) {
      _userName = value;
    });
    // ignore: await_only_futures
    _user = await FirebaseAuth.instance.currentUser;
  }

  Future<String> getUserProfilePicUrl() async {
    imageCache.clear();

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userId)
        .get()
        .then((value) {
      userProfilePicUrl = value.data()['profilePic'];
    });

    return userProfilePicUrl;
  }

  @override
  Widget build(BuildContext context) {
    Widget profilePicture;
    profilePicture = new FutureBuilder<String>(
        future: getUserProfilePicUrl(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return new CircleAvatar(
              backgroundImage: NetworkImage(
                userProfilePicUrl,
              ),
              onBackgroundImageError: null,
              radius: 100,
            );
          } else if (snapshot.hasError) {
            return new Text("${snapshot.error}");
          }
          // By default, show a loading spinner
          return new CircularProgressIndicator();
        });

    return Scaffold(
      appBar:
          AppBar(title: Text('User Info'), centerTitle: true, elevation: 0.0),
      body: SafeArea(
        child: Container(
          child: Center(
            child: Column(
              children: [
                profilePicture,
                SizedBox(height: 30),
                Text(
                  widget.userName,
                  style: TextStyle(fontSize: 20),
                ),
                //Button to chat with this user
                //
                ElevatedButton(
                  onPressed: () async {
                    DBService().createConversation(
                        _userName, widget.userName, _user.uid, widget.userId);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        // ignore: await_only_futures
                        builder: await (context) => ConversationHomeScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: kSteelBlue, // background
                    onPrimary: Colors.white, // foreground
                  ),
                  child: Text(
                    'Start Conversation',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
