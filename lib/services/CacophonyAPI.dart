import 'dart:convert';
import 'dart:io';
import 'package:bird_verifier/services/AudioHelper.dart';
import 'package:bird_verifier/services/Functions.dart';
import 'package:bird_verifier/services/LocalStorageAccess.dart';
import 'package:bird_verifier/services/predictions_database.dart';
import 'package:bird_verifier/model/prediction.dart';
import 'package:bird_verifier/Pages/home.dart';
import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';



import 'package:http/http.dart';
// import 'package:path_provider/path_provider.dart';



class CacophonyAPI {
  // Uncomment either the production or test url
  static final String SERVER_HOST = "api.cacophony.org.nz";

  // final String SERVER_HOST = "api-test.cacophony.org.nz";

  static final String SCHEME = "https";

  static final String AUTHENTICATE_USER_END_POINT = "/authenticate_user/";
  static final String TEMPORARY_JWT_END_POINT = "/token";
  static final String RECORDINGS_GET_A_RECORDING_END_POINT = "/api/v1/recordings/";
  static final String RECORDINGS_GET_DATA = "/api/v1/recordings/";
  static final String GET_LIST_OF_DEVICES_END_POINT = "/api/v1/devices";
  static final String GET_A_FILE_USING_A_JWT_END_POINT = "/api/v1/signedUrl";
  static final String GENERATE_REPORT_FOR_A_SET_OF_RECORDINGS_END_POINT = "/api/v1/recordings/report";
  static final String DEVICE_GET_A_SINGLE_DEVICE = "/api/v1/devices/";
  static final String TAG = "/api/v1/tags";

  static late String tagType;

  static late String devicesAsJsonString;
  static String cacophonyUserToken = "empty";

  // static String downloadFileJWTToken = "empty";

  // CacophonyAPI({required this.tagType});

  static Future<void> authenticateAUser() async {
    try {
      String urlString =
          SCHEME + "://" + SERVER_HOST + AUTHENTICATE_USER_END_POINT;
      // https://pub.dev/packages/http
      String password = await LocalStorageAccess.getCacophonyUserPassword();
      String username = await LocalStorageAccess.getCacophonyUsername();
      var response = await post(Uri.parse(urlString),body: {'username': username, 'password': password});

      // testing in Postman https://morioh.com/p/4da5d921c827
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 401) {
        await LocalStorageAccess.saveCacophonyPassword("empty");
        return;
      }

      final responseJson = jsonDecode(response.body);
      cacophonyUserToken = responseJson["token"];
    } catch (e) {
      print('$e');
    }
  }

  static Future<String> getDeviceId(String deviceName) async {
    String deviceId = await LocalStorageAccess.getDeviceId(deviceName);

    if (deviceId == "empty"){
      // Haven't yet got this one from server, so download all device ids
      await getListOfDevices();
      deviceId = await LocalStorageAccess.getDeviceId(deviceName);

      return deviceId;
    }else{
      return deviceId;
    }


  }

  static Future <void> getListOfDevices() async {
    try {
      if (cacophonyUserToken == "empty") {
        await authenticateAUser();
        print("after authentication $cacophonyUserToken");
      }

      // https://www.tutorialspoint.com/dart_programming/dart_programming_map.htm

      var headers = {'Authorization': '$cacophonyUserToken'};

      String urlString =
          SCHEME + "://" + SERVER_HOST + GET_LIST_OF_DEVICES_END_POINT;
      // https://pub.dev/packages/http

      var request = Request('GET', Uri.parse(urlString));

      request.headers.addAll(headers);

      StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        devicesAsJsonString = await response.stream.bytesToString();
        print("devicesAsJsonString $devicesAsJsonString");

        Map responseMap = jsonDecode(devicesAsJsonString);

        var devices = responseMap['devices'];
        print("devices $devices");

        var rows = responseMap['devices']['rows'];
        print("rows $rows");


        for (var i = 0; i < rows.length; i++) {
          var item = rows[i];
          print("item: $item");

          var deviceName = item['devicename'];
          print("deviceName: $deviceName");

          var deviceId = item['id'];
          print("deviceId: $deviceId");

          LocalStorageAccess.saveDeviceId(deviceName, deviceId.toString());
        }




      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      print('$e');
    }
  }



  static Future<void> downloadARecording(int recordingId, String downloadFileJWTToken) async {
    var client = Client();
    try {
      String urlString =
          SCHEME + "://" + SERVER_HOST + GET_A_FILE_USING_A_JWT_END_POINT;

      var request =
      Request('GET', Uri.parse(urlString + '?jwt=' + downloadFileJWTToken));

      // var client = Client();
      var response = await client.send(request);

      // Save response to file

      await LocalStorageAccess.saveRecordingResponse(recordingId, response);


    } catch (e) {
      print('$e');
    }finally{
      client.close();
    }
  }





  static Future <void> getDeviceDetails() async {
    try {

      getListOfDevices();


      if (cacophonyUserToken == "empty") {
        await authenticateAUser();
        print("after authentication $cacophonyUserToken");
      }

      // https://www.tutorialspoint.com/dart_programming/dart_programming_map.htm

      var headers = {'Authorization': '$cacophonyUserToken'};

      String urlString = SCHEME + "://" + SERVER_HOST + DEVICE_GET_A_SINGLE_DEVICE;
      String deviceName = "hammond_park_v6";
      urlString = urlString + deviceName;

      print(urlString);

      var request = Request('GET', Uri.parse(urlString));

      request.headers.addAll(headers);

      StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        devicesAsJsonString = await response.stream.bytesToString();
        print("devicesAsJsonString $devicesAsJsonString");
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      print('$e');
    }
  }


  static Future <Map> downloadRecordingsDataUsingOffset(int offset, int startAtRecordingId, Function setUserMessage) async {
    if (Functions.isDebugging){
      setUserMessage("5a");
    }


    var returnValues = new Map();

    try {
      if (cacophonyUserToken == "empty") {
        await authenticateAUser();

      }
      if (Functions.isDebugging){
        setUserMessage("5b");
      }

      // https://www.tutorialspoint.com/dart_programming/dart_programming_map.htm

      var headers = {'Authorization': '$cacophonyUserToken'};

      String urlString = SCHEME + "://" + SERVER_HOST + RECORDINGS_GET_DATA;



      var request = Request('GET', Uri.parse(urlString + '?where={"type":"audio", "additionalMetadata.analysis.species_identify_version": "2021-02-01" , "id": {"\$gt":$startAtRecordingId}}&limit=300&order=[["id", "ASC"]]&offset=$offset'));

      request.headers.addAll(headers);

      StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        if (Functions.isDebugging){
          setUserMessage("5c");
        }

        String responseString = await response.stream.bytesToString();
        Map responseMap = jsonDecode(responseString);

        var count = responseMap['count'];
        print('There are $count new recordings to download');
        var rows = responseMap['rows'];
        var countOfRowsDownloaded = rows.length;

        int countOfDownloadedPredictions = 0;

        for (var i = 0; i < rows.length; i++) {


          var item = rows[i];

          var recordingId = item['id'];
          var type = item['type'];
          var recordingDateTimeStr = item['recordingDateTime'];
          DateTime recordingDateTime = DateTime.parse(recordingDateTimeStr);

          String deviceName = item['Device']['devicename'];
          int deviceId = item['Device']['id'];


          var additionalMetadata = item['additionalMetadata'];
          if (additionalMetadata == null){
            continue;
          }


          var species_identify = item['additionalMetadata']['analysis']['species_identify'];
          if (species_identify == null){
            continue;
          }


          for (var i = 0; i < species_identify.length; i++) {
            countOfDownloadedPredictions++;
            var item = species_identify[i];

            var begin_s = item['begin_s'];
            double begin_s_dbl = begin_s + .0;

            var end_s = item['end_s'];
            double end_s_dbl = end_s + .0;

            String species = item['species'];
            var liklihood = item['liklihood']; // liklihood is how certain/confident the model is of its prediction
            double liklihood_dbl = liklihood + .0;


            // Save into local database
             Prediction predictionToSave = new Prediction(recordingId: recordingId, species: species, begin_s: begin_s_dbl, end_s: end_s_dbl, liklihood: liklihood_dbl, type: type, recordingDateTime: recordingDateTime, deviceName: deviceName, deviceId: deviceId, downloadFileJWTToken: "abc");
            Prediction returnedPrediction = await PredictionsDatabase.instance.create(predictionToSave);

          }
          setUserMessage("Downloaded $countOfDownloadedPredictions predictions");
        }

        returnValues['countOfRowsDownloaded'] = countOfRowsDownloaded;
        returnValues['countOfDownloadedPredictions'] = countOfDownloadedPredictions;

        return returnValues;

      }
      else {

        returnValues['countOfRowsReturned'] = 0;
        returnValues['countOfDownloadedPredictions'] = 0;
        return returnValues;
      }

    } catch (e) {
      print('$e');
      returnValues['countOfRowsReturned'] = 0;
      returnValues['countOfDownloadedPredictions'] = 0;
      return returnValues;
    }
  }



  static Future <void> downloadRecordingsData(Function setUserMessage) async {
    if (Functions.isDebugging){
      setUserMessage("1");
    }

    try {
      int offset = 0;
      int pageSize = 300;
      int startAtRecordingId = 860116;
      int countOfRowsDownloaded = 0;
      int totalCountOfRowsDownloaded = 0;
      int totalCountOfPredictions = 0;

      try {
        // Get the recording Id of the last one in the local database
        // Note, this will mean that if the last recordings didn't have any predictions,
        // their data will be downloaded again - which is good as perhaps the model
        // hadn't been run over them before
        if (Functions.isDebugging){
          setUserMessage("2");
        }

        startAtRecordingId = await PredictionsDatabase.instance.getMaxRecordingId();
        if (Functions.isDebugging){
          setUserMessage("3");
        }
      }catch (e){
        print("First time, no database");
        if (Functions.isDebugging){
          setUserMessage("4");
        }
        // setUserMessage("Press Download again");
      }

      while (true && totalCountOfPredictions < 30) {
        if (Functions.isDebugging){
          setUserMessage("5");
        }
        // numberOfRowsDownloaded = await downloadRecordingsDataUsingOffset(offset, startAtRecordingId);
        Map  returnValues = await downloadRecordingsDataUsingOffset(offset, startAtRecordingId, setUserMessage);

        countOfRowsDownloaded = returnValues['countOfRowsDownloaded'];

        setUserMessage("Have downloaded $totalCountOfPredictions new predictions so far....");
        if (countOfRowsDownloaded == 0){
          break;
        }
        totalCountOfRowsDownloaded += countOfRowsDownloaded;
        // print("countOfRowsDownloaded $countOfRowsDownloaded");
        // print("totalCountOfRowsDownloaded $totalCountOfRowsDownloaded");

        int countOfDownloadedPredictions = returnValues['countOfDownloadedPredictions'];
        totalCountOfPredictions += countOfDownloadedPredictions;
        // print("countOfDownloadedPredictions $countOfDownloadedPredictions");
        // print("totalCountOfPredictions $totalCountOfPredictions");


        offset+=pageSize;
        // print("offset $offset");
      }
      // print("Finished downloading predictions");
      setUserMessage("Finished downloading $totalCountOfPredictions new predictions");


    } catch (e) {
      print('$e');
    }
  }

static Future <String> getDownloadFileJWTToken(String recordingId) async{
  late String downloadFileJWTToken;
  print('About to get information for recordingId $recordingId');
  try {
    if (cacophonyUserToken == "empty") {
      await authenticateAUser();
      // print("after authentication $cacophonyUserToken");
    }

    String urlString = SCHEME +
        "://" +
        SERVER_HOST +
        RECORDINGS_GET_A_RECORDING_END_POINT +
        recordingId;

    var headers = {'Authorization': cacophonyUserToken};
    var request = Request('GET', Uri.parse(urlString));

    request.headers.addAll(headers);

    StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      // String responseString = await response.stream.bytesToString();
      String responseString = await response.stream.bytesToString();
      // print(responseString);

      print("");
      print("");

      Map responseMap = jsonDecode(responseString);
      downloadFileJWTToken = responseMap['downloadFileJWT'];


    } else {
      print(response.reasonPhrase);
    }
  } catch (e) {
    print('$e');
  }
  return downloadFileJWTToken;
}

  static Future <void> sendVerificationToCacophonyServer(Prediction verifiedPrediction) async {
    String what = verifiedPrediction.species;
    // what = "tag_verification_$what $verification";
    print(what);
    int recordingId = verifiedPrediction.recordingId;
    print("recordingId is $recordingId");
    double startTime = verifiedPrediction.begin_s;
    double endTime = verifiedPrediction.end_s;
    double duration = endTime - startTime;
    double likihood = verifiedPrediction.liklihood;
    print("likihood is $likihood");
    String? verification = verifiedPrediction.verification;
    double confidence = Functions.convertVerificationStringToConfidenceDouble(verification!);
    print("verification is $verification");
    print("confidence is $confidence");
    what = "tag_verification_$what $verification";


    try {
      print(
          "About to send confidence to server $verifiedPrediction.confidence");


        if (cacophonyUserToken == "empty") {
          await authenticateAUser();
          // print("after authentication $cacophonyUserToken");
        }


      var headers = {
        'Authorization': '$cacophonyUserToken',
        'Content-Type': 'application/x-www-form-urlencoded'
      };

      String urlString = SCHEME + "://" + SERVER_HOST + TAG;


      // var request = Request('POST', Uri.parse('https://api.cacophony.org.nz/api/v1/tags'));
      var request = Request('POST', Uri.parse(urlString));
      // request.bodyFields = {
      //   'recordingId': '938712',
      //   'tag': '{"what" : "tim_test_morepork2" , "confidence" : 0.9 ,  "startTime" : 5.1 , "duration" : 3.0}'
      // };

      request.bodyFields = {
        'recordingId': '$recordingId',
        'tag': '{"what" : "$what" , "confidence" : $confidence ,  "startTime" : $startTime , "duration" : $duration}'
      };

      request.headers.addAll(headers);

      StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
      }
      else {
        print(response.reasonPhrase);
      }



    } catch (e) {
      print('$e');
    }
  }

}
