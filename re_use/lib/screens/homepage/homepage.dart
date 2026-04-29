import 'package:flutter/material.dart';
import 'package:re_use/components/bottomNavBar.dart';
import 'package:re_use/components/card.dart';
import 'package:re_use/components/mapView.dart'; // <-- NIEUWE IMPORT
import 'package:re_use/screens/createpage/create_listing_screen.dart';
import 'package:re_use/services/item_service.dart';
import 'package:re_use/screens/detailpage/detailpage.dart';
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
  static const Color _textDark = Color(0xFF2F3E36);
  static const Color _filterFill = Color(0xFFE3EEE9);

  bool _showMap = false; //

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
          _HeaderActionIcon(
            // Verander het icoontje visueel indien gewenst als map actief is
            assetPath: _showMap
                ? 'assets/navBar/list.png'
                : 'assets/navBar/map.png',
            onTap: () {
              setState(() {
                _showMap = !_showMap; //
              });
            },
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

      // -- BODY: filter row + item grid/map --------------------------------------
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

            // -- ITEM GRID OF MAP VIEW ----------------------------------------------
            const SizedBox(height: 12),
            Expanded(
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

                  final List<Item> items = snapshot.data ?? <Item>[];
                  if (items.isEmpty) {
                    return const Center(
                      child: Text('No listings yet. Tap + to add one.'),
                    );
                  }

                  if (_showMap) {
                    // Belangrijk: Om Map correct te tonen in een padding structuur
                    // is een ClipRRect soms handig, we geven het hier direct door.
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ItemMapView(items: items),
                    );
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
                                  ) {
                                    return child;
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
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // -- BOTTOM NAV BAR ------------------------------------------------------
      bottomNavigationBar: BottomNavBar(
        onHomeTap: () {
          // Zoals gevraagd: PushReplacement zorgt voor een refresh van de pagina
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
    // Kleuren moeten nu via Theme of vaste constanten als de widget buiten
    // de class valt. Voor het gemak heb ik de hex codes hier direct ingezet.
    return SizedBox(
      height: 44,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFE3EEE9),
          side: const BorderSide(color: Color(0xFF6F9476), width: 1),
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
                color: Color(0xFF2F3E36),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: Color(0xFF2F3E36),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderActionIcon extends StatelessWidget {
  const _HeaderActionIcon({required this.assetPath, required this.onTap});

  final String assetPath;
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
          // TODO: Weghalen
          // Failsafe ingebouwd: als je 'assets/navBar/list.png' nog niet hebt,
          // zal het een error tonen. Voeg dat icoontje even toe aan je assets!
          child: Image.asset(
            assetPath,
            width: 24,
            height: 24,
            color: Colors.white,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.map, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
