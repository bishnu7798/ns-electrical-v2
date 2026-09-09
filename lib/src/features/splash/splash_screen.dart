import 'package:flutter/material.dart';
import 'dart:async';

import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../shared/constants/app_constants.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import '../../core/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late AnimationController _loadingController;
  late Animation<double> _loadingAnimation;
  bool _isConnected = true;
  bool _showNoInternetDialog = false;

  @override
  void initState() {
    super.initState();
    
    // Check internet connectivity
    _checkInternetConnectivity();
    
    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    ));
    
    // Text animations
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));
    
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    ));
    
    // Loading animation controller
    _loadingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _logoController.forward();
    
    // Navigate after 3 seconds
    Timer(const Duration(seconds: 3), () {
      _navigateToNextScreen();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  Future<void> _checkInternetConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });
    
    // If not connected, show dialog
    if (!_isConnected && mounted) {
      _showNoInternetDialog = true;
      _showNoInternetConnectionDialog();
    }
  }

  void _showNoInternetConnectionDialog() {
    if (_showNoInternetDialog) {
      showDialog(
        context: context,
        barrierDismissible: false, // User must tap button to dismiss
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('No Internet Connection'),
            content: const Text('Please connect to the internet to use this application.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Retry'),
                onPressed: () async {
                  Navigator.of(context).pop(); // Close dialog
                  _showNoInternetDialog = false;
                  await _checkInternetConnectivity(); // Check again
                  // If now connected, proceed to next screen
                  if (_isConnected) {
                    _navigateToNextScreen();
                  }
                },
              ),
            ],
          );
        },
      );
    }
  }

  _navigateToNextScreen() {
    // Only navigate if connected to internet
    if (_isConnected) {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      if (authService.isLoggedIn) {
        // Navigate to home screen if already logged in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // Navigate to login screen if not logged in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 184, 212, 234),
              Color.fromARGB(255, 176, 210, 226),
              Color.fromARGB(255, 150, 190, 220),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              ScaleTransition(
                scale: _logoScaleAnimation,
                child: FadeTransition(
                  opacity: _logoFadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/NSLOGO1.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback widget if image fails to load
                          return Container(
                            width: 120,
                            height: 120,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.electrical_services,
                              color: Colors.white,
                              size: 60,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Animated Text
              FadeTransition(
                opacity: _textFadeAnimation,
                child: SlideTransition(
                  position: _textSlideAnimation,
                  child: Column(
                    children: [
                      Text(
                        AppConstants.appName,
                        style: GoogleFonts.openSans(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppConstants.appTitle,
                        style: GoogleFonts.openSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.7),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 50),
              
              // Unit-like Loading Animation
              FadeTransition(
                opacity: _logoFadeAnimation,
                child: Column(
                  children: [
                    // Custom electrical unit loading animation
                    Container(
                      width: 120,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Animated electrical symbols
                          AnimatedBuilder(
                            animation: _loadingAnimation,
                            builder: (context, child) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Lightning bolt symbol
                                  Transform.rotate(
                                    angle: _loadingAnimation.value * 2 * 3.14159,
                                    child: Icon(
                                      Icons.flash_on,
                                      color: Colors.white.withValues(alpha: 0.7),
                                      size: 24,
                                    ),
                                  ),
                                  // Circuit symbol
                                  Opacity(
                                    opacity: 0.5 + 0.5 * _loadingAnimation.value,
                                    child: const Icon(
                                      Icons.settings,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  // Power symbol
                                  Transform.scale(
                                    scale: 0.8 + 0.2 * _loadingAnimation.value,
                                    child: Icon(
                                      Icons.power_settings_new,
                                      color: Colors.white.withValues(alpha: 0.7),
                                      size: 24,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          // Moving indicator
                          AnimatedBuilder(
                            animation: _loadingAnimation,
                            builder: (context, child) {
                              return Positioned(
                                left: 10 + _loadingAnimation.value * 100,
                                child: Container(
                                  width: 8,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      _isConnected ? 'Initializing Systems' : 'Checking Connection...',
                      style: GoogleFonts.openSans(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}