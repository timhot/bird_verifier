import 'package:bird_verifier/services/Functions.dart';
import 'package:flutter/material.dart';
import 'package:bird_verifier/services/CacophonyAPI.dart';
import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:bird_verifier/services/AudioHelper.dart';
import 'package:bird_verifier/services/LocalStorageAccess.dart';
import 'package:bird_verifier/services/predictions_database.dart';
import 'package:bird_verifier/model/prediction.dart';
import 'package:intl/intl.dart';
// import 'package:bird_verifier/services/functions.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();


}

class _HomeState extends State<Home> {
  late Prediction? currentPrediction;
  TextEditingController _textFieldController = TextEditingController();

  String? localFilePath;
  String? localAudioCacheURI;
  String? userMessage = "";
  String? userMessageCurrentRecordingIdAndStartPosition = "Recording : ";
  String? userMessageCurrentRecordingDateTime = "When : ";
  String? userMessageCanYouHearA = "Can your hear a ? (Even in the background)";



final passwordTextFieldController = TextEditingController(); // https://flutter.dev/docs/cookbook/forms/retrieve-input

  AssetsAudioPlayer? assetsAudioPlayer;



@override
void dispose(){
  // Clean up the controller when the widget is dispose
  passwordTextFieldController.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style =
    ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

    return Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(

        child: ListView(
          children:<Widget>[

            ElevatedButton(
              style: style,
              onPressed: downloadRecordingsData,
              child: const Text('Download new predictions'),
            ),

            Text(
              '$userMessage',
              textScaleFactor: 1.5,
            ),


            ElevatedButton(
              style: style,
              onPressed: playNextUnVerified,
              child: const Text('Play (again)'),
            ),




            Text(
              '$userMessageCurrentRecordingIdAndStartPosition',
            ),
            Text(
              '$userMessageCurrentRecordingDateTime',
            ),

            Text(
                '$userMessageCanYouHearA',
              textScaleFactor: 1.4,
            ),


            TextButton(
                onPressed: () => verifyRecording("definitely"),
                style: TextButton.styleFrom(
                  primary: Colors.pink,
                  textStyle: TextStyle(
                    fontSize: 30,
                  ),
                ),
                child: const Text('Definitely')),

            TextButton(
                onPressed: () => verifyRecording("almost_certainly"),
                style: TextButton.styleFrom(
                  primary: Colors.pink,
                  textStyle: TextStyle(
                    fontSize: 30,
                  ),
                ),
                child: const Text('Almost certainly')),

            TextButton(
                onPressed: () => verifyRecording("probably"),
                style: TextButton.styleFrom(
                  primary: Colors.pink,
                  textStyle: TextStyle(
                    fontSize: 30,
                  ),
                ),
                child: const Text('Probably')),

            TextButton(
                onPressed: () => verifyRecording("maybe"),
                style: TextButton.styleFrom(
                  primary: Colors.pink,
                  textStyle: TextStyle(
                    fontSize: 30,
                  ),
                ),
                child: const Text('Maybe')),

            TextButton(
                onPressed: () => verifyRecording("unknown"),
                style: TextButton.styleFrom(
                  primary: Colors.pink,
                  textStyle: TextStyle(
                    fontSize: 30,
                  ),
                ),
                child: const Text('Unknown')),

            TextButton(
                onPressed: () => verifyRecording("maybe_not"),
                style: TextButton.styleFrom(
                  primary: Colors.pink,
                  textStyle: TextStyle(
                    fontSize: 30,
                  ),
                ),
                child: const Text('Maybe NOT')),

            TextButton(
                onPressed: () => verifyRecording("probably_not"),
                style: TextButton.styleFrom(
                  primary: Colors.pink,
                  textStyle: TextStyle(
                    fontSize: 30,
                  ),
                ),
                child: const Text('Probably NOT')),

            TextButton(
                onPressed: () => verifyRecording("almost_certainly_not"),
                style: TextButton.styleFrom(
                  primary: Colors.pink,
                  textStyle: TextStyle(
                    fontSize: 30,
                  ),
                ),
                child: const Text('Almost Certainly Not')),

            TextButton(
                onPressed: () => verifyRecording("definitely_not"),
                style: TextButton.styleFrom(
                  primary: Colors.pink,
                  textStyle: TextStyle(
                    fontSize: 30,
                  ),
                ),
                child: const Text('Definitely NOT')),



            TextButton(
                onPressed: resetCredentials,
                style: TextButton.styleFrom(
                  primary: Colors.pink,
                  textStyle: TextStyle(
                    fontSize: 30,
                  ),
                ),
                child: const Text('Forget username and password')),

]
        ),

      ),
    );
  }

  void downloadRecordingsData() async{

   await checkHaveCredentials();
   setUserMessage("Started to download model predictions - please wait");

  await CacophonyAPI.downloadRecordingsData(setUserMessage);
   playNextUnVerified();
  }

  void setUserMessage(String message){
    setState(() {
      userMessage = message;
    });
  }

  void playNextUnVerified() async {

    await checkHaveCredentials();

    // Functions.playNextUnVerifiedPrediction();

    currentPrediction = await Functions.getNextUnVerifiedPrediction(setUserMessage);
    if (currentPrediction == null){
      setUserMessage("No more predictions on phone");
      showAlertDialog(context, "Oops - No more predictions on phone", "You need to download some more :-)");
    }else {
      setState(() {
        userMessageCurrentRecordingIdAndStartPosition =
        "Recording: ${currentPrediction!
            .recordingId}, Start time: ${currentPrediction!
            .begin_s}, ${currentPrediction!.deviceName}";
        DateTime dateTime = currentPrediction!.recordingDateTime.toLocal();
        // var newFormat = DateFormat("yy-MM-dd");
        var newFormat = DateFormat("dd MMM yyyy hh:mm a");
        String dateTimeStr = newFormat.format(dateTime);

        // userMessageCurrentRecordingDateTime = "When: ${currentPrediction.recordingDateTime.toLocal()}";
        userMessageCurrentRecordingDateTime = "When: $dateTimeStr";
        userMessageCanYouHearA =
        "Can your hear a ${currentPrediction!.species} (Even in the background)";
      });

      await Functions.playNextUnVerifiedPrediction(currentPrediction!, setUserMessage);

      print("just played ${currentPrediction!.recordingId}");
    }
  }





  void locallyStoredPredictions() async {

    List<Prediction> allPredictions = await PredictionsDatabase.instance.readAllPredictions();

    for (var i = 0; i < allPredictions.length; i++) {
      Prediction prediction = allPredictions[i];
      print(prediction.species);

      print('species is ${prediction.species}, begin_s is ${prediction.begin_s}, end_s is ${prediction.end_s}, liklihood is ${prediction.liklihood}');


    }

  }


  void stop() {
    assetsAudioPlayer!.stop();
    assetsAudioPlayer = null;
  }



  // verifyRecording(int certaintyFactor)  {
  // print("lastRecordingId is $lastRecordingId");
  //   Functions.verifyRecording(certaintyFactor);
  // }

  verifyRecording(String verification)  {
    currentPrediction!.verification = verification;
    Functions.verifyRecording(currentPrediction!);

    playNextUnVerified();
  }

  showAlertDialog(BuildContext context, String alertTitle, String alertMessage) {
    // Create button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(alertTitle),
      content: Text(alertMessage),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }



  Future<void> _displayTextInputDialog(BuildContext context, String credential) async {
    String hintText = "Cacophony Server $credential";

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(

            title: Text('Enter your Cacophony $credential'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  if (credential == "password"){
                    LocalStorageAccess.saveCacophonyPassword(value);
                    hintText = "Cacophony Server password";
                  }else if (credential == "username"){
                    LocalStorageAccess.saveCacophonyUsername(value);
                  }

                });
              },
              controller: _textFieldController,
              decoration: InputDecoration(hintText: hintText),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('OK'),
                onPressed: () {

                  setState(() {
                    // codeDialog = valueText;
                    // print("valueText $valueText");
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }


   Future<void> checkHaveCredentials() async {

    String? username = await LocalStorageAccess.getCacophonyUsername();
    if (username == "empty") {
      _textFieldController.clear();
      await _displayTextInputDialog(context, "username");


    }

    String? password = await LocalStorageAccess.getCacophonyUserPassword();
    if (password == "empty") {
      _textFieldController.clear();
      await _displayTextInputDialog(context, "password");

    }

  }

  Future<void> resetCredentials() async {
    LocalStorageAccess.saveCacophonyPassword("empty");
    LocalStorageAccess.saveCacophonyUsername("empty");
  }



}


