import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat/helper/helper_functions.dart';
import 'package:chat/models/UserModel.dart';
import 'package:chat/services/db_service.dart';
import 'package:flutter/services.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create User Object From User Schema
  UserModel _userFromFirebaseUser(User user) {
    return (user != null) ? UserModel(uid: user.uid) : null;
  }

  // Sign In w/ Email and Password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Registration w/ Email and Password (Traditional) Method
  Future registerWithEmailAndPassword(
      String fullName, String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;

      // Create a new document for the user with uid
      await DBService(uid: user.uid).updateUserData(fullName, email);
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //Sign Out Method
  Future signOut() async {
    try {
      await HelperFunctions.saveUserLoggedInSharedPreference(false);
      await HelperFunctions.saveUserEmailSharedPreference('');
      await HelperFunctions.saveUserNameSharedPreference('');

      return await _auth.signOut().whenComplete(() async {
        print("Logged out");
        await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
          print("Logged in: $value");
        });
        await HelperFunctions.getUserEmailSharedPreference().then((value) {
          print("Email: $value");
        });
        await HelperFunctions.getUserNameSharedPreference().then((value) {
          print("Full Name: $value");
        });
      });
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
