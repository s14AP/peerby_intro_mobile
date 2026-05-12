import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:re_use/firebase_options.dart';
import 'package:re_use/screens/auth/login_screen.dart';
import 'package:re_use/screens/homepage/homepage.dart';
import 'package:re_use/services/auth_service.dart';
import 'package:re_use/services/item_service.dart';
import 'package:re_use/utils/maps_script_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  if (kIsWeb) {
    await loadMapsScript(dotenv.env['google_maps_api_key'] ?? '');
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await ItemService().seedItemsIfEmpty();

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) {
        return const MyApp();
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String _globalFontFamily = 'Inter';

  @override
  Widget build(BuildContext context) {
    final ThemeData lightTheme = ThemeData.light();
    final ThemeData darkTheme = ThemeData.dark();

    return MaterialApp(
      // ignore: deprecated_member_use
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: lightTheme.copyWith(
        textTheme: lightTheme.textTheme.apply(fontFamily: _globalFontFamily),
        primaryTextTheme: lightTheme.primaryTextTheme.apply(
          fontFamily: _globalFontFamily,
        ),
      ),
      darkTheme: darkTheme.copyWith(
        textTheme: darkTheme.textTheme.apply(fontFamily: _globalFontFamily),
        primaryTextTheme: darkTheme.primaryTextTheme.apply(
          fontFamily: _globalFontFamily,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final Stream<User?> _authStream = AuthService().authStateChanges;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomePage();
        }
        return const LoginScreen();
      },
    );
  }
}
