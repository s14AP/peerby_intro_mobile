import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:re_use/services/reservation_service.dart';
import 'package:re_use/types/item.dart';
import 'package:re_use/types/reservation.dart';

class ReservationRequestSheet extends StatefulWidget {
  const ReservationRequestSheet({super.key, required this.item});
  final Item item;

  @override
  State<ReservationRequestSheet> createState() =>
      _ReservationRequestSheetState();
}

class _ReservationRequestSheetState extends State<ReservationRequestSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  int? _hours;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  bool _loading = false;

  static const Color _teal = Color(0xFF6F9476);
  static const Color _dark = Color(0xFF2F3E36);
  static const Color _muted = Color(0xFF6D7D74);
  static const Color _border = Color(0xFFD7E6DE);
  static const Color _fill = Color(0xFFF3FAF7);

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pickDate({required bool isStart}) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? now : (_startDate ?? now),
      firstDate: isStart ? now : (_startDate ?? now),
      lastDate: now.add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF6F9476)),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && !_endDate!.isAfter(picked)) _endDate = null;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    final bool isUur = widget.item.typePayment == TypePayment.uur;
    if (_startDate == null) return;
    if (isUur) {
      if (_hours == null || _hours! <= 0) return;
      _endDate = _startDate!.add(Duration(hours: _hours!));
    }
    if (_endDate == null) return;
    setState(() => _loading = true);
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await ReservationService().createReservation(
        Reservation(
          id: '',
          itemId: widget.item.id,
          itemTitle: widget.item.title,
          itemImageUrl: widget.item.imageUrl,
          ownerId: widget.item.ownerId,
          renterId: user.uid,
          renterName: user.displayName ?? 'Onbekend',
          renterAvatarUrl: user.photoURL ?? '',
          startDate: _startDate!,
          endDate: _endDate!,
          message: _messageController.text.trim(),
          price: widget.item.price,
          typePayment: widget.item.typePayment.name,
        ),
      );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Huurverzoek verzonden!')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isUur = widget.item.typePayment == TypePayment.uur;
    final bool canSubmit = isUur
        ? _startDate != null && (_hours ?? 0) > 0 && !_loading
        : _startDate != null && _endDate != null && !_loading;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3EEE9),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Stuur huurverzoek',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _dark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.item.title,
                style: const TextStyle(fontSize: 13, color: _muted),
              ),
              const SizedBox(height: 20),
              if (isUur)
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _fill,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Uren',
                              style: TextStyle(
                                fontSize: 11,
                                color: _muted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            TextField(
                              controller: _hoursController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _dark,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                                hintText: 'bv. 3',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF9AADA4),
                                ),
                              ),
                              onChanged: (String v) {
                                setState(() {
                                  _hours = int.tryParse(v);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateButton(
                        label: 'Datum',
                        value: _startDate != null ? _fmt(_startDate!) : null,
                        onTap: () => _pickDate(isStart: true),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _DateButton(
                        label: 'Van',
                        value: _startDate != null ? _fmt(_startDate!) : null,
                        onTap: () => _pickDate(isStart: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateButton(
                        label: 'Tot',
                        value: _endDate != null ? _fmt(_endDate!) : null,
                        onTap: () => _pickDate(isStart: false),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              TextField(
                controller: _messageController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Voeg een bericht toe (optioneel)...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF9AADA4),
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: _fill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _teal),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: canSubmit ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _teal,
                    disabledBackgroundColor: const Color(0xFFB5CAB9),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Verstuur verzoek',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3FAF7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD7E6DE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF6D7D74)),
            ),
            const SizedBox(height: 2),
            Text(
              value ?? 'Kies datum',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: value != null
                    ? const Color(0xFF2F3E36)
                    : const Color(0xFF9AADA4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
