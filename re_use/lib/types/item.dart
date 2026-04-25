import 'package:cloud_firestore/cloud_firestore.dart';

enum TypePayment { uur, dag, week, maand }

TypePayment typePaymentFromString(String value) {
  return TypePayment.values.firstWhere(
    (TypePayment type) => type.name == value,
    orElse: () => TypePayment.dag,
  );
}

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
    this.ownerId = '',
    this.createdAt,
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
  final String ownerId;
  final DateTime? createdAt;

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
      'ownerId': ownerId,
      // Keep server ordering consistent across devices.
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
    };
  }

  factory Item.fromMap(String id, Map<String, dynamic> map) {
    final Object? createdRaw = map['createdAt'];
    final DateTime? createdAt = createdRaw is Timestamp
        ? createdRaw.toDate()
        : null;

    return Item(
      id: id,
      title: (map['title'] ?? '') as String,
      description: map['description'] as String?,
      locationCity: (map['locationCity'] ?? '') as String,
      locationCountry: (map['locationCountry'] ?? '') as String,
      imageUrl: (map['imageUrl'] ?? '') as String,
      ownerName: (map['ownerName'] ?? '') as String,
      ownerAvatarUrl: (map['ownerAvatarUrl'] ?? '') as String,
      category: (map['category'] ?? '') as String,
      typePayment: typePaymentFromString(
        (map['typePayment'] ?? 'dag') as String,
      ),
      price: ((map['price'] ?? 0) as num).toDouble(),
      ownerId: (map['ownerId'] ?? '') as String,
      createdAt: createdAt,
    );
  }
}
