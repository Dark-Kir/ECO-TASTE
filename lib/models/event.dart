class Event {
  final String id;
  final String name;
  final String date;
  final String time;
  final String location;
  final String image;
  final String description;
  final String phone;
  final String instagram;
  final String mapUrl;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.time,
    required this.location,
    required this.image,
    required this.description,
    required this.phone,
    required this.instagram,
    required this.mapUrl,
  });

  factory Event.fromFirestore(Map<String, dynamic> data, String id) {
    return Event(
      id: id,
      name: data['name'] ?? '',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      location: data['location'] ?? '',
      image: data['image'] ?? '',
      description: data['description'] ?? '',
      phone: data['phone'] ?? '',
      instagram: data['instagram'] ?? '',
      mapUrl: data['mapUrl'] ?? '',
    );
  }
}