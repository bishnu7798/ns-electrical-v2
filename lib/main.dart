import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for SystemChrome
import 'package:provider/provider.dart';

import 'src/app.dart';
import 'src/core/services/auth_service.dart';
import 'src/core/providers/language_provider.dart'; // Add this import
import 'src/core/providers/theme_provider.dart'; // Add this import
import 'src/core/services/permission_service.dart';
import 'src/core/services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    // For proper Firebase setup, you need to run `flutterfire configure` first
    // and add the appropriate configuration files to your project
    await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform, // Uncomment after flutterfire configure
    );
  } catch (e) {
    print('Firebase not properly configured. Running in offline mode. Error: $e');
  }
  
  // Request initial permissions
  try {
    final permissionService = PermissionService();
    await permissionService.requestInitialPermissions();
  } catch (e) {
    print('Error requesting permissions: $e');
  }
  
  // Initialize local storage
  try {
    final localStorageService = LocalStorageService();
    await localStorageService.init();
  } catch (e) {
    print('Error initializing local storage: $e');
  }
  
  // Optimize for web and mobile platforms
  if (kIsWeb) {
    // Web-specific optimizations
    // Ensure desktop-like scrolling behavior on web
    // This improves the user experience on web platforms
  } else {
    // Mobile-specific optimizations
    // Lock orientation to portrait for mobile devices
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Enable adaptive layout for different screen densities
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }
  
  // Performance optimization: Only rebuild widgets when necessary
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: _initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return const Scaffold(
              body: Center(
                child: Text('Failed to initialize app'),
              ),
            );
          } else {
            return snapshot.data!;
          }
        },
      ),
    ),
  );
}

Future<Widget> _initializeApp() async {
  // Initialize the auth service
  final authService = AuthService();
  await authService.init();
  
  // Create providers
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: authService),
      ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ChangeNotifierProvider(create: (context) => LanguageProvider()),
    ],
    child: MyApp(authService: authService),
  );
}