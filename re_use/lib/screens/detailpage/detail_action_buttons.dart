import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:re_use/screens/chat/chat_screen.dart';
import 'package:re_use/screens/reservations/reservation_request_sheet.dart';
import 'package:re_use/types/chat.dart';
import 'package:re_use/types/item.dart';

class DetailActionButtons extends StatelessWidget {
  const DetailActionButtons({super.key, required this.item});
  final Item item;

  static const Color _buttonColor = Color(0xFF7FAA8A);
  static const Color _disabledColor = Color(0xFFB5CAB9);

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    final bool isOwner = uid == item.ownerId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: isOwner
                  ? null
                  : () {
                      final User? user = FirebaseAuth.instance.currentUser;
                      if (user == null) return;
                      final String chatId = ChatConversation.buildId(
                        user.uid,
                        item.ownerId,
                        item.id,
                      );
                      final ChatConversation conversation = ChatConversation(
                        id: chatId,
                        participants: <String>[user.uid, item.ownerId],
                        buyerId: user.uid,
                        sellerId: item.ownerId,
                        itemId: item.id,
                        itemTitle: item.title,
                        itemImageUrl: item.imageUrl,
                        lastMessage: '',
                        lastMessageTime: DateTime.now(),
                        buyerName: user.displayName ?? 'Onbekend',
                        sellerName: item.ownerName,
                        buyerAvatarUrl: user.photoURL ?? '',
                        sellerAvatarUrl: item.ownerAvatarUrl,
                        price: item.price,
                        typePayment: item.typePayment.name,
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ChatScreen(conversation: conversation),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonColor,
                disabledBackgroundColor: _disabledColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              ),
              child: const Text(
                'CHAT',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, letterSpacing: 0.4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: isOwner
                  ? null
                  : () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => ReservationRequestSheet(item: item),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonColor,
                disabledBackgroundColor: _disabledColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              ),
              child: Text(
                isOwner ? 'Dit is jouw advertentie' : 'STUUR HUURVERZOEK',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
