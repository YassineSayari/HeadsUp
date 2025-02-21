import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:headsup/pages/const/theme.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayPage extends StatefulWidget {
  final String topic;
  final List<String> mawdhou3;

  PlayPage({required this.topic, required this.mawdhou3});

  @override
  _PlayPageState createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  List<String> selectedAnimals = [];
  int currentIndex = 0;
  int score = 0;
  int totalLeans = 0;
  bool gameStarted = false;
  StreamSubscription? accelerometerSubscription;
  SharedPreferences? prefs;
  Random random = Random();
  Timer? timer;
  double selectedTime = 90.0;
  double selectedWordCount = 6.0;
  List<Player> players = [];
  bool showPlayButton = true;

  @override
  void initState() {
    super.initState();
    initSharedPreferences();
    loadPlayers();
  }

  void initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    loadPlayers();
  }

  void loadPlayers() {
    List<String>? playerNames = prefs?.getStringList('playerNames');
    if (playerNames != null) {
      setState(() {
        players = playerNames.map((name) => Player(name: name, score: 0)).toList();
      });
    }
  }

  void savePlayers() {
    List<String> playerNames = players.map((player) => player.name).toList();
    prefs?.setStringList('playerNames', playerNames);
  }

  void removePlayer(int index) {
    setState(() {
      players.removeAt(index);
      savePlayers();
    });
  }

  void onLean(bool isForward) {
    if (isForward) {
      setState(() {
        score++;
      });
    }
    totalLeans++;
    goToNextAnimal();
  }

  void goToNextAnimal() {
    if (currentIndex < selectedAnimals.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      stopGame();
    }
  }

  void listenToAccelerometer() {
    accelerometerSubscription = accelerometerEvents
        .throttleTime(const Duration(milliseconds: 450))
        .listen((event) {
      if (gameStarted) {
        if (event.z < -4.5) {
          onLean(true);
        } else if (event.z > 6.0) {
          onLean(false);
        }
      }
    });
  }

  void startGame() {
    widget.mawdhou3.shuffle();
    selectedAnimals = widget.mawdhou3.sublist(0, min(selectedWordCount.toInt(), widget.mawdhou3.length));
  }

  void startTimer() {
    const int maxGameDurationInSeconds = 300;
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        if (maxGameDurationInSeconds - t.tick <= 0) {
          stopGame();
        }
      });
    });
  }

  void stopGame() {
    accelerometerSubscription?.cancel();
    timer?.cancel();

    // Set back to portrait orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    int currentScore = score;
    int total = selectedAnimals.length;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text(
            'Your Score: $currentScore / $total\nTotal Leans: $totalLeans',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    setState(() {
      currentIndex = 0;
      score = 0;
      totalLeans = 0;
      gameStarted = false;
      showPlayButton = true;
      selectedAnimals.clear();
      savePlayers();
    });
  }

  Future<void> playGameForPlayer(int playerIndex) async {
    // Set to landscape orientation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    gameStarted = true;
    showPlayButton = false;
    startGame();
    startTimer();
    listenToAccelerometer();
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

  void addPlayer(String playerName) {
    setState(() {
      players.add(Player(name: playerName, score: score));
      savePlayers(); // Save players when a new player is added
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
      body: Stack(
        children: [
          Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (selectedAnimals.isNotEmpty)
                    Text(
                      ' ${selectedAnimals[currentIndex]}',
                      style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  SizedBox(height: 20),
                  Text(
                    'Time Left: ${selectedTime - (timer?.tick ?? 0)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  if (!gameStarted)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Number of Words: ${selectedWordCount.toInt()}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(width: 2),
                        RangeSlider(
                          values: RangeValues(1, selectedWordCount),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          onChanged: (values) {
                            setState(() {
                              selectedWordCount = values.end;
                            });
                          },
                        ),
                      ],
                    ),
                  SizedBox(height: 20),
                  if (!gameStarted)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Max Time: ${selectedTime.toInt()}s',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(width: 20),
                        RangeSlider(
                          values: RangeValues(30, selectedTime),
                          min: 30,
                          max: 300,
                          divisions: 270,
                          onChanged: (values) {
                            setState(() {
                              selectedTime = values.end;
                            });
                          },
                        ),
                      ],
                    ),
                  SizedBox(height: 20),
                  if (showPlayButton)
                    ElevatedButton(
                      onPressed: () {
                        //rotateToHorizontal();
                      },
                      child: Text('Play'),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 16,
            child: gameStarted
                ? Container() // Hide the add player button during the game
                : IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                showAddPlayerDialog();
              },
            ),
          ),
          Positioned(
            top: 450,
            right: 100,
            child: ElevatedButton(
              onPressed: () {
                resetScores();
              },
              child: Text('Reset Scores'),
            ),
          ),
          Positioned(
            top: 150,
            left: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!gameStarted)
                  for (int index = 0; index < players.length; index++)
                    Row(
                      children: [
                        Text(
                          '${players[index].name}: ${players[index].score}',
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(width: 30),
                        Container(
                          width: 40,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              removePlayer(index);
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            playGameForPlayer(index);
                          },
                          child: Text('Play $index'),
                        ),
                      ],
                    ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    accelerometerSubscription?.cancel();
    timer?.cancel();
    super.dispose();
  }
}

class Player {
  final String name;
  int score;

  Player({required this.name, required this.score});
}