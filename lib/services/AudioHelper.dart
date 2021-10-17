import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:bird_verifier/services/CacophonyAPI.dart';
import 'package:bird_verifier/services/LocalStorageAccess.dart';

class AudioHelper{

  static AssetsAudioPlayer? assetsAudioPlayer;

  static Future<void>playPrediction(String filePathAsString, double startPositionSeconds, double durationSeconds)  async {

    int startPositionMillSecondsInt = (startPositionSeconds * 1000).toInt();
    int durationMillSecondsInt = (durationSeconds * 1000).toInt();

    if (assetsAudioPlayer != null){
      return;
    }
    assetsAudioPlayer = AssetsAudioPlayer();

    await assetsAudioPlayer!.open(

      Audio.file(filePathAsString),
    );
    await assetsAudioPlayer!.seek(Duration(milliseconds: startPositionMillSecondsInt));

    assetsAudioPlayer!.play();

    await Future.delayed(Duration(milliseconds: durationMillSecondsInt)); // running of code pauses for 3 seconds
    stop();
  }

  static stop() {
    assetsAudioPlayer!.stop();
    assetsAudioPlayer = null;
  }

 static Future<void> seek() async {  // final assetsAudioPlayer = AssetsAudioPlayer();
    // assetsAudioPlayer.seekBy(Duration(seconds: 60));
    assetsAudioPlayer!.seek(Duration(seconds: 60));
  }

}