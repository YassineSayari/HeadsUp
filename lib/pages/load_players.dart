import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class LoadPage extends StatefulWidget {
  const LoadPage({Key? key}) : super(key: key);

  @override
  State<LoadPage> createState() => _LoadPageState();
}

class _LoadPageState extends State<LoadPage> {
  List<Player> players = [];
  int selectedWordCount=0;
  int selectedTime=30;

  @override
  void initState() {
    super.initState();
    initSharedPreferences();
  }

  void initSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? playerNames = prefs.getStringList('playerNames');
    List<String>? playerImages = prefs.getStringList('playerImages');
    if (playerNames != null) {
      setState(() {
        players = List.generate(
          playerNames.length,
          (index) => Player(
            name: playerNames[index],
            score: 0,
            imagePath: playerImages?[index],
          ),
        );
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
    List<String> playerImages = players.map((player) => player.imagePath ?? '').toList();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('playerNames', playerNames);
    await prefs.setStringList('playerImages', playerImages);
  }

  void removePlayer(int index) {
    setState(() {
      players.removeAt(index);
      savePlayers();
    });
  }

  Future<void> updatePlayerImage(int index) async {
    // Request camera permission
    var status = await Permission.camera.request();
    if (status.isGranted) {
      final ImagePicker _picker = ImagePicker();
      try {
        final XFile? image = await _picker.pickImage(source: ImageSource.camera);
        
        if (image != null) {
          setState(() {
            players[index].imagePath = image.path;
            savePlayers();
          });
        }
      } catch (e) {
        print('Error picking image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    } else {
      print('Camera permission denied');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera permission is required to take a selfie')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 48, 74, 142),
      appBar: AppBar(
        title: Text(
          "Add Players",
          style: TextStyle(fontFamily: 'YourFontName', fontSize: 45, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color.fromARGB(255, 48, 74, 142),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Text(
                    'Choose Max Words',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.minimize_rounded, color: Colors.white, size: 30),
                      onPressed: () {
                        setState(() {
                        selectedWordCount -= 1;
                         });
                      },
                    ),
                    Text(
                    ' ${selectedWordCount.toInt()}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    IconButton(
                        icon: Icon(Icons.add, color: Colors.white, size: 30),
                        onPressed: () {
                          setState(() {
                        selectedWordCount += 1;
                         });
                        },
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Text(
                    'Select Max Time',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.minimize_rounded, color: Colors.white, size: 30),
                      onPressed: () {
                        setState(() {
                        selectedTime -= 1;
                         });
                      },
                    ),
                    Text(
                    ' ${selectedTime.toInt()}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    IconButton(
                        icon: Icon(Icons.add, color: Colors.white, size: 30),
                        onPressed: () {
                              setState(() {
                        selectedTime += 1;
                         });
                        },
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.60,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: players.length + 1,
              itemBuilder: (context, index) {
                if (index == players.length) {
                  return AddPlayerCard(onTap: showAddPlayerDialog);
                }
                return PlayerCard(
                  player: players[index],
                  onRemove: () => removePlayer(index),
                  onUpdateImage: updatePlayerImage,
                  index: index,
                );
              },
            ),
          ),
          SizedBox(height: 10),
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

class Player {
  final String name;
  int score;
  String? imagePath;

  Player({required this.name, this.score = 0, this.imagePath});
}

class PlayerCard extends StatelessWidget {
  final Player player;
  final VoidCallback onRemove;
  final Function(int) onUpdateImage;
  final int index;

  const PlayerCard({
    Key? key,
    required this.player,
    required this.onRemove,
    required this.onUpdateImage,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              GestureDetector(
                onTap: () => onUpdateImage(index),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: player.imagePath != null && player.imagePath!.isNotEmpty
                      ? FileImage(File(player.imagePath!))
                      : AssetImage('assets/images/default_image.png') as ImageProvider,
                ),
              ),
              SizedBox(height: 5),
              Text(
                player.name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(
                    'Score: ',
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  ),
                  Text(
                    '${player.score}',
                    style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ),      
              SizedBox(height: 5),
              ElevatedButton(
                onPressed: () {
                  // Implement your action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 40),
                ),
                child: Text(
                  "Play",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
           Positioned(
                top: -15,
                right: -5,
                child: IconButton(
                  icon: Icon(Icons.minimize_rounded, color: Colors.white, size: 30),
                  onPressed: () {
                    onRemove();
                  },
                ),
              ),
        ],
      ),
    );
  }
}

class AddPlayerCard extends StatelessWidget {
  final VoidCallback onTap;

  const AddPlayerCard({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 60,
                color: Colors.blue,
              ),
              SizedBox(height: 8),
              Text(
                'Add Player',
                style: TextStyle(fontSize: 18, color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

