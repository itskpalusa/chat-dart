import 'package:apple_sign_in/apple_sign_in_button.dart' as asib;
import 'package:apple_sign_in/scope.dart';
import 'package:chat/screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:chat/helper/helper_functions.dart';
import 'package:chat/services/auth_services.dart';
import 'package:chat/services/db_service.dart';
import 'package:chat/constants.dart';
import 'package:chat/loading.dart';
import 'package:provider/provider.dart';
import 'apple_sign_in.dart';

class LoginScreen extends StatefulWidget {
  final Function toggleView;

  LoginScreen({this.toggleView});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // text field state
  String email = '';
  String fullName = '';

  String password = '';
  String error = '';

  _onSignIn() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });

      await _auth
          .signInWithEmailAndPassword(email, password)
          .then((result) async {
        if (result != null) {
          QuerySnapshot userInfoSnapshot = await DBService().getUserData(email);

          await HelperFunctions.saveUserLoggedInSharedPreference(true);
          await HelperFunctions.saveUserEmailSharedPreference(email);
          await HelperFunctions.saveUserNameSharedPreference(
              userInfoSnapshot.docs[0].data()['fullName']);

          print("Signed In");
          await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
            print("Logged in: $value");
          });
          await HelperFunctions.getUserEmailSharedPreference().then((value) {
            print("Email: $value");
          });
          await HelperFunctions.getUserNameSharedPreference().then((value) {
            print("Full Name: $value");
          });

          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (context) => Home()));
        } else {
          setState(() {
            error = 'Error signing in!';
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appleSignInAvailable =
        Provider.of<AppleSignInAvailable>(context, listen: false);

    return _isLoading
        ? Loading()
        : Scaffold(
            body: Form(
              key: _formKey,
              child: Container(
                child: ListView(
                  padding:
                      EdgeInsets.symmetric(horizontal: 30.0, vertical: 80.0),
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Image(
                          image: AssetImage('lib/images/logo_notext.png'),
                          height: 100,
                          width: 100,
                        ),
                        SizedBox(height: 20.0),

                        Text("DashChat",
                            style: TextStyle(
                                fontSize: 40.0, fontWeight: FontWeight.bold)),
                        SizedBox(height: 30.0),
                        Text("Sign In", style: TextStyle(fontSize: 25.0)),
                        SizedBox(height: 20.0),
                        TextFormField(
                          decoration:
                              ktextInputDecoration.copyWith(labelText: 'Email'),
                          validator: (val) {
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(val)
                                ? null
                                : "Please enter a valid email";
                          },
                          onChanged: (val) {
                            setState(() {
                              email = val;
                            });
                          },
                        ),
                        SizedBox(height: 15.0),
                        TextFormField(
                          decoration: ktextInputDecoration.copyWith(
                              labelText: 'Password'),
                          validator: (val) => val.length < 6
                              ? 'Password not strong enough'
                              : null,
                          obscureText: true,
                          onChanged: (val) {
                            setState(() {
                              password = val;
                            });
                          },
                        ),
                        SizedBox(height: 20.0),
                        SizedBox(
                          width: double.infinity,
                          height: 50.0,
                          child: RaisedButton(
                              elevation: 0.0,
                              color: Colors.blue,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                              child: Text('Sign In',
                                  style: TextStyle(fontSize: 16.0)),
                              onPressed: () {
                                _onSignIn();
                              }),
                        ),
                        // SizedBox(height: 20.0),
                        // if (appleSignInAvailable.isAvailable)
                        //   asib.AppleSignInButton(
                        //       style: asib.ButtonStyle.black,
                        //       type: asib.ButtonType.signIn,
                        //       onPressed: () => {
                        //             _signInWithApple(context),
                        //             Navigator.of(context).pushReplacement(
                        //                 MaterialPageRoute(
                        //                     builder: (context) => Home())),
                        //           }),
                        SizedBox(height: 10.0),
                        Text.rich(
                          TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(fontSize: 14.0),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Register here',
                                style: TextStyle(
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    widget.toggleView();
                                  },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Text(error,
                            style:
                                TextStyle(color: Colors.red, fontSize: 14.0)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

Future<void> _signInWithApple(BuildContext context) async {
  try {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = await authService
        .signInWithApple(scopes: [Scope.email, Scope.fullName]);
    if (authService != null) {
      await HelperFunctions.saveUserLoggedInSharedPreference(true);
      await HelperFunctions.saveUserEmailSharedPreference(user.email);
      await HelperFunctions.saveUserNameSharedPreference(user.displayName);
    }
    print('uid: ${user.displayName}');
    print('uid: ${user.email}');
  } catch (e) {
    // TODO: Show alert here
    print(e);
  }
}
