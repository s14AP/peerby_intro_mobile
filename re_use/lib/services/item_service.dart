import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:re_use/types/item.dart';

class ItemService {
  final CollectionReference<Map<String, dynamic>> _itemsCollection =
      FirebaseFirestore.instance.collection('items');

  Stream<List<Item>> streamItems() {
    return _itemsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
          return snapshot.docs.map((
            QueryDocumentSnapshot<Map<String, dynamic>> doc,
          ) {
            return Item.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  Future<void> createItem(Item item) async {
    await _itemsCollection.add(item.toMap());
  }
}
