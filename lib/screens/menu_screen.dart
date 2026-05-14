import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuScreen extends StatefulWidget {
  final String placeId;
  final String placeName;

  const MenuScreen({
    super.key,
    required this.placeId,
    required this.placeName,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String selectedCategory = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.placeName),
      ),
      backgroundColor: const Color(0xFFF5EBDD),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('places')
            .doc(widget.placeId)
            .collection('menu')
            .snapshots(),
        builder: (context, snapshot) {
          /// загрузка
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          /// ошибка
          if (snapshot.hasError) {
            return const Center(child: Text('Ошибка загрузки'));
          }

          /// пусто
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Меню пока пустое'));
          }

          final docs = snapshot.data!.docs;

          /// 🔥 ГРУППИРОВКА ПО КАТЕГОРИЯМ
          final Map<String, List<Map<String, dynamic>>> grouped = {};

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final category = data['category'] ?? 'Без категории';

            if (!grouped.containsKey(category)) {
              grouped[category] = [];
            }

            grouped[category]!.add(data);
          }

          final categories = grouped.keys.toList();

          /// первый запуск
          if (selectedCategory.isEmpty && categories.isNotEmpty) {
            selectedCategory = categories.first;
          }

          final items = grouped[selectedCategory] ?? [];

          return Column(
            children: [
              /// 🔥 КАТЕГОРИИ (ТАБЫ)
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: categories.length,
                  itemBuilder: (_, index) {
                    final category = categories[index];
                    final isSelected = category == selectedCategory;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFD4B483)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFD4B483)),
                        ),
                        child: Center(
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              /// 🔥 СПИСОК БЛЮД
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    final data = items[index];

                    final image = data['image'] ?? '';
                    final name = data['name'] ?? '';
                    final description = data['description'] ?? '';
                    final price = data['price'] ?? '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      child: Row(
                        children: [
                          /// фото
                          ClipRRect(
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(16),
                            ),
                            child: image.isNotEmpty
                                ? Image.network(
                                    image,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey[300],
                                  ),
                          ),

                          /// инфо
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(description),
                                  const SizedBox(height: 8),
                                  Text(
                                    price,
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}