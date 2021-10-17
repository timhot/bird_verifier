import 'package:csv/csv.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bird_verifier/services/AudioHelper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:bird_verifier/services/Functions.dart';

class LocalStorageAccess{

  static final storage = new FlutterSecureStorage(); // https://pub.dev/packages/flutter_secure_storage



  static var db;




  static Future<String> getLocalRecordingFilePathName(int recordingId) async {

    final directory = await getApplicationDocumentsDirectory();
    String pathAsString = directory.path;
    pathAsString = pathAsString + '/' + recordingId.toString() + '.m4a';
    print("pathAsString is $pathAsString");

    return pathAsString;

  }






  static Future<String> getCacophonyUserPassword() async {
    String? value = await storage.read(key: "cacophonyUserPassword");
    if (value == null) {
      return "empty";
    } else {
      return value;
    }
  }

  static Future<void> saveCacophonyPassword(String password) async {
    await storage.write(key: "cacophonyUserPassword", value: password);
  }

  static Future<void> saveCacophonyUsername(String username) async {
    await storage.write(key: "cacophonyUserUsername", value: username);
  }

  static Future<String> getCacophonyUsername() async {
    String? value = await storage.read(key: "cacophonyUserUsername");
    if (value == null) {
      return "empty";
    } else {
      return value;
    }
  }

  static Future<void> saveDeviceId(String deviceName, String deviceId) async {
    // Functions.checkStoragePermission();
    await storage.write(key: deviceName, value: deviceId);
  }

  static Future<String> getDeviceId(String deviceName) async {
    // Functions.checkStoragePermission();
    String? value = await storage.read(key: deviceName);
    if (value == null) {
      return "empty";
    } else {
      return value;
    }
  }



  static Future <void> saveRecordingResponse(int recordingId, var response) async {
    // Functions.checkStoragePermission();

    late final file;


    String pathAsString =await getLocalRecordingFilePathName(recordingId);

    file = File(pathAsString);


    var sink = file.openWrite();
    await response.stream.pipe(sink);
    sink.close();

    print("Saved $recordingId file");



  }



}