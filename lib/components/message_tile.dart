import 'package:chat/screens/image_detail_screen.dart';
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
  final String attachment;
  final String groupId;
  final String messageId;
  final List likes;

  MessageTile(
      {this.message,
      this.sender,
      this.sentByMe,
      this.senderId,
      this.attachment,
      this.groupId,
      this.messageId,
      this.likes});

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  final key = new GlobalKey<ScaffoldState>();
  String userProfilePicUrl;
  User _user = FirebaseAuth.instance.currentUser;

  // initState
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget liked;
    if (widget.likes == null) {
      liked = SizedBox(width: 0);
    } else {
      liked = Row(children: [
        Icon(Icons.favorite, color: Colors.pink),
        Text(widget.likes.length.toString())
      ]);
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

    String url = widget.attachment;
    Widget attachment;
    if (url != null)
      attachment = Image.network(
        url,
        scale: 10,
      );
    else
      attachment = SizedBox(height: 0);

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
      },
    );

    return GestureDetector(
        onTap: () {
          if (url != null) {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) {
                return ImageDetailScreen(
                  image: url,
                );
              },
            ));
          } else {
            BuildContext con = context;
            final snackBar = SnackBar(content: new Text("No image to expand"));
            Scaffold.of(con).showSnackBar(snackBar);
          }
        },
        onDoubleTap: () {
          FirebaseFirestore.instance
              .collection('groups')
              .doc(widget.groupId)
              .collection('messages')
              .doc(widget.messageId)
              .update({
            'liked': FieldValue.arrayUnion([_user.uid])
          });
          print("$_user  liked message");
        },
        onLongPress: () {
          Clipboard.setData(
            new ClipboardData(text: (widget.message)),
          );
          BuildContext con = context;
          final snackBar = SnackBar(content: new Text("Copied!"));
          Scaffold.of(con).showSnackBar(snackBar);
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
                Row(
                  children: [
                    widget.sentByMe ? SizedBox(height: 0) : profilePicture,
                    SizedBox(
                      width: 8,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => UserProfileScreen(
                              userName: widget.sender,
                              userId: widget.senderId,
                            ),
                          ),
                        );
                      },
                      child: Text(widget.sender,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5)),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    liked
                  ],
                ),
                SizedBox(height: 7.0),
                attachment,
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
