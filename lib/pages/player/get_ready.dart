import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:headsup/pages/const/theme.dart';
import 'package:headsup/pages/play.dart';
import 'package:headsup/pages/player/player_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadyPage extends StatefulWidget {
  const ReadyPage({super.key});

  @override
  State<ReadyPage> createState() => _ReadyPageState();
}

class _ReadyPageState extends State<ReadyPage> {
    double selectedTime = 90.0; // Initial time
  double selectedWordCount = 6.0; // Initial word count
  List<Player> players = [];

    @override
  void initState() {
    super.initState();
    initSharedPreferences(); // Initialize SharedPreferences
  }
    void initSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? playerNames = prefs.getStringList('playerNames');
    if (playerNames != null) {
      setState(() {
        players = playerNames.map((name) => Player(name: name, score: 0)).toList();
      });
    }
  }
    void addPlayer(String playerName) {
    setState(() {
      players.add(Player(name: playerName, score: 0));
      savePlayers(); 
    });
  }
    Future<void> savePlayers() async {
    List<String> playerNames = players.map((player) => player.name).toList();
        SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('playerNames', playerNames);
  }

    void removePlayer(int index) {
    setState(() {
      players.removeAt(index);
      savePlayers(); // Save updated players list
    });
  }
    void resetScores() {
    setState(() {
      for (var player in players) {
        player.score = 0;
      }
      savePlayers(); // Save the updated scores
    });
  }


  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.backGroundColor,
    appBar: AppBar(
      title: Text("Play",style: TextStyle(fontFamily: AppTheme.fontName,fontSize: 45,fontWeight: FontWeight.w600),),
      backgroundColor: AppColors.backGroundColor,
      centerTitle: true,
    ),
    body: Column(
      children: [
      SizedBox(height: 20),
        Container(
          height: 450,
          child: Expanded(
            child: ListView.builder(
              itemCount: players.length,
              //physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    PlayerContainer(
                      name: players[index].name,
                      score: players[index].score,
                    ),
                    Stack(
                      children: [
                         Align(
                              alignment: Alignment.centerRight,
                              child:Image.asset("assets/images/rb_3542.png",
                                height: 50.h,
                                width: 50.w,
                                fit:BoxFit.cover,
                                ),
                              
                            ),
                        IconButton(
                          onPressed: () {
                            removePlayer(index);
                          },
                          icon: Icon(
                            Icons.play_arrow,
                            size: AppTheme.removeIconSize.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    ),
  );
}


  Future<void> showAddPlayerDialog() async {
    TextEditingController playerNameController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Player'),
          content: TextField(
            controller: playerNameController,
            decoration: InputDecoration(labelText: 'Player Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String playerName = playerNameController.text;
                if (playerName.isNotEmpty) {
                  addPlayer(playerName);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}