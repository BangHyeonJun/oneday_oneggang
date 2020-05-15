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

  double _volume = 100;
  bool _muted = false;
  bool _isPlayerReady = false;

  int index = 0;
  List<Map<String, String>> _ids = [
    {
      "title": "1일 1깡 교과서 (이거보고 따라하세요)",
      "artist": "비(Rain)",
      "music": "깡(GGANG)",
      "Publisher": "케비넷 [KBS청주]",
      "dropdownTitle": "뮤직뱅크 - 비",
      "url": "https://www.youtube.com/watch?v=hpI2A4RTvhs&t=186s"
    },
    {
      "title": "비 RAIN - 깡 GANG Official M/V",
      "artist": "비(Rain)",
      "music": "깡(GGANG)",
      "Publisher": "GENIE MUSIC",
      "dropdownTitle": "공식 뮤비",
      "url": "https://www.youtube.com/watch?v=xqFvYsy4wE4"
    },
  ];
  YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // showNotification();

    // 애드 몹
    FirebaseAdMob.instance
        .initialize(appId: "ca-app-pub-4278000043835062~6424902116");
    bannerAd
      ..load()
      ..show(
        anchorType: AnchorType.bottom,
      );

    // 유튜브
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(_ids[index]["url"]),
      flags: YoutubePlayerFlags(
        autoPlay: false,
        disableDragSeek: false,
        captionLanguage: "ko",
        loop: true,
        enableCaption: false,
        // forceHD: true,
      ),
    );

    // 테스트
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

    var title = "꾸러기 표정 비 ☔";
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

  void changeVideo(int idx) {
    var id = YoutubePlayer.convertUrlToId(_ids[idx]["url"]);

    _controller.load(id);
    _controller.mute();
    Future.delayed(const Duration(milliseconds: 1300), () {
      _controller.pause();
      _controller.unMute();
    });
  }

  // 테스트

  bool _value1 = false;
  bool _value2 = false;

  void _onChanged1(bool value) => setState(() => _value1 = value);
  void _onChanged2(bool value) => setState(() => _value2 = value);

  void onChangeDrobox(int idx) {
    setState(() => index = idx);
    changeVideo(idx);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // var mediaQuery = MediaQuery.of(context);

    return MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.black,
        ),
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.black,
                bottom: TabBar(
                  tabs: [
                    Tab(
                      child: Text(
                        "메인",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "설정",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                title: Text('Tabs Demo'),
              ),
              body: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 60),
                child: TabBarView(
                  children: [
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
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
                          Container(
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(14, 10, 14, 0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Center(
                                    child: DropdownButton<String>(
                                        // value: _ids[index]["dropdownTitle"],
                                        value: index.toString(),
                                        isExpanded: true,
                                        onChanged: (String string) =>
                                            onChangeDrobox(int.parse(string)),
                                        selectedItemBuilder:
                                            (BuildContext context) {
                                          return _ids.map<Widget>(
                                              (Map<String, String> item) {
                                            return Text(item["dropdownTitle"]);
                                          }).toList();
                                        },
                                        items:
                                            _ids.asMap().entries.map((entry) {
                                          int idx = entry.key;
                                          Map<String, String> val = entry.value;

                                          return DropdownMenuItem<String>(
                                            child: Text(val["dropdownTitle"]),
                                            value: idx.toString(),

                                            // child: Text("0"),
                                            // value: "0",
                                          );
                                        }).toList()),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        // 타이틀
                                        Text(
                                          "출처 : ",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromRGBO(
                                                  153, 153, 153, 1)),
                                        ),
                                        // 내용
                                        Flexible(
                                          child: Text(
                                            "${_ids[index]['url']}",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Color.fromRGBO(
                                                    153, 153, 153, 1)),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 4),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        // 타이틀
                                        Text(
                                          "제목 : ",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromRGBO(
                                                  153, 153, 153, 1)),
                                        ),
                                        // 내용
                                        Flexible(
                                          child: Text(
                                            "${_ids[index]['title']}",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Color.fromRGBO(
                                                    153, 153, 153, 1)),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 4),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        // 타이틀
                                        Text(
                                          "음악 : ",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromRGBO(
                                                  153, 153, 153, 1)),
                                        ),
                                        // 내용
                                        Flexible(
                                          child: Text(
                                            "${_ids[index]['artist']} - ${_ids[index]['music']}",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Color.fromRGBO(
                                                    153, 153, 153, 1)),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 4),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        // 타이틀
                                        Text(
                                          "게시자 : ",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromRGBO(
                                                  153, 153, 153, 1)),
                                        ),
                                        // 내용
                                        Flexible(
                                          child: Text(
                                            "${_ids[index]['Publisher']}",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Color.fromRGBO(
                                                    153, 153, 153, 1)),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                              child: Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: RaisedButton(
                                child: Text('개발자👨‍💻를 위해 한번만 눌러주세요💝',
                                    style: TextStyle(fontSize: 20)),
                                onPressed: () => showNotification(),
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),
                    Container(
                        color: Colors.white,
                        child: Column(children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: ListView(
                                padding: EdgeInsets.all(8),
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                          flex: 5,
                                          child: ListTile(
                                            leading: Icon(
                                              Icons.notifications,
                                              color: Colors.grey,
                                            ),
                                            title: Text("알람 설정"),
                                            subtitle:
                                                Text("하루 일 깡을 알람으로 받아보세요"),
                                          )),
                                      Expanded(
                                          flex: 1,
                                          child: Switch(
                                              value: _value1,
                                              onChanged: _onChanged1)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                          flex: 1,
                                          child: Icon(
                                            Icons.timer,
                                            color: Colors.grey,
                                          )),
                                      Expanded(
                                          flex: 4, child: Text("알람 시간 설정")),
                                      Expanded(
                                          flex: 1,
                                          child: Switch(
                                              value: _value1,
                                              onChanged: _onChanged1)),
                                    ],
                                  ),
                                ]),
                          ),
                          Container(
                              height: 60,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 60,
                                  child: RaisedButton(
                                    child: Text('개발자👨‍💻를 위해 한번만 눌러주세요💝',
                                        style: TextStyle(fontSize: 20)),
                                    onPressed: () => showNotification(),
                                  ),
                                ),
                              )),
                        ])),
                  ],
                ),
              )),
        ));
  }
}

////////////////////////////////////////////////////////////////////////////////////

// child: Column(
//   children: <Widget>[
//     // 유튜브 관련
//     Column(
//       children: <Widget>[
//         Center(
//           child: YoutubePlayer(
//             controller: _controller,
//             showVideoProgressIndicator: true,
//             bottomActions: [
//               CurrentPosition(),
//               ProgressBar(isExpanded: true),
//               FullScreenButton(),
//             ],
//           ),
//         ),
//         Text(
//           "출처 : 케비넷 [KBS청주]",
//           style: TextStyle(
//               fontSize: 12,
//               color: Color.fromRGBO(153, 153, 153, 1)),
//         )
//       ],
//     ),
//     Expanded(
//       child: ListView(
//         children: <Widget>[Text("테스트")],
//       ),
//     ),
//     SizedBox(
//         width: double.infinity,
//         height: 60.0,
//         child: RaisedButton(
//             child: Text('개발자👨‍💻를 위해 한번만 눌러주세요💝',
//                 style: TextStyle(fontSize: 16)),
//             onPressed: () => print('RaisedButton'))),
//     SizedBox(
//       height: 60.0,
//     )
//   ],
// ),
// Container(
//   height: 60.0,
//   child: Column(
//     children: <Widget>[
//       RaisedButton(
//         child: Text('RaisedButton', style: TextStyle(fontSize: 24)),
//         onPressed: () => print('RaisedButton'),
//       )
//     ],
//   ),
// )
// IconButton(
//   icon: Icon(Icons.add),
//   onPressed: showNotification,
// ),
