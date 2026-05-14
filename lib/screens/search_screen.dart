import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/place.dart';
import '../widgets/place_card.dart';
import 'place_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';
  String selectedLocation = 'Все';
  String selectedCategory = 'Все';
  RangeValues selectedRatingRange = const RangeValues(0.0, 5.0);

  final List<String> locations = const [
    'Все',
    'Балхаш',
    'Барковское',
    'Чубар-Тюбек',
    'Торангалык',
  ];

  final List<String> categories = const [
    'Все',
    'Рестораны',
    'Кафе',
  ];

  @override
  Widget build(BuildContext context) {
    final bool hasSearch = query.isNotEmpty ||
        selectedLocation != 'Все' ||
        selectedCategory != 'Все' ||
        selectedRatingRange != const RangeValues(0.0, 5.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5EBDD),
      appBar: AppBar(
        title: const Text('Поиск'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔍 ПОИСК
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFD4B483)),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    query = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Введите название, кухню или локацию...',
                  prefixIcon: Icon(Icons.search, color: Color(0xFF8B6A43)),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// 📍 ЛОКАЦИЯ
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Локация',
                style: TextStyle(
                  color: Color(0xFF7A5C3A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),

            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: locations.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final location = locations[index];
                  final isSelected = selectedLocation == location;

                  return ChoiceChip(
                    label: Text(location),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        selectedLocation = location;
                      });
                    },
                    selectedColor: const Color(0xFFC9A96B),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color:
                          isSelected ? Colors.white : const Color(0xFF8B6A43),
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            /// 🍽 ТИП
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Тип',
                style: TextStyle(
                  color: Color(0xFF7A5C3A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),

            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category;

                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    selectedColor: const Color(0xFFC9A96B),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color:
                          isSelected ? Colors.white : const Color(0xFF8B6A43),
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            /// ⭐ РЕЙТИНГ
            RangeSlider(
              values: selectedRatingRange,
              min: 0,
              max: 5,
              divisions: 10,
              labels: RangeLabels(
                selectedRatingRange.start.toStringAsFixed(1),
                selectedRatingRange.end.toStringAsFixed(1),
              ),
              onChanged: (values) {
                setState(() {
                  selectedRatingRange = values;
                });
              },
            ),

            const SizedBox(height: 20),

            /// 🔥 СПИСОК ИЗ FIREBASE
            Expanded(
              child: !hasSearch
                  ? const Center(child: Text('Введите запрос'))
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('places')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final places = snapshot.data!.docs
                            .map((doc) => Place.fromFirestore(doc))
                            .toList();

                        final filtered = places.where((place) {
                          final q = query.toLowerCase().trim();

                          final matchesQuery = q.isEmpty ||
                              place.name.toLowerCase().contains(q) ||
                              place.subcategory.toLowerCase().contains(q) ||
                              place.category.toLowerCase().contains(q) ||
                              place.location.toLowerCase().contains(q) ||
                              place.cuisine.toLowerCase().contains(q) ||
                              place.description.toLowerCase().contains(q) ||
                              place.rating.toString().contains(q);

                          final matchesLocation =
                              selectedLocation == 'Все' ||
                                  place.location.toLowerCase() ==
                                      selectedLocation.toLowerCase();

                          final matchesCategory =
                              selectedCategory == 'Все' ||
                                  (selectedCategory == 'Рестораны' &&
                                      place.category == 'restaurant') ||
                                  (selectedCategory == 'Кафе' &&
                                      place.category == 'cafe');

                          final matchesRating =
                              place.rating >= selectedRatingRange.start &&
                                  place.rating <= selectedRatingRange.end;

                          return matchesQuery &&
                              matchesLocation &&
                              matchesCategory &&
                              matchesRating;
                        }).toList();

                        if (filtered.isEmpty) {
                          return const Center(child: Text('Ничего не найдено'));
                        }

                        return ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final place = filtered[index];

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
            ),
          ],
        ),
      ),
    );
  }
}