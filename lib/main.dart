import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:notifikasi/message_widget.dart';

void main() {
  runApp(MyApp());
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  _firebaseMessaging.requestNotificationPermissions();
  _firebaseMessaging.getToken().then((token) {
    print(token);
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Notifier'),
          backgroundColor: Colors.lightGreen,
        ),
        body: MessageWidget(),
      ),
    );
  }
}
