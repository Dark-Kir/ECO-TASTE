import 'package:cloud_firestore/cloud_firestore.dart';

/// 🌿 ECO MODEL
class EcoRating {
  final int cleanliness;
  final int localProducts;
  final int noPlastic;

  const EcoRating({
    required this.cleanliness,
    required this.localProducts,
    required this.noPlastic,
  });

  factory EcoRating.fromMap(Map<String, dynamic> map) {

  int parse(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    if (value is double) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }

  return EcoRating(
    cleanliness: parse(map['cleanliness']),
    localProducts: parse(map['localProducts']),
    noPlastic: parse(map['noPlastic']),
  );
} 

  double get score {
    return (cleanliness + localProducts + noPlastic) / 3;
  }
}

class Place {
  final String id;
  final String name;
  final String category;
  final String subcategory;
  final String location;
  final String cuisine;
  final double rating;
  final String phone;
  final String schedule;
  final String description;

  final String mainImage;
  final String logo;

  final String extraInfo;
  final List<String> gallery;

  final String? instagramUrl;
  final String? mapUrl;

  /// 🌿 ECO
  final EcoRating ecoRating;

  const Place({
    required this.id,
    required this.name,
    required this.category,
    required this.subcategory,
    required this.location,
    required this.cuisine,
    required this.rating,
    required this.phone,
    required this.schedule,
    required this.description,
    required this.extraInfo,
    required this.gallery,
    this.mainImage = '',
    this.logo = '',
    this.instagramUrl,
    this.mapUrl,
    required this.ecoRating,
  });

  factory Place.fromMap(String id, Map<String, dynamic> map) {
    print('INSTAGRAM RAW: ${map['instagramUrl']}');
    print('MAP RAW: ${map['mapUrl']}');

    final instagram = _cleanUrl(map['instagramUrl']);
    final mapUrl = _cleanUrl(map['mapUrl']);

    print('INSTAGRAM CLEAN: $instagram');
    print('MAP CLEAN: $mapUrl');

    /// 🔥 ВАЖНЫЙ FIX ЗДЕСЬ
    final ecoMap = Map<String, dynamic>.from(
  map['ecoRating'] ?? {},
);

print('ECO MAP FROM FIREBASE: $ecoMap');

    return Place(
      id: id,
      name: (map['name'] ?? '').toString(),
      category: (map['category'] ?? '').toString(),
      subcategory: (map['subcategory'] ?? '').toString(),
      location: (map['location'] ?? '').toString(),
      cuisine: (map['cuisine'] ?? '').toString(),
      rating: (map['rating'] ?? 0).toDouble(),
      phone: (map['phone'] ?? '').toString(),
      schedule: (map['schedule'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      extraInfo: (map['extraInfo'] ?? '').toString(),

      gallery: (map['gallery'] is List)
          ? List<String>.from(map['gallery'])
          : [],

      mainImage: (map['mainImage'] ?? '').toString().trim(),
      logo: (map['logo'] ?? '').toString().trim(),

      instagramUrl: instagram,
      mapUrl: mapUrl,

      /// 🌿 FIXED
      ecoRating: EcoRating.fromMap(ecoMap),
    );
  }

  factory Place.fromFirestore(DocumentSnapshot doc) {

  final raw = doc.data();

  print('RAW DOC = $raw');

  final data = Map<String, dynamic>.from(
    raw as Map,
  );

  return Place.fromMap(doc.id, data);
}

  static String? _cleanUrl(dynamic value) {
    if (value == null) return null;

    String url = value.toString().trim();

    url = url.replaceAll('\n', '');
    url = url.replaceAll('\r', '');
    url = url.replaceAll('"', '');

    if (!url.startsWith('http')) {
      url = 'https://$url';
    }

    return url;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'subcategory': subcategory,
      'location': location,
      'cuisine': cuisine,
      'rating': rating,
      'phone': phone,
      'schedule': schedule,
      'description': description,
      'extraInfo': extraInfo,
      'gallery': gallery,
      'mainImage': mainImage,
      'logo': logo,
      'instagramUrl': instagramUrl,
      'mapUrl': mapUrl,

      /// 🌿 ECO SAVE
      'ecoRating': {
        'cleanliness': ecoRating.cleanliness,
        'localProducts': ecoRating.localProducts,
        'noPlastic': ecoRating.noPlastic,
      },
    };
  }
}