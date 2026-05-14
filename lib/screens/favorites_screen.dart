import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/place.dart';
import '../services/favorites_service.dart';
import '../widgets/place_card.dart';
import 'place_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EBDD),
      appBar: AppBar(
        title: const Text('Избранное'),
      ),

      /// 🔥 1. получаем ID избранных
      body: StreamBuilder<List<String>>(
        stream: FavoritesService.getFavorites(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final favoriteIds = snapshot.data!;

          /// ❌ пусто
          if (favoriteIds.isEmpty) {
            return _emptyState();
          }

          /// 🔥 2. тянем сами места из Firebase
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('places')
                .where(FieldPath.documentId, whereIn: favoriteIds)
                .snapshots(),
            builder: (context, placeSnapshot) {
              if (!placeSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final places = placeSnapshot.data!.docs
                  .map((doc) => Place.fromFirestore(doc))
                  .toList();

              if (places.isEmpty) {
                return _emptyState();
              }

              /// ✅ список
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: places.length,
                itemBuilder: (context, index) {
                  final place = places[index];

                  return PlaceCard(
                    place: place,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PlaceDetailScreen(place: place),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  /// 🔥 пустое состояние
  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF5EBDD),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFD4B483),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.favorite_border,
                size: 48,
                color: Color(0xFF8B6A43),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Нет избранных мест',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6A4325),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Добавляйте заведения в избранное,\nчтобы быстро находить их позже',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}