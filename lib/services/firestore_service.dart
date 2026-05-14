import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/place.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔥 Все места
  static Stream<List<Place>> getAllPlaces() {
    return _db.collection('places').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        /// 🔥 ВАЖНО: используем fromMap
        return Place.fromMap(doc.id, data);
      }).toList();
    });
  }

  /// 🔥 По категории
  static Stream<List<Place>> getPlacesByCategory(String category) {
    return _db
        .collection('places')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        /// 🔥 ВАЖНО: используем fromMap
        return Place.fromMap(doc.id, data);
      }).toList();
    });
  }
}