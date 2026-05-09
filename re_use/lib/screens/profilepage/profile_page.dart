import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:re_use/components/bottomNavBar.dart';
import 'package:re_use/components/card.dart';
import 'package:re_use/screens/homepage/homepage.dart';
import 'package:re_use/services/auth_service.dart';
import 'package:re_use/services/item_service.dart';
import 'package:re_use/types/item.dart';
import 'package:re_use/screens/profilepage/edit_profile_page.dart';
import 'package:re_use/screens/reservations/item_reservations_sheet.dart';
import 'package:re_use/services/reservation_service.dart';
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
      builder: (BuildContext context) => const _SettingsSheet(),
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
      ),
      body: StreamBuilder<List<Reservation>>(
        stream: ReservationService().watchForOwner(user?.uid ?? ''),
        builder: (BuildContext context, AsyncSnapshot<List<Reservation>> reservSnap) {
          final List<Reservation> ownerReservations =
              reservSnap.data ?? <Reservation>[];

          return StreamBuilder<List<Item>>(
            stream: itemService.watchItems(),
            builder: (BuildContext context, AsyncSnapshot<List<Item>> snapshot) {
              final List<Item> myItems = (snapshot.data ?? <Item>[])
                  .where((Item i) => i.ownerId == user?.uid)
                  .toList();

              // Reserveringen gegroepeerd per item
              final Map<String, List<Reservation>> byItem =
                  <String, List<Reservation>>{};
              for (final Reservation r in ownerReservations) {
                byItem.putIfAbsent(r.itemId, () => <Reservation>[]).add(r);
              }

              // Huurder: eigen uitgaande verzoeken (filter uit dezelfde owner-stream)
              // We listen apart hieronder.

              return CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: _ProfileHeader(
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
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: _dark,
                        ),
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.69,
                            ),
                        delegate: SliverChildBuilderDelegate((
                          BuildContext context,
                          int index,
                        ) {
                          final Item item = myItems[index];
                          final bool hasDecimals =
                              item.price.truncateToDouble() != item.price;
                          final String priceText = item.price == 0
                              ? 'Gratis'
                              : '€${item.price.toStringAsFixed(hasDecimals ? 2 : 0)} / ${item.typePayment.name}';
                          final List<Reservation> itemRes =
                              byItem[item.id] ?? <Reservation>[];
                          final int pendingCount = itemRes
                              .where(
                                (Reservation r) =>
                                    r.status == ReservationStatus.pending,
                              )
                              .length;

                          return GestureDetector(
                            onTap: () {
                              showModalBottomSheet<void>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) =>
                                    ItemReservationsSheet(item: item),
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
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
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
                        }, childCount: myItems.length),
                      ),
                    ),

                  // ── Mijn huurverzoeken (huurder-sectie) ──────────────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Mijn huurverzoeken',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: _dark,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _RenterReservationsList(uid: user?.uid ?? ''),
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
        onProfileTap: () {},
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.initials,
    required this.memberSince,
    required this.onSettings,
  });

  final String displayName;
  final String email;
  final String? photoUrl;
  final String initials;
  final DateTime? memberSince;
  final VoidCallback onSettings;

  static const Color _teal = Color(0xFF6F9476);
  static const Color _dark = Color(0xFF2F3E36);
  static const Color _muted = Color(0xFF6D7D74);
  static const Color _fill = Color(0xFFE3EEE9);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF3FAF7),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      child: Column(
        children: <Widget>[
          // Avatar
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _teal, width: 2.5),
            ),
            child: ClipOval(
              child: photoUrl != null && photoUrl!.isNotEmpty
                  ? Image.network(
                      photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _InitialsAvatar(initials),
                    )
                  : _InitialsAvatar(initials),
            ),
          ),
          const SizedBox(height: 14),
          // Name
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
          const SizedBox(height: 4),
          // Email
          Text(email, style: const TextStyle(fontSize: 13, color: _muted)),
          if (memberSince != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              'Lid sinds ${memberSince!.year}',
              style: const TextStyle(fontSize: 12, color: _muted),
            ),
          ],
          const SizedBox(height: 20),
          // Settings button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: onSettings,
              icon: const Icon(
                Icons.settings_outlined,
                size: 18,
                color: Colors.white,
              ),
              label: const Text(
                'Instellingen',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: _fill, thickness: 1),
        ],
      ),
    );
  }
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();

  static const Color _dark = Color(0xFF2F3E36);
  static const Color _fill = Color(0xFFE3EEE9);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: _fill,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Instellingen',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _dark,
              ),
            ),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.person_outline,
              label: 'Profiel bewerken',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                );
              },
            ),
            _SettingsTile(
              icon: Icons.notifications_outlined,
              label: 'Meldingen',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.lock_outline,
              label: 'Privacy',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.help_outline,
              label: 'Help & ondersteuning',
              onTap: () {},
            ),
            const Divider(height: 24),
            _SettingsTile(
              icon: Icons.logout,
              label: 'Uitloggen',
              color: Colors.red.shade600,
              onTap: () async {
                Navigator.of(context).pop();
                await AuthService().signOut();
                if (context.mounted) {
                  // Pop all routes until root, then AuthGate will show LoginScreen
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  static const Color _dark = Color(0xFF2F3E36);

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = color ?? _dark;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: <Widget>[
            Icon(icon, color: effectiveColor, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: effectiveColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (color == null)
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF6D7D74),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _RenterReservationsList extends StatelessWidget {
  const _RenterReservationsList({required this.uid});
  final String uid;

  static const Color _dark = Color(0xFF2F3E36);
  static const Color _muted = Color(0xFF6D7D74);

  String _fmt(DateTime d, String typePayment) {
    final String date =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    if (typePayment == 'uur') {
      return '$date  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    }
    return date;
  }

  Color _statusColor(ReservationStatus s) {
    switch (s) {
      case ReservationStatus.accepted:
        return Colors.green.shade600;
      case ReservationStatus.rejected:
        return Colors.red.shade400;
      case ReservationStatus.pending:
        return Colors.orange.shade600;
    }
  }

  String _statusLabel(ReservationStatus s) {
    switch (s) {
      case ReservationStatus.accepted:
        return 'Geaccepteerd';
      case ReservationStatus.rejected:
        return 'Geweigerd';
      case ReservationStatus.pending:
        return 'In afwachting';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Reservation>>(
      stream: ReservationService().watchForRenter(uid),
      builder: (BuildContext context, AsyncSnapshot<List<Reservation>> snap) {
        final List<Reservation> reservations = snap.data ?? <Reservation>[];
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (reservations.isEmpty) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Text(
              'Je hebt nog geen huurverzoeken gestuurd.',
              style: TextStyle(color: _muted, fontSize: 14),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reservations.length,
          separatorBuilder: (_, _) => const Divider(height: 20),
          itemBuilder: (BuildContext context, int i) {
            final Reservation r = reservations[i];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    r.itemImageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 56,
                      height: 56,
                      color: const Color(0xFFE3EEE9),
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        size: 20,
                        color: Color(0xFF9AADA4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        r.itemTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: _dark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_fmt(r.startDate, r.typePayment)} – ${_fmt(r.endDate, r.typePayment)}',
                        style: const TextStyle(fontSize: 12, color: _muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(r.status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _statusLabel(r.status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(r.status),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar(this.initials);

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF6F9476),
      alignment: Alignment.center,
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
