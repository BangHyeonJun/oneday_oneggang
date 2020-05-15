import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  YoutubePlayerController _controller = YoutubePlayerController(
    initialVideoId: "hpI2A4RTvhs",
    flags: YoutubePlayerFlags(
      autoPlay: false,
      disableDragSeek: true,
      captionLanguage: "ko",
      loop: true,
      // forceHD: true,
    ),
  );

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
              child: Text("Hello World"),
            )
          ],
        ),
      ),
    );
  }
}
