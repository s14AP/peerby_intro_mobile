import 'package:flutter/material.dart';
import 'package:re_use/services/reservation_service.dart';
import 'package:re_use/types/reservation.dart';

class RenterReservationsList extends StatelessWidget {
  const RenterReservationsList({super.key, required this.uid});
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
