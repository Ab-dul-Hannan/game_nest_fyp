import 'package:flutter/widgets.dart';
import 'package:audioplayers/audioplayers.dart';

class MusicService with WidgetsBindingObserver {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;

    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(0.5);
    await _player.play(AssetSource('audio/music_gamenest_bg.mp3'));

    WidgetsBinding.instance.addObserver(_AppLifecycleHandler(_player));

    _isInitialized = true;
  }

  static Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  static Future<void> mute(bool isMuted) async {
    if (isMuted) {
      await _player.setVolume(0);
    }
  }
}

class _AppLifecycleHandler extends WidgetsBindingObserver {
  final AudioPlayer player;

  _AppLifecycleHandler(this.player);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      player.pause();
    } else if (state == AppLifecycleState.resumed) {
      player.resume();
    }
  }
}