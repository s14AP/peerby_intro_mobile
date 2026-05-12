import 'package:cloud_firestore/cloud_firestore.dart';
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
      availableFrom: item.availableFrom,
      availableTo: item.availableTo,
    );

    await docRef.set(itemWithId.toMap());
  }

  Future<void> deleteItem(String id) async {
    await _itemsCollection.doc(id).delete();
  }
}
