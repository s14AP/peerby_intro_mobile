import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:re_use/types/item.dart';

const Color _textDark = Color(0xFF2F3E36);
const Color _borderColor = Color(0xFFD7E6DE);

class DetailSellerHeader extends StatefulWidget {
  const DetailSellerHeader({super.key, required this.item});
  final Item item;

  @override
  State<DetailSellerHeader> createState() => _DetailSellerHeaderState();
}

class _DetailSellerHeaderState extends State<DetailSellerHeader> {
  String? _distanceLabel;

  @override
  void initState() {
    super.initState();
    _fetchDistance();
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const double r = 6371;
    final double dLat = (lat2 - lat1) * pi / 180;
    final double dLon = (lon2 - lon1) * pi / 180;
    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  Future<void> _fetchDistance() async {
    if (widget.item.latitude == null || widget.item.longitude == null) return;
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final Position pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      final double km = _haversineKm(
        pos.latitude,
        pos.longitude,
        widget.item.latitude!,
        widget.item.longitude!,
      );
      if (!mounted) return;
      setState(() {
        _distanceLabel = km < 1
            ? '${(km * 1000).round()} m'
            : '${km.toStringAsFixed(1)} km';
      });
    } catch (_) {}
  }

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
            foregroundImage: NetworkImage(widget.item.ownerAvatarUrl),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.item.ownerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: _textDark,
                  ),
                ),
              ],
            ),
          ),
          if (_distanceLabel != null)
            Text(
              _distanceLabel!,
              style: const TextStyle(fontSize: 20, color: _textDark),
            ),
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
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color: _textDark,
            ),
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
                  beschikbaar =
                      '${fmt(item.availableFrom!)} – ${fmt(item.availableTo!)}';
                } else if (item.availableFrom != null) {
                  beschikbaar = 'Vanaf ${fmt(item.availableFrom!)}';
                } else if (item.availableTo != null) {
                  beschikbaar = 'Tot ${fmt(item.availableTo!)}';
                }
                return 'Categorie: ${item.category}\nLocatie: ${item.locationCity}, ${item.locationCountry}\nType: ${item.typePayment.name}\nBeschikbaarheid: $beschikbaar';
              }(),
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                color: _textDark,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            'Beschrijving',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color: _textDark,
            ),
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
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                color: _textDark,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            'Verkoper',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color: _textDark,
            ),
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
