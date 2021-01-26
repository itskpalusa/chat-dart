import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chat/screens/chat_screen.dart';

class GroupTile extends StatelessWidget {
  final String userName;
  final String groupId;
  final String groupName;

  GroupTile({this.userName, this.groupId, this.groupName});

  String groupPicUrl;

  Future<String> getGroupPicUrl() async {
    await FirebaseFirestore.instance
        .collection("groups")
        .doc(groupId)
        .get()
        .then((value) {
      groupPicUrl = value.data()['groupIcon'];
    });
    if (groupPicUrl == "" || groupPicUrl == null)
      groupPicUrl =
          'https://dashstrap.com/static/media/image.06e2febd.png?__WB_REVISION__=06e2febd33a82f083544d2cf25d1eaa6';

    return groupPicUrl;
  }

  @override
  Widget build(BuildContext context) {
    Widget displayGroupIcon;
    displayGroupIcon = new FutureBuilder<String>(
        future: getGroupPicUrl(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return CachedNetworkImage(
              height: 50,
              width: 50,
              imageUrl: groupPicUrl != null
                  ? groupPicUrl
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
            builder: (context) => ChatScreen(
              groupId: groupId,
              userName: userName,
              groupName: groupName,
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
          title: Text(groupName),
          subtitle: Text("Join the conversation as $userName",
              style: TextStyle(fontSize: 14.0)),
        ),
      ),
    );
  }
}
