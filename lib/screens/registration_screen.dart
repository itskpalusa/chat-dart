import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:chat/helper/helper_functions.dart';
import 'package:chat/services/auth_services.dart';
import 'package:chat/constants.dart';
import 'package:chat/loading.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home.dart';

class RegistrationScreen extends StatefulWidget {
  final Function toggleView;

  RegistrationScreen({this.toggleView});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool acceptedEULAandTerms = false;

  // text field state
  String fullName = '';
  String email = '';
  String password = '';
  String error = '';

  _launchURL() async {
    const url = 'https://dashstrap.com/eula';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _onRegister() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      if (acceptedEULAandTerms) {
        await _auth
            .registerWithEmailAndPassword(fullName, email, password)
            .then((result) async {
          if (result != null) {
            await HelperFunctions.saveUserLoggedInSharedPreference(true);
            await HelperFunctions.saveUserEmailSharedPreference(email);
            await HelperFunctions.saveUserNameSharedPreference(fullName);

            print("Registered");
            await HelperFunctions.getUserLoggedInSharedPreference()
                .then((value) {
              print("Logged in: $value");
            });
            await HelperFunctions.getUserEmailSharedPreference().then((value) {
              print("Email: $value");
            });
            await HelperFunctions.getUserNameSharedPreference().then((value) {
              print("Full Name: $value");
            });

            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => Home()));
          } else {
            setState(() {
              error = 'Error while registering the user!';
              _isLoading = false;
            });
          }
        });
      } else {
        setState(() {
          error = 'Error while registering the user!';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          Text("Register", style: TextStyle(fontSize: 25.0)),
                          SizedBox(height: 20.0),
                          TextFormField(
                            decoration: ktextInputDecoration.copyWith(
                                labelText: 'Full Name'),
                            onChanged: (val) {
                              setState(() {
                                fullName = val;
                              });
                            },
                          ),
                          SizedBox(height: 15.0),
                          TextFormField(
                            decoration: ktextInputDecoration.copyWith(
                                labelText: 'Email'),
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
                          SizedBox(height: 15.0),
                          CheckboxListTile(
                            title: Text(
                                "By Signing Up for DashChat I Accept the EULA and Terms of Service"),
                            value: acceptedEULAandTerms,
                            onChanged: (newValue) {
                              setState(() {
                                acceptedEULAandTerms = newValue;
                              });
                            },
                            controlAffinity: ListTileControlAffinity
                                .leading, //  <-- leading Checkbox
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 50.0,
                            child: RaisedButton(
                                elevation: 0.0,
                                color: Colors.blue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0)),
                                child: Text('Register',
                                    style: TextStyle(fontSize: 16.0)),
                                onPressed: () {
                                  _onRegister();
                                }),
                          ),
                          SizedBox(height: 10.0),
                          Text.rich(
                            TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(fontSize: 14.0),
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Sign In',
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
                          GestureDetector(
                            onTap: _launchURL,
                            child: Text('View Terms and EULA'),
                          ),
                          SizedBox(height: 20.0),
                          Text(error,
                              style:
                                  TextStyle(color: Colors.red, fontSize: 14.0)),
                        ],
                      ),
                    ],
                  ),
                )),
          );
  }
}
