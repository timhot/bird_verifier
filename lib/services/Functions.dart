import 'package:flutter/material.dart';
import 'package:bird_verifier/services/CacophonyAPI.dart';
import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:bird_verifier/services/AudioHelper.dart';
import 'package:bird_verifier/services/LocalStorageAccess.dart';
import 'package:bird_verifier/services/predictions_database.dart';
import 'package:bird_verifier/model/prediction.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:super_easy_permissions/super_easy_permissions.dart';

import 'dart:io';

// import 'package:simple_permissions/simple_permissions.dart';

class Functions{

  static bool isDebugging = false;

  static Future<Prediction?> getNextUnVerifiedPrediction(Function setUserMessage) async {
    Prediction? nextUnverifiedPrediction = await PredictionsDatabase.instance
        .getNextUnVerifiedPrediction(setUserMessage);

    return nextUnverifiedPrediction;
  }


    static Future<void> playNextUnVerifiedPrediction(Prediction prediction, Function setUserMessage) async {

    Prediction? nextUnverifiedPrediction = await PredictionsDatabase.instance.getNextUnVerifiedPrediction(setUserMessage);

    // print("testing current verification value ${nextUnverifiedPrediction.verification}");

    int recordingId = nextUnverifiedPrediction!.recordingId;
    double startPosition = nextUnverifiedPrediction.begin_s;
    double endPosition = nextUnverifiedPrediction.end_s;
    double duration = endPosition - startPosition;


    String filePathAsString = await LocalStorageAccess.getLocalRecordingFilePathName(recordingId);

    if (FileSystemEntity.typeSync(filePathAsString) == FileSystemEntityType.notFound){
      String downloadFileJWTToken = await CacophonyAPI.getDownloadFileJWTToken(recordingId.toString());
      await CacophonyAPI.downloadARecording(recordingId, downloadFileJWTToken);
    }

    await AudioHelper.playPrediction(filePathAsString, startPosition, duration);




  }



  static void verifyRecording(Prediction currentPrediction) async{
    // Certainty factors taken from p75 of book 'Artificial Intelligence' 3rd Ed, by Michael Negnevitsky
    print("certaintyFactor is ${currentPrediction.verification}");

    int returnValue = await PredictionsDatabase.instance.update(currentPrediction);
    print("returnValue is $returnValue");

    if (returnValue == 1){ // Create tag on Cacophony server
      sendVerificationToCacophonyServer( currentPrediction);

    }

  }

  static void sendVerificationToCacophonyServer(Prediction verifiedPrediction) async{
    await CacophonyAPI.sendVerificationToCacophonyServer(verifiedPrediction);
  }

static double convertVerificationStringToConfidenceDouble(String verification){
    // Used p75 of the book 'Aritificial Intelligence - A Guide to Intelligent Systems' by Negnevitsky
    double confidence;
    switch (verification) {
      case 'definitely':
        confidence = 1.0;
        break;
      case 'almost_certainly':
        confidence = 0.8;
        break;
      case 'probably':
        confidence = 0.6;
        break;
      case 'maybe':
        confidence = 0.4;
        break;
      case 'unknown':
        confidence = 0;
        break;
      case 'maybe_not':
        confidence = -0.4;
        break;
      case 'probably_not':
        confidence = -0.6;
        break;
      case 'almost_certainly_not':
        confidence = -0.8;
        break;
      case 'definitely_not':
        confidence = -1.0;
        break;
      default:
        confidence = -99;
    }
    return confidence;

}


}