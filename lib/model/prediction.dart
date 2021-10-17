final String tablePredictions = 'predictions';


class PredictionFields{

  static final List<String> values = [
    id, recordingId, species, begin_s, end_s, liklihood, type, recordingDateTime, deviceName, deviceId, downloadFileJWTToken, verification,
  ];

  static final String id = '_id';
  static final String recordingId = 'recordingId';
  static final String species = 'species';
  static final String begin_s = 'begin_s';
  static final String end_s = 'end_s';
  static final String liklihood = 'liklihood';  // This is the confidence of the model that there is a call from this bird somewhere in the time slice/duration.  There may be other noises also present, even louder.
  static final String type = 'type';
  static final String recordingDateTime = 'recordingDateTime';
  static final String deviceName = 'deviceName';
  static final String deviceId = 'deviceId';
  static final String downloadFileJWTToken = 'downloadFileJWTToken';
  static final String verification = 'verification';  // This is the how certain the human agrees with the model saying there is e.g. 'morepork' or NOT, somewhere in that time period.  I decide to use words here, rather than a number so the intention of the user is kept in the local db
}


class Prediction {
  final int? id;
  final int recordingId;
  final String species;
  final double begin_s;
  final double end_s;
  final double liklihood;
  final String type;
  final DateTime recordingDateTime;
  final String deviceName;
  final int deviceId;
  final String downloadFileJWTToken;
  String? verification;

   Prediction({
    this.id,
    required this.recordingId,
    required this.species,
    required this.begin_s,
    required this.end_s,
    required this.liklihood,
    required this.type,
    required this.recordingDateTime,
    required this.deviceName,
    required this.deviceId,
    required this.downloadFileJWTToken,
     this.verification,
});

  Prediction copy({
    int? id,
    String? species,
    double? begin_s,
    double? end_s,
    double? liklihood,
    String? type,
    DateTime? recordingDateTime,
    String? deviceName,
    int? deviceId,
    String? downloadFileJWTToken,
    String? verification,
  }) =>
  Prediction(recordingId: recordingId,
      id: id ?? this.id,
      species: species ?? this.species,
      begin_s: begin_s ?? this.begin_s,
      end_s: end_s ?? this.end_s,
      liklihood: liklihood ?? this.liklihood,
      type: type ?? this.type,
      recordingDateTime: recordingDateTime ?? this.recordingDateTime,
      deviceName: deviceName ?? this.deviceName,
    deviceId: deviceId ?? this.deviceId,
    downloadFileJWTToken: downloadFileJWTToken ?? this.downloadFileJWTToken,
    verification: verification ?? this.verification,
  );

  static Prediction fromJson(Map<String, Object?> json) => Prediction(
    id: json[PredictionFields.id] as int?,
    recordingId: json[PredictionFields.recordingId] as int,
    species: json[PredictionFields.species] as String,
    begin_s: json[PredictionFields.begin_s] as double,
    end_s: json[PredictionFields.end_s] as double,
    liklihood: json[PredictionFields.liklihood] as double,
    type: json[PredictionFields.type] as String,
    recordingDateTime: DateTime.parse(json[PredictionFields.recordingDateTime] as String),
    deviceName: json[PredictionFields.deviceName] as String,
    deviceId: json[PredictionFields.deviceId] as int,
    downloadFileJWTToken: json[PredictionFields.downloadFileJWTToken] as String,
    // verification: json[PredictionFields.verification] as String,
    verification: json[PredictionFields.verification] == null ? null : json[PredictionFields.verification] as String, //https://stackoverflow.com/questions/58312787/parsing-json-in-flutter-results-in-null-values-of-objectss-fields
  );

  Map<String,Object?> toJson() => {
    PredictionFields.id: id,
    PredictionFields.recordingId: recordingId,
    PredictionFields.species: species,
    PredictionFields.begin_s: begin_s,
    PredictionFields.end_s: end_s,
    PredictionFields.liklihood: liklihood,
    PredictionFields.type: type,
    PredictionFields.recordingDateTime: recordingDateTime.toIso8601String(),
    PredictionFields.deviceName: deviceName,
    PredictionFields.deviceId: deviceId,
    PredictionFields.downloadFileJWTToken: downloadFileJWTToken,
    PredictionFields.verification: verification,
  };



}