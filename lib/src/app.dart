import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // For PointerDeviceKind
import 'package:provider/provider.dart';

import 'shared/constants/app_constants.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_screen.dart';
import 'features/dtr/dtr_screen.dart';
import 'features/pole/pole_schedule_screen.dart';
import 'features/pole/add_pole_screen_new.dart';
import 'features/dtr/dtr_list_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/settings/profile_settings_screen.dart';
import 'features/settings/change_password_screen.dart';
import 'features/settings/privacy_policy_screen.dart'; // Add privacy policy screen import
import 'features/settings/terms_of_service_screen.dart'; // Add terms of service screen import

import 'core/models/dtr_model.dart';
import 'core/models/pole_model.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/language_provider.dart'; // Add this import
import 'core/services/auth_service.dart'; // Add this import
import 'shared/widgets/connectivity_banner.dart';

class MyApp extends StatefulWidget {
  final AuthService authService;
  
  const MyApp({super.key, required this.authService});
  
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    // Dispose of the auth service to cancel the auth state subscription
    widget.authService.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return ConnectivityBanner(
          child: MaterialApp(
            title: AppConstants.appName,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
            routes: {
              AppConstants.splashRoute: (context) => const SplashScreen(),
              AppConstants.loginRoute: (context) => const LoginScreen(),
              AppConstants.dashboardRoute: (context) => const HomeScreen(),
              AppConstants.reportsRoute: (context) => const DTRListScreen(),
              AppConstants.settingsRoute: (context) => const SettingsScreen(),
              AppConstants.profileSettingsRoute: (context) => const ProfileSettingsScreen(),
              AppConstants.changePasswordRoute: (context) => const ChangePasswordScreen(),
              AppConstants.privacyPolicyRoute: (context) => const PrivacyPolicyScreen(), // Add privacy policy route
              AppConstants.termsOfServiceRoute: (context) => const TermsOfServiceScreen(), // Add terms of service route

            },
            onGenerateRoute: (settings) {
              if (settings.name == AppConstants.dtrRoute) {
                // Handle DTR screen with optional DTR argument for editing
                final args = settings.arguments as DTR?;
                return MaterialPageRoute(
                  builder: (context) => DTRScreen(dtr: args),
                  maintainState: false, // Don't maintain state to ensure fresh data
                );
              } else if (settings.name == AppConstants.poleScheduleRoute) {
                final args = settings.arguments as Map<String, dynamic>;
                final dtr = args['dtr'] as DTR;
                return MaterialPageRoute(
                  builder: (context) => PoleScheduleScreen(dtr: dtr),
                );
              } else if (settings.name == AppConstants.addPoleRoute) {
                final args = settings.arguments as Map<String, dynamic>?;
                final dtr = args?['dtr'] as DTR;
                final poleToEdit = args?['poleToEdit'] as Pole?;
                return MaterialPageRoute(
                  builder: (context) => AddPoleScreenNew(dtr: dtr, poleToEdit: poleToEdit),
                );

              }
              return null;
            },
            debugShowCheckedModeBanner: false, // Remove DEBUG banner
            // Add scroll behavior for better web experience
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.mouse,
                PointerDeviceKind.touch,
                PointerDeviceKind.stylus,
                PointerDeviceKind.unknown
              },
            ),
          ),
        );
      },
    );
  }
}