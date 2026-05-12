import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:re_use/components/bottomNavBar.dart';
import 'package:re_use/components/card.dart';
import 'package:re_use/screens/chat/chat_list_screen.dart';
import 'package:re_use/screens/createpage/create_listing_screen.dart';
import 'package:re_use/screens/homepage/homepage.dart';
import 'package:re_use/screens/profilepage/profile_header.dart';
import 'package:re_use/screens/profilepage/profile_settings_sheet.dart';
import 'package:re_use/screens/profilepage/renter_reservations_list.dart';
import 'package:re_use/screens/reservations/item_reservations_sheet.dart';
import 'package:re_use/services/auth_service.dart';
import 'package:re_use/services/item_service.dart';
import 'package:re_use/services/reservation_service.dart';
import 'package:re_use/types/item.dart';
import 'package:re_use/types/reservation.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const Color _pageBackground = Color(0xFFF3FAF7);
  static const Color _headerTeal = Color(0xFF6F9476);
  static const Color _dark = Color(0xFF2F3E36);
  static const Color _muted = Color(0xFF6D7D74);

  static void _showSettings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => const ProfileSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final ItemService itemService = ItemService();
    final User? user = authService.currentUser;

    final String displayName = (user?.displayName?.isNotEmpty == true)
        ? user!.displayName!
        : 'Gebruiker';
    final String email = user?.email ?? '';
    final String? photoUrl = user?.photoURL;
    final String initials = displayName
        .trim()
        .split(' ')
        .where((String s) => s.isNotEmpty)
        .take(2)
        .map((String s) => s[0].toUpperCase())
        .join();
    final DateTime? memberSince = user?.metadata.creationTime;

    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: _headerTeal,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 76,
        titleSpacing: 20,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: 0.84,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  child: Image.asset('assets/login/Logo.png', height: 40, width: 40),
                ),
              ),
            ),
            const SizedBox(width: 3),
            const Text(
              'e-use',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Reservation>>(
        stream: ReservationService().watchForOwner(user?.uid ?? ''),
        builder: (BuildContext context, AsyncSnapshot<List<Reservation>> reservSnap) {
          final List<Reservation> ownerReservations = reservSnap.data ?? <Reservation>[];

          return StreamBuilder<List<Item>>(
            stream: itemService.watchItems(),
            builder: (BuildContext context, AsyncSnapshot<List<Item>> snapshot) {
              final List<Item> myItems = (snapshot.data ?? <Item>[])
                  .where((Item i) => i.ownerId == user?.uid)
                  .toList();

              final Map<String, List<Reservation>> byItem = <String, List<Reservation>>{};
              for (final Reservation r in ownerReservations) {
                byItem.putIfAbsent(r.itemId, () => <Reservation>[]).add(r);
              }

              return CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: ProfileHeader(
                      displayName: displayName,
                      email: email,
                      photoUrl: photoUrl,
                      initials: initials,
                      memberSince: memberSince,
                      onSettings: () => _showSettings(context),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Mijn advertenties',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _dark),
                      ),
                    ),
                  ),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (myItems.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.inbox_outlined, size: 48, color: _muted),
                            const SizedBox(height: 12),
                            Text(
                              'Je hebt nog geen advertenties.',
                              style: TextStyle(color: _muted, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.69,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            final Item item = myItems[index];
                            final bool hasDecimals =
                                item.price.truncateToDouble() != item.price;
                            final String priceText = item.price == 0
                                ? 'Gratis'
                                : '€${item.price.toStringAsFixed(hasDecimals ? 2 : 0)} / ${item.typePayment.name}';
                            final List<Reservation> itemRes =
                                byItem[item.id] ?? <Reservation>[];
                            final int pendingCount = itemRes
                                .where((Reservation r) =>
                                    r.status == ReservationStatus.pending)
                                .length;

                            return GestureDetector(
                              onTap: () {
                                showModalBottomSheet<void>(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => ItemReservationsSheet(item: item),
                                );
                              },
                              child: Stack(
                                children: <Widget>[
                                  ItemCard(
                                    title: item.title,
                                    distance: item.locationCity,
                                    imageUrl: item.imageUrl,
                                    ownerName: item.ownerName,
                                    ownerAvatarUrl: item.ownerAvatarUrl,
                                    price: priceText,
                                  ),
                                  if (pendingCount > 0)
                                    Positioned(
                                      top: 6,
                                      left: 6,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade600,
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          '$pendingCount nieuw',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                          childCount: myItems.length,
                        ),
                      ),
                    ),

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Mijn huurverzoeken',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _dark),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: RenterReservationsList(uid: user?.uid ?? ''),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            },
          );
        },
      ),

      extendBody: true,
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
        onProfileTap: () {},
      ),
    );
  }
}
