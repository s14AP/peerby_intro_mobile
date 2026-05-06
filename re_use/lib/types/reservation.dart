import 'package:cloud_firestore/cloud_firestore.dart';

enum ReservationStatus { pending, accepted, rejected }

ReservationStatus reservationStatusFromString(String value) {
  return ReservationStatus.values.firstWhere(
    (ReservationStatus s) => s.name == value,
    orElse: () => ReservationStatus.pending,
  );
}

class Reservation {
  const Reservation({
    required this.id,
    required this.itemId,
    required this.itemTitle,
    required this.itemImageUrl,
    required this.ownerId,
    required this.renterId,
    required this.renterName,
    required this.renterAvatarUrl,
    required this.startDate,
    required this.endDate,
    this.message = '',
    this.status = ReservationStatus.pending,
    this.createdAt,
    required this.price,
    required this.typePayment,
  });

  final String id;
  final String itemId;
  final String itemTitle;
  final String itemImageUrl;
  final String ownerId; // uid van de verhuurder
  final String renterId; // uid van de huurder
  final String renterName;
  final String renterAvatarUrl;
  final DateTime startDate;
  final DateTime endDate;
  final String message;
  final ReservationStatus status;
  final DateTime? createdAt;
  final double price;
  final String typePayment;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'itemId': itemId,
    'itemTitle': itemTitle,
    'itemImageUrl': itemImageUrl,
    'ownerId': ownerId,
    'renterId': renterId,
    'renterName': renterName,
    'renterAvatarUrl': renterAvatarUrl,
    'startDate': Timestamp.fromDate(startDate),
    'endDate': Timestamp.fromDate(endDate),
    'message': message,
    'status': status.name,
    'createdAt': FieldValue.serverTimestamp(),
    'price': price,
    'typePayment': typePayment,
  };

  factory Reservation.fromMap(String id, Map<String, dynamic> map) {
    return Reservation(
      id: id,
      itemId: (map['itemId'] ?? '') as String,
      itemTitle: (map['itemTitle'] ?? '') as String,
      itemImageUrl: (map['itemImageUrl'] ?? '') as String,
      ownerId: (map['ownerId'] ?? '') as String,
      renterId: (map['renterId'] ?? '') as String,
      renterName: (map['renterName'] ?? '') as String,
      renterAvatarUrl: (map['renterAvatarUrl'] ?? '') as String,
      startDate: map['startDate'] is Timestamp
          ? (map['startDate'] as Timestamp).toDate()
          : DateTime.now(),
      endDate: map['endDate'] is Timestamp
          ? (map['endDate'] as Timestamp).toDate()
          : DateTime.now(),
      message: (map['message'] ?? '') as String,
      status: reservationStatusFromString(
        (map['status'] ?? 'pending') as String,
      ),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      price: ((map['price'] ?? 0) as num).toDouble(),
      typePayment: (map['typePayment'] ?? 'dag') as String,
    );
  }
}
