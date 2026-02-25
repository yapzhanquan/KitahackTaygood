import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'config/app_config.dart';
import 'config/firebase_options.dart';
import 'providers/project_provider.dart';
import 'providers/auth_provider.dart' as app_auth;
import 'screens/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase only in firebase mode
  if (AppConfig.dataMode == DataMode.firebase) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Connect to emulators if enabled
    if (AppConfig.useEmulators) {
      FirebaseFirestore.instance.useFirestoreEmulator(
        AppConfig.emulatorHost,
        AppConfig.firestorePort,
      );
      await FirebaseAuth.instance.useAuthEmulator(
        AppConfig.emulatorHost,
        AppConfig.authPort,
      );
      FirebaseStorage.instance.useStorageEmulator(
        AppConfig.emulatorHost,
        AppConfig.storagePort,
      );
    }
  }

  runApp(const ProjekWatchApp());
}

class ProjekWatchApp extends StatelessWidget {
  const ProjekWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => app_auth.AuthProvider()),
      ],
      child: MaterialApp(
        title: 'ProjekWatch',
        debugShowCheckedModeBanner: false,
        debugShowMaterialGrid: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFFAFAFA),
          textTheme: GoogleFonts.interTextTheme(
            ThemeData.light().textTheme,
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 57, 57, 71),
            brightness: Brightness.light,
            surface: const Color(0xFFFAFAFA),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF1A1A2E),
            elevation: 0,
            scrolledUnderElevation: 1,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A2E),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF1A1A2E), width: 1.5),
            ),
          ),
        ),
        home: const MainPage(),
      ),
    );
  }
}
