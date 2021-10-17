
// https://www.youtube.com/watch?v=UpKrhZ0Hppk

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:bird_verifier/model/prediction.dart';

class PredictionsDatabase{
  static final String databaseName = 'predictions_db7.db';

  static final PredictionsDatabase instance = PredictionsDatabase.init();

  static Database? _database;

  PredictionsDatabase.init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB(databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);

  }

  Future _createDB(Database db, int version) async{
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final textTypeNullAllowed = 'TEXT';
    final integerType = 'INTEGER NOT NULL';
    final realType = 'REAL NOT NULL';

    await db.execute('''
    CREATE TABLE $tablePredictions(
     ${PredictionFields.id} $idType,
     ${PredictionFields.recordingId} $integerType,
     ${PredictionFields.species} $textType,
     ${PredictionFields.begin_s} $realType,     
     ${PredictionFields.end_s} $realType,     
     ${PredictionFields.liklihood} $realType,
     ${PredictionFields.type} $textType,
     ${PredictionFields.recordingDateTime} $textType,
     ${PredictionFields.deviceName} $textType,
     ${PredictionFields.deviceId} $integerType,
     ${PredictionFields.downloadFileJWTToken} $textType,
     ${PredictionFields.verification} $textTypeNullAllowed
     )      
    ''');
  }

  Future<Prediction> create(Prediction prediction) async {
    final db = await instance.database;
    try {
      final id = await db.insert(tablePredictions, prediction.toJson());
      return prediction.copy(id: id);
    }catch (e) {
      print('$e');

      return prediction.copy(id: -1);
    }
  }

  Future<Prediction> readPrediction(int id) async {
    final db = await instance.database;
    print("tim was here");

    final maps = await db.query(
      tablePredictions,
      columns: PredictionFields.values,
      where: '${PredictionFields.id} = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty){
      return Prediction.fromJson(maps.first);
    }else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Prediction>> readAllPredictions() async {
    final db = await instance.database;

    final orderBy = '${PredictionFields.recordingId} ASC';


    final result = await db.query(tablePredictions, orderBy: orderBy);

    return result.map((json) => Prediction.fromJson(json)).toList();
  }


  Future<Prediction?> getNextUnVerifiedPrediction(Function setUserMessage) async {
    final db = await instance.database;

    final maps = await db.query(
      tablePredictions,
      columns: PredictionFields.values,
      where: '${PredictionFields.verification} IS NULL',

    );
    if (maps.isNotEmpty){
      int numberOfUnverifiedPredictions = maps.length;
      numberOfUnverifiedPredictions--; // It will be one less by the time this is displayed
      setUserMessage("$numberOfUnverifiedPredictions predictions left to verify");

      return Prediction.fromJson(maps.first);
    }else {
      return null;
    }
  }


  Future<int> getMaxRecordingId() async{
    final db = await instance.database;
    final result = await db.rawQuery('SELECT MAX(recordingId) AS largestRecordingId FROM $tablePredictions');

    var abc = result[0]['largestRecordingId'];
    int largestRecordingIdInt = int.parse(abc.toString());

    return largestRecordingIdInt;
  }

  Future<int> update(Prediction prediction) async {
    final db = await instance.database;

    return db.update(
        tablePredictions,
        prediction.toJson(),
        where: '${PredictionFields.id} = ?',
        whereArgs: [prediction.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tablePredictions,
      where: '${PredictionFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }





}