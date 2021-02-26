import 'package:chat/helper/helper_functions.dart';
import 'package:chat/screens/user_profile_screen.dart';
import 'package:chat/services/db_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class ContactsScreen extends StatefulWidget {
  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  User _user;
  Stream _contacts;

  // initState
  @override
  void initState() {
    super.initState();
    _getUserAuth();
  }

  _getUserAuth() async {
    // ignore: await_only_futures
    _user = await FirebaseAuth.instance.currentUser;
    DBService(uid: _user.uid).getUserGroups().then(
      (snapshots) {
        setState(() {
          _contacts = snapshots;
        });
      },
    );
  }

  Widget noContacts() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 20.0),
          Text("No contacts"),
        ],
      ),
    );
  }

  // TODO: FIX BUG WHERE USER CANT ENTER CONTACTS FIRST
  // MAYBE UID?

  userContacts() {
    return StreamBuilder(
      stream: _contacts,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data['contacts'] != null) {
          if (snapshot.data['contacts'].length != 0) {
            var userDocument = snapshot.data;
            List<String> contacts = List.from(userDocument['contacts']);

            return Scaffold(
              body: SafeArea(
                child: ListView(
                  children: <Widget>[
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        // Get contact names
                        //TODO: CAN YOU SAVE A list locally

                        // Return
                        return Container(
                          height: 40,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Theme.of(context).dividerColor))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => UserProfileScreen(
                                        userName: contacts[index].substring(
                                            contacts[index].indexOf("_") + 1),
                                        userId: contacts[index].substring(
                                            0, contacts[index].indexOf('_')),
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                    contacts[index].substring(
                                        contacts[index].indexOf("_") + 1),
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5)),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            );
          } else {
            return noContacts();
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
        backgroundColor: kPortGoreBackground,
        centerTitle: true,
        elevation: 0.0,
      ),
      body: userContacts(),
    );
  }
}
