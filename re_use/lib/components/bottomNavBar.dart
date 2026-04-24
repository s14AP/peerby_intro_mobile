import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    this.onHomeTap,
    this.onChatTap,
    this.onAddTap,
    this.onProfileTap,
  });

  final VoidCallback? onHomeTap;
  final VoidCallback? onChatTap;
  final VoidCallback? onAddTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FCFA),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x336F9476)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x166F9476),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _NavIcon(
                assetPath: 'assets/navBar/home.png',
                onTap: onHomeTap ?? () {},
              ),
              _NavIcon(
                assetPath: 'assets/navBar/chat.png',
                onTap: onChatTap ?? () {},
              ),
              _NavIcon(
                assetPath: 'assets/navBar/add.png',
                onTap: onAddTap ?? () {},
              ),
              _NavIcon(
                assetPath: 'assets/navBar/user.png',
                onTap: onProfileTap ?? () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.assetPath, required this.onTap});

  final String assetPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Image.asset(
            assetPath,
            width: 24,
            height: 24,
            color: const Color(0xFF2F3E36),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
