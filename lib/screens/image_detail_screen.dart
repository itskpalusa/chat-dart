import 'package:flutter/material.dart';

class ImageDetailScreen extends StatefulWidget {
  final String image;

  ImageDetailScreen({this.image});

  @override
  _ImageDetailScreenState createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          child: Center(
            child: Image.network(widget.image),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
