import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:chat/services/db_service.dart';
import 'package:chat/components/conversation_message_tile.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '../constants.dart';

Future<void> saveTokenToDatabase(String token) async {
  // Assume user is logged in for this example
  String userId = FirebaseAuth.instance.currentUser.uid;

  await FirebaseFirestore.instance.collection('users').doc(userId).update({
    'tokens': FieldValue.arrayUnion([token]),
  });
}

class ConversationChatScreen extends StatefulWidget {
  final String conversationId;
  final String userName;
  final String otherUserName;

  ConversationChatScreen(
      {this.conversationId, this.userName, this.otherUserName});

  @override
  _ConversationChatScreenState createState() => _ConversationChatScreenState();
}

class _ConversationChatScreenState extends State<ConversationChatScreen> {
  String otherUser;
  String profilePicUrl;

  static FirebaseAnalytics analytics = FirebaseAnalytics();

  Stream<QuerySnapshot> _chats;

  TextEditingController messageEditingController = new TextEditingController();
  User _user = FirebaseAuth.instance.currentUser;
  ScrollController _scrollController;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  // For Attachment(Images)
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  String imageUrl;

  Future<void> getTokenAndSaveAsync() async {
    String token = await FirebaseMessaging().getToken();
    await saveTokenToDatabase(token);
    fcmSubscribe();
  }

  void fcmSubscribe() {
    _firebaseMessaging.subscribeToTopic('${widget.conversationId}');
    _firebaseMessaging.getToken().then((token) => print(token));
  }

  Widget _chatMessages() {
    return StreamBuilder(
      stream: _chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? Padding(
                padding: EdgeInsets.only(bottom: Platform.isIOS ? 70 : 80),
                child: ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data.documents.length,
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    return ConversationMessageTile(
                      message: snapshot.data.documents[index].data()["message"],
                      messageTime:
                          snapshot.data.documents[index].data()["time"],
                      timestamp:
                          snapshot.data.documents[index].data()['timestamp'],
                      sender: snapshot.data.documents[index].data()["sender"],
                      sentByMe: _user.uid ==
                          snapshot.data.documents[index].data()["senderId"],
                      conversationId: widget.conversationId,
                      messageId: snapshot.data.documents[index].documentID,
                      senderId:
                          snapshot.data.documents[index].data()["senderId"],
                      likes: snapshot.data.documents[index].data()['liked'],
                      attachment: (snapshot.data.documents[index]
                                  .data()["attachment"] !=
                              null)
                          ? snapshot.data.documents[index].data()["attachment"]
                          : null,
                    );
                  },
                ))
            : Container();
      },
    );
  }

  _sendMessage() async {
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageEditingController.text,
        "sender": widget.userName,
        'senderId': _user.uid,
        'time': DateTime.now().millisecondsSinceEpoch,
        'timestamp': FieldValue.serverTimestamp(),
        'conversationId': widget.conversationId,
      };

      DBService()
          .sendMessageInConversation(widget.conversationId, chatMessageMap);

      setState(() {
        messageEditingController.text = "";
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      });
    }
  }

  uploadImageAttachment() async {
    final _firebaseStorage = FirebaseStorage.instance;
    final _imagePicker = ImagePicker();
    PickedFile image;
    // ignore: unused_local_variable
    User firebaseUser = FirebaseAuth.instance.currentUser;
    String conversationId = widget.conversationId;
    String timeSeconds = DateTime.now().millisecondsSinceEpoch.toString();
    var imageAttachmentName = conversationId + timeSeconds;
    //Select Image
    image = await _imagePicker.getImage(
        source: ImageSource.gallery, imageQuality: 75);

    var file = File(image.path);

    if (image != null) {
      //Upload to Firebase
      var snapshot = await _firebaseStorage
          .ref()
          .child('attachments/$imageAttachmentName')
          // ignore: await_only_futures
          .putFile(await file);
      var downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        imageUrl = downloadUrl;
      });
    } else {
      print('No Image Path Received');
    }
    firebaseUser = FirebaseAuth.instance.currentUser;
    Map<String, dynamic> chatAndAttachmentMessageMap = {
      "message": messageEditingController.text,
      "attachment": imageUrl,
      "sender": widget.userName,
      'senderId': _user.uid,
      'time': DateTime.now().millisecondsSinceEpoch,
      'timestamp': FieldValue.serverTimestamp(),
      'conversationId': widget.conversationId,
    };

    FirebaseFirestore.instance
        .collection("conversations")
        .doc(conversationId)
        .update(<String, dynamic>{'profilePic': imageUrl});

    DBService().sendAttachmentInConversation(
        widget.conversationId, chatAndAttachmentMessageMap);
    setState(() {
      messageEditingController.text = "";
      _scrollController.jumpTo(_scrollController.position.minScrollExtent);
    });
  }

  @override
  void initState() {
    super.initState();
    analytics.setCurrentScreen(screenName: "/chat/${widget.conversationId}");
    print("/chat/${widget.conversationId}");
    getTokenAndSaveAsync();
    _scrollController = ScrollController();
    DBService().getConversationChats(widget.conversationId).then((val) {
      setState(() {
        _chats = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        title: Text(widget.otherUserName),
        backgroundColor: kPortGoreBackground,
        centerTitle: true,
        elevation: 0.0,
      ),
      body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Container(
            child: Stack(
              children: <Widget>[
                _chatMessages(),
                Container(
                  alignment: Alignment.bottomCenter,
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                    color: Colors.grey[700],
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: messageEditingController,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
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
                            uploadImageAttachment();
                          },
                          child: RotatedBox(
                            quarterTurns: 0,
                            child: Icon(
                              Icons.image,
                              color: Colors.white,
                            ),
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
                                color: kSteelBlue,
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
          )),
    );
  }
}
