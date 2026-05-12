import 'package:flutter/material.dart';
import 'package:re_use/types/item.dart';

const Color _textDark = Color(0xFF2F3E36);
const Color _textMuted = Color(0xFF5F6F67);
const Color _borderColor = Color(0xFFD7E6DE);

class DetailSellerHeader extends StatelessWidget {
  const DetailSellerHeader({super.key, required this.item});
  final Item item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: _borderColor),
          bottom: BorderSide(color: _borderColor),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFE0E0E0),
            foregroundImage: NetworkImage(item.ownerAvatarUrl),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.ownerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: _textDark,
                  ),
                ),
                const Text(
                  '★ 4.3 (23 reviews)',
                  style: TextStyle(fontSize: 11, color: _textMuted),
                ),
              ],
            ),
          ),
          const Text('5km', style: TextStyle(fontSize: 20, color: _textDark)),
        ],
      ),
    );
  }
}

class DetailInfoSection extends StatelessWidget {
  const DetailInfoSection({super.key, required this.item});
  final Item item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Divider(height: 1, thickness: 1, color: _borderColor),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            'Kenmerken',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400, color: _textDark),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EEEE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              () {
                String fmt(DateTime d) =>
                    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
                String beschikbaar = 'Altijd beschikbaar';
                if (item.availableFrom != null && item.availableTo != null) {
                  beschikbaar = '${fmt(item.availableFrom!)} – ${fmt(item.availableTo!)}';
                } else if (item.availableFrom != null) {
                  beschikbaar = 'Vanaf ${fmt(item.availableFrom!)}';
                } else if (item.availableTo != null) {
                  beschikbaar = 'Tot ${fmt(item.availableTo!)}';
                }
                return 'Categorie: ${item.category}\nLocatie: ${item.locationCity}, ${item.locationCountry}\nType: ${item.typePayment.name}\nBeschikbaarheid: $beschikbaar';
              }(),
              style: const TextStyle(fontSize: 13, height: 1.35, color: _textDark),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            'Beschrijving',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400, color: _textDark),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EEEE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.description ?? 'Geen beschrijving toegevoegd.',
              style: const TextStyle(fontSize: 13, height: 1.35, color: _textDark),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            'Verkoper',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400, color: _textDark),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFE0E0E0),
                foregroundImage: NetworkImage(item.ownerAvatarUrl),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.ownerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _textDark,
                      ),
                    ),
                    const Text(
                      '★ 4.3 (23 reviews)',
                      style: TextStyle(fontSize: 10.5, color: _textMuted),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Andere items van ${item.ownerName}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF2F5CA8),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  item.locationCity,
                  style: const TextStyle(fontSize: 12.5, color: _textDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
