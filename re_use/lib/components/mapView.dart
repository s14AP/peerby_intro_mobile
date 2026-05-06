import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:re_use/types/item.dart';
import 'package:re_use/screens/detailpage/detailpage.dart';

class ItemMapView extends StatefulWidget {
  const ItemMapView({super.key, required this.items});

  final List<Item> items;

  @override
  State<ItemMapView> createState() => _ItemMapViewState();
}

class _ItemMapViewState extends State<ItemMapView> {
  GoogleMapController? _mapController;
  LatLng? _userLocation;

  // Belgium center as fallback
  static const LatLng _fallbackCenter = LatLng(50.85, 4.35);

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
  }

  Future<void> _fetchUserLocation() async {
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
      if (!mounted) return;
      _userLocation = LatLng(pos.latitude, pos.longitude);
      _animateToUser();
    } catch (_) {
      // Location unavailable — stay on fallback center
    }
  }

  void _animateToUser() {
    final LatLng? loc = _userLocation;
    if (loc == null || _mapController == null) return;
    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(loc, 12.0),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _animateToUser();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Set<Marker> markers = widget.items
        .where((Item item) => item.latitude != null && item.longitude != null)
        .map((Item item) {
          final bool hasDecimals = item.price.truncateToDouble() != item.price;
          final String priceText = item.price == 0
              ? 'Gratis'
              : '€${item.price.toStringAsFixed(hasDecimals ? 2 : 0)} / ${item.typePayment.name}';

          return Marker(
            markerId: MarkerId(item.id),
            position: LatLng(item.latitude!, item.longitude!),
            infoWindow: InfoWindow(
              title: item.title,
              snippet: priceText,
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder<void>(
                    pageBuilder: (ctx, anim, secAnim) => DetailPage(item: item),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                    transitionsBuilder: (ctx, anim, secAnim, child) => child,
                  ),
                );
              },
            ),
          );
        })
        .toSet();

    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: const CameraPosition(
        target: _fallbackCenter,
        zoom: 7.5,
      ),
      markers: markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }
}
