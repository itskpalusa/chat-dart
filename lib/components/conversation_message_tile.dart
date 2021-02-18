import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/screens/image_detail_screen.dart';
import 'package:chat/screens/user_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:linkable/linkable.dart';

import '../constants.dart';

class ConversationMessageTile extends StatefulWidget {
  final String message;
  final String sender;
  final bool sentByMe;
  final String senderId;
  final String attachment;
  final String conversationId;
  final String messageId;
  final List likes;
  final int messageTime;
  final Timestamp timestamp;

  ConversationMessageTile(
      {this.message,
      this.sender,
      this.sentByMe,
      this.senderId,
      this.attachment,
      this.conversationId,
      this.messageId,
      this.likes,
      this.messageTime,
      this.timestamp});

  @override
  _ConversationMessageTileState createState() =>
      _ConversationMessageTileState();
}

class _ConversationMessageTileState extends State<ConversationMessageTile> {
  final key = new GlobalKey<ScaffoldState>();
  String userProfilePicUrl;
  User _user = FirebaseAuth.instance.currentUser;

  // initState
  @override
  void initState() {
    super.initState();

    getTimeStamp().then((data) {
      setState(() {
        this.messageSentTime = data;
      });
    });
  }

  var messageSentTime;

  Future getTimeStamp() async {
    //Time Parsing
    var messageTimeParsed =
        DateTime.fromMillisecondsSinceEpoch(widget.messageTime, isUtc: true);
    var today = DateTime.now();
    if (today.difference(messageTimeParsed).inHours > 24) {
      final DateFormat formatter = DateFormat('MM/dd hh:mm a');
      final String formatted =
          formatter.format(widget.timestamp.toDate().toLocal());
      return messageSentTime = formatted;
    } else {
      final DateFormat formatter = DateFormat('hh:mm a');
      final String formatted =
          formatter.format(widget.timestamp.toDate().toLocal());
      return messageSentTime = formatted;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget liked;
    if (widget.likes == null) {
      liked = Icon(Icons.favorite_outline, color: Colors.white);
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
      attachment = CachedNetworkImage(
        imageUrl: url != null
            ? url
            : 'https://dashstrap.com/static/media/image.06e2febd.png?__WB_REVISION__=06e2febd33a82f083544d2cf25d1eaa6',
      );
    else
      attachment = SizedBox(height: 0);

    Widget profilePicture;
    profilePicture = new FutureBuilder<String>(
      future: getUserProfilePicUrl(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return CachedNetworkImage(
            imageUrl: userProfilePicUrl != null
                ? userProfilePicUrl
                : "https://dashstrap.com/static/media/image.06e2febd.png?__WB_REVISION__=06e2febd33a82f083544d2cf25d1eaa6",
            height: 30,
            width: 30,
            placeholder: (BuildContext context, url) => CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
            ),
            imageBuilder: (BuildContext context, image) => CircleAvatar(
              backgroundImage: image,
            ),
            errorWidget: (context, url, error) => const Icon(Icons.person),
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
              .collection('conversations')
              .doc(widget.conversationId)
              .collection('messages')
              .doc(widget.messageId)
              .update({
            'liked': FieldValue.arrayUnion([_user.uid])
          });
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    widget.sentByMe ? SizedBox(height: 0) : profilePicture,
                    SizedBox(
                      width: 2,
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
                    Spacer(),
                    Text(
                      messageSentTime ?? " ",
                      style: TextStyle(color: Colors.black45),
                    ),
                  ],
                ),
                SizedBox(height: 7.0),
                attachment,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Linkable(
                        text: widget.message,
                        textColor: Colors.white,
                        linkColor: widget.senderId == _user.uid
                            ? Colors.white
                            : kPortGoreBackground,
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 15.0, color: Colors.white),
                      ),
                    ),
                    liked,
                  ],
                ),
              ],
            ),
          ),
        )));
  }
}
