import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  final String userName;
  final String userId;

  const UserProfileScreen({this.userName, this.userId});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String userProfilePicUrl;

  // initState
  @override
  void initState() {
    super.initState();
    imageCache.clear();
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
