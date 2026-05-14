import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import 'event_detail_screen.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  DateTime _parseDate(String date) {
    try {
      return DateTime.parse(date);
    } catch (e) {
      return DateTime(2100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("События"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Ошибка"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data!.docs
              .map((doc) => Event.fromFirestore(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  ))
              .toList();

          // 🔥 сортировка по дате
          events.sort((a, b) {
            final aDate = _parseDate(a.date);
            final bDate = _parseDate(b.date);
            return aDate.compareTo(bDate);
          });

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];

              return GestureDetector(
  onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => EventDetailScreen(event: event),
    ),
  );
},
  child: Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    margin: const EdgeInsets.only(bottom: 14),
    elevation: 4,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Image.network(
            event.image,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          // затемнение
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),

          // текст
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${event.date} • ${event.time}",
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
                Text(
                  event.location,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);
            },
          );
        },
      ),
    );
  }
}