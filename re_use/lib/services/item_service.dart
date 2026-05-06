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
            return Item.fromMap(doc.id, doc.data());
          })
          .toList(growable: false);
    });
  }

  Stream<List<Item>> streamItems() {
    return watchItems();
  }

  Future<void> createItem(Item item) async {
    final DocumentReference<Map<String, dynamic>> docRef = _itemsCollection
        .doc();
    final Item itemWithId = Item(
      id: docRef.id,
      title: item.title,
      description: item.description,
      locationCity: item.locationCity,
      locationCountry: item.locationCountry,
      imageUrl: item.imageUrl,
      ownerName: item.ownerName,
      ownerAvatarUrl: item.ownerAvatarUrl,
      category: item.category,
      typePayment: item.typePayment,
      price: item.price,
      ownerId: item.ownerId,
      latitude: item.latitude,
      longitude: item.longitude,
      createdAt: item.createdAt,
    );

    await docRef.set(itemWithId.toMap());
  }

  Future<void> seedItemsIfEmpty() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _itemsCollection
        .get();

    final Map<String, Map<String, dynamic>> existingDocs = {
      for (final doc in snapshot.docs) doc.id: doc.data(),
    };

    final WriteBatch batch = _firestore.batch();
    int writeCount = 0;
    for (final Item item in seededItems) {
      final DocumentReference<Map<String, dynamic>> docRef = _itemsCollection
          .doc(item.id);

      if (!existingDocs.containsKey(item.id)) {
        batch.set(docRef, item.toMap());
        writeCount++;
      } else {
        final Map<String, dynamic> existing = existingDocs[item.id]!;
        final bool needsPatch =
            existing['latitude'] != item.latitude ||
            existing['longitude'] != item.longitude ||
            existing['locationCity'] != item.locationCity ||
            existing['locationCountry'] != item.locationCountry;
        if (needsPatch) {
          batch.update(docRef, <String, dynamic>{
            'latitude': item.latitude,
            'longitude': item.longitude,
            'locationCity': item.locationCity,
            'locationCountry': item.locationCountry,
          });
          writeCount++;
        }
      }
    }

    if (writeCount == 0) {
      return;
    }

    await batch.commit();
  }
}
