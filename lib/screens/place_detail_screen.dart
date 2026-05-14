import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../l10n/app_localizations.dart';

import '../models/place.dart';
import '../services/rating_service.dart';
import 'menu_screen.dart';
import 'fullscreen_gallery.dart';

class PlaceDetailScreen extends StatefulWidget {
  final Place place;

  const PlaceDetailScreen({super.key, required this.place});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  double selectedRating = 0;
  bool isLoadingRating = true;

  double averageRating = 0;
  int ratingCount = 0;

  int currentIndex = 0;

  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserRating();
    _loadAverageRating();
  }

  Future<void> _loadUserRating() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => isLoadingRating = false);
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('places')
        .doc(widget.place.id)
        .collection('userRatings')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      selectedRating = (doc['value'] ?? 0).toDouble();
    }

    setState(() {
      isLoadingRating = false;
    });
  }

  Future<void> _loadAverageRating() async {
    final doc = await FirebaseFirestore.instance
        .collection('places')
        .doc(widget.place.id)
        .get();

    if (doc.exists) {
      final data = doc.data()!;

      setState(() {
        averageRating = (data['rating'] ?? 0).toDouble();
        ratingCount = (data['ratingsCount'] ?? 0);
      });
    }
  }

  Future<void> _addComment() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала войдите в аккаунт')),
      );
      return;
    }

    if (_commentController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection('places')
        .doc(widget.place.id)
        .collection('comments')
        .add({
      'text': _commentController.text.trim(),
      'userId': user.uid,
      'userName': user.email ?? 'User',
      'createdAt': FieldValue.serverTimestamp(),
    });

    _commentController.clear();
  }

  Future<void> _openUrl(String? url) async {
    if (url == null || url.isEmpty) return;

    final uri = Uri.parse(url);

    bool ok = await launchUrl(uri);

    if (!ok) {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    if (phone.isEmpty) return;

    String cleanedPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final Uri uri = Uri.parse("https://wa.me/$cleanedPhone");

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _circleImageButton({
    required String assetPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFD4B483), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset(assetPath, fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget _ratingStars() {
    if (isLoadingRating) {
      return const Center(child: CircularProgressIndicator());
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;

        return IconButton(
          icon: Icon(
            starIndex <= selectedRating
                ? Icons.star
                : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: () async {
            final user = FirebaseAuth.instance.currentUser;

            if (user == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Сначала войдите в аккаунт')),
              );
              return;
            }

            setState(() {
              selectedRating = starIndex.toDouble();
            });

            await RatingService.ratePlace(
              placeId: widget.place.id,
              rating: selectedRating,
            );

            await _loadAverageRating();
          },
        );
      }),
    );
  }

  Widget _ecoRatingBlock(Place place) {
    final eco = place.ecoRating;

    
      print(place.ecoRating.cleanliness);
      print(place.ecoRating.localProducts);
      print(place.ecoRating.noPlastic);
      print('ECO SCORE = ${eco.score}');

    Widget stars(int count) {
      return Row(
        children: List.generate(5, (i) {
          return Icon(
            i < count ? Icons.star : Icons.star_border,
            size: 16,
            color: Colors.green,
          );
        }),
      );
    }

    final score =
    '${eco.cleanliness}-${eco.localProducts}-${eco.noPlastic}';;

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F6F0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("🌿 Eco Rating: $score",
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          _ecoRow("Благоустройство", stars(eco.cleanliness)),
          _ecoRow("Вкус региона", stars(eco.localProducts)),
          _ecoRow("Экоупаковка", stars(eco.noPlastic)),
        ],
      ),
    );
  }

  Widget _ecoRow(String title, Widget stars) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        stars,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5EBDD),
        appBar: AppBar(
          title: Text(widget.place.name),
        ),

        /// 🔥 ВОТ ЕДИНСТВЕННОЕ ДОБАВЛЕНИЕ
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('places')
              .doc(widget.place.id)
              .snapshots(),
          builder: (context, snapshot) {

            if (!snapshot.hasData || !snapshot.data!.exists) {
             return const Center(child: CircularProgressIndicator());
             }

             final place = Place.fromFirestore(snapshot.data!);

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).viewPadding.bottom + 40,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 240,
                    child: Column(
                      children: [
                        Expanded(
                          child: PageView.builder(
                            itemCount: place.gallery.isNotEmpty
                                ? place.gallery.length
                                : 1,
                            onPageChanged: (index) {
                              setState(() {
                                currentIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final imageUrl = place.gallery.isNotEmpty
                                  ? place.gallery[index]
                                  : place.mainImage;

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FullScreenGallery(
                                        images: place.gallery.isNotEmpty
                                            ? place.gallery
                                            : [place.mainImage],
                                        initialIndex: index,
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(22),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            place.gallery.isNotEmpty ? place.gallery.length : 1,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: currentIndex == index ? 10 : 6,
                              height: currentIndex == index ? 10 : 6,
                              decoration: BoxDecoration(
                                color: currentIndex == index
                                    ? const Color(0xFFD4B483)
                                    : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFD4B483)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow(Icons.restaurant, loc.cuisine, place.cuisine),
                        const SizedBox(height: 12),
                        _infoRow(Icons.access_time, loc.schedule, place.schedule),
                        const SizedBox(height: 12),
                        _infoRow(Icons.phone, loc.phone, place.phone),

const SizedBox(height: 20),

Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    const Icon(Icons.star, color: Colors.amber, size: 20),

    const SizedBox(width: 6),

    Text(
      averageRating.toStringAsFixed(1),
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),

    const SizedBox(width: 6),

    Text(
      '($ratingCount)',
      style: const TextStyle(
        color: Colors.grey,
      ),
    ),
  ],
),

const SizedBox(height: 8),

Text(loc.ratePlace),

const SizedBox(height: 8),

_ratingStars(),

/// 🌿 ECO BLOCK ПОД ЗВЁЗДАМИ
_ecoRatingBlock(place),

const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MenuScreen(
                                    placeId: place.id,
                                    placeName: place.name,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.menu_book),
                            label: Text(loc.menu),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _circleImageButton(
                              assetPath: 'assets/icon/instagram.png',
                              onTap: () => _openUrl(place.instagramUrl),
                            ),
                            _circleImageButton(
                              assetPath: 'assets/icon/2gis.png',
                              onTap: () => _openUrl(place.mapUrl),
                            ),
                            _circleImageButton(
                              assetPath: 'assets/icon/phone.png',
                              onTap: () => _openWhatsApp(place.phone),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFD4B483)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loc.aboutPlace),
                        const SizedBox(height: 10),
                        Text(
                          place.description.isNotEmpty
                              ? place.description
                              : loc.noDescription,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFD4B483)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Отзывы',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),

                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('places')
                              .doc(widget.place.id)
                              .collection('comments')
                              .orderBy('createdAt', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const CircularProgressIndicator();
                            }

                            final docs = snapshot.data!.docs;

                            if (docs.isEmpty) {
                              return const Text('Пока нет отзывов');
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                final data = docs[index];

                                return ListTile(
                                  title: Text(data['userName'] ?? ''),
                                  subtitle: Text(data['text'] ?? ''),
                                );
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                enabled: FirebaseAuth.instance.currentUser != null,
                                decoration: InputDecoration(
                                  hintText: FirebaseAuth.instance.currentUser != null
                                      ? 'Написать отзыв...'
                                      : 'Войдите, чтобы писать',
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: FirebaseAuth.instance.currentUser != null
                                  ? _addComment
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFD4B483)),
        const SizedBox(width: 10),
        Expanded(child: Text('$title: $value')),
      ],
    );
  }
}