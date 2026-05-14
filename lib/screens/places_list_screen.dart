import 'package:flutter/material.dart';
import '../models/place.dart';
import '../services/firestore_service.dart';
import 'place_detail_screen.dart';

class PlacesListScreen extends StatelessWidget {
  const PlacesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Заведения'),
      ),
      body: StreamBuilder<List<Place>>(
        stream: FirestoreService.getAllPlaces(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Нет заведений'));
          }

          final places = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              return _PlaceCard(place: place);
            },
          );
        },
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final Place place;

  const _PlaceCard({required this.place});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlaceDetailScreen(place: place),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔥 КАРТИНКА (исправлено)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: place.mainImage.isNotEmpty
                  ? Image.network(
                      place.mainImage,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/images/menu_restaurants.jpg',
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
            ),

            /// Контент
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Название
                  Text(
                    place.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// Подкатегория + кухня
                  Text(
                    '${place.subcategory} • ${place.cuisine}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// Локация + рейтинги
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Expanded(
      child: Text(
        place.location,
        style: TextStyle(color: Colors.grey[700]),
        overflow: TextOverflow.ellipsis,
      ),
    ),

    Row(
      children: [
        Text(
          '⭐ ${place.rating}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(width: 10),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF355E3B),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.eco,
                color: Colors.white,
                size: 14,
              ),

              const SizedBox(width: 4),

              Text(
                place.ecoRating.score.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ],
),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}