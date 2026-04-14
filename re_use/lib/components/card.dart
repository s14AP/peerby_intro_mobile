import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  static const double _imageHeight = 140;

  final String title;
  final String distance;
  final String imageUrl;
  final String ownerName;
  final String ownerAvatarUrl;
  final String price; // the ? means optional — some items are free to borrow

  const ItemCard({
    super.key,
    required this.title,
    required this.distance,
    required this.imageUrl,
    required this.ownerName,
    required this.ownerAvatarUrl,
    required this.price, // no 'required' because it's optional
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2), // changes position of shadow
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
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color.fromARGB(255, 219, 219, 219),
                      width: 1,
                    ),
                  ),
                ),
                child: SizedBox(
                  height: _imageHeight,
                  width: double.infinity,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFF2F2F2),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: Color(0xFF9A9A9A),
                          size: 28,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // price badge (only shows if price is passed in)
              if (price != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xD9000000),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      price!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // ── BOTTOM: text info ────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // item title
                SizedBox(
                  height: 34,
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // owner row
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFEEEEEE),
                      foregroundImage: NetworkImage(ownerAvatarUrl),
                      radius: 9,
                      child: const Icon(
                        Icons.person,
                        size: 11,
                        color: Color(0xFF7A7A7A),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        ownerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8A8A8A),
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
                      color: Color(0xFF8A8A8A),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        distance,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8A8A8A),
                        ),
                      ),
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
