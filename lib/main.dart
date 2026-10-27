import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/splash_screen.dart';
import 'store/app_store.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark),
  );
  runApp(DovixApp(store: AppStore()));
}

class DovixApp extends StatelessWidget {
  const DovixApp({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      store: store,
      child: MaterialApp(
        title: 'Dovix AI Call Center',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        // On web/desktop, frame the app at phone width so the mobile layout holds.
        builder: (context, child) => ColoredBox(
          color: const Color(0xFFE2E8F0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ClipRect(child: child),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
