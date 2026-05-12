import 'package:flutter/material.dart';
import 'package:re_use/screens/auth/login_screen.dart';
import 'package:re_use/screens/profilepage/edit_profile_page.dart';
import 'package:re_use/services/auth_service.dart';

class ProfileSettingsSheet extends StatelessWidget {
  const ProfileSettingsSheet({super.key});

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
            ProfileSettingsTile(
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
            ProfileSettingsTile(
              icon: Icons.notifications_outlined,
              label: 'Meldingen',
              onTap: () {},
            ),
            ProfileSettingsTile(
              icon: Icons.lock_outline,
              label: 'Privacy',
              onTap: () {},
            ),
            ProfileSettingsTile(
              icon: Icons.help_outline,
              label: 'Help & ondersteuning',
              onTap: () {},
            ),
            const Divider(height: 24),
            ProfileSettingsTile(
              icon: Icons.logout,
              label: 'Uitloggen',
              color: Colors.red.shade600,
              onTap: () async {
                await AuthService().signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(
                      builder: (_) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileSettingsTile extends StatelessWidget {
  const ProfileSettingsTile({
    super.key,
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
              const Icon(Icons.chevron_right, color: Color(0xFF6D7D74), size: 20),
          ],
        ),
      ),
    );
  }
}
