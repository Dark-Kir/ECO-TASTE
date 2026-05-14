import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/event.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  void _launch(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    await launchUrl(uri);
  }

  void _call(String phone) async {
    if (phone.isEmpty) return;
    final uri = Uri.parse("tel:$phone");
    await launchUrl(uri);
  }

  // 🔥 КРУГЛАЯ КНОПКА С ТВОЕЙ ИКОНКОЙ
  Widget _buildCircleButton({
    required String asset,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9), // 🔥 без deprecated
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFD4B483),
            width: 1.3,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset(
            asset,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPhone = event.phone.trim().isNotEmpty;
    final hasInstagram = event.instagram.trim().isNotEmpty;
    final hasMap = event.mapUrl.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5EBDD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EBDD),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF6E4B2A)),
        title: Text(
          event.name,
          style: const TextStyle(
            color: Color(0xFF6E4B2A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔥 КАРТИНКА
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              child: Image.network(
                event.image,
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFD4B483),
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔥 Название
                    Text(
                      event.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6E4B2A),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 📅 Дата
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 16, color: Color(0xFF8B6A43)),
                        const SizedBox(width: 6),
                        Text(
                          "${event.date} • ${event.time}",
                          style: const TextStyle(
                            color: Color(0xFF7A5C3A),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // 📍 Локация
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Color(0xFF8B6A43)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            event.location,
                            style: const TextStyle(
                              color: Color(0xFF7A5C3A),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 📝 Описание
                    Text(
                      event.description,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6E4B2A),
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 26),

                    // 🔥 КНОПКИ С ИКОНКАМИ
                    if (hasPhone || hasInstagram || hasMap)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (hasPhone)
                            _buildCircleButton(
                              asset: 'assets/icon/phone.png',
                              onTap: () => _call(event.phone),
                            ),

                          if (hasInstagram)
                            _buildCircleButton(
                              asset: 'assets/icon/instagram.png',
                              onTap: () => _launch(event.instagram),
                            ),

                          if (hasMap)
                            _buildCircleButton(
                              asset: 'assets/icon/2gis.png',
                              onTap: () => _launch(event.mapUrl),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}