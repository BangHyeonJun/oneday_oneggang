import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:firebase_admob/firebase_admob.dart';

void main() => runApp(new MaterialApp(home: MainPage()));

class MainPage extends StatefulWidget {
  MyApp createState() => MyApp();
}

class MyApp extends State<MainPage> {
  // 공유 데이터
  SharedPreferences _prefs;

  // 알림 관련
  Time notificationTime = new Time();
  String strNotificationTime;
  bool isNotification = false;
  String notificationTitle = "꾸러기 표정 비 ☔";
  String notificationContents = "오늘도 하루 일 깡을 하실 시간입니다. 🕴🕺";

  // 동영상 관련
  YoutubePlayerController _controller;
  List<Map<String, String>> videoArr = [
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
  int currVideoIndex = 0;

  // 광고 관련

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

  // 앱 실행 시 처음 시작되는 부분
  @override
  void initState() {
    super.initState();

    initEvent();
  }

  void initEvent() async {
    // 동영상 초기화
    initVieoPlayer();

    // 광고 초기화
    // initBannerAdv();
    initRewardAdv();

    // 공유 데이터 초기화
    await initSharedData();

    // 공유데이터에서 필요한 아이템 가져오는 부분
    initSharedIsNotification();
    initSharedNotificationTime();

    // 알림 초기화
    initNotification();
    notificationEventForIsNotification();
  }

  // 공유 데이터 초기화
  Future<void> initSharedData() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 공유데이터에 알림이 존재하는지를 확인
  void initSharedNotificationTime() {
    int hour = _prefs.getInt('hour') ?? 19;
    int minute = _prefs.getInt('minute') ?? 0;
    int second = _prefs.getInt('second') ?? 0;

    notificationTime = Time(hour, minute, second);
  }

  // 공유 데이터에 Notification 설정 여부를 확인
  void initSharedIsNotification() {
    bool isNoti = _prefs.getBool('isNotification') ?? true;

    isNotification = isNoti;
  }

  // 공유 데이터에 notification 시간을 저장합니다.
  void setNotificationTime(int hour, int minute, int second) {
    _prefs.setInt("hour", hour);
    _prefs.setInt("minute", minute);
    _prefs.setInt("second", second);

    setState(() => notificationTime = Time(hour, minute, second));
  }

  // 공유 데이터에 Notification 설정 여부를 저장합니다.
  void seIstNotification(bool isNoti) {
    _prefs.setBool("isNotification", isNoti);

    isNotification = isNoti;
  }

  // notification 초기화
  void initNotification() async {
    WidgetsFlutterBinding.ensureInitialized();
  }

  // isNotification에 따라 알람 설정 작업
  void notificationEventForIsNotification() {
    print(isNotification);
    if (isNotification) {
      showNotification(
          notificationTime, notificationTitle, notificationContents);
    } else {
      removeAllNotification();
    }
  }

  // 모든 알림을 지워줍니다.
  void removeAllNotification() {
    FlutterLocalNotificationsPlugin().cancelAll();
  }

  // 알림을 세팅해 줍니다.
  Future<void> showNotification(
      Time time, String title, String contents) async {
    var initAndroidSetting =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initIosSetting = IOSInitializationSettings();
    var initSetting =
        InitializationSettings(initAndroidSetting, initIosSetting);
    await FlutterLocalNotificationsPlugin().initialize(initSetting);

    var android = AndroidNotificationDetails(
        'channelId', 'channelName', 'channelDescription');
    var iOS = IOSNotificationDetails();
    var platform = NotificationDetails(android, iOS);

    await FlutterLocalNotificationsPlugin()
        .showDailyAtTime(0, title, contents, time, platform);
  }

  // 베너 광고를 초기화 해줍니다.
  void initBannerAdv() {
    FirebaseAdMob.instance
        .initialize(appId: "ca-app-pub-4278000043835062~6424902116");
  }

  // 베너 광고를 실행시킵니다.
  void runBannerAdv() {
    bannerAd
      ..load()
      ..show(anchorType: AnchorType.bottom, anchorOffset: 0);
  }

  // 베너 광고를 사라지게 합니다.
  void hideBannerAdv() {
    bannerAd..dispose();
  }

  // 리워드 광고를 초기화 해줍니다.
  void initRewardAdv() {
    RewardedVideoAd.instance.load(
      adUnitId: RewardedVideoAd.testAdUnitId,
      targetingInfo: targetingInfo,
    );
  }

  void initRewardListener() {
    RewardedVideoAd.instance.listener =
        (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
      print("Rewarded Video Ad event $event");
      if (event == RewardedVideoAdEvent.rewarded) {
        showToastMsg("아싸~ 오늘은 포카칩이다. 🥔🥔🥔");
      }
    };
  }

  void runRewardAdv() {
    initRewardListener();
    RewardedVideoAd.instance.show();
  }

  // 토스트 메세지를 보여줍니다.
  void showToastMsg(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.cyan,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  // 동영상 플레이어를 초기화 해줍니다.
  void initVieoPlayer() {
    _controller = YoutubePlayerController(
      initialVideoId:
          YoutubePlayer.convertUrlToId(videoArr[currVideoIndex]["url"]),
      flags: YoutubePlayerFlags(
        autoPlay: false,
        disableDragSeek: false,
        captionLanguage: "ko",
        loop: true,
        enableCaption: false,
        // forceHD: true,
      ),
    )..addListener(youtubeVideoListener);
  }

  // 비디오 플레이어에서 어떤 이벤트 발생시 실행되는 함수
  void youtubeVideoListener() {
    if (_controller.value.isFullScreen) {
      // hideBannerAdv();
    } else {
      // runBannerAdv();
    }
  }

  // 드랍다운
  void changeVideo(int idx) {
    var id = YoutubePlayer.convertUrlToId(videoArr[idx]["url"]);

    _controller.load(id);
    _controller.mute();
    Future.delayed(const Duration(milliseconds: 1300), () {
      _controller.pause();
      _controller.unMute();
    });
  }

  // 드롭박스가 변경될 시 실행되어지는 함수
  void onChangeDrobox(int idx) {
    setState(() => currVideoIndex = idx);
    changeVideo(idx);
  }

  // 라디오 버튼
  void onChangeIsNotification(bool value) {
    setState(() => isNotification = value);

    seIstNotification(value);
    notificationEventForIsNotification();
  }

  // 알림 시간 픽커를 호출하는 함수
  void onClickSettingTime(BuildContext context) {
    DateTime now = DateTime.now();

    DatePicker.showTimePicker(context,
        showTitleActions: true, locale: LocaleType.ko, onChanged: (date) {
      print('change $date in time zone ' +
          date.timeZoneOffset.inHours.toString());
    }, onConfirm: (date) {
      int hour = date.hour;
      int minute = date.minute;
      int second = date.second;

      setNotificationTime(hour, minute, second);
      notificationEventForIsNotification();
    },
        currentTime: DateTime.utc(
            now.year,
            now.month,
            now.day,
            notificationTime.hour,
            notificationTime.minute,
            notificationTime.second));
  }

  // 시간을 문자열로 변경해 줍니다.
  String convertTime2String(Time time) {
    int hour = time.hour;
    int minute = time.minute;
    // int second = time.second;

    String result = "";

    // 시간 계산
    if (hour > 12) {
      result += "PM ";
      result += (hour - 12).toString() + ":";
    } else {
      result += "AM ";
      result += (hour).toString() + ":";
    }

    if (minute >= 10) {
      result += minute.toString();
    } else {
      result += "0" + minute.toString();
    }

    return result;
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
              body: Container(
                // Padding(
                // padding: EdgeInsets.fromLTRB(0, 0, 0, 60),
                child: TabBarView(
                  children: [
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: <Widget>[
                          Expanded(
                              flex: 1,
                              child: ListView(
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
                                      padding:
                                          EdgeInsets.fromLTRB(14, 10, 14, 0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Center(
                                            child: DropdownButton<String>(
                                                // value: videoArr[currVideoIndex]["dropdownTitle"],
                                                value:
                                                    currVideoIndex.toString(),
                                                isExpanded: true,
                                                onChanged: (String string) =>
                                                    onChangeDrobox(
                                                        int.parse(string)),
                                                selectedItemBuilder:
                                                    (BuildContext context) {
                                                  return videoArr.map<Widget>(
                                                      (Map<String, String>
                                                          item) {
                                                    return Text(
                                                        item["dropdownTitle"]);
                                                  }).toList();
                                                },
                                                items: videoArr
                                                    .asMap()
                                                    .entries
                                                    .map((entry) {
                                                  int idx = entry.key;
                                                  Map<String, String> val =
                                                      entry.value;

                                                  return DropdownMenuItem<
                                                      String>(
                                                    child: Text(
                                                        val["dropdownTitle"]),
                                                    value: idx.toString(),
                                                  );
                                                }).toList()),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 4, 0, 4),
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromRGBO(
                                                          153, 153, 153, 1)),
                                                ),
                                                // 내용
                                                Flexible(
                                                  child: Text(
                                                    "${videoArr[currVideoIndex]['url']}",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Color.fromRGBO(
                                                            153, 153, 153, 1)),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 4),
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromRGBO(
                                                          153, 153, 153, 1)),
                                                ),
                                                // 내용
                                                Flexible(
                                                  child: Text(
                                                    "${videoArr[currVideoIndex]['title']}",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Color.fromRGBO(
                                                            153, 153, 153, 1)),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 4),
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromRGBO(
                                                          153, 153, 153, 1)),
                                                ),
                                                // 내용
                                                Flexible(
                                                  child: Text(
                                                    "${videoArr[currVideoIndex]['artist']} - ${videoArr[currVideoIndex]['music']}",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Color.fromRGBO(
                                                            153, 153, 153, 1)),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 4),
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromRGBO(
                                                          153, 153, 153, 1)),
                                                ),
                                                // 내용
                                                Flexible(
                                                  child: Text(
                                                    "${videoArr[currVideoIndex]['Publisher']}",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Color.fromRGBO(
                                                            153, 153, 153, 1)),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                          Container(
                              height: 60,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 60,
                                  child: RaisedButton(
                                    color: Colors.amber,
                                    child: Text('개발자👨‍💻를 위해 한번만 눌러주세요💝',
                                        style: TextStyle(fontSize: 16)),
                                    onPressed: () => runRewardAdv(),
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
                            child:
                                ListView(padding: EdgeInsets.all(8), children: <
                                    Widget>[
                              Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                  //                   <--- left side
                                  color: Color.fromRGBO(0, 0, 0, 0.1),
                                  width: 1.0,
                                ))),
                                child: Row(
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
                                              Text("📫 하루 일 깡을 알람으로 받아보세요"),
                                        )),
                                    Expanded(
                                        flex: 1,
                                        child: Switch(
                                            value: isNotification,
                                            onChanged: onChangeIsNotification)),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                  //                   <--- left side
                                  color: Color.fromRGBO(0, 0, 0, 0.1),
                                  width: 1.0,
                                ))),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                        flex: 5,
                                        child: ListTile(
                                          enabled: isNotification,
                                          leading: Icon(
                                            Icons.timer,
                                            color: Colors.grey,
                                          ),
                                          title: Text("알람 시간 설정"),
                                          subtitle: Text("⏰ 알람 받을 시간을 알려주세요"),
                                        )),
                                    Expanded(
                                        flex: 1,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: InkWell(
                                            splashColor: Colors.grey,
                                            onTap: () => isNotification
                                                ? onClickSettingTime(context)
                                                : {},
                                            child: Container(
                                                alignment: Alignment.center,
                                                height: 60,
                                                child: AnimatedDefaultTextStyle(
                                                  duration: const Duration(
                                                      milliseconds: 250),
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: isNotification
                                                        ? Color.fromRGBO(
                                                            119, 136, 152, 1)
                                                        : Color.fromRGBO(
                                                            173, 181, 189, 0.5),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  child: Text(
                                                      convertTime2String(
                                                          notificationTime)),
                                                )),
                                          ),
                                        ))
                                  ],
                                ),
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
                                    color: Colors.amber,
                                    child: Text('개발자👨‍💻를 위해 한번만 눌러주세요💝',
                                        style: TextStyle(fontSize: 16)),
                                    onPressed: () => runRewardAdv(),
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
