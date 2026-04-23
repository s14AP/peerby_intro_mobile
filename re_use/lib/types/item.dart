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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'locationCity': locationCity,
      'locationCountry': locationCountry,
      'imageUrl': imageUrl,
      'ownerName': ownerName,
      'ownerAvatarUrl': ownerAvatarUrl,
      'category': category,
      'typePayment': typePayment.name,
      'price': price,
    };
  }

  static Item fromMap(Map<String, dynamic> map, {required String id}) {
    return Item(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      locationCity: map['locationCity'] as String? ?? '',
      locationCountry: map['locationCountry'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      ownerName: map['ownerName'] as String? ?? '',
      ownerAvatarUrl: map['ownerAvatarUrl'] as String? ?? '',
      category: map['category'] as String? ?? '',
      typePayment: _typePaymentFromString(map['typePayment'] as String?),
      price: (map['price'] as num?)?.toDouble() ?? 0,
    );
  }

  static TypePayment _typePaymentFromString(String? value) {
    return TypePayment.values.firstWhere(
      (TypePayment type) => type.name == value,
      orElse: () => TypePayment.day,
    );
  }
}
