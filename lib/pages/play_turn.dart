import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

class GamePage extends StatefulWidget {
  final int selectedWordCount;
  final int selectedTime;
  final List<String> mawdhou3; // List of words or animals

  const GamePage({
    Key? key,
    required this.selectedWordCount,
    required this.mawdhou3, required this.selectedTime,
  }) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int score = 0;
  int totalLeans = 0;
  int currentIndex = 0;
  bool gameStarted = false;
  bool showPlayButton = true;
  late List<String> selectedAnimals;
  late Timer timer;
  StreamSubscription? accelerometerSubscription;

  @override
  void dispose() {
    accelerometerSubscription?.cancel();
    timer.cancel();
    super.dispose();
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
    selectedAnimals = widget.mawdhou3.sublist(0, min(widget.selectedWordCount, widget.mawdhou3.length));
  }

  void startTimer() {
    const int maxGameDurationInSeconds = 300; // 5 minutes game duration
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
    timer.cancel();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

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
                savePlayerScore(currentScore); // Save the score after the game ends
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
    });
  }

  Future<void> savePlayerScore(int score) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get existing player scores as a list of strings
    List<String>? playerScoresStringList = prefs.getStringList('playerScores') ?? [];

    // Add the new score to the list (as a string)
    playerScoresStringList.add(score.toString());

    // Save the list of scores (as strings)
    await prefs.setStringList('playerScores', playerScoresStringList);
  }

  Future<List<int>> getPlayerScores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get the list of scores as strings
    List<String>? playerScoresStringList = prefs.getStringList('playerScores') ?? [];

    // Convert the list of strings back into a list of integers
    List<int> playerScores = playerScoresStringList.map((score) => int.parse(score)).toList();

    return playerScores;
  }

  Future<void> playGameForPlayer(int playerIndex) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Game Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showPlayButton)
              ElevatedButton(
                onPressed: () => playGameForPlayer(0),
                child: Text("Start Game"),
              ),
            if (!showPlayButton)
              Text(
                'Score: $score\nLeans: $totalLeans\nAnimal: ${selectedAnimals[currentIndex]}',
                style: TextStyle(fontSize: 24),
              ),
          ],
        ),
      ),
    );
  }
}
