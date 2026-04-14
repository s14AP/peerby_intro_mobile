import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:re_use/screens/homepage/homepage.dart';

void main() {
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

  static const String _globalFontFamily = '.SF Pro Text';

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
      home: const HomePage(),
    );
  }
}
