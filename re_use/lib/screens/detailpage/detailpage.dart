import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:re_use/components/bottomNavBar.dart';
import 'package:re_use/screens/chat/chat_list_screen.dart';
import 'package:re_use/screens/createpage/create_listing_screen.dart';
import 'package:re_use/screens/detailpage/detail_action_buttons.dart';
import 'package:re_use/screens/detailpage/detail_info_section.dart';
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
    if (widget.item.imageUrl.startsWith('data:')) {
      return <String>[widget.item.imageUrl];
    }
    final List<String> candidates = widget.item.imageUrl
        .split(',')
        .map((String url) => url.trim())
        .where((String url) => url.isNotEmpty)
        .toList(growable: false);
    return candidates.isEmpty ? <String>[widget.item.imageUrl] : candidates;
  }

  static const Color _pageBackground = Color(0xFFF3FAF7);
  static const Color _headerTeal = Color(0xFF6F9476);
  static const Color _cardBackground = Color(0xFFFBFEFD);
  static const Color _textDark = Color(0xFF2F3E36);

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
    final bool hasDecimals = widget.item.price.truncateToDouble() != widget.item.price;
    if (widget.item.price == 0) return 'Gratis';
    return '€ ${widget.item.price.toStringAsFixed(hasDecimals ? 2 : 0)}/${widget.item.typePayment.name}';
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('data:image/')) {
      return Image.memory(
        base64Decode(imageUrl.split(',').last),
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => _imageError(),
      );
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _imageError(),
    );
  }

  Widget _imageError() => Container(
    color: const Color(0xFFE3E3E3),
    alignment: Alignment.center,
    child: const Icon(Icons.image_not_supported_outlined, color: Color(0xFF8E8E8E), size: 34),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: _pageBackground,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Image.asset(
            'assets/general/back.png',
            height: 34,
            width: 34,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: _headerTeal,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ClipRect(
              child: Align(
                alignment: Alignment.center,
                widthFactor: 0.84,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  child: Image.asset('assets/login/Logo.png', height: 34, width: 34),
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'e-use',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: _cardBackground,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Image gallery
              Stack(
                children: <Widget>[
                  SizedBox(
                    height: 235,
                    width: double.infinity,
                    child: PageView.builder(
                      controller: _imageController,
                      itemCount: _imageUrls.length,
                      onPageChanged: (int index) =>
                          setState(() => _currentImageIndex = index),
                      itemBuilder: (BuildContext context, int index) =>
                          _buildImage(_imageUrls[index]),
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
                      child: const Icon(Icons.favorite_border, color: _textDark, size: 20),
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

              DetailSellerHeader(item: widget.item),

              // Title + price
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Row(
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

              DetailActionButtons(item: widget.item),

              const SizedBox(height: 20),

              DetailInfoSection(item: widget.item),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        onHomeTap: () {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder<void>(
              pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              transitionsBuilder: (ctx, anim, secAnim, child) => child,
            ),
          );
        },
        onChatTap: () {
          Navigator.of(context).push(
            PageRouteBuilder<void>(
              pageBuilder: (ctx, anim, secAnim) => const ChatListScreen(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              transitionsBuilder: (ctx, anim, secAnim, child) => child,
            ),
          );
        },
        onAddTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const CreateListingScreen(),
            ),
          );
        },
      ),
    );
  }
}
