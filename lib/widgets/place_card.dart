import 'package:flutter/material.dart';
import '../models/place.dart';
import '../services/favorites_service.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback onTap;

  const PlaceCard({
    super.key,
    required this.place,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFC9A96E);
    const brownColor = Color(0xFF6A4325);
    const beigeColor = Color(0xFFF5EBDD);

    final logoUrl = place.logo.trim();
    final imageUrl = place.mainImage.trim();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: goldColor.withOpacity(0.55)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔥 КАРТИНКА + СТЕК
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              child: SizedBox(
                width: double.infinity,
                height: 190,
                child: Stack(
                  children: [
                    /// 🔥 ФОН
                    Positioned.fill(
                      child: imageUrl.startsWith('http')
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: beigeColor,
                                child: const Icon(Icons.image, size: 40),
                              ),
                            )
                          : Container(
                              color: beigeColor,
                              child: const Icon(Icons.image, size: 40),
                            ),
                    ),

                    /// 🔥 ЛОГО ПО ЦЕНТРУ (ГЛАВНЫЙ ФИКС)
                    if (logoUrl.isNotEmpty && logoUrl.startsWith('http'))
                      Positioned.fill(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Image.network(
                              logoUrl,
                              fit: BoxFit.contain,
                              height: 150,
                              errorBuilder: (_, __, ___) {
                                return const Icon(Icons.image, size: 50);
                              },
                            ),
                          ),
                        ),
                      ),

                    /// КАТЕГОРИЯ
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          place.subcategory,
                          style: const TextStyle(
                            color: brownColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),

                    /// ❤️ ИЗБРАННОЕ
                    Positioned(
                      top: 12,
                      right: 12,
                      child: StreamBuilder<bool>(
                        stream: FavoritesService.isFavoriteStream(place.id),
                        builder: (context, snapshot) {
                          final isFav = snapshot.data ?? false;

                          return GestureDetector(
                            onTap: () async {
                              if (isFav) {
                                await FavoritesService.removeFromFavorites(place.id);
                              } else {
                                await FavoritesService.addToFavorites(place.id);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.red : Colors.black54,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    /// ⭐ РЕЙТИНГ + 🌿 ECO
Positioned(
  top: 60,
  right: 12,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [

      /// ⭐ Обычный рейтинг
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: goldColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star,
              color: Colors.white,
              size: 16,
            ),

            const SizedBox(width: 4),

            Text(
              place.rating.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 8),

      /// 🌿 ECO РЕЙТИНГ
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF355E3B),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.eco,
              color: Colors.white,
              size: 16,
            ),

            const SizedBox(width: 4),

            Text(
              place.ecoRating.score.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),
                  ],
                ),
              ),
            ),

            /// 🔽 НИЖНЯЯ ЧАСТЬ
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: brownColor,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: goldColor, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          place.location,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4A3426),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(Icons.restaurant_menu,
                          color: goldColor, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          place.cuisine,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4A3426),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Text(
                    place.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Color(0xFF7A6352),
                    ),
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