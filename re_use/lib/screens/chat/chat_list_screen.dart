import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:re_use/components/bottomNavBar.dart';
import 'package:re_use/screens/chat/chat_screen.dart';
import 'package:re_use/screens/createpage/create_listing_screen.dart';
import 'package:re_use/screens/homepage/homepage.dart';
import 'package:re_use/screens/profilepage/profile_page.dart';
import 'package:re_use/services/chat_service.dart';
import 'package:re_use/types/chat.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late final Stream<List<ChatConversation>> _stream;
  late final String _uid;

  static const Color _pageBackground = Color(0xFFF3FAF7);
  static const Color _headerTeal = Color(0xFF6F9476);
  static const Color _dark = Color(0xFF2F3E36);
  static const Color _muted = Color(0xFF6D7D74);
  static const Color _border = Color(0xFFD7E6DE);

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    _stream = ChatService().watchConversations(_uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: _headerTeal,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 76,
        titleSpacing: 20,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: 0.84,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'assets/login/Logo.png',
                    height: 40,
                    width: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 3),
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
      extendBody: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Text(
              'Berichten',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _dark,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ChatConversation>>(
              stream: _stream,
              builder: (
                BuildContext context,
                AsyncSnapshot<List<ChatConversation>> snap,
              ) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: Text(
                      'Kon berichten niet laden.',
                      style: TextStyle(color: _muted, fontSize: 14),
                    ),
                  );
                }
                final List<ChatConversation> chats =
                    snap.data ?? <ChatConversation>[];
                if (chats.isEmpty) {
                  return Center(
                    child: Text(
                      'Nog geen gesprekken.',
                      style: TextStyle(color: _muted, fontSize: 14),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: chats.length,
                  separatorBuilder: (_, _) =>
                      Divider(height: 1, color: _border),
                  itemBuilder: (BuildContext context, int i) {
                    final ChatConversation chat = chats[i];
                    final bool isBuyer = chat.buyerId == _uid;
                    final String otherName =
                        isBuyer ? chat.sellerName : chat.buyerName;
                    final String otherAvatar =
                        isBuyer ? chat.sellerAvatarUrl : chat.buyerAvatarUrl;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFFD7E6DE),
                        foregroundImage: otherAvatar.isNotEmpty
                            ? NetworkImage(otherAvatar)
                            : null,
                        child: otherAvatar.isEmpty
                            ? Text(
                                otherName.isNotEmpty
                                    ? otherName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: _headerTeal,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : null,
                      ),
                      title: Text(
                        chat.itemTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: _dark,
                        ),
                      ),
                      subtitle: Text(
                        otherName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: _muted),
                      ),
                      trailing: chat.lastMessage.isNotEmpty
                          ? SizedBox(
                              width: 100,
                              child: Text(
                                chat.lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _muted,
                                ),
                              ),
                            )
                          : null,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ChatScreen(conversation: chat),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        onHomeTap: () => Navigator.of(context).pushReplacement(
          PageRouteBuilder<void>(
            pageBuilder: (ctx, anim, secAnim) => const HomePage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            transitionsBuilder: (ctx, anim, secAnim, child) => child,
          ),
        ),
        onChatTap: () {},
        onAddTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const CreateListingScreen(),
          ),
        ),
        onProfileTap: () => Navigator.of(context).pushReplacement(
          PageRouteBuilder<void>(
            pageBuilder: (ctx, anim, secAnim) => const ProfilePage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            transitionsBuilder: (ctx, anim, secAnim, child) => child,
          ),
        ),
      ),
    );
  }
}
