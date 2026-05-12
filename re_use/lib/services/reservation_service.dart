import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:re_use/types/reservation.dart';

class ReservationService {
  ReservationService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('reservations');

  Future<void> createReservation(Reservation reservation) async {
    final DocumentReference<Map<String, dynamic>> docRef = _col.doc();
    final Reservation r = Reservation(
      id: docRef.id,
      itemId: reservation.itemId,
      itemTitle: reservation.itemTitle,
      itemImageUrl: reservation.itemImageUrl,
      ownerId: reservation.ownerId,
      renterId: reservation.renterId,
      renterName: reservation.renterName,
      renterAvatarUrl: reservation.renterAvatarUrl,
      startDate: reservation.startDate,
      endDate: reservation.endDate,
      message: reservation.message,
      price: reservation.price,
      typePayment: reservation.typePayment,
    );
    await docRef.set(r.toMap());
  }

  // Verhuurder: alle verzoeken op al zijn items
  Stream<List<Reservation>> watchForOwner(String ownerId) {
    return _col.where('ownerId', isEqualTo: ownerId).snapshots().map((
      QuerySnapshot<Map<String, dynamic>> s,
    ) {
      final List<Reservation> list = s.docs
          .map((d) => Reservation.fromMap(d.id, d.data()))
          .toList();
      list.sort((a, b) {
        final DateTime at = a.createdAt ?? DateTime(0);
        final DateTime bt = b.createdAt ?? DateTime(0);
        return bt.compareTo(at);
      });
      return list;
    });
  }

  // Huurder: eigen uitgaande verzoeken
  Stream<List<Reservation>> watchForRenter(String renterId) {
    return _col.where('renterId', isEqualTo: renterId).snapshots().map((
      QuerySnapshot<Map<String, dynamic>> s,
    ) {
      final List<Reservation> list = s.docs
          .map((d) => Reservation.fromMap(d.id, d.data()))
          .toList();
      list.sort((a, b) {
        final DateTime at = a.createdAt ?? DateTime(0);
        final DateTime bt = b.createdAt ?? DateTime(0);
        return bt.compareTo(at);
      });
      return list;
    });
  }

  // Verhuurder: verzoeken per specifiek item (voor de bottom sheet)
  Stream<List<Reservation>> watchForItem(String itemId) {
    return _col.where('itemId', isEqualTo: itemId).snapshots().map((
      QuerySnapshot<Map<String, dynamic>> s,
    ) {
      final List<Reservation> list = s.docs
          .map((d) => Reservation.fromMap(d.id, d.data()))
          .toList();
      list.sort((a, b) {
        final DateTime at = a.createdAt ?? DateTime(0);
        final DateTime bt = b.createdAt ?? DateTime(0);
        return bt.compareTo(at);
      });
      return list;
    });
  }

  Future<void> updateStatus(String id, ReservationStatus status) async {
    await _col.doc(id).update(<String, dynamic>{'status': status.name});
  }

  Future<bool> hasOverlap(String itemId, DateTime start, DateTime end) async {
    final QuerySnapshot<Map<String, dynamic>> snap = await _col
        .where('itemId', isEqualTo: itemId)
        .where('status', isEqualTo: 'accepted')
        .get();
    for (final doc in snap.docs) {
      final Map<String, dynamic> data = doc.data();
      final DateTime existingStart = (data['startDate'] as Timestamp).toDate();
      final DateTime existingEnd = (data['endDate'] as Timestamp).toDate();
      if (start.isBefore(existingEnd) && end.isAfter(existingStart)) {
        return true;
      }
    }
    return false;
  }
}
