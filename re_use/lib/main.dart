import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:re_use/firebase_options.dart';
import 'package:re_use/screens/auth/login_screen.dart';
import 'package:re_use/screens/homepage/homepage.dart';
import 'package:re_use/services/auth_service.dart';
import 'package:re_use/services/item_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ItemService().seedItemsIfEmpty();

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

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // still loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // logged in → go to homepage
        if (snapshot.hasData) {
          return const HomePage();
        }

        // not logged in → go to login
        return const LoginScreen();
      },
    );
  }
}
