import 'package:flutter/material.dart';
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
  GoogleMapController? mapController;

  // Standaard startpositie (bijv. Brussel)
  final LatLng _center = const LatLng(50.8503, 4.3517);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    // Zet de items om naar Markers.
    // We filteren items eruit die geen latitude of longitude hebben.
    final Set<Marker> markers = widget.items
        .where((item) => item.latitude != null && item.longitude != null)
        .map((item) {
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
                // Ga naar detailpagina als je op de info-window van een marker klikt
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailPage(item: item),
                  ),
                );
              },
            ),
          );
        })
        .toSet();

    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(target: _center, zoom: 11.0),
      markers: markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }
}
