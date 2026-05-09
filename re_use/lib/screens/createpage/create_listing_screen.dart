import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:re_use/services/auth_service.dart';
import 'package:re_use/services/item_service.dart';
import 'package:re_use/types/item.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

const Color _teal = Color(0xFF6F9476);
const Color _bg = Color(0xFFF3FAF7);
const Color _dark = Color(0xFF2F3E36);

const List<String> _categories = <String>[
  'Crafts',
  'Electronics',
  'Garden',
  'Kitchen',
  'Music',
  'Outdoor',
  'Sports',
  'Tech',
  'Tools',
  'Transport',
  'Other',
];

const List<String> _countries = <String>['België', 'Nederland'];

const Map<String, String> _countryToEnglish = <String, String>{
  'België': 'Belgium',
  'Nederland': 'Netherlands',
};

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  Uint8List? _pickedImageBytes;
  String? _pickedImageBase64;
  final TextEditingController _priceController = TextEditingController();

  final AuthService _authService = AuthService();
  final ItemService _itemService = ItemService();

  TypePayment _selectedTypePayment = TypePayment.dag;
  String _selectedCategory = _categories.first;
  String _selectedCountry = _countries.first;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<({double? lat, double? lng})> _geocode(
    String city,
    String country,
  ) async {
    try {
      final Uri url = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        <String, String>{
          'city': city,
          'country': country,
          'format': 'json',
          'limit': '1',
        },
      );
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'User-Agent': 're-use-app/1.0',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode != 200) return (lat: null, lng: null);
      final List<dynamic> results = jsonDecode(response.body) as List<dynamic>;
      if (results.isEmpty) return (lat: null, lng: null);
      final Map<String, dynamic> first = results.first as Map<String, dynamic>;
      return (
        lat: double.tryParse(first['lat'] as String),
        lng: double.tryParse(first['lon'] as String),
      );
    } catch (_) {
      return (lat: null, lng: null);
    }
  }

  Future<void> _submit() async {
    if (_pickedImageBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecteer een afbeelding.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final user = _authService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Je moet ingelogd zijn om een item toe te voegen.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final String city = _cityController.text.trim();
      final String countryEn = _countryToEnglish[_selectedCountry]!;
      final double parsedPrice = double.parse(_priceController.text.trim());
      final String ownerName = user.displayName?.trim().isNotEmpty == true
          ? user.displayName!.trim()
          : (user.email?.split('@').first ?? 'User');

      final (:lat, :lng) = await _geocode(city, countryEn);

      final Item item = Item(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        locationCity: city,
        locationCountry: countryEn,
        imageUrl: _pickedImageBase64!,
        ownerName: ownerName,
        ownerAvatarUrl: user.photoURL ?? '',
        category: _selectedCategory,
        typePayment: _selectedTypePayment,
        price: parsedPrice,
        ownerId: user.uid,
        latitude: lat,
        longitude: lng,
      );

      await _itemService.createItem(item);

      if (!mounted) return;
      final String message = lat != null
          ? 'Item gepubliceerd en zichtbaar op de kaart!'
          : 'Item gepubliceerd, maar stad niet gevonden op de kaart. Controleer de stadsnaam.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Er ging iets mis. Probeer opnieuw.')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showImageSourceSheet() {
    if (kIsWeb) {
      _pickImage(ImageSource.gallery);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galerij'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? xFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 60,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (xFile == null) return;
    final bytes = await xFile.readAsBytes();
    setState(() {
      _pickedImageBytes = bytes;
      _pickedImageBase64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _teal,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Item toevoegen',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            children: <Widget>[
              _SectionLabel('Over het item'),
              const SizedBox(height: 10),
              _Field(
                controller: _titleController,
                label: 'Titel',
                hint: 'bijv. Boormachine Bosch',
                validator: (String? v) =>
                    v == null || v.trim().isEmpty ? 'Titel is verplicht' : null,
              ),
              const SizedBox(height: 12),
              _Field(
                controller: _descriptionController,
                label: 'Beschrijving',
                hint: 'Staat, inclusief accessoires, bijzonderheden…',
                minLines: 4,
                maxLines: 6,
              ),
              const SizedBox(height: 12),
              _DropdownField<String>(
                label: 'Categorie',
                value: _selectedCategory,
                items: _categories,
                itemLabel: (String s) => s,
                onChanged: (String? v) {
                  if (v != null) setState(() => _selectedCategory = v);
                },
              ),
              const SizedBox(height: 24),
              _SectionLabel('Locatie'),
              const SizedBox(height: 10),
              _DropdownField<String>(
                label: 'Land',
                value: _selectedCountry,
                items: _countries,
                itemLabel: (String s) => s,
                onChanged: (String? v) {
                  if (v != null) setState(() => _selectedCountry = v);
                },
              ),
              const SizedBox(height: 12),
              _Field(
                controller: _cityController,
                label: 'Stad',
                hint: 'bijv. Antwerpen',
                validator: (String? v) =>
                    v == null || v.trim().isEmpty ? 'Stad is verplicht' : null,
              ),
              const SizedBox(height: 24),
              _SectionLabel('Prijs & type'),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _Field(
                      controller: _priceController,
                      label: 'Prijs (€)',
                      hint: '0',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (String? v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Verplicht';
                        }
                        if (double.tryParse(v.trim()) == null ||
                            double.parse(v.trim()) < 0) {
                          return 'Ongeldig';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DropdownField<TypePayment>(
                      label: 'Per',
                      value: _selectedTypePayment,
                      items: TypePayment.values,
                      itemLabel: (TypePayment t) => t.name,
                      onChanged: (TypePayment? v) {
                        if (v != null) {
                          setState(() => _selectedTypePayment = v);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SectionLabel('Afbeelding'),
              const SizedBox(height: 10),
              _pickedImageBytes != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            _pickedImageBytes!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => _showImageSourceSheet(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Wijzigen',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : GestureDetector(
                      onTap: () => _showImageSourceSheet(),
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFB5CFC0)),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              color: Color(0xFF7A9183),
                              size: 32,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Kies een afbeelding',
                              style: TextStyle(
                                color: Color(0xFF7A9183),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _teal,
                    disabledBackgroundColor: _teal.withAlpha(120),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Publiceren',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _teal,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.hint,
    this.minLines,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final int? minLines;
  final int? maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: _dark),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0xFF7A9183)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFB5CFC0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFB5CFC0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _teal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?) onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 15, color: _dark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF7A9183)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFB5CFC0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFB5CFC0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _teal, width: 1.5),
        ),
      ),
      items: items.map((T item) {
        return DropdownMenuItem<T>(value: item, child: Text(itemLabel(item)));
      }).toList(),
    );
  }
}
