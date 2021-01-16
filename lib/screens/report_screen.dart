import 'package:flutter/material.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Report Message',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 27.0,
                  fontWeight: FontWeight.bold)),
          elevation: 0.0,
        ),
        body: Container(
          child: ListView(children: <Widget>[
            SizedBox(height: 20.0),
            Text(
              "Please email the developers at team@dashstrap.com, and we will look at the details of your report shortly.",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),
            Text(
              "Include the follow:\n\n1. Your name \n2. Reported User's name\n3. Description of user's reported message, or screenshot.\n4. Any additional details",
              textAlign: TextAlign.center,
            ),
          ]),
        ));
  }
}
