import 'package:flutter/material.dart';
import 'package:re_use/components/bottomNavBar.dart';
import 'package:re_use/components/card.dart';
import 'package:re_use/services/item_service.dart';
import 'package:re_use/types/data_seeding.dart';
import 'package:re_use/screens/detailpage/detailpage.dart';
import 'package:re_use/types/item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static final ItemService _itemService = ItemService();

  static const Color _pageBackground = Color(0xFFF3FAF7);
  static const Color _headerTeal = Color(0xFF6F9476);
  static const Color _textDark = Color(0xFF2F3E36);
  static const Color _filterFill = Color(0xFFE3EEE9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: _pageBackground,
      // -- APP BAR ------------------------------------------------------
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
            Transform.translate(
              offset: const Offset(0, 0),
              child: const Text(
                'e-use',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: _filterFill),
        ),
        actions: <Widget>[
          _HeaderActionIcon(assetPath: 'assets/navBar/map.png', onTap: () {}),
          Padding(
            padding: const EdgeInsets.only(right: 28),
            child: _HeaderActionIcon(
              assetPath: 'assets/navBar/bell.png',
              onTap: () {},
            ),
          ),
        ],
      ),

      // -- BODY: filter row + item grid --------------------------------------
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 28,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    _FilterPlaceholderButton(label: 'Afstand'),
                    SizedBox(width: 8),
                    _FilterPlaceholderButton(label: 'Categorie'),
                    SizedBox(width: 8),
                    _FilterPlaceholderButton(label: 'Prijs'),
                  ],
                ),
              ),
            ),

            // -- ITEM GRID ----------------------------------------------
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<Item>>(
                stream: _itemService.watchItems(),
                builder: (BuildContext context, AsyncSnapshot<List<Item>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Could not load items.'));
                  }

                  final List<Item> items = snapshot.data ?? <Item>[];
                  if (items.isEmpty) {
                    return const Center(child: Text('No items available yet.'));
                  }

                  return GridView.builder(
                    itemCount: items.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.69,
                        ),
                    itemBuilder: (BuildContext context, int index) {
                      final Item item = items[index];
                      final bool hasDecimals =
                          item.price.truncateToDouble() != item.price;
                      final String priceText = item.price == 0
                          ? 'Free'
                          : '€${item.price.toStringAsFixed(hasDecimals ? 2 : 0)} / ${item.typePayment.name}';

                      return GestureDetector(
                        onTap: () {
                          // Custom Route with NO animation
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      DetailPage(item: item),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    return child; // Returns the page immediately
                                  },
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
                  ); // <-- FIXED: Added missing semicolon to close GridView.builder
                }, // <-- FIXED: Added missing brace to close the StreamBuilder builder
              ),
            ),
          ],
        ),
      ),

      // -- BOTTOM NAV BAR ------------------------------------------------------
      bottomNavigationBar: BottomNavBar(
        onHomeTap: () {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const HomePage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
      ),
    );
  }
}

// -- HELPER WIDGETS -----------------------------------------------------------

class _FilterPlaceholderButton extends StatelessWidget {
  const _FilterPlaceholderButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: HomePage._filterFill,
          side: const BorderSide(color: HomePage._headerTeal, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: Row(
          children: <Widget>[
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: HomePage._textDark,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: HomePage._textDark,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderActionIcon extends StatelessWidget {
  const _HeaderActionIcon({
    required this.assetPath,
    required this.onTap,
    this.color,
  });

  final String assetPath;
  final VoidCallback onTap;
  final Color? color;

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
            assetPath,
            width: 24,
            height: 24,
            color: Colors.white,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
