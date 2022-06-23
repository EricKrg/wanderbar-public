import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

class Recipe {
  String title;
  String photo;
  String calories;
  String time;
  String description;

  List<Ingridient> ingridients;
  List<TutorialStep> tutorial;
  List<Review> reviews;

  Recipe(
      {this.title,
      this.photo,
      this.calories,
      this.time,
      this.description,
      this.ingridients,
      this.tutorial,
      this.reviews});

  factory Recipe.fromJson(Map<String, Object> json) {
    return Recipe(
      title: json['title'],
      photo: json['photo'],
      calories: json['calories'],
      time: json['time'],
      description: json['description'],
    );
  }
}

class TutorialStep {
  String step;
  String description;
  TutorialStep({this.step, this.description});

  Map<String, Object> toMap() {
    return {
      'step': step,
      'description': description,
    };
  }

  factory TutorialStep.fromJson(Map<String, Object> json) => TutorialStep(
        step: json['step'],
        description: json['description'],
      );

  static List<TutorialStep> toList(List<Map<String, Object>> json) {
    return List.from(json)
        .map(
            (e) => TutorialStep(step: e['step'], description: e['description']))
        .toList();
  }
}

class Review {
  String username;
  String review;
  Review({this.username, this.review});

  factory Review.fromJson(Map<String, Object> json) => Review(
        review: json['review'],
        username: json['username'],
      );

  Map<String, Object> toMap() {
    return {
      'username': username,
      'review': review,
    };
  }

  static List<Review> toList(List<Map<String, Object>> json) {
    return List.from(json)
        .map((e) => Review(username: e['username'], review: e['review']))
        .toList();
  }
}

class Ingridient {
  String name;
  String size;

  Ingridient({this.name, this.size});
  factory Ingridient.fromJson(Map<String, Object> json) => Ingridient(
        name: json['name'],
        size: json['size'],
      );

  Map<String, Object> toMap() {
    return {
      'name': name,
      'size': size,
    };
  }

  static List<Ingridient> toList(List<Map<String, Object>> json) {
    return List.from(json)
        .map((e) => Ingridient(name: e['name'], size: e['size']))
        .toList();
  }
}

class UserTripCollection {
  DocumentReference trip;
  DateTime recordDate;

  UserTripCollection({this.trip, this.recordDate});

  factory UserTripCollection.fromJson(Map<String, Object> json) =>
      UserTripCollection(
        trip: (json['trip'] as DocumentReference),
        recordDate: json['recordDate'] != null
            ? timeStampToDate(json['recordDate'])
            : null,
      );

  Map<String, Object> toMap() {
    return {'trip': this.trip, 'recordDate': this.recordDate};
  }
}

class UserSimple {
  String displayName;
  String email;
  String photoUrl;

  UserSimple({this.displayName, this.email, this.photoUrl});

  factory UserSimple.fromJson(Map<String, Object> json) {
    if (json is String) {
      return UserSimple(displayName: "", email: "", photoUrl: "");
    }
    final userSimple = UserSimple(
        displayName: json["displayName"],
        email: json["email"],
        photoUrl: json["photoUrl"]);
    return userSimple;
  }
  Map<String, Object> toMap() {
    return {
      'displayName': this.displayName,
      'email': this.email,
      "photoUrl": this.photoUrl
    };
  }
}

class Trip {
  String titel;
  String id;
  String photo;
  DocumentReference owner;
  DateTime recordDate;
  GeoPoint center;
  double zoom;
  List<DocumentReference> quickLogs = [];
  List<DocumentReference> sharedWith = [];
  List<String> sharedWithNames = [];

  Trip(
      {this.titel,
      this.id,
      this.photo,
      this.owner,
      this.quickLogs,
      this.recordDate,
      this.center,
      this.zoom,
      this.sharedWith});

  factory Trip.fromJson(Map<String, Object> json) {
    final trip = Trip(
      id: json['id'],
      owner: json['owner'],
      titel: json['titel'],
      photo: json['photo'],
      zoom: json['zoom'] != null ? json['zoom'] : 9,
      center: json['center'] != null ? json['center'] as GeoPoint : null,
      recordDate: json['recordDate'] != null
          ? timeStampToDate(json['recordDate'])
          : null,
      sharedWith:
          json['sharedWith'] != null ? List.from(json['sharedWith']) : [],
      quickLogs: List.from(json['quickLogs']),
    );
    return trip;
  }
  Map<String, Object> toMap() {
    return {
      'id': id,
      'owner': this.owner,
      'quickLogs': this.quickLogs,
      'titel': this.titel,
      'photo': this.photo,
      'recordDate': recordDate,
      'center': center,
      'sharedWith': this.sharedWith
    };
  }
}

class QuickLog {
  String uuid = Uuid().v4();
  String titel;
  String description;
  DateTime recordDate;
  DocumentReference selfRef;

  String photo;
  GeoFirePoint point;
  List<QuickLogEntry> entries = [];

  QuickLog(
      {this.description,
      this.recordDate,
      this.entries,
      this.titel,
      this.photo,
      this.point,
      this.selfRef});
  factory QuickLog.fromJson(Map<String, dynamic> json) {
    final ql = QuickLog(
        entries: getEntriesFromDoc(json['entries']),
        recordDate: timeStampToDate(json['recordDate']),
        description: json['description'],
        titel: json['titel'],
        photo: json['photo'],
        point: json["point"] != null
            ? Geoflutterfire().point(
                latitude: json["point"]["latitude"],
                longitude: json["point"]["latitude"])
            : null,
        selfRef: json['selfRef'] != null ? json["selfRef"] : null);
    return ql;
  }

  Map<String, Object> toMap() {
    var entriesConverted = [];
    this.entries.forEach((element) {
      entriesConverted.add(element.toMap());
    });
    return {
      'selfRef': selfRef,
      'entries': entriesConverted,
      'recordDate': this.recordDate,
      'description': this.description,
      'titel': this.titel,
      'photo': this.photo,
      'point': this.point != null ? this.point.data : null
    };
  }

  QuickLog.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : uuid = doc.data()["uuid"],
        titel = doc.data()["titel"],
        description = doc.data()["description"],
        recordDate = timeStampToDate(doc.data()["recordDate"]),
        //null ? DateTime.parse( Timestamp.f(doc.data()["recordDate"])) : DateTime.now() ,

        photo = doc.data()["photo"],
        entries = getEntriesFromDoc(doc.data()["entries"]);
}

DateTime timeStampToDate(Timestamp input) {
  return input.toDate();
}

List<QuickLogEntry> getEntriesFromDoc(dynamic doc) {
  List<QuickLogEntry> qlEntries = [];
  List.from(doc).forEach((element) {
    QuickLogEntry qlEntry = QuickLogEntry.fromJson(element);
    qlEntries.add(qlEntry);
  });
  return qlEntries;
}

List<QuickLog> getQuickLogsFromDoc(dynamic doc) {
  List<QuickLog> qlEntries = [];
  List.from(doc).forEach((element) {
    QuickLog qlEntry = QuickLog.fromJson(element);
    qlEntries.add(qlEntry);
  });
  return qlEntries;
}

List<UserSimple> getUserSimpleFromDoc(dynamic doc) {
  List<UserSimple> entries = [];
  List.from(doc).forEach((element) {
    UserSimple qlEntry = UserSimple.fromJson(element);
    entries.add(qlEntry);
  });
  return entries;
}

class QuickLogEntry {
  String uuid = Uuid().v4();
  String titel;
  DateTime recordDate;
  QuickLogType entryType;
  String content;
  String fileUrl;
  bool isLocalFile = false;
  Position position;

  QuickLogEntry(
      {this.content,
      this.fileUrl,
      this.isLocalFile,
      this.recordDate,
      this.entryType,
      this.titel,
      this.position});
  factory QuickLogEntry.fromJson(Map<String, dynamic> json) => QuickLogEntry(
      entryType: QuickLogType.values.byName(json['type']),
      recordDate: timeStampToDate(json['recordDate']),
      content: json['content'],
      fileUrl: json['fileUrl'],
      isLocalFile: json['isLocalFile'] == null ? false : json['isLocalFile'],
      titel: json['titel'],
      position: getPositionfromJson(json));

  Map<String, Object> toMap() {
    return {
      'type': this.entryType.name,
      'recordDate': this.recordDate,
      'content': this.content,
      'fileUrl': this.fileUrl,
      'isLocalFile': this.isLocalFile,
      'titel': this.titel,
      "position": this.position != null ? this.position.toJson() : null,
    };
  }

  static Position getPositionfromJson(dynamic json) {
    if (json['position'] == null) {
      return null;
    }
    try {
      json['position']['latitude'] = json['position']['latitude'].toDouble();
      json['position']['longitude'] = json['position']['longitude'].toDouble();
      json['position']['altitude'] =
          json['position']['altitude'].toDouble() ?? 0.0;
      json['position']['accuracy'] =
          json['position']['accuracy'].toDouble() ?? 0.0;
      json['position']['heading'] = json['position']['heading'] ?? 0.0;
      json['position']['speed'] = json['position']['speed'].toDouble() ?? 0.0;
      json['position']['speed_accuracy'] =
          json['position']['speed_accuracy'].toDouble() ?? 0.0;
      return Position.fromMap(json['position']);
    } catch (e) {
      print("pos ERROR $e");
      return null;
    }
  }

  static List<QuickLogEntry> toList(List<Map<String, Object>> json) {
    return List.from(json)
        .map((e) => QuickLogEntry(
              content: e['content'],
              titel: e['titel'],
              recordDate: e['recordDate'],
              entryType: e['type'],
              position: e['position'] != null ? e['position'] : null,
            ))
        .toList();
  }
}

enum QuickLogType { photo, text, location, audio, geolocation }
