import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

// void main() => runApp(MyApp());
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // notification
  var initAndroidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
  var initIosSetting = IOSInitializationSettings();
  var initSetting = InitializationSettings(initAndroidSetting, initIosSetting);
  await FlutterLocalNotificationsPlugin().initialize(initSetting);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  YoutubePlayerController _controller = YoutubePlayerController(
    initialVideoId: "hpI2A4RTvhs",
    flags: YoutubePlayerFlags(
      autoPlay: false,
      disableDragSeek: false,
      captionLanguage: "ko",
      loop: true,
      enableCaption: false,
      // forceHD: true,
    ),
  );

  Future<void> showNotification() async {
    setNotificatoinSchedule();

    var title = "하루 일 깡";
    var contents = "아직 하루 일 깡을 하지 않았습니다.";

    var android = AndroidNotificationDetails(
        'channelId', 'channelName', 'channelDescription');
    var iOS = IOSNotificationDetails();
    var platform = NotificationDetails(android, iOS);

    final prefs = await SharedPreferences.getInstance();
    final counter = prefs.getString('schedule') ?? '2020-05-15 17:55:00';

    await FlutterLocalNotificationsPlugin()
        .schedule(0, title, contents, DateTime.parse(counter), platform);
  }

  void setNotificatoinSchedule() async {
    // obtain shared preferences
    final prefs = await SharedPreferences.getInstance();

    // set value
    prefs.setString('schedule', '2020-05-15 18:10:00');
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '하루 일 깡',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("하루 일 깡"),
        ),
        body: Column(
          children: <Widget>[
            Center(
              child: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                bottomActions: [
                  CurrentPosition(),
                  ProgressBar(isExpanded: true),
                  FullScreenButton(),
                ],
              ),
            ),
            Center(
              child: Text("출처 : 케비넷 [KBS청주]"),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: showNotification,
            ),
          ],
        ),
      ),
    );
  }
}
