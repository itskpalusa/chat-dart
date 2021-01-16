import 'package:chat/screens/home_screen.dart';
import 'package:chat/screens/report_screen.dart';
import 'package:flutter/material.dart';

class MessageTile extends StatelessWidget {
  final String message;
  final String sender;
  final bool sentByMe;

  MessageTile({this.message, this.sender, this.sentByMe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onLongPress: () {
          print("PRESSED");
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ReportScreen()));
        },
        child: SafeArea(
            child: Container(
          padding: EdgeInsets.only(
              top: 4,
              bottom: 4,
              left: sentByMe ? 0 : 24,
              right: sentByMe ? 24 : 0),
          alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: sentByMe
                ? EdgeInsets.only(left: 50)
                : EdgeInsets.only(right: 50),
            padding: EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
            decoration: BoxDecoration(
              borderRadius: sentByMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(23),
                      topRight: Radius.circular(23),
                      bottomLeft: Radius.circular(23))
                  : BorderRadius.only(
                      topLeft: Radius.circular(23),
                      topRight: Radius.circular(23),
                      bottomRight: Radius.circular(23)),
              color: sentByMe ? Colors.blueAccent : Colors.grey,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                sentByMe
                    ? SizedBox(height: 0)
                    : Text(sender,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5)),
                SizedBox(height: 7.0),
                Text(
                  message,
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 15.0, color: Colors.white),
                ),
              ],
            ),
          ),
        )));
  }
}
