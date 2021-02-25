import 'package:chat/constants.dart';
import 'package:chat/services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wiredash/wiredash.dart';

import 'authentication_screen.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';

import 'edit_info_screen.dart';

class SettingsScreen extends StatefulWidget {
  final String userName;
  final String email;
  final String phone;

  SettingsScreen({this.userName, this.email, this.phone});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _auth = AuthService();
  String profilePicUrl;
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  String imageUrl;

  User firebaseUser;

  // initState
  @override
  void initState() {
    super.initState();
    firebaseUser = FirebaseAuth.instance.currentUser;
    imageCache.clear();

    _getUserAuth();
  }

  // functions
  _getUserAuth() async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(firebaseUser.uid)
        .get()
        // ignore: await_only_futures
        .then(await (value) {
          profilePicUrl = value.data()['profilePic'];
        });
  }

  uploadImage() async {
    final _firebaseStorage = FirebaseStorage.instance;
    final _imagePicker = ImagePicker();
    PickedFile image;
    User firebaseUser = FirebaseAuth.instance.currentUser;
    String userID = firebaseUser.uid;
    //Select Image
    image = await _imagePicker.getImage(
        source: ImageSource.gallery, imageQuality: 75);

    var file = File(image.path);

    if (image != null) {
      //Upload to Firebase
      var snapshot = await _firebaseStorage
          .ref()
          .child('profilePictures/$userID')
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

    FirebaseFirestore.instance
        .collection("users")
        .doc(firebaseUser.uid)
        .update(<String, dynamic>{'profilePic': imageUrl});
  }

  Future<String> getProfilePicUrl() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(firebaseUser.uid)
        .get()
        .then((value) {
      profilePicUrl = value.data()['profilePic'];
    });
    return profilePicUrl;
  }

  @override
  Widget build(BuildContext context) {
    Widget display;
    display = new FutureBuilder<String>(
        future: getProfilePicUrl(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return new CircleAvatar(
              backgroundImage: NetworkImage(profilePicUrl),
              onBackgroundImageError: null,
              radius: 100,
            );
          } else if (snapshot.hasError) {
            return new Text("${snapshot.error}");
          }
          // By default, show a loading spinner
          return new CircularProgressIndicator();
        });

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings',
            style: TextStyle(
                color: Colors.white,
                fontSize: 27.0,
                fontWeight: FontWeight.bold)),
        backgroundColor: kPortGoreBackground,
        elevation: 0.0,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 50.0),
        child: ListView(
          children: <Widget>[
            display,
            ElevatedButton(
              onPressed: () {
                uploadImage();
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) return kSteelBlue;
                  return kSteelBlue; // Use the component's default.
                },
              )),
              child: Text(
                'Change Profile Picture',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 15.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Full Name', style: TextStyle(fontSize: 17.0)),
                Text(widget.userName, style: TextStyle(fontSize: 17.0)),
              ],
            ),
            Divider(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Email', style: TextStyle(fontSize: 17.0)),
                Text(widget.email, style: TextStyle(fontSize: 17.0)),
              ],
            ),
            Divider(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Phone', style: TextStyle(fontSize: 17.0)),
                Text(widget.phone, style: TextStyle(fontSize: 17.0)),
              ],
            ),
            SizedBox(height: 15.0),
            ElevatedButton(
              onPressed: () => Wiredash.of(context).show(),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) return kSteelBlue;
                  return kSteelBlue; // Use the component's default.
                },
              )),
              child: Text(
                'Give Feedback',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 15.0),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    // ignore: await_only_futures
                    builder: await (context) => EditInformationScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: kSteelBlue, // background
                onPrimary: Colors.white, // foreground
              ),
              child: Text(
                'Edit Information',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () async {
                await _auth.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => AuthenticatePage()),
                    (Route<dynamic> route) => false);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // background
                onPrimary: Colors.white, // foreground
              ),
              child: Text(
                'Logout',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
            Text(
              "Made with ❤️ in Fort Collins, CO",
              textAlign: TextAlign.center,
            ),
            Text(
              "Version 1.1.04",
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
