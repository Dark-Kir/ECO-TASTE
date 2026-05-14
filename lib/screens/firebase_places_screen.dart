import 'package:flutter/material.dart';
import '../models/place.dart';
import '../services/firestore_service.dart';

class FirebasePlacesScreen extends StatelessWidget {
  const FirebasePlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Заведения из Firebase'),
      ),
      body: StreamBuilder<List<Place>>(
        stream: FirestoreService.getAllPlaces(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Ошибка: ${snapshot.error}'),
            );
          }

          final places = snapshot.data ?? [];

          if (places.isEmpty) {
            return const Center(
              child: Text('В Firestore пока нет заведений'),
            );
          }

          return ListView.builder(
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text(place.name),
                  subtitle: Text(
                    '${place.location} • ${place.cuisine}\nРейтинг: ${place.rating}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}