import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:re_use/components/bottomNavBar.dart';
import 'package:re_use/components/card.dart';
import 'package:re_use/components/mapView.dart';
import 'package:re_use/screens/createpage/create_listing_screen.dart';
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
        if (item.latitude != null && item.longitude != null) {
          final double km = _haversineKm(
            _userPosition!.latitude,
            _userPosition!.longitude,
            item.latitude!,
            item.longitude!,
          );
          if (km > _filterMaxDistance!) return false;
        }
        // Items without coordinates are always shown
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
      builder: (_) => _DistanceSheet(
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
      builder: (_) => _OptionSheet(
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
      builder: (_) => _SliderSheet(
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
      builder: (_) => _OptionSheet(
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
          _HeaderActionIcon(
            assetPath: _showMap
                ? 'assets/navBar/list.png'
                : 'assets/navBar/map.png',
            onTap: () => setState(() => _showMap = !_showMap),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 28),
            child: _HeaderActionIcon(
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
                // -- FILTER ROW -------------------------------------------
                SizedBox(
                  height: 36,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        _FilterButton(
                          label: _filterMaxDistance != null
                              ? '≤ ${_filterMaxDistance!.toStringAsFixed(0)} km'
                              : 'Afstand',
                          active: _filterMaxDistance != null,
                          disabled: _userPosition == null,
                          onTap: () => _showDistanceFilter(context),
                        ),
                        const SizedBox(width: 8),
                        _FilterButton(
                          label: _filterCategory ?? 'Categorie',
                          active: _filterCategory != null,
                          onTap: () => _showCategoryFilter(context, categories),
                        ),
                        const SizedBox(width: 8),
                        _FilterButton(
                          label: _filterMaxPrice != null
                              ? '≤ €${_filterMaxPrice!.toStringAsFixed(0)}'
                              : 'Prijs',
                          active: _filterMaxPrice != null,
                          onTap: () => _showPriceFilter(context, maxPrice),
                        ),
                        const SizedBox(width: 8),
                        _FilterButton(
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

                // -- ITEM GRID OR MAP -------------------------------------
                const SizedBox(height: 12),
                Expanded(
                  child: filteredItems.isEmpty
                      ? const Center(child: Text('Geen items gevonden.'))
                      : _showMap
                      ? Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).padding.bottom + 78,
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
                                ? 'Free'
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
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const HomePage(),
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
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const ProfilePage(),
            ),
          );
        },
      ),
    );
  }
}

// -- FILTER BUTTON ------------------------------------------------------------

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.active,
    required this.onTap,
    this.disabled = false,
  });

  final String label;
  final bool active;
  final bool disabled;
  final VoidCallback onTap;

  static const Color _teal = Color(0xFF6F9476);
  static const Color _fill = Color(0xFFE3EEE9);
  static const Color _dark = Color(0xFF2F3E36);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: OutlinedButton(
        onPressed: disabled ? null : onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: active ? _teal : _fill,
          side: BorderSide(
            color: disabled ? Colors.grey.shade400 : _teal,
            width: 1,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          disabledBackgroundColor: Colors.grey.shade200,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: disabled
                    ? Colors.grey.shade500
                    : active
                    ? Colors.white
                    : _dark,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: disabled
                  ? Colors.grey.shade500
                  : active
                  ? Colors.white
                  : _dark,
            ),
          ],
        ),
      ),
    );
  }
}

// -- OPTION BOTTOM SHEET ------------------------------------------------------

class _OptionSheet extends StatelessWidget {
  const _OptionSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelect,
    this.useChips = false,
  });

  final String title;
  final List<String> options;
  final String? selected;
  final void Function(String?) onSelect;
  final bool useChips;

  void _pick(BuildContext context, String? value) {
    onSelect(value);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const Divider(height: 1),
          if (options.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Geen opties beschikbaar.'),
            )
          else if (useChips)
            _ChipBody(
              options: options,
              selected: selected,
              onPick: (String? v) => _pick(context, v),
            )
          else
            _ListBody(
              options: options,
              selected: selected,
              onPick: (String? v) => _pick(context, v),
            ),
        ],
      ),
    );
  }
}

// Chip/pill layout (categories)
class _ChipBody extends StatelessWidget {
  const _ChipBody({
    required this.options,
    required this.selected,
    required this.onPick,
  });

  final List<String> options;
  final String? selected;
  final void Function(String?) onPick;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            if (selected != null)
              _Chip(
                label: 'Alle',
                isActive: false,
                isClear: true,
                onTap: () => onPick(null),
              ),
            ...options.map(
              (String opt) => _Chip(
                label: opt,
                isActive: opt == selected,
                isClear: false,
                onTap: () => onPick(opt),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isActive,
    required this.isClear,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final bool isClear;
  final VoidCallback onTap;

  static const Color _teal = Color(0xFF6F9476);
  static const Color _dark = Color(0xFF2F3E36);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? _teal : const Color(0xFFE3EEE9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? _teal : const Color(0xFFB5CFC0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (isClear) ...<Widget>[
              const Icon(Icons.close, size: 13, color: _dark),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : _dark,
              ),
            ),
            if (isActive) ...<Widget>[
              const SizedBox(width: 4),
              const Icon(Icons.check, size: 13, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}

// Single-column list layout (type, city, etc.)
class _ListBody extends StatelessWidget {
  const _ListBody({
    required this.options,
    required this.selected,
    required this.onPick,
  });

  final List<String> options;
  final String? selected;
  final void Function(String?) onPick;

  static const Color _teal = Color(0xFF6F9476);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          if (selected != null)
            ListTile(
              leading: const Icon(Icons.clear, size: 20),
              title: const Text('Alle'),
              onTap: () => onPick(null),
            ),
          ...options.map(
            (String opt) => ListTile(
              title: Text(opt),
              trailing: selected == opt
                  ? const Icon(Icons.check, color: _teal)
                  : null,
              onTap: () => onPick(opt),
            ),
          ),
        ],
      ),
    );
  }
}

// -- DISTANCE SLIDER SHEET ----------------------------------------------------

class _DistanceSheet extends StatefulWidget {
  const _DistanceSheet({required this.current, required this.onSelect});

  final double? current;
  final void Function(double?) onSelect;

  @override
  State<_DistanceSheet> createState() => _DistanceSheetState();
}

class _DistanceSheetState extends State<_DistanceSheet> {
  static const double _maxKm = 50;
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.current ?? _maxKm;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Max afstand',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('0 km'),
                Text(
                  '${_value.toStringAsFixed(0)} km',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF6F9476),
                  ),
                ),
                const Text('50 km'),
              ],
            ),
            Slider(
              value: _value,
              min: 1,
              max: _maxKm,
              divisions: 49,
              activeColor: const Color(0xFF6F9476),
              onChanged: (double v) => setState(() => _value = v),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onSelect(null);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF6F9476)),
                    ),
                    child: const Text(
                      'Reset',
                      style: TextStyle(color: Color(0xFF6F9476)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSelect(_value < _maxKm ? _value : null);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6F9476),
                    ),
                    child: const Text(
                      'Toepassen',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// -- GENERIC SLIDER SHEET (price etc.) ----------------------------------------

class _SliderSheet extends StatefulWidget {
  const _SliderSheet({
    required this.title,
    required this.unit,
    required this.unitBefore,
    required this.maxAvailable,
    required this.current,
    required this.onSelect,
  });

  final String title;
  final String unit;
  final bool unitBefore;
  final double maxAvailable;
  final double? current;
  final void Function(double?) onSelect;

  @override
  State<_SliderSheet> createState() => _SliderSheetState();
}

class _SliderSheetState extends State<_SliderSheet> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.current ?? widget.maxAvailable;
  }

  String _fmt(double v) {
    final String num = v.toStringAsFixed(0);
    return widget.unitBefore ? '${widget.unit}$num' : '$num ${widget.unit}';
  }

  @override
  Widget build(BuildContext context) {
    final int divisions = widget.maxAvailable > 0
        ? widget.maxAvailable.clamp(10, 100).toInt()
        : 10;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(_fmt(0)),
                Text(
                  _fmt(_value),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF6F9476),
                  ),
                ),
                Text(_fmt(widget.maxAvailable)),
              ],
            ),
            Slider(
              value: _value,
              min: 0,
              max: widget.maxAvailable,
              divisions: divisions,
              activeColor: const Color(0xFF6F9476),
              onChanged: (double v) => setState(() => _value = v),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onSelect(null);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF6F9476)),
                    ),
                    child: const Text(
                      'Reset',
                      style: TextStyle(color: Color(0xFF6F9476)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSelect(
                        _value < widget.maxAvailable ? _value : null,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6F9476),
                    ),
                    child: const Text(
                      'Toepassen',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// -- HEADER ACTION ICON -------------------------------------------------------

class _HeaderActionIcon extends StatelessWidget {
  const _HeaderActionIcon({
    this.assetPath,
    this.iconOverride,
    required this.onTap,
  });

  final String? assetPath;
  final IconData? iconOverride;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: Image.asset(
            assetPath ?? '',
            width: 24,
            height: 24,
            color: Colors.white,
            fit: BoxFit.contain,
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stackTrace) =>
                    const Icon(Icons.map, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
