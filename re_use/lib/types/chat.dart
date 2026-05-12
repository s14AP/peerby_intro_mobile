import 'package:cloud_firestore/cloud_firestore.dart';

class ChatConversation {
  final String id;
  final List<String> participants;
  final String buyerId;
  final String sellerId;
  final String itemId;
  final String itemTitle;
  final String itemImageUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String buyerName;
  final String sellerName;
  final String buyerAvatarUrl;
  final String sellerAvatarUrl;
  final double price;
  final String typePayment;

  const ChatConversation({
    required this.id,
    required this.participants,
    required this.buyerId,
    required this.sellerId,
    required this.itemId,
    required this.itemTitle,
    required this.itemImageUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.buyerName,
    required this.sellerName,
    required this.buyerAvatarUrl,
    required this.sellerAvatarUrl,
    required this.price,
    required this.typePayment,
  });

  static String buildId(String uid1, String uid2, String itemId) {
    final List<String> sorted = <String>[uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}_$itemId';
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'participants': participants,
    'buyerId': buyerId,
    'sellerId': sellerId,
    'itemId': itemId,
    'itemTitle': itemTitle,
    'itemImageUrl': itemImageUrl,
    'lastMessage': lastMessage,
    'lastMessageTime': Timestamp.fromDate(lastMessageTime),
    'buyerName': buyerName,
    'sellerName': sellerName,
    'buyerAvatarUrl': buyerAvatarUrl,
    'sellerAvatarUrl': sellerAvatarUrl,
    'price': price,
    'typePayment': typePayment,
  };

  factory ChatConversation.fromMap(String id, Map<String, dynamic> map) =>
      ChatConversation(
        id: id,
        participants: List<String>.from(map['participants'] as List<dynamic>),
        buyerId: map['buyerId'] as String,
        sellerId: map['sellerId'] as String,
        itemId: map['itemId'] as String,
        itemTitle: map['itemTitle'] as String,
        itemImageUrl: map['itemImageUrl'] as String? ?? '',
        lastMessage: map['lastMessage'] as String? ?? '',
        lastMessageTime:
            (map['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
        buyerName: map['buyerName'] as String? ?? '',
        sellerName: map['sellerName'] as String? ?? '',
        buyerAvatarUrl: map['buyerAvatarUrl'] as String? ?? '',
        sellerAvatarUrl: map['sellerAvatarUrl'] as String? ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
        typePayment: map['typePayment'] as String? ?? '',
      );
}

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => <String, dynamic>{
    'senderId': senderId,
    'text': text,
    'timestamp': Timestamp.fromDate(timestamp),
  };

  factory ChatMessage.fromMap(String id, Map<String, dynamic> map) =>
      ChatMessage(
        id: id,
        senderId: map['senderId'] as String,
        text: map['text'] as String,
        timestamp:
            (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}
