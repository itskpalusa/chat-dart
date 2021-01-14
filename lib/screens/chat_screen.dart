import 'package:chat/screens/chat_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat/services/db_service.dart';
import 'package:chat/components/message_tile.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  final String groupId;
  final String userName;
  final String groupName;

  ChatScreen({this.groupId, this.userName, this.groupName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Stream<QuerySnapshot> _chats;
  TextEditingController messageEditingController = new TextEditingController();
  User _user = FirebaseAuth.instance.currentUser;
  ScrollController _scrollController;

  Widget _chatMessages() {
    return StreamBuilder(
      stream: _chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? Padding(
                padding: EdgeInsets.only(bottom: Platform.isIOS ? 40 : 80),
                child: ListView.builder(  reverse: true,

                  itemCount: snapshot.data.documents.length,
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    return MessageTile(
                      message: snapshot.data.documents[index].data()["message"],
                      sender: snapshot.data.documents[index].data()["sender"],
                      sentByMe: _user.uid ==
                          snapshot.data.documents[index].data()["senderId"],
                    );
                  },
                ))
            : Container();
      },
    );
  }

  _sendMessage() {
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageEditingController.text,
        "sender": widget.userName,
        'senderId': _user.uid,
        'time': DateTime.now().millisecondsSinceEpoch,
        'timestamp': Timestamp.now()
      };

      DBService().sendMessage(widget.groupId, chatMessageMap);

      setState(() {
        messageEditingController.text = "";
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    }
  }

  void scrollToBottom() {
    final bottomOffset = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      bottomOffset,
      duration: Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
  }


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    print(_user.uid);
    _scrollController = ScrollController();
    DBService().getChats(widget.groupId).then((val) {
      setState(() {
        _chats = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        centerTitle: true,
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.settings,
            ),
            onPressed: () {
              // do something
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatSettings(
                      groupId: widget.groupId, groupName: widget.groupName),
                ),
              );
            },
          )
        ],
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            _chatMessages(),
            // Container(),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                color: Colors.grey[700],
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: messageEditingController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            hintText: "Send a message ...",
                            hintStyle: TextStyle(
                              color: Colors.white38,
                              fontSize: 16,
                            ),
                            border: InputBorder.none),
                      ),
                    ),
                    SizedBox(width: 12.0),
                    GestureDetector(
                      onTap: () {
                        _sendMessage();
                      },
                      child: Container(
                        height: 50.0,
                        width: 50.0,
                        decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(50)),
                        child: Center(
                            child: Icon(Icons.send, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
