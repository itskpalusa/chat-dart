import 'package:chat/screens/chat_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:chat/services/db_service.dart';
import 'package:chat/components/message_tile.dart';
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

class ChatScreen extends StatefulWidget {
  final String groupId;
  final String userName;
  final String groupName;

  ChatScreen({this.groupId, this.userName, this.groupName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<String> members;
  bool isPrivate;
  String admin;
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
    _firebaseMessaging.subscribeToTopic('${widget.groupId}');
    _firebaseMessaging.getToken().then((token) => print(token));
  }

  Widget group(BuildContext context) {
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
        members = List.from(userDocument['members']);
        isPrivate = userDocument['private'];
        admin = userDocument['admin'];

        return SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Text(
                  'Key: ${widget.groupId}',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
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
                    'Members:',
                    textAlign: TextAlign.center,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      return Text(
                        members[index]
                            .substring(members[index].indexOf("_") + 1),
                        textAlign: TextAlign.center,
                      );
                    },
                  )
                ],
              )),
            ],
          ),
        );
      },
    );
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
                    return MessageTile(
                      message: snapshot.data.documents[index].data()["message"],
                      sender: snapshot.data.documents[index].data()["sender"],
                      sentByMe: _user.uid ==
                          snapshot.data.documents[index].data()["senderId"],
                      groupId: widget.groupId,
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
        'groupId': widget.groupId,
        'groupName': widget.groupName
      };

      DBService().sendMessage(widget.groupId, chatMessageMap);

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
    User firebaseUser = FirebaseAuth.instance.currentUser;
    String groupName = widget.groupName;
    String groupId = widget.groupId;
    String timeSeconds = DateTime.now().millisecondsSinceEpoch.toString();
    var imageAttachmentName = groupName + groupId + timeSeconds;
    //Select Image
    image = await _imagePicker.getImage(
        source: ImageSource.gallery, imageQuality: 75);

    var file = File(image.path);

    if (image != null) {
      //Upload to Firebase
      var snapshot = await _firebaseStorage
          .ref()
          .child('attachments/$imageAttachmentName')
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
      'groupId': widget.groupId,
      'groupName': widget.groupName
    };

    FirebaseFirestore.instance
        .collection("groups")
        .doc(groupId)
        .update(<String, dynamic>{'profilePic': imageUrl});

    DBService().sendAttachment(widget.groupId, chatAndAttachmentMessageMap);
    setState(() {
      messageEditingController.text = "";
      _scrollController.jumpTo(_scrollController.position.minScrollExtent);
    });
  }

  @override
  void initState() {
    super.initState();
    analytics.setCurrentScreen(screenName: "/chat/${widget.groupId}");
    print("/chat/${widget.groupId}");
    getTokenAndSaveAsync();
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
      resizeToAvoidBottomInset: true,
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        title: Text(widget.groupName),
        backgroundColor: kPortGoreBackground,
        centerTitle: true,
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.settings,
            ),
            onPressed: () async {
              // do something
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: await (context) => ChatSettings(
                      groupId: widget.groupId,
                      groupName: widget.groupName,
                      private: isPrivate,
                      admin: admin),
                ),
              );
            },
          )
        ],
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
