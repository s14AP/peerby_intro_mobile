import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
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
                      errorBuilder: (_, _, _) => InitialsAvatar(initials),
                    )
                  : InitialsAvatar(initials),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
          const SizedBox(height: 4),
          Text(email, style: const TextStyle(fontSize: 13, color: _muted)),
          if (memberSince != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              'Lid sinds ${memberSince!.year}',
              style: const TextStyle(fontSize: 12, color: _muted),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: onSettings,
              icon: const Icon(Icons.settings_outlined, size: 18, color: Colors.white),
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

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar(this.initials, {super.key});

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
