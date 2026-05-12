import 'package:flutter/material.dart';

// Filter chip button shown in the horizontal filter row
class HomeFilterButton extends StatelessWidget {
  const HomeFilterButton({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
    this.disabled = false,
  });

  final String label;
  final bool active;
  final bool disabled;
  final VoidCallback onTap;

  static const Color _teal = Color(0xFF6F9476);
  static const Color _fill = Color(0xFFE3EEE9);
  static const Color _dark = Color(0xFF2F3E36);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: OutlinedButton(
        onPressed: disabled ? null : onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: active ? _teal : _fill,
          side: BorderSide(
            color: disabled ? Colors.grey.shade400 : _teal,
            width: 1,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          disabledBackgroundColor: Colors.grey.shade200,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: disabled
                    ? Colors.grey.shade500
                    : active
                    ? Colors.white
                    : _dark,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: disabled
                  ? Colors.grey.shade500
                  : active
                  ? Colors.white
                  : _dark,
            ),
          ],
        ),
      ),
    );
  }
}

// Generic option bottom sheet (list or chip layout)
class HomeOptionSheet extends StatelessWidget {
  const HomeOptionSheet({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelect,
    this.useChips = false,
  });

  final String title;
  final List<String> options;
  final String? selected;
  final void Function(String?) onSelect;
  final bool useChips;

  void _pick(BuildContext context, String? value) {
    onSelect(value);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const Divider(height: 1),
          if (options.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Geen opties beschikbaar.'),
            )
          else if (useChips)
            _ChipBody(
              options: options,
              selected: selected,
              onPick: (String? v) => _pick(context, v),
            )
          else
            _ListBody(
              options: options,
              selected: selected,
              onPick: (String? v) => _pick(context, v),
            ),
        ],
      ),
    );
  }
}

class _ChipBody extends StatelessWidget {
  const _ChipBody({
    required this.options,
    required this.selected,
    required this.onPick,
  });

  final List<String> options;
  final String? selected;
  final void Function(String?) onPick;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            if (selected != null)
              _Chip(
                label: 'Alle',
                isActive: false,
                isClear: true,
                onTap: () => onPick(null),
              ),
            ...options.map(
              (String opt) => _Chip(
                label: opt,
                isActive: opt == selected,
                isClear: false,
                onTap: () => onPick(opt),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isActive,
    required this.isClear,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final bool isClear;
  final VoidCallback onTap;

  static const Color _teal = Color(0xFF6F9476);
  static const Color _dark = Color(0xFF2F3E36);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? _teal : const Color(0xFFE3EEE9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? _teal : const Color(0xFFB5CFC0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (isClear) ...<Widget>[
              const Icon(Icons.close, size: 13, color: _dark),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : _dark,
              ),
            ),
            if (isActive) ...<Widget>[
              const SizedBox(width: 4),
              const Icon(Icons.check, size: 13, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}

class _ListBody extends StatelessWidget {
  const _ListBody({
    required this.options,
    required this.selected,
    required this.onPick,
  });

  final List<String> options;
  final String? selected;
  final void Function(String?) onPick;

  static const Color _teal = Color(0xFF6F9476);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          if (selected != null)
            ListTile(
              leading: const Icon(Icons.clear, size: 20),
              title: const Text('Alle'),
              onTap: () => onPick(null),
            ),
          ...options.map(
            (String opt) => ListTile(
              title: Text(opt),
              trailing: selected == opt
                  ? const Icon(Icons.check, color: _teal)
                  : null,
              onTap: () => onPick(opt),
            ),
          ),
        ],
      ),
    );
  }
}

// Distance slider sheet
class HomeDistanceSheet extends StatefulWidget {
  const HomeDistanceSheet({super.key, required this.current, required this.onSelect});

  final double? current;
  final void Function(double?) onSelect;

  @override
  State<HomeDistanceSheet> createState() => _HomeDistanceSheetState();
}

class _HomeDistanceSheetState extends State<HomeDistanceSheet> {
  static const double _maxKm = 250;
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.current ?? _maxKm;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Max afstand',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('0 km'),
                Text(
                  '${_value.toStringAsFixed(0)} km',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF6F9476),
                  ),
                ),
                const Text('250 km'),
              ],
            ),
            Slider(
              value: _value,
              min: 1,
              max: _maxKm,
              divisions: 249,
              activeColor: const Color(0xFF6F9476),
              onChanged: (double v) => setState(() => _value = v),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onSelect(null);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF6F9476)),
                    ),
                    child: const Text(
                      'Reset',
                      style: TextStyle(color: Color(0xFF6F9476)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSelect(_value < _maxKm ? _value : null);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6F9476),
                    ),
                    child: const Text(
                      'Toepassen',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Generic slider sheet (price, etc.)
class HomeSliderSheet extends StatefulWidget {
  const HomeSliderSheet({
    super.key,
    required this.title,
    required this.unit,
    required this.unitBefore,
    required this.maxAvailable,
    required this.current,
    required this.onSelect,
  });

  final String title;
  final String unit;
  final bool unitBefore;
  final double maxAvailable;
  final double? current;
  final void Function(double?) onSelect;

  @override
  State<HomeSliderSheet> createState() => _HomeSliderSheetState();
}

class _HomeSliderSheetState extends State<HomeSliderSheet> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.current ?? widget.maxAvailable;
  }

  String _fmt(double v) {
    final String num = v.toStringAsFixed(0);
    return widget.unitBefore ? '${widget.unit}$num' : '$num ${widget.unit}';
  }

  @override
  Widget build(BuildContext context) {
    final int divisions = widget.maxAvailable > 0
        ? widget.maxAvailable.clamp(10, 100).toInt()
        : 10;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(_fmt(0)),
                Text(
                  _fmt(_value),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF6F9476),
                  ),
                ),
                Text(_fmt(widget.maxAvailable)),
              ],
            ),
            Slider(
              value: _value,
              min: 0,
              max: widget.maxAvailable,
              divisions: divisions,
              activeColor: const Color(0xFF6F9476),
              onChanged: (double v) => setState(() => _value = v),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onSelect(null);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF6F9476)),
                    ),
                    child: const Text(
                      'Reset',
                      style: TextStyle(color: Color(0xFF6F9476)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSelect(
                        _value < widget.maxAvailable ? _value : null,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6F9476),
                    ),
                    child: const Text(
                      'Toepassen',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Header icon button used in the home app bar
class HomeHeaderActionIcon extends StatelessWidget {
  const HomeHeaderActionIcon({
    super.key,
    this.assetPath,
    required this.onTap,
  });

  final String? assetPath;
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
            assetPath ?? '',
            width: 24,
            height: 24,
            color: Colors.white,
            fit: BoxFit.contain,
            errorBuilder: (BuildContext context, Object error, StackTrace? _) =>
                const Icon(Icons.map, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
