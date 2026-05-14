import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class FavoritesService {
  static final _db = FirebaseFirestore.instance;

  static String? get _uid => AuthService.currentUser?.uid;

  /// ➕ Добавить в избранное
  static Future<void> addToFavorites(String placeId) async {
    print("🔥 TRY ADD: $placeId UID: $_uid");

    if (_uid == null) {
      print("❌ UID NULL — пользователь не авторизован");
      return;
    }

    await _db
        .collection('users')
        .doc(_uid)
        .collection('favorites')
        .doc(placeId)
        .set({
      'createdAt': FieldValue.serverTimestamp(),
    });

    print("✅ ADDED SUCCESS");
  }

  /// ❌ Удалить из избранного
  static Future<void> removeFromFavorites(String placeId) async {
    print("🗑 REMOVE: $placeId UID: $_uid");

    if (_uid == null) {
      print("❌ UID NULL");
      return;
    }

    await _db
        .collection('users')
        .doc(_uid)
        .collection('favorites')
        .doc(placeId)
        .delete();

    print("✅ REMOVED");
  }

  /// 🔍 Проверка (разовая)
  static Future<bool> isFavorite(String placeId) async {
    if (_uid == null) return false;

    final doc = await _db
        .collection('users')
        .doc(_uid)
        .collection('favorites')
        .doc(placeId)
        .get();

    return doc.exists;
  }

  /// 🔥 Поток (живое обновление)
  static Stream<bool> isFavoriteStream(String placeId) {
    print("👀 STREAM CHECK UID: $_uid");

    if (_uid == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(_uid)
        .collection('favorites')
        .doc(placeId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// 📋 Получить все избранные
  static Stream<List<String>> getFavorites() {
    print("📋 GET FAVORITES UID: $_uid");

    if (_uid == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(_uid)
        .collection('favorites')
        .snapshots()
        .map((snapshot) {
      print("🔥 FAVORITES COUNT: ${snapshot.docs.length}");
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }
}