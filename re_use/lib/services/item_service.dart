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
        .get();

    final Set<String> existingIds = snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => doc.id)
        .toSet();

    final WriteBatch batch = _firestore.batch();
    int writeCount = 0;
    for (final Item item in seededItems) {
      if (existingIds.contains(item.id)) {
        continue;
      }

      final DocumentReference<Map<String, dynamic>> docRef = _itemsCollection
          .doc(item.id);
      batch.set(docRef, item.toMap());
      writeCount++;
    }

    if (writeCount == 0) {
      return;
    }

    await batch.commit();
  }
}
