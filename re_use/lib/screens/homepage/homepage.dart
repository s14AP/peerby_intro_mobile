import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:re_use/components/bottomNavBar.dart';
import 'package:re_use/components/card.dart';
import 'package:re_use/components/mapView.dart';
import 'package:re_use/screens/chat/chat_list_screen.dart';
import 'package:re_use/screens/createpage/create_listing_screen.dart';
import 'package:re_use/screens/homepage/home_filters.dart';
import 'package:re_use/services/item_service.dart';
import 'package:re_use/screens/detailpage/detailpage.dart';
import 'package:re_use/screens/profilepage/profile_page.dart';
import 'package:re_use/types/item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ItemService _itemService = ItemService();

  static const Color _pageBackground = Color(0xFFF3FAF7);
  static const Color _headerTeal = Color(0xFF6F9476);
  static const Color _filterFill = Color(0xFFE3EEE9);

  bool _showMap = false;

  // User location
  Position? _userPosition;

  // Active filters — null means "no filter applied"
  double? _filterMaxDistance; // km
  String? _filterCategory;
  TypePayment? _filterTypePayment;
  double? _filterMaxPrice;

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
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return;
      }
      final Position pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      if (mounted) setState(() => _userPosition = pos);
    } catch (_) {
      // Location unavailable — distance filter will be hidden
    }
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

  List<Item> _applyFilters(List<Item> items) {
    return items.where((Item item) {
      if (_filterMaxDistance != null && _userPosition != null) {
        if (item.latitude == null || item.longitude == null) return false;
        final double km = _haversineKm(
          _userPosition!.latitude,
          _userPosition!.longitude,
          item.latitude!,
          item.longitude!,
        );
        if (km > _filterMaxDistance!) return false;
      }
      if (_filterCategory != null && item.category != _filterCategory) {
        return false;
      }
      if (_filterTypePayment != null &&
          item.typePayment != _filterTypePayment) {
        return false;
      }
      if (_filterMaxPrice != null && item.price > _filterMaxPrice!) {
        return false;
      }
      return true;
    }).toList();
  }

  String _typeLabel(TypePayment type) {
    switch (type) {
      case TypePayment.uur:
        return 'Per uur';
      case TypePayment.dag:
        return 'Per dag';
      case TypePayment.week:
        return 'Per week';
      case TypePayment.maand:
        return 'Per maand';
    }
  }

  void _showDistanceFilter(BuildContext ctx) {
    if (_userPosition == null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text(
            'Locatie niet beschikbaar. Controleer je instellingen.',
          ),
        ),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => HomeDistanceSheet(
        current: _filterMaxDistance,
        onSelect: (double? v) => setState(() => _filterMaxDistance = v),
      ),
    );
  }

  void _showCategoryFilter(BuildContext ctx, List<String> categories) {
    showModalBottomSheet<void>(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => HomeOptionSheet(
        title: 'Categorie',
        options: categories,
        selected: _filterCategory,
        useChips: true,
        onSelect: (String? v) => setState(() => _filterCategory = v),
      ),
    );
  }

  void _showPriceFilter(BuildContext ctx, double maxAvailable) {
    showModalBottomSheet<void>(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => HomeSliderSheet(
        title: 'Max prijs',
        unit: '€',
        unitBefore: true,
        maxAvailable: maxAvailable,
        current: _filterMaxPrice,
        onSelect: (double? v) => setState(() => _filterMaxPrice = v),
      ),
    );
  }

  void _showTypeFilter(BuildContext ctx) {
    final List<String> labels = TypePayment.values.map(_typeLabel).toList();
    final String? selectedLabel = _filterTypePayment != null
        ? _typeLabel(_filterTypePayment!)
        : null;

    showModalBottomSheet<void>(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => HomeOptionSheet(
        title: 'Type',
        options: labels,
        selected: selectedLabel,
        onSelect: (String? v) {
          setState(() {
            _filterTypePayment = v != null
                ? TypePayment.values.firstWhere((t) => _typeLabel(t) == v)
                : null;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: _pageBackground,
      // -- APP BAR ----------------------------------------------------------
      appBar: AppBar(
        backgroundColor: _headerTeal,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 76,
        titleSpacing: 20,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: 0.84,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'assets/login/Logo.png',
                    height: 40,
                    width: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 3),
            const Text(
              'e-use',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: _filterFill),
        ),
        actions: <Widget>[
          HomeHeaderActionIcon(
            assetPath: _showMap
                ? 'assets/navBar/list.png'
                : 'assets/navBar/map.png',
            onTap: () => setState(() => _showMap = !_showMap),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 28),
            child: HomeHeaderActionIcon(
              assetPath: 'assets/navBar/bell.png',
              onTap: () {},
            ),
          ),
        ],
      ),

      // -- BODY -------------------------------------------------------------
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        child: StreamBuilder<List<Item>>(
          stream: _itemService.watchItems(),
          builder: (BuildContext context, AsyncSnapshot<List<Item>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text('Could not load listings right now.'),
              );
            }

            final List<Item> allItems = snapshot.data ?? <Item>[];
            final List<Item> filteredItems = _applyFilters(allItems);

            final List<String> categories =
                allItems.map((Item i) => i.category).toSet().toList()..sort();
            final double maxPrice = allItems.isEmpty
                ? 100.0
                : max(
                    50.0,
                    allItems
                        .map((Item i) => i.price)
                        .reduce((double a, double b) => a > b ? a : b),
                  );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // -- FILTER ROW (hidden in map mode) ----------------------
                if (!_showMap) ...<Widget>[
                  SizedBox(
                    height: 36,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          HomeFilterButton(
                            label: _filterMaxDistance != null
                                ? '≤ ${_filterMaxDistance!.toStringAsFixed(0)} km'
                                : 'Afstand',
                            active: _filterMaxDistance != null,
                            disabled: _userPosition == null,
                            onTap: () => _showDistanceFilter(context),
                          ),
                          const SizedBox(width: 8),
                          HomeFilterButton(
                            label: _filterCategory ?? 'Categorie',
                            active: _filterCategory != null,
                            onTap: () =>
                                _showCategoryFilter(context, categories),
                          ),
                          const SizedBox(width: 8),
                          HomeFilterButton(
                            label: _filterMaxPrice != null
                                ? '≤ €${_filterMaxPrice!.toStringAsFixed(0)}'
                                : 'Prijs',
                            active: _filterMaxPrice != null,
                            onTap: () => _showPriceFilter(context, maxPrice),
                          ),
                          const SizedBox(width: 8),
                          HomeFilterButton(
                            label: _filterTypePayment != null
                                ? _typeLabel(_filterTypePayment!)
                                : 'Type',
                            active: _filterTypePayment != null,
                            onTap: () => _showTypeFilter(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // -- ITEM GRID OR MAP -------------------------------------
                Expanded(
                  child: filteredItems.isEmpty
                      ? const Center(child: Text('Geen items gevonden.'))
                      : _showMap
                      ? Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).padding.bottom,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: ItemMapView(items: filteredItems),
                          ),
                        )
                      : GridView.builder(
                          itemCount: filteredItems.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.69,
                              ),
                          itemBuilder: (BuildContext context, int index) {
                            final Item item = filteredItems[index];
                            final bool hasDecimals =
                                item.price.truncateToDouble() != item.price;
                            final String priceText = item.price == 0
                                ? 'Gratis'
                                : '€${item.price.toStringAsFixed(hasDecimals ? 2 : 0)} / ${item.typePayment.name}';

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          BuildContext context,
                                          Animation<double> animation,
                                          Animation<double> secondaryAnimation,
                                        ) => DetailPage(item: item),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                    transitionsBuilder:
                                        (
                                          BuildContext context,
                                          Animation<double> animation,
                                          Animation<double> secondaryAnimation,
                                          Widget child,
                                        ) => child,
                                  ),
                                );
                              },
                              child: ItemCard(
                                title: item.title,
                                distance: item.locationCity,
                                imageUrl: item.imageUrl,
                                ownerName: item.ownerName,
                                ownerAvatarUrl: item.ownerAvatarUrl,
                                price: priceText,
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),

      // -- BOTTOM NAV BAR ---------------------------------------------------
      bottomNavigationBar: BottomNavBar(
        onHomeTap: () {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder<void>(
              pageBuilder: (ctx, anim, secAnim) => const HomePage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              transitionsBuilder: (ctx, anim, secAnim, child) => child,
            ),
          );
        },
        onChatTap: () {
          Navigator.of(context).push(
            PageRouteBuilder<void>(
              pageBuilder: (ctx, anim, secAnim) => const ChatListScreen(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              transitionsBuilder: (ctx, anim, secAnim, child) => child,
            ),
          );
        },
        onAddTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const CreateListingScreen(),
            ),
          );
        },
        onProfileTap: () {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder<void>(
              pageBuilder: (ctx, anim, secAnim) => const ProfilePage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              transitionsBuilder: (ctx, anim, secAnim, child) => child,
            ),
          );
        },
      ),
    );
  }
}
