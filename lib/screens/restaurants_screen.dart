import 'package:flutter/material.dart';
import '../models/place.dart';
import '../services/firestore_service.dart';
import '../widgets/place_card.dart';
import 'place_detail_screen.dart';

class RestaurantsScreen extends StatelessWidget {
  const RestaurantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EBDD),
      appBar: AppBar(
        title: const Text('Рестораны'),
      ),
      body: StreamBuilder<List<Place>>(
        stream: FirestoreService.getPlacesByCategory('restaurant'),
        builder: (context, snapshot) {
          /// ⏳ Загрузка
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          /// ❌ Ошибка
          if (snapshot.hasError) {
            return Center(
              child: Text('Ошибка: ${snapshot.error}'),
            );
          }

          /// 📦 Данные
          final List<Place> restaurants = snapshot.data ?? [];

          /// ❌ Пусто
          if (restaurants.isEmpty) {
            return const Center(
              child: Text('Рестораны пока не добавлены'),
            );
          }

          /// ✅ Список
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final Place place = restaurants[index];

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
      ),
    );
  }
}