import 'package:flutter/material.dart';
import 'package:re_use/components/bottomNavBar.dart';
import 'package:re_use/components/card.dart';
import 'package:re_use/types/data_seeding.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      // -- APP BAR ------------------------------------------------------
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 76,
        titleSpacing: 20,
        title: const Text(
          're-use',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E1A22),
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Color(0xFFE8E8E8)),
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
              child: GridView.builder(
                itemCount: seededItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.69,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final item = seededItems[index];
                  final bool hasDecimals =
                      item.price.truncateToDouble() != item.price;
                  final String priceText = item.price == 0
                      ? 'Free'
                      : '€${item.price.toStringAsFixed(hasDecimals ? 2 : 0)} / ${item.typePayment.name}';

                  return ItemCard(
                    title: item.title,
                    distance: item.locationCity,
                    imageUrl: item.imageUrl,
                    ownerName: item.ownerName,
                    ownerAvatarUrl: item.ownerAvatarUrl,
                    price: priceText,
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
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const HomePage(),
            ),
          );
        },
      ),
    );
  }
}

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
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF222222), width: 1),
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
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: Color(0xFF111111),
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
          child: Image.asset(
            assetPath,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
