import 'package:flutter/material.dart';
import 'package:re_use/components/bottomNavBar.dart';
import 'package:re_use/screens/homepage/homepage.dart';
import 'package:re_use/types/item.dart';

class DetailPage extends StatefulWidget {
  final Item item;

  const DetailPage({super.key, required this.item});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late final PageController _imageController;
  int _currentImageIndex = 0;

  List<String> get _imageUrls {
    final List<String> candidates = widget.item.imageUrl
        .split(',')
        .map((String url) => url.trim())
        .where((String url) => url.isNotEmpty)
        .toList(growable: false);

    if (candidates.isEmpty) {
      return <String>[widget.item.imageUrl];
    }

    return candidates;
  }

  static const Color _pageBackground = Color(0xFFF3FAF7);
  static const Color _headerTeal = Color(0xFF6F9476);
  static const Color _cardBackground = Color(0xFFFBFEFD);
  static const Color _borderColor = Color(0xFFD7E6DE);
  static const Color _textDark = Color(0xFF2F3E36);
  static const Color _textMuted = Color(0xFF5F6F67);

  @override
  void initState() {
    super.initState();
    _imageController = PageController();
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  String _formattedPrice() {
    final bool hasDecimals =
        widget.item.price.truncateToDouble() != widget.item.price;
    if (widget.item.price == 0) {
      return 'Gratis';
    }

    return '€ ${widget.item.price.toStringAsFixed(hasDecimals ? 2 : 0)}/${widget.item.typePayment.name}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: _pageBackground,

      // -- APP BAR ------------------------------------------------------
      appBar: AppBar(
        // 1. Tell the AppBar to center whatever is in the 'title' property
        centerTitle: true,

        leading: IconButton(
          icon: Image.asset(
            'assets/general/back.png',
            height: 34,
            width: 34,
            color: Colors.white, // <-- Added this to make the back arrow white!
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: _headerTeal,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing:
            0, // Changed this to 0 so it centers perfectly without an offset

        title: Row(
          // 2. This is crucial! It forces the Row to be small so it can actually be centered
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ClipRect(
              child: Align(
                alignment: Alignment.center,
                widthFactor: 0.84,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'assets/login/Logo.png',
                    height: 34,
                    width: 34,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
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

      // -- BODY ------------------------------------------------------
      body: SingleChildScrollView(
        child: Container(
          color: _cardBackground,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  SizedBox(
                    height: 235,
                    width: double.infinity,
                    child: PageView.builder(
                      controller: _imageController,
                      itemCount: _imageUrls.length,
                      onPageChanged: (int index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return Image.network(
                          _imageUrls[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFE3E3E3),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                color: Color(0xFF8E8E8E),
                                size: 34,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        color: _textDark,
                        size: 20,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Text(
                      '${_currentImageIndex + 1}/${_imageUrls.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: _borderColor),
                    bottom: BorderSide(color: _borderColor),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFE0E0E0),
                      foregroundImage: NetworkImage(widget.item.ownerAvatarUrl),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.item.ownerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: _textDark,
                            ),
                          ),
                          const Text(
                            '★ 4.3 (23 reviews)',
                            style: TextStyle(fontSize: 11, color: _textMuted),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      '5km',
                      style: TextStyle(fontSize: 20, color: _textDark),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Row(
                  // Change from .end to .center
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        widget.item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          // Note: height: 2 adds a lot of internal padding to the text.
                          // If it doesn't look perfectly centered, try reducing this!
                          height: 2,
                          color: _textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formattedPrice(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: _textDark,
                        height: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7FAA8A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: const Text(
                          'CHAT',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7FAA8A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: const Text(
                          'STUUR HUURVERZOEK',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                            // Add padding to the bottom
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(height: 1, thickness: 1, color: _borderColor),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  'Kenmerken',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: _textDark,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EEEE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Categorie: ${widget.item.category}\nLocatie: ${widget.item.locationCity}, ${widget.item.locationCountry}\nType: ${widget.item.typePayment.name}',
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: _textDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'Beschrijving',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: _textDark,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EEEE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.item.description ?? 'Geen beschrijving toegevoegd.',
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: _textDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'Verkoper',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: _textDark,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFFE0E0E0),
                      foregroundImage: NetworkImage(widget.item.ownerAvatarUrl),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.item.ownerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: _textDark,
                            ),
                          ),
                          const Text(
                            '★ 4.3 (23 reviews)',
                            style: TextStyle(fontSize: 10.5, color: _textMuted),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Andere items van ${widget.item.ownerName}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF2F5CA8),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        widget.item.locationCity,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: _textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),

      // -- BOTTOM NAV BAR ------------------------------------------------------
      // Now it sits correctly at the Scaffold level!
      bottomNavigationBar: BottomNavBar(
        onHomeTap: () {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const HomePage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
      ),
    ); // Close the Scaffold
  }
}
