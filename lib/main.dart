import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_admob/firebase_admob.dart';

void main() => runApp(MainPage());
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // notification
//   var initAndroidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
//   var initIosSetting = IOSInitializationSettings();
//   var initSetting = InitializationSettings(initAndroidSetting, initIosSetting);
//   await FlutterLocalNotificationsPlugin().initialize(initSetting);

//   runApp(MyApp());
// }

class MainPage extends StatefulWidget {
  MyApp createState() => MyApp();
}

class MyApp extends State<MainPage> {
  static MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>['flutter', 'firebase', 'admob'],
    testDevices: <String>[],
  );

  BannerAd bannerAd = BannerAd(
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.fullBanner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event is $event");
      });

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

  @override
  void initState() {
    super.initState();
    // showNotification();
    FirebaseAdMob.instance
        .initialize(appId: "ca-app-pub-4278000043835062~6424902116");
    bannerAd
      ..load()
      ..show(
        anchorType: AnchorType.bottom,
      );
  }

  Future<void> showNotification() async {
    WidgetsFlutterBinding.ensureInitialized();

    // notification
    var initAndroidSetting =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initIosSetting = IOSInitializationSettings();
    var initSetting =
        InitializationSettings(initAndroidSetting, initIosSetting);
    await FlutterLocalNotificationsPlugin().initialize(initSetting);

    var title = "재간둥이 비 ☔";
    var contents = "오늘도 하루 일 깡을 하실 시간입니다. 🕴🕺";

    var android = AndroidNotificationDetails(
        'channelId', 'channelName', 'channelDescription');
    var iOS = IOSNotificationDetails();
    var platform = NotificationDetails(android, iOS);

    var time = Time(17, 0, 0);

    await FlutterLocalNotificationsPlugin()
        .schedule(0, title, contents, DateTime.now(), platform);

    // await FlutterLocalNotificationsPlugin()
    //     .showDailyAtTime(0, title, contents, time, platform);
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
