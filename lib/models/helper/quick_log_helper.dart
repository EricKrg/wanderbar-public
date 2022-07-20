import 'dart:developer';
import 'dart:io';

import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:wanderbar/models/core/log_model.dart';
import 'package:wanderbar/views/widgets/map_record_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class QuickLogHelper {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get a non-default Storage bucket
  final _storage = FirebaseStorage.instance;
  final _geo = Geoflutterfire();

  static QuickLogHelper get instance {
    if (_instance == null) {
      _instance = QuickLogHelper._init();
    }
    return _instance;
  }

  static QuickLogHelper _instance;
  QuickLogHelper._init();

  QuickLogHelper() {
    _db.settings = Settings(
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        persistenceEnabled: true);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getTripsAsStream(User user) {
    return _db
        .collection("${user.email}-trips")
        .orderBy("recordDate", descending: true)
        .snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getTrips(User user) async {
    final trips = await _db.collection("${user.email}-trips").get();
    return trips;
  }

  Future<List<Trip>> resolveUserTrips(User user) async {
    final res = await this.getTrips(user);
    final trips =
        res.docs.map((e) => UserTripCollection.fromJson(e.data())).toList();
    final resolvedTrips = Future.wait(trips.map((trip) async {
      final resTrip = await trip.trip.get();

      final t = Trip.fromJson(resTrip.data());
      final editors = await Future.wait(t.sharedWith.map((e) async {
        final user = await e.get();
        final resUser = UserSimple.fromJson(user.data());
        return resUser.displayName;
      }).toList());
      final owner = await t.owner.get();
      editors.add(UserSimple.fromJson(owner.data()).displayName);
      t.sharedWithNames = editors;
      return t;
    }).toList());
    return resolvedTrips;
  }

  Future<DocumentSnapshot> getTrip(String docPath) {
    return _db.doc(docPath).get();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getTripAsStream(
      String docPath) {
    return _db.doc(docPath).snapshots();
  }

  Stream<DocumentSnapshot> getTripfromPath(String docPath) {
    return _db.doc(docPath).snapshots();
  }

  Future<Trip> addTrip(User user, Trip trip) async {
    print("add trip");
    try {
      final recordDate = new DateTime.now();
      var res = await _db.collection("trips").add(trip.toMap());
      await _db
          .collection("${user.email}-trips")
          .doc(res.id)
          .set({"trip": _db.doc(res.path), "recordDate": recordDate});

      trip.id = res.id;
      var userResult = await this.getUserSimpleByEmail(user.email);
      if (userResult.docs.isNotEmpty) {
        trip.owner = userResult.docs.first.reference;
      } else {
        createSimpleUser(user);
      }

      trip.recordDate = recordDate;
      await _db.collection("trips").doc(res.id).update(trip.toMap());
      return trip;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String> addForeignTrip(User user, String tripId) async {
    try {
      final tripRes = await _db.collection("trips").doc(tripId).get();
      final trip = Trip.fromJson(tripRes.data());
      await _db.collection("${user.email}-trips").doc(tripId).set(
          {"trip": _db.doc("/trips/$tripId"), "recordDate": trip.recordDate});

      var userResult = await this.getUserSimpleByEmail(user.email);

      if (userResult.docs.isNotEmpty) {
        if (trip.sharedWith.contains(userResult.docs.first.reference)) {
          print("User already joined this trip, not adding");
        } else {
          trip.sharedWith.add(userResult.docs.first.reference);
        }
      } else {
        var userRef = await createSimpleUser(user);
        trip.sharedWith.add(userRef);
      }

      _db.collection("trips").doc(tripId).update(trip.toMap());
    } catch (e) {
      print(e);
    }
  }

  Future<bool> canDeleteTrip(User user, Trip trip) async {
    var tripOwner = UserSimple.fromJson((await trip.owner.get()).data());
    return user.email == tripOwner.email;
  }

  Future<void> deleteTrip(User user, Trip trip) async {
    if (await canDeleteTrip(user, trip)) {
      try {
        _db.collection("${user.email}-trips").doc(trip.id).delete();
        trip.sharedWith.forEach((element) async {
          final sharedUser = UserSimple.fromJson((await element.get()).data());
          _db.collection("${sharedUser.email}-trips").doc(trip.id).delete();
        });
        _db.collection("trips").doc(trip.id).delete();
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> updateTrip(Trip trip) async {
    try {
      print("update trip");
      List<QuickLogEntry> allEntries = [];
      await Future.forEach(trip.quickLogs, (DocumentReference element) async {
        final res = await element.get();
        allEntries.addAll(QuickLog.fromJson(res.data()).entries);
      });

      LatLng center = getCurrentCenter(allEntries);
      trip.zoom = getZoomLvl(allEntries);

      trip.center = GeoPoint(center.latitude, center.longitude);
      await _db.collection("trips").doc(trip.id).update(trip.toMap());
    } catch (e) {
      print("FAILED TRIP UPDATE $e");
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getTripById(String id) {
    return _db.collection("trips").doc(id).get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getQuickLogsAsStream(User user) {
    return FirebaseFirestore.instance
        .collection(user.uid)
        .orderBy("recordDate", descending: true)
        .snapshots();
  }

  Stream<List<DocumentSnapshot<Object>>> getQuickLogSelectionAsStream(
      List<DocumentReference> refs) {
    final streams = refs.map((element) {
      return element.snapshots();
    });

    final res = StreamZip(streams);
    return res.asBroadcastStream();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getQuickLogAsStream(
      DocumentReference selfRes) {
    return selfRes.snapshots();
  }

  Stream<List<QuickLogEntry>> getQuickLogsEntryAsStream(
      DocumentReference selfRef) {
    return selfRef
        .snapshots()
        .map((event) => QuickLog.fromJson(event.data()).entries);
  }

  Future<List<QuickLog>> getAllQuickLogs(User user) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection(user.uid)
        .orderBy("recordDate", descending: true)
        .get();
    final res = snapshot.docs.map((docSnapshot) {
      return QuickLog.fromJson(docSnapshot.data());
    }).toList();
    return res;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getById(
      User user, String uuid) {
    return FirebaseFirestore.instance
        .collection(user.uid)
        .doc(uuid)
        .snapshots();
  }

  Future<String> addQuickLog(User user, QuickLog quickLog) async {
    try {
      var res = await _db.collection(user.uid).add(quickLog.toMap());
      quickLog.selfRef = res;
      final center = getCurrentCenter(quickLog.entries);
      quickLog.point = GeoFirePoint(center.latitude, center.longitude);
      await res.update(quickLog.toMap());
      //await _db.collection(user.uid).doc(res.id).set({"selfRes": res});
      return res.id;
    } catch (e) {
      print(e);
    }
  }

  updateQuickLog(DocumentReference selfRes, QuickLog quickLog) async {
    try {
      print("update quicklog");
      final center = getCurrentCenter(quickLog.entries);
      quickLog.point = GeoFirePoint(center.latitude, center.longitude);
      selfRes.update(quickLog.toMap());
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteQuickLog(
      DocumentReference selfRes, QuickLog quickLog) async {
    print(quickLog.toString());

    final toUpdate = await _db
        .collection("trips")
        .where("quickLogs", arrayContains: selfRes)
        .get();

    toUpdate.docs.forEach((element) async {
      final updateTrip = Trip.fromJson(element.data());
      updateTrip.quickLogs.remove(selfRes);
      await _db.collection("trips").doc(element.id).update(updateTrip.toMap());
    });
    await selfRes.delete();
  }

  Future<TaskSnapshot> uploadFile(File file, User user) async {
    try {
      final fileName = basename(file.path);
      _storage.setMaxUploadRetryTime(Duration(seconds: 10));
      return await _storage
          .ref("images/${user.uid}/${Uuid().v4()}$fileName")
          .putFile(file);
    } catch (e) {
      print("ERRRRRROR $e");
    }
  }

  Future<TaskSnapshot> uploadUserImage(File file, User user) async {
    try {
      print("UPLOAD");
      final fileName = basename(file.path);
      _storage.setMaxUploadRetryTime(Duration(seconds: 10));
      return await _storage.ref("user/${user.uid}.jpg").putFile(file);
    } catch (e) {
      print("ERRRRRROR $e");
    } finally {
      print("FINISHED");
    }
  }

  Future<String> getDownloadUrlForPath(
      QuickLogEntry entry, bool forceRefresh) async {
    try {
      //CacheManager().getSingleFile(path);
      if (entry.fileUrl != null && !forceRefresh) {
        return entry.fileUrl;
      } else {
        final fileUrl = await _storage.ref(entry.content).getDownloadURL();
        return fileUrl;
      }
    } catch (e) {
      print(e);
    }
  }

  removeFromStorage(String path) async {
    try {
      print("remove old");
      _storage.ref(path).delete();
    } catch (e) {
      print(e);
    }
  }

  String createCollectionId(User user) {
    return "${user.email}-${DateTime.now().microsecondsSinceEpoch}";
  }

  // tries to upload the file async if it fails bc the device is i.e. offline
  // it set the flag isLocalFile to true so that the user can try to upload the file again
  Future<bool> tryUpload(
      String imagePath, QuickLog ql, String entryUUID) async {
    try {
      print("TRY UPLOAD");
      TaskSnapshot upload = await this
          .uploadFile(File(imagePath), FirebaseAuth.instance.currentUser);
      final fileUrl = await upload.ref.getDownloadURL();

      var entry = ql.entries.firstWhere((element) => element.uuid == entryUUID);
      // remove old entry
      ql.entries.remove(entry);
      entry.fileUrl = fileUrl;
      entry.content = upload.ref.fullPath;
      entry.isLocalFile = false;
      // add new entry with updated fileUrl
      ql.entries.add(entry);
      this.updateQuickLog(ql.selfRef, ql);
      return true;
    } catch (e) {
      print("ERROR uploading $e");
      var entry = ql.entries.firstWhere((element) => element.uuid == entryUUID);
      // remove old entry
      ql.entries.remove(entry);
      entry.isLocalFile = true;
      // add new entry with updated fileUrl
      ql.entries.add(entry);
      this.updateQuickLog(ql.selfRef, ql);
      return false;
    }
  }

  // tries to update the file url, i.e. if it got revoked from the firebase storage
  tryUpdatingFileUrl(QuickLog parent, QuickLogEntry qlEntry, int retry) async {
    if (retry > 1) return;
    print("TRY UPDATE");
    final fileUrl = await this.getDownloadUrlForPath(qlEntry, true);
    print(fileUrl);
    var oldEntry =
        parent.entries.firstWhere((element) => element.uuid == qlEntry.uuid);
    // remove old entry
    parent.entries.remove(oldEntry);
    qlEntry.fileUrl = fileUrl;
    // add new entry with updated fileUrl
    parent.entries.add(qlEntry);
    this.updateQuickLog(parent.selfRef, parent);
  }

  Future<List<QuickLogEntry>> getLatestQuickLogEntry(
      User user, QuickLogType type) async {
    try {
      final res =
          await _db.collection(user.uid).where("entries", isNotEqualTo: [])
              // .orderBy("recordDate", descending: true)
              .get();
      final List<QuickLogEntry> allEntries = [];
      res.docs.forEach((e) {
        final ql = QuickLog.fromJson(e.data());
        allEntries.addAll(ql.entries);
      });
      final allPhotos = allEntries.where((QuickLogEntry element) {
        return element.entryType == QuickLogType.photo;
      }).toList();

      allPhotos.sort(((a, b) {
        return b.recordDate.compareTo(a.recordDate);
      }));
      return allPhotos.sublist(0, 4);
    } catch (e) {
      print(e);
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamLatestQuicklogEntries(
      User user) {
    final res =
        _db.collection(user.uid).where("entries", isNotEqualTo: []).snapshots();
    return res;
  }

  List<QuickLogEntry> filterLatestPhotos(
      QuerySnapshot<Map<String, dynamic>> res) {
    final List<QuickLogEntry> allEntries = [];
    res.docs.forEach((e) {
      final ql = QuickLog.fromJson(e.data());
      allEntries.addAll(ql.entries);
    });

    final allPhotos = allEntries.where((QuickLogEntry element) {
      return element.entryType == QuickLogType.photo;
    }).toList();

    allPhotos.sort(((a, b) {
      return b.recordDate.compareTo(a.recordDate);
    }));
    if (allPhotos.length > 3) {
      return allPhotos.sublist(0, 4);
    }
    return allPhotos;
  }

  Future<DocumentReference> createSimpleUser(User user) async {
    await _db.collection("users").doc(user.email).set(UserSimple(
            displayName: user.displayName,
            email: user.email,
            photoUrl: user.photoURL)
        .toMap());
    return _db.collection("users").doc(user.email);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getUserSimpleByEmail(
      String email) async {
    return await _db.collection("users").where("email", isEqualTo: email).get();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserAsStream(String email) {
    return _db.collection("users").doc(email).snapshots();
  }

  Stream<List<DocumentSnapshot<Object>>> getUsersStreams(
      List<DocumentReference> refs) {
    final streams = refs.map((element) {
      return element.snapshots();
    });

    final res = StreamZip(streams);
    return res.asBroadcastStream();
  }

  Query<Map<String, dynamic>> searchCollectionByKey(
      List<String> searchTerms, String collection) {
    return _db.collection(collection).where('titel', whereIn: searchTerms);
  }

  Future<bool> hasInternetConn() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
  }
}
