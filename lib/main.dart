import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/colors.dart';
import 'screens/main_wrapper.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi notification service
  await NotificationService().initialize();
  
  runApp(const SekolahKitaApp());
}

class SekolahKitaApp extends StatelessWidget {
  const SekolahKitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SekolahKita',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.softTeal,
        textTheme: GoogleFonts.nunitoTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: AppColors.textDark,
          displayColor: AppColors.textDark,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue),
      ),
      home: const MainWrapper(),
    );
  }
}
