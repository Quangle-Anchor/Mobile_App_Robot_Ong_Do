import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_colors.dart';
import 'providers/calligraphy_provider.dart';
import 'providers/robot_stream_provider.dart';
import 'providers/history_provider.dart';
import 'screens/main_navigation.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CalligraphyProvider()),
        ChangeNotifierProvider(create: (_) => RobotStreamProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final String baseFontFamily =
        (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows)
        ? 'Segoe UI'
        : 'Georgia';

    return MaterialApp(
      title: 'Robot Ông Đồ',
      debugShowCheckedModeBanner: false,

      // Beautiful Custom Theme settings mapping the design tokens from styles.css
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.gold,
          surface: AppColors.card, // 'background' deprecated → use 'surface'
        ),

        // Premium default component themes
        cardTheme: CardThemeData(
          // CardTheme → CardThemeData
          color: AppColors.card,
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
            side: const BorderSide(color: AppColors.border, width: 1.0),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.card,
          foregroundColor: AppColors.ink,
          elevation: 0.0,
        ),

        // Elegant serif default font config for standard displays
        fontFamily: baseFontFamily,
      ),

      // Load responsive primary layout controller shell
      home: const MainNavigationScreen(),
    );
  }
}
