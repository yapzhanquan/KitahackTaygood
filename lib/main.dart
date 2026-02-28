import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'providers/project_provider.dart';
import 'providers/report_provider.dart';
import 'providers/compare_provider.dart';
import 'presentation/screens/main_page.dart';

void main() {
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
  
  runApp(const ProjekWatchApp());
}

/// ProjekWatch - Community Project Tracking Application
/// 
/// Architecture: Clean Architecture Lite
/// - presentation/ : UI components, screens, widgets
/// - domain/ : Business logic, services
/// - core/ : Theme, constants, utilities
/// - providers/ : State management (Provider)
/// - models/ : Data models
class ProjekWatchApp extends StatelessWidget {
  const ProjekWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
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
