import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'config/app_config.dart';
import 'config/firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'providers/project_provider.dart';
import 'providers/report_provider.dart';
import 'providers/compare_provider.dart';
import 'providers/auth_provider.dart' as app_auth;
import 'presentation/screens/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final runtimeMode = await _resolveRuntimeDataMode();
  AppConfig.setRuntimeDataMode(runtimeMode);

  runApp(ProjekWatchApp(runtimeMode: runtimeMode));
}

Future<DataMode> _resolveRuntimeDataMode() async {
  if (AppConfig.dataMode != DataMode.firebase) {
    return DataMode.mock;
  }

  if (!DefaultFirebaseOptions.isConfigured) {
    debugPrint(
      'DATA_MODE=firebase requested but firebase_options.dart has placeholder '
      'values. Falling back to mock mode.',
    );
    return DataMode.mock;
  }

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

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

    return DataMode.firebase;
  } catch (error) {
    debugPrint('Firebase initialization failed ($error). Falling back to mock mode.');
    return DataMode.mock;
  }
}

/// ProjekWatch - Community Project Tracking Application
class ProjekWatchApp extends StatelessWidget {
  final DataMode runtimeMode;

  const ProjekWatchApp({super.key, required this.runtimeMode});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProjectProvider(dataMode: runtimeMode),
        ),
        ChangeNotifierProvider(
          create: (_) => app_auth.AuthProvider(dataMode: runtimeMode),
        ),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => CompareProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const MainPage(),
      ),
    );
  }
}

