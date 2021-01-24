import 'package:chat/screens/user_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class MessageTile extends StatefulWidget {
  final String message;
  final String sender;
  final bool sentByMe;
  final String senderId;

  MessageTile({this.message, this.sender, this.sentByMe, this.senderId});

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  final key = new GlobalKey<ScaffoldState>();
  String userProfilePicUrl;

  // initState
  @override
  void initState() {
    super.initState();
  }

  // functions
  Future<String> getUserProfilePicUrl() async {
    imageCache.clear();

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.senderId)
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
              radius: 15,
            );
          } else if (snapshot.hasError) {
            return new Text("${snapshot.error}");
          }
          // By default, show a loading spinner
          return new CircularProgressIndicator();
        });

    return GestureDetector(
        onLongPress: () {
          Clipboard.setData(
            new ClipboardData(text: (widget.message)),
          );

          BuildContext con = context;
          final snackBar = SnackBar(content: new Text("Copied!"));
          Scaffold.of(con).showSnackBar(snackBar);
        },
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => UserProfileScreen(
                    userName: widget.sender,
                    userId: widget.senderId,
                  )));
        },
        child: SafeArea(
            child: Container(
          padding: EdgeInsets.only(
              top: 4,
              bottom: 4,
              left: widget.sentByMe ? 0 : 24,
              right: widget.sentByMe ? 24 : 0),
          alignment:
              widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: widget.sentByMe
                ? EdgeInsets.only(left: 50)
                : EdgeInsets.only(right: 50),
            padding: EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
            decoration: BoxDecoration(
              borderRadius: widget.sentByMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(23),
                      topRight: Radius.circular(23),
                      bottomLeft: Radius.circular(23))
                  : BorderRadius.only(
                      topLeft: Radius.circular(23),
                      topRight: Radius.circular(23),
                      bottomRight: Radius.circular(23)),
              color: widget.sentByMe ? Colors.blueAccent : Colors.grey,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(children: [
                  widget.sentByMe ? SizedBox(height: 0) : profilePicture,
                  SizedBox(
                    width: 8,
                  ),
                  Text(widget.sender,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5)),
                ]),
                SizedBox(height: 7.0),
                Text(
                  widget.message,
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 15.0, color: Colors.white),
                ),
              ],
            ),
          ),
        )));
  }
}
