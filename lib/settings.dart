import 'package:flutter/material.dart';
import 'music_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _musicVolume = 0.5;
  bool _musicEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_game_nest_8.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Center(
                    child: Text(
                      "Music Settings",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Enable Music",
                        style: TextStyle(fontSize: 18),
                      ),
                      Switch(
                        value: _musicEnabled,
                        activeColor: Colors.blue,
                        onChanged: (value) {
                          setState(() {
                            _musicEnabled = value;
                          });

                          if (!value) {
                            MusicService.setVolume(0);
                          } else {
                            MusicService.setVolume(_musicVolume);
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Music Volume",
                    style: TextStyle(fontSize: 18),
                  ),

                  const SizedBox(height: 10),

                  Slider(
                    value: _musicVolume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    activeColor: Colors.blue,
                    label: "${(_musicVolume * 100).round()}%",
                    onChanged: _musicEnabled
                        ? (value) {
                      setState(() {
                        _musicVolume = value;
                      });

                      MusicService.setVolume(value);
                    }
                        : null,
                  ),

                  const SizedBox(height: 10),

                  Center(
                    child: Text(
                      "Volume: ${(_musicVolume * 100).round()}%",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.blue,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Back to Menu"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}