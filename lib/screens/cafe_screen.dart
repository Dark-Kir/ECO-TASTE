import 'package:flutter/material.dart';
import '../models/place.dart';
import '../services/firestore_service.dart';
import '../widgets/place_card.dart';
import 'place_detail_screen.dart';

class CafeScreen extends StatelessWidget {
  const CafeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Кафе и гастро-точки'),
      ),
      body: StreamBuilder<List<Place>>(
        stream: FirestoreService.getPlacesByCategory('cafe'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Ошибка: ${snapshot.error}'),
            );
          }

          final List<Place> cafes = snapshot.data ?? [];

          if (cafes.isEmpty) {
            return const Center(
              child: Text('Кафе пока не добавлены'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cafes.length,
            itemBuilder: (context, index) {
              final Place place = cafes[index];

              return PlaceCard(
                place: place,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlaceDetailScreen(place: place),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}