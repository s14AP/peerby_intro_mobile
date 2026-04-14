enum TypePayment { hour, day, week, month }

class Item {
  const Item({
    required this.id,
    required this.title,
    this.description,
    required this.locationCity,
    required this.locationCountry,
    required this.imageUrl,
    required this.ownerName,
    required this.ownerAvatarUrl,
    required this.category,
    required this.typePayment,
    required this.price,
  });

  final String id;
  final String title;
  final String? description;
  final String locationCity;
  final String locationCountry;
  final String imageUrl;
  final String ownerName;
  final String ownerAvatarUrl;
  final String category;
  final TypePayment typePayment;
  final double price;
}
