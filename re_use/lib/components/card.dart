import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final String title;
  final String distance;
  final String imageUrl;
  final String ownerName;
  final String ownerAvatarUrl;
  final String? price; // the ? means optional — some items are free to borrow

  const ItemCard({
    super.key,
    required this.title,
    required this.distance,
    required this.imageUrl,
    required this.ownerName,
    required this.ownerAvatarUrl,
    this.price, // no 'required' because it's optional
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      clipBehavior:
          Clip.hardEdge, // makes sure image respects the rounded corners
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── TOP: item image ──────────────────────────────
          Stack(
            children: [
              Image.network(
                imageUrl,
                height: 140,
                width: double.infinity, // full width of the card
                fit: BoxFit.cover,
              ),

              // price badge (only shows if price is passed in)
              if (price != null)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 130,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      price!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // ── BOTTOM: text info ────────────────────────────
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // item title
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                // owner row
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(ownerAvatarUrl),
                      radius: 10,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        ownerName,
                        overflow: TextOverflow.ellipsis,
                        // owner name — add color to the TextStyle
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // distance
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      distance,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
