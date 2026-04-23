import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:re_use/types/data_seeding.dart';
import 'package:re_use/types/item.dart';

class ItemService {
  ItemService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _itemsCollection =>
      _firestore.collection('items');

  Stream<List<Item>> watchItems() {
    return _itemsCollection.snapshots().map((
      QuerySnapshot<Map<String, dynamic>> snapshot,
    ) {
      return snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
            return Item.fromMap(doc.data(), id: doc.id);
          })
          .toList(growable: false);
    });
  }

  Future<void> seedItemsIfEmpty() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _itemsCollection
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return;
    }

    final WriteBatch batch = _firestore.batch();
    for (final Item item in seededItems) {
      final DocumentReference<Map<String, dynamic>> docRef = _itemsCollection
          .doc(item.id);
      batch.set(docRef, item.toMap());
    }

    await batch.commit();
  }
}
