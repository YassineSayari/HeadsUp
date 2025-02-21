import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:headsup/pages/const/theme.dart';
import 'package:headsup/pages/const/topics.dart';
import 'package:headsup/pages/load_players.dart';
import 'package:headsup/pages/play.dart';
import 'package:headsup/pages/playcard.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    setToPortraitMode();
  }

  void setToPortraitMode() {
    // Force portrait orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backGroundColor,
        centerTitle: true,
        title: Text(
          'Topics',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontFamily: AppTheme.fontName,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: AppColors.backGroundColor,
      body: ListView.builder(
        itemCount: (topics.length / 2).ceil(),
        itemBuilder: (context, index) {
          final firstIndex = index * 2;
          final secondIndex = index * 2 + 1;
          return Row(
            children: [
              Expanded(
                child: PlayCard(
                  topicImage: topicImages[topics.keys.elementAt(firstIndex)]!,
                  topic: topics.keys.elementAt(firstIndex),
                  onPressed: () => _play(topics.keys.elementAt(firstIndex)),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: secondIndex < topics.length
                    ? PlayCard(
                        topicImage: topicImages[topics.keys.elementAt(secondIndex)]!,
                        topic: topics.keys.elementAt(secondIndex),
                        onPressed: () => _play(topics.keys.elementAt(secondIndex)),
                      )
                    : SizedBox(),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoadPage(),
            ),
          );
        },
        child: Icon(Icons.snowmobile_sharp),
        backgroundColor: Color.fromARGB(255, 43, 199, 38),
      ),
    );
  }

  void _play(String topic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayPage(
          topic: topic,
          mawdhou3: topics[topic]!,
        ),
      ),
    );
  }
}
