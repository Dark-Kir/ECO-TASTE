import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RatingService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> ratePlace({
    required String placeId,
    required double rating,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final userId = user.uid;

    final placeRef = _db.collection('places').doc(placeId);
    final userRatingRef =
        placeRef.collection('userRatings').doc(userId);

    final snapshot = await placeRef.get();
    final data = snapshot.data() ?? {};

    double currentRating = (data['rating'] ?? 0).toDouble();
    int ratingsCount = (data['ratingsCount'] ?? 0);

    final existing = await userRatingRef.get();

    /// ⭐ ПЕРВАЯ ОЦЕНКА
    if (ratingsCount == 0) {
      await placeRef.set({
        'rating': rating,
        'ratingsCount': 1,
      }, SetOptions(merge: true));

      await userRatingRef.set({'value': rating});
      return;
    }

    /// 🔁 ОБНОВЛЕНИЕ
    if (existing.exists) {
      double oldRating = (existing.data()?['value'] ?? 0).toDouble();

      double newAverage =
          ((currentRating * ratingsCount) - oldRating + rating) /
              ratingsCount;

      await placeRef.update({'rating': newAverage});
      await userRatingRef.update({'value': rating});
    }

    /// ⭐ НОВЫЙ ПОЛЬЗОВАТЕЛЬ
    else {
      double newAverage =
          ((currentRating * ratingsCount) + rating) /
              (ratingsCount + 1);

      await placeRef.update({
        'rating': newAverage,
        'ratingsCount': ratingsCount + 1,
      });

      await userRatingRef.set({'value': rating});
    }
  }
}