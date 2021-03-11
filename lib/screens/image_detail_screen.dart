import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_downloader/image_downloader.dart';

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
          onLongPress: () async {
            try {
              // Saved with this method.
              var imageId = await ImageDownloader.downloadImage(widget.image);
              if (imageId == null) {
                return;
              }

              // Below is a method of obtaining saved image information.
              // ignore: unused_local_variable
              var fileName = await ImageDownloader.findName(imageId);
              // ignore: unused_local_variable
              var path = await ImageDownloader.findPath(imageId);
              // ignore: unused_local_variable
              var size = await ImageDownloader.findByteSize(imageId);
              // ignore: unused_local_variable
              var mimeType = await ImageDownloader.findMimeType(imageId);
            } on PlatformException catch (error) {
              print(error);
            }
            BuildContext con = context;
            final snackBar = SnackBar(content: new Text("Saved Image"));
            ScaffoldMessenger.of(con).showSnackBar(snackBar);
            print('pop');
          },
        ),
      ),
    );
  }
}
