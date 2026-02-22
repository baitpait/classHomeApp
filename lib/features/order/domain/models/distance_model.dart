class DistanceModel {
  int? originIndex;
  int? destinationIndex;
  List<String>? status;
  int? distanceMeters;
  String? duration;
  String? staticDuration;
  List<String>? travelAdvisory;
  String? condition;
  LocalizedValues? localizedValues;

  DistanceModel(
      {this.originIndex,
        this.destinationIndex,
        this.status,
        this.distanceMeters,
        this.duration,
        this.staticDuration,
        this.travelAdvisory,
        this.condition,
        this.localizedValues});

  DistanceModel.fromJson(Map<String, dynamic> json) {
    originIndex = json['originIndex'];
    destinationIndex = json['destinationIndex'];
    status = json['status'].cast<String>();
    distanceMeters = json['distanceMeters'];
    duration = json['duration'];
    staticDuration = json['staticDuration'];
    travelAdvisory = json['travelAdvisory'].cast<String>();
    condition = json['condition'];
    localizedValues = json['localizedValues'] != null
        ? LocalizedValues.fromJson(json['localizedValues'])
        : null;
  }
}

class LocalizedValues {
  Distance? distance;
  Distance? duration;
  Distance? staticDuration;

  LocalizedValues({this.distance, this.duration, this.staticDuration});

  LocalizedValues.fromJson(Map<String, dynamic> json) {
    distance = json['distance'] != null
        ? Distance.fromJson(json['distance'])
        : null;
    duration = json['duration'] != null
        ? Distance.fromJson(json['duration'])
        : null;
    staticDuration = json['staticDuration'] != null
        ? Distance.fromJson(json['staticDuration'])
        : null;
  }
}

class Distance {
  String? text;

  Distance({this.text});

  Distance.fromJson(Map<String, dynamic> json) {
    text = json['text'];
  }
}
