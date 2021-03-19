import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notifikasi/model/Notifikasi.dart';
import 'package:notifikasi/model/Pesan.dart';
import 'package:notifikasi/service/api_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class MessageWidget extends StatefulWidget {
  @override
  _MessageWidgetState createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final AudioPlayer audioPlayer = AudioPlayer();
  final List<Pesan> messages = [];
  String token = '';
  String mp3uri = '';
  List<Notifikasi> notifikasion;
  ApiService apiService = ApiService();

  Future<void> _handleNotification(
      Map<dynamic, dynamic> message, bool dialog) async {
    print(message);
    final dynamic data = message['data'] ?? message;
    final dynamic notification = message['notification'] ?? message;
    String title = notification['title'];
    String body = notification['body'];
    String sound = data['sound'];
    setState(() {
      messages.add(Pesan(
        title: title,
        body: body,
        sound: sound,
      ));
    });
  }

  Future<void> _createNotificationChannel(
      String id, String name, String description, String sound) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var androidNotificationChannel = AndroidNotificationChannel(
      id,
      name,
      description,
      sound: RawResourceAndroidNotificationSound(sound),
      playSound: true,
    );
    print(sound);
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
  }

  Future<void> _createNotificationChannelFromUri(
      String id, String name, String description, String uri) async {
    final UriAndroidNotificationSound uriSound =
        UriAndroidNotificationSound(uri);
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var androidNotificationChannel = AndroidNotificationChannel(
      id,
      name,
      description,
      sound: uriSound,
      playSound: true,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
  }

  static var httpClient = new HttpClient();
  Future<File> _downloadFile(String url, String filename) async {
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);

    Directory dir = await getExternalStorageDirectory();
    String appPath = dir.path;
    print("appPath : " + appPath);
    File file = new File('$appPath/$filename');
    await file.writeAsBytes(bytes);
    print(dir.listSync());
    mp3uri = file.uri.toString();
    return file;
  }

  void playSound(String uri) {
    AudioPlayer player = AudioPlayer();
    player.play(uri);
  }

  @override
  void initState() {
    print(mp3uri);
    _firebaseMessaging.subscribeToTopic('ok');

    // TODO: implement initState
    super.initState();
    try {
      _firebaseMessaging.getToken().then((token) => setState(() {
            this.token = token;
          }));

      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
          // final dynamic notification = message['notification'] ?? message;

          // String channelId = notification['title'];
          // String url = notification['url'];
          // String channelId = "kucing";
          // String url =
          //     'https://82020905-a-62cb3a1a-s-sites.googlegroups.com/site/cdn4kicaumania/suara%20kucing%20anak.mp3?attachauth=ANoY7cqcGVwZiAoWXVzifplgxPuI4ywx5UwDUHRvchVF-WD2hdJTwiTCWyU9c95g8XnPl5fpLpkpw6qbPoswUf8WvVVDaM74uIsxoDnF1sW3jn-9F0p7_WCBrbMdS6JhDKSxwOXPdmHtdRnBlAt1zf3tBECsnsCkmxlU-YMW2wJeI2VHc2raQJj1U53xe6J-b-XtqMSyo5mjwIeINpcj-2cppy292Zx-DqqRMCMM-VZVVxbMB8TKLQs%3D&attredirects=0';
          // print(channelId);
          // print(url);
          // _handleNotification(message, true);
          // // _downloadFile(url, '$channelId.wav').then((_) {
          // //   _showSoundUriNotification(channelId);
          // // });
          // _downloadFile(url, '$channelId.wav').then((_) {
          //   _createNotificationChannelFromUri(
          //       channelId, 'kucing', 'suara kucing');
          // });
        },
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");
          // _downloadFile('', 'kucing.wav').then((_) {});
        },
        onResume: (Map<String, dynamic> message) async {
          print("onResume: $message");
        },
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('token: $token');
    return Column(
      children: [
        RaisedButton(
          onPressed: () {
            try {
              apiService.getNotif().then((notifikasi) {
                notifikasi.forEach((notif) {
                  _downloadFile(notif.path, '${notif.title}.wav').then((_) {
                    print(mp3uri);
                    _createNotificationChannelFromUri(
                        notif.title, 'channel_name', 'channel_desc', mp3uri);
                  }).then((_) => print('sukses daftar channel'));
                  // _createNotificationChannelFromUri(
                  //         notif.title, 'notif_name', 'notif_desc')
                  //     .then((_) => print('sukses bikin channel'));
                });
              });
            } catch (e) {
              print(e);
            }
          },
          child: Icon(Icons.play_arrow),
        ),
        RaisedButton(
          onPressed: () {
            playSound(
                'file:///storage/emulated/0/Android/data/com.example.notifikasi/files/ayam.wav');
          },
          child: Text('Play'),
        ),
        Expanded(
          child: ListView(
            children: messages.map(buildMessage).toList(),
          ),
        ),
      ],
    );
  }

  Widget buildMessage(Pesan message) =>
      ListTile(title: Text(message.title), subtitle: Text(message.body));
}
