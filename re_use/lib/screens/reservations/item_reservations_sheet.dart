import 'package:flutter/material.dart';
import 'package:re_use/services/reservation_service.dart';
import 'package:re_use/types/item.dart';
import 'package:re_use/types/reservation.dart';
import 'package:re_use/services/item_service.dart';

class ItemReservationsSheet extends StatelessWidget {
  const ItemReservationsSheet({super.key, required this.item});
  final Item item;

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

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3EEE9),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Verzoeken voor',
                          style: TextStyle(fontSize: 13, color: _muted),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          tooltip: 'Advertentie verwijderen',
                          onPressed: () async {
                            final bool? confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Advertentie verwijderen'),
                                content: const Text(
                                  'Weet je zeker dat je deze advertentie wilt verwijderen?',
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Annuleren'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text(
                                      'Verwijderen',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true && context.mounted) {
                              await ItemService().deleteItem(item.id);
                              if (context.mounted) Navigator.of(context).pop();
                            }
                          },
                        ),
                      ],
                    ),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _dark,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: StreamBuilder<List<Reservation>>(
                  stream: ReservationService().watchForItem(item.id),
                  builder:
                      (
                        BuildContext context,
                        AsyncSnapshot<List<Reservation>> snap,
                      ) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final List<Reservation> reservations = snap.data ?? [];
                        if (reservations.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 48,
                                  color: _muted,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Nog geen verzoeken.',
                                  style: TextStyle(color: _muted),
                                ),
                              ],
                            ),
                          );
                        }
                        return ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                          itemCount: reservations.length,
                          separatorBuilder: (_, _) => const Divider(height: 24),
                          itemBuilder: (BuildContext context, int i) {
                            final Reservation r = reservations[i];
                            return _ReservationCard(
                              reservation: r,
                              formatDate: (DateTime d) =>
                                  _fmt(d, r.typePayment),
                            );
                          },
                        );
                      },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReservationCard extends StatefulWidget {
  const _ReservationCard({required this.reservation, required this.formatDate});

  final Reservation reservation;
  final String Function(DateTime) formatDate;

  @override
  State<_ReservationCard> createState() => _ReservationCardState();
}

class _ReservationCardState extends State<_ReservationCard> {
  bool _loading = false;

  static const Color _teal = Color(0xFF6F9476);
  static const Color _dark = Color(0xFF2F3E36);
  static const Color _muted = Color(0xFF6D7D74);

  Future<void> _updateStatus(ReservationStatus status) async {
    setState(() => _loading = true);
    try {
      await ReservationService().updateStatus(widget.reservation.id, status);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
    final Reservation r = widget.reservation;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFE0E0E0),
              foregroundImage: r.renterAvatarUrl.isNotEmpty
                  ? NetworkImage(r.renterAvatarUrl)
                  : null,
              child: r.renterAvatarUrl.isEmpty
                  ? Text(
                      r.renterName.isNotEmpty
                          ? r.renterName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Color(0xFF6F9476),
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    r.renterName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: _dark,
                    ),
                  ),
                  Text(
                    '${widget.formatDate(r.startDate)} – ${widget.formatDate(r.endDate)}',
                    style: const TextStyle(fontSize: 12, color: _muted),
                  ),
                ],
              ),
            ),
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
        ),
        if (r.message.isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3FAF7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              r.message,
              style: const TextStyle(fontSize: 13, color: _dark),
            ),
          ),
        ],
        if (r.status == ReservationStatus.pending) ...<Widget>[
          const SizedBox(height: 10),
          if (_loading)
            const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateStatus(ReservationStatus.rejected),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade400,
                      side: BorderSide(color: Colors.red.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Weigeren',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(ReservationStatus.accepted),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Accepteren',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ],
    );
  }
}
