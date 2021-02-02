import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/screens/conversation_chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat/screens/chat_screen.dart';

class ConversationTile extends StatelessWidget {
  final String userName;
  final String conversationId;
  final String otherUser;

  ConversationTile({this.userName, this.conversationId, this.otherUser});

  String profilePicUrl;
  String otherUserId;
  User _user;

  String _destructureId(String res) {
    return res.substring(0, res.indexOf('_'));
  }

  Future<String> getOtherUserProfilePic() async {
    _user = await FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection("conversations")
        .doc(conversationId)
        .get()
        .then((value) {
      if (_destructureId(value.data()['user1']) == _user.uid)
        otherUserId = _destructureId(value.data()['user2']);
      else
        otherUserId = _destructureId(value.data()['user1']);
    });

    await FirebaseFirestore.instance
        .collection("users")
        .doc(otherUserId)
        .get()
        .then((value) {
      profilePicUrl = value.data()['profilePic'];
    });

    if (profilePicUrl == "" || profilePicUrl == null)
      profilePicUrl =
          'https://dashstrap.com/static/media/image.06e2febd.png?__WB_REVISION__=06e2febd33a82f083544d2cf25d1eaa6';

    return profilePicUrl;
  }

  @override
  Widget build(BuildContext context) {
    Widget displayGroupIcon;
    displayGroupIcon = new FutureBuilder<String>(
        future: getOtherUserProfilePic(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return CachedNetworkImage(
              height: 50,
              width: 50,
              imageUrl: profilePicUrl != null
                  ? profilePicUrl
                  : "https://dashstrap.com/static/media/image.06e2febd.png?__WB_REVISION__=06e2febd33a82f083544d2cf25d1eaa6",
              placeholder: (BuildContext context, url) => CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20,
              ),
              imageBuilder: (BuildContext context, image) => CircleAvatar(
                backgroundImage: image,
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            );
          } else if (snapshot.hasError) {
            return new Text("${snapshot.error}");
          }
          // By default, show a loading spinner
          return new CircularProgressIndicator();
        });

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationChatScreen(
              conversationId: conversationId,
              userName: userName,
              otherUserName: otherUser,
            ),
          ),
        );
      },
      child: Container(
        child: ListTile(
          leading: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 44,
              minHeight: 44,
              maxWidth: 44,
              maxHeight: 44,
            ),
            child: displayGroupIcon,
          ),
          title: Text(otherUser),
          subtitle: Text("Join the conversation as $userName",
              style: TextStyle(fontSize: 14.0)),
        ),
      ),
    );
  }
}
