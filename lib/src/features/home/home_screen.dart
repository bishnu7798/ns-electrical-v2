import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import '../../core/services/auth_service.dart';
import '../../shared/constants/app_constants.dart';
import '../../core/models/dtr_model.dart';
import '../../core/services/dtr_service.dart';
import '../../core/services/pole_service.dart';
import '../../shared/widgets/responsive_builder.dart';
import '../../core/providers/language_provider.dart';
import '../../core/utils/translation_service.dart';
import 'package:animate_do/animate_do.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  final _dtrService = DTRService();
  final _poleService = PoleService();
  List<DTR> _dtrs = [];
  List<DTR> _filteredDtrs = [];
  bool _isSearching = false;
  Map<String, double> _dtrRouteLengths = {};
  String _locationName = '';
  String _currentTime = '';
  
  String? _deletingDtrId;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    _getCurrentLocation();
    _updateCurrentTime();
    
    // Update time every minute
    Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        _updateCurrentTime();
      }
    });
    
    await _loadDTRs();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check location permission
      var status = await Permission.location.status;
      if (!status.isGranted) {
        status = await Permission.location.request();
        if (!status.isGranted) {
          setState(() {
            _locationName = 'Good to see you';
          });
          return;
        }
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Convert coordinates to place name (reverse geocoding)
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String locationName = '';
        
        // Build location name from placemark components
        if (place.locality != null && place.locality!.isNotEmpty) {
          locationName = place.locality!;
        } else if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
          locationName = place.subAdministrativeArea!;
        } else if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          locationName = place.administrativeArea!;
        } else {
          locationName = '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}';
        }

        setState(() {
          _locationName = locationName;
        });
      }
    } catch (e) {
      setState(() {
        _locationName = 'Location unavailable';
      });
      debugPrint('Error getting location: $e');
    }
  }

  void _updateCurrentTime() {
    setState(() {
      _currentTime = DateFormat('hh:mm a, dd MMM yyyy').format(DateTime.now());
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // Properly dispose of the controller
    super.dispose();
  }

  Future<void> _loadDTRs() async {
    try {
      final dtrs = await _dtrService.getAllDTRs();
      setState(() {
        _dtrs = dtrs;
        _filteredDtrs = dtrs;
      });
      
      await _loadRouteLengths(dtrs);
    } catch (e) {
      debugPrint('Error loading DTRs: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load DTRs: $e')),
        );
      }
    }
  }

  Future<void> _loadRouteLengths(List<DTR> dtrs) async {
    Map<String, double> routeLengths = {};
    
    for (var dtr in dtrs) {
      final poles = await _poleService.getPolesForDTR(dtr.id);
      double totalLength = poles.fold(0.0, (sum, pole) => sum + pole.routhLength);
      routeLengths[dtr.id] = totalLength;
    }
    
    setState(() {
      _dtrRouteLengths = routeLengths;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      extendBodyBehindAppBar: true,
      appBar: _buildModernAppBar(context, authService, languageProvider, isDarkMode),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveBuilder(
              builder: (context, isMobile, isTablet, isDesktop) {
                return RefreshIndicator(
                  onRefresh: _loadDTRs,
                  color: colorScheme.primary,
                  backgroundColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      // Top spacing for app bar
                      SliverToBoxAdapter(
                        child: SizedBox(height: isMobile ? 100 : 120),
                      ),
                      
                      // Welcome Section
                      SliverToBoxAdapter(
                        child: FadeInDown(
                          duration: const Duration(milliseconds: 600),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 16.0 : 24.0,
                            ),
                            child: _buildModernWelcomeCard(context, authService, isDarkMode, colorScheme),
                          ),
                        ),
                      ),
                      
                      SliverToBoxAdapter(
                        child: SizedBox(height: isMobile ? 20 : 28),
                      ),
                      
                      // Quick Actions
                      SliverToBoxAdapter(
                        child: FadeInUp(
                          delay: const Duration(milliseconds: 200),
                          duration: const Duration(milliseconds: 600),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 16.0 : 24.0,
                            ),
                            child: _buildQuickActions(context, isDarkMode, colorScheme),
                          ),
                        ),
                      ),
                      
                      SliverToBoxAdapter(
                        child: SizedBox(height: isMobile ? 24 : 32),
                      ),
                      
                      // Section Header
                      SliverToBoxAdapter(
                        child: FadeInLeft(
                          delay: const Duration(milliseconds: 400),
                          duration: const Duration(milliseconds: 600),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 16.0 : 24.0,
                            ),
                            child: _buildModernHeader(context, isMobile, colorScheme),
                          ),
                        ),
                      ),
                      
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 16),
                      ),
                      
                      // DTR List
                      SliverToBoxAdapter(
                        child: FadeInUp(
                          delay: const Duration(milliseconds: 500),
                          duration: const Duration(milliseconds: 600),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 16.0 : 24.0,
                            ),
                            child: _buildModernDtrList(context, isMobile, isDarkMode, colorScheme),
                          ),
                        ),
                      ),
                      
                      // Bottom spacing
                      SliverToBoxAdapter(
                        child: SizedBox(height: isMobile ? 100 : 120),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: _buildModernFAB(context, isDarkMode, colorScheme),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  PreferredSizeWidget _buildModernAppBar(
    BuildContext context,
    AuthService authService,
    LanguageProvider languageProvider,
    bool isDarkMode,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode 
                ? [
                    const Color(0xFF1E1E1E),
                    const Color(0xFF2D2D2D),
                  ]
                : [
                    colorScheme.primary,
                    colorScheme.primaryContainer,
                  ],
          ),
        ),
      ),
      title: Row(
        children: [
          Hero(
            tag: 'app_logo',
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.asset(
                  'assets/images/NSLOGO1.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.electrical_services,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 24,
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppConstants.project,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Electrical Management',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w400,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
      centerTitle: false,
      actions: [
        // Search Button
        _buildAppBarActionButton(
          context,
          icon: Icons.search,
          onPressed: () => _showSearchDialog(context),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(width: 8),
        // Profile Menu
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: PopupMenuButton<String>(
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            menuPadding: const EdgeInsets.symmetric(vertical: 8),
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  authService.userInitials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            onSelected: (String result) async {
              switch (result) {
                case 'settings':
                  Navigator.pushNamed(context, AppConstants.settingsRoute);
                  break;
                case 'reports':
                  Navigator.pushNamed(context, AppConstants.reportsRoute);
                  break;
                case 'logout':
                  _showLogoutDialog(context, languageProvider);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              _buildPopupMenuItem(
                value: 'settings',
                icon: Icons.settings_outlined,
                title: 'Settings',
                subtitle: 'App preferences',
              ),
              _buildPopupMenuItem(
                value: 'reports',
                icon: Icons.insert_chart_outlined,
                title: 'Reports',
                subtitle: 'View analytics',
              ),
              const PopupMenuDivider(),
              _buildPopupMenuItem(
                value: 'logout',
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Sign out',
                isDestructive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBarActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDarkMode,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.9),
            size: 20,
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
    bool isDestructive = false,
  }) {
    return PopupMenuItem<String>(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDestructive 
                  ? Colors.red.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isDestructive ? Colors.red : Colors.grey[700],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDestructive ? Colors.red : null,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, LanguageProvider languageProvider) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout, color: Colors.red),
              ),
              const SizedBox(width: 12),
              Text(
                TranslationService.translate('logout', languageProvider.selectedLanguage),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            TranslationService.translate('are_you_sure_you_want_to_logout', languageProvider.selectedLanguage),
            style: TextStyle(
              color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(
                foregroundColor: isDarkMode ? Colors.grey[400] : Colors.grey,
              ),
              child: Text(TranslationService.translate('cancel', languageProvider.selectedLanguage)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final authService = Provider.of<AuthService>(context, listen: false);
                await authService.logout();
                
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppConstants.loginRoute,
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(TranslationService.translate('logout', languageProvider.selectedLanguage)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModernWelcomeCard(
    BuildContext context,
    AuthService authService,
    bool isDarkMode,
    ColorScheme colorScheme,
  ) {
    final userName = authService.userEmail.split('@')[0];
    final hour = DateTime.now().hour;
    String greeting;
    IconData greetingIcon;
    
    if (hour < 12) {
      greeting = 'Good Morning';
      greetingIcon = Icons.wb_sunny_outlined;
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      greetingIcon = Icons.wb_cloudy_outlined;
    } else {
      greeting = 'Good Evening';
      greetingIcon = Icons.nights_stay_outlined;
    }
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  const Color(0xFF2D2D2D),
                  const Color(0xFF1E1E1E),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF8F9FA),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withValues(alpha: 0.3)
                : colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDarkMode 
              ? Colors.grey[800]!
              : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primaryContainer,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  greetingIcon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _capitalizeFirst(userName),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? Colors.grey[850]
                  : colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _locationName.isEmpty ? 'Getting location...' : _locationName,
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.access_time_outlined,
                  size: 16,
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                ),
                const SizedBox(width: 4),
                Text(
                  _currentTime.isEmpty ? '--:--' : _currentTime.split(',')[0],
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Widget _buildQuickActions(BuildContext context, bool isDarkMode, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                context,
                icon: Icons.add_circle_outline,
                label: 'New DTR',
                color: colorScheme.primary,
                onTap: () async {
                  final result = await Navigator.pushNamed(context, AppConstants.dtrRoute);
                  if (result != null) {
                    _loadDTRs();
                  }
                },
                isDarkMode: isDarkMode,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                context,
                icon: Icons.insert_chart_outlined,
                label: 'Reports',
                color: Colors.orange,
                onTap: () {
                  Navigator.pushNamed(context, AppConstants.reportsRoute);
                },
                isDarkMode: isDarkMode,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                context,
                icon: Icons.settings_outlined,
                label: 'Settings',
                color: Colors.green,
                onTap: () {
                  Navigator.pushNamed(context, AppConstants.settingsRoute);
                },
                isDarkMode: isDarkMode,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: isDarkMode 
                ? const Color(0xFF2D2D2D)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode 
                  ? Colors.grey[800]!
                  : Colors.grey[200]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode 
                    ? Colors.black.withValues(alpha: 0.2)
                    : color.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernFAB(BuildContext context, bool isDarkMode, ColorScheme colorScheme) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, AppConstants.dtrRoute);
          if (result != null) {
            _loadDTRs();
          }
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: const Icon(Icons.add),
        label: const Text(
          'Add DTR',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildModernStatisticsSection(
    BuildContext context,
    bool isMobile,
    bool isDarkMode,
    ColorScheme colorScheme,
  ) {
    final totalDtrs = _dtrs.length;
    final villages = _calculateUniqueVillages();
    final routeLength = _calculateTotalRouteLength();
    final capacity = _calculateTotalCapacity();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard Overview',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isMobile ? 2 : 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isMobile ? 1.3 : 1.5,
          children: [
            _buildModernStatCard(
              context,
              icon: Icons.electrical_services,
              title: 'Total DTRs',
              value: totalDtrs.toString(),
              subtitle: 'Active transformers',
              color: colorScheme.primary,
              gradientColors: [colorScheme.primary, colorScheme.primaryContainer],
              isDarkMode: isDarkMode,
            ),
            _buildModernStatCard(
              context,
              icon: Icons.location_city,
              title: 'Villages',
              value: villages.toString(),
              subtitle: 'Covered areas',
              color: Colors.orange,
              gradientColors: [Colors.orange, Colors.orange.shade300],
              isDarkMode: isDarkMode,
            ),
            _buildModernStatCard(
              context,
              icon: Icons.route_outlined,
              title: 'Route Length',
              value: '${routeLength.toStringAsFixed(1)} km',
              subtitle: 'Total distance',
              color: Colors.green,
              gradientColors: [Colors.green, Colors.green.shade300],
              isDarkMode: isDarkMode,
            ),
            _buildModernStatCard(
              context,
              icon: Icons.bolt,
              title: 'Capacity',
              value: '${capacity.toStringAsFixed(0)} kVA',
              subtitle: 'Power output',
              color: Colors.purple,
              gradientColors: [Colors.purple, Colors.purple.shade300],
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required List<Color> gradientColors,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [const Color(0xFF2D2D2D), const Color(0xFF252525)]
              : [Colors.white, const Color(0xFFF8F9FA)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withValues(alpha: 0.2)
                : color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              if (value != '0')
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.4),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _calculateUniqueVillages() {
    final villages = <String>{};
    for (final dtr in _dtrs) {
      villages.add(dtr.village);
    }
    return villages.length;
  }

  double _calculateTotalRouteLength() {
    double total = 0;
    for (final entry in _dtrRouteLengths.entries) {
      total += entry.value.toDouble();
    }
    // Convert meters to kilometers
    return total / 1000;
  }

  double _calculateTotalCapacity() {
    double total = 0;
    for (final dtr in _dtrs) {
      try {
        total += double.tryParse(dtr.capacity) ?? 0.0;
      } catch (e) {
        // If parsing fails, add 0 to the total
        total += 0.0;
      }
    }
    return total;
  }

  Widget _buildModernHeader(BuildContext context, bool isMobile, ColorScheme colorScheme) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary,
                    colorScheme.primaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.format_list_bulleted,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your DTRs',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  _filteredDtrs.isEmpty 
                      ? 'No records found'
                      : '${_filteredDtrs.length} ${_filteredDtrs.length == 1 ? 'record' : 'records'} available',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
        if (_filteredDtrs.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 14,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_filteredDtrs.length}',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildModernDtrList(BuildContext context, bool isMobile, bool isDarkMode, ColorScheme colorScheme) {
    if (_filteredDtrs.isEmpty) {
      return _isSearching
          ? _buildModernNoSearchResultsWidget(isDarkMode, colorScheme)
          : _buildModernEmptyStateWidget(isDarkMode, colorScheme);
    }

    return Column(
      children: List.generate(_filteredDtrs.length, (index) {
        final dtr = _filteredDtrs[index];
        return SlideInUp(
          delay: Duration(milliseconds: 50 + (index * 80)),
          duration: const Duration(milliseconds: 500),
          child: _buildModernDtrCard(context, dtr, isDarkMode, colorScheme),
        );
      }),
    );
  }



  Widget _buildModernDtrCard(BuildContext context, DTR dtr, bool isDarkMode, ColorScheme colorScheme) {
    final isDeleting = _deletingDtrId == dtr.id;
    final routeLength = _dtrRouteLengths[dtr.id] ?? 0.0;
    
    if (isDeleting) {
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeIn,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.scale(
              scale: 0.95 + (0.05 * value),
              child: child,
            ),
          );
        },
        onEnd: () async {
          await _deleteDtrPermanently(dtr);
        },
        child: _buildModernDtrCardContent(context, dtr, routeLength, isDarkMode, colorScheme),
      );
    }
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final result = await Navigator.pushNamed(
            context,
            AppConstants.poleScheduleRoute,
            arguments: {'dtr': dtr},
          );
          if (result != null) {
            _loadDTRs();
          }
        },
        onLongPress: () => _showModernDtrOptions(context, dtr, isDarkMode, colorScheme),
        borderRadius: BorderRadius.circular(20),
        child: _buildModernDtrCardContent(context, dtr, routeLength, isDarkMode, colorScheme),
      ),
    );
  }

  Widget _buildModernDtrCardContent(
    BuildContext context,
    DTR dtr,
    double routeLength,
    bool isDarkMode,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [const Color(0xFF2D2D2D), const Color(0xFF252525)]
              : [Colors.white, const Color(0xFFFAFBFC)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withValues(alpha: 0.2)
                : colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary,
                        colorScheme.primaryContainer,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/images/dtr.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.electrical_services,
                            color: Colors.white,
                            size: 26,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dtr.dtrCode,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: isDarkMode ? Colors.white : Colors.black,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${dtr.village}, ${dtr.location}',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDarkMode 
                        ? Colors.grey[800]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          
          // Divider
          Divider(
            height: 1,
            color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            indent: 16,
            endIndent: 16,
          ),
          
          // Details Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildModernDtrDetail(
                    icon: Icons.bolt_outlined,
                    label: 'Capacity',
                    value: '${dtr.capacity} kVA',
                    color: Colors.orange,
                    isDarkMode: isDarkMode,
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                ),
                Expanded(
                  child: _buildModernDtrDetail(
                    icon: Icons.confirmation_number_outlined,
                    label: 'CCC',
                    value: dtr.ccc.isEmpty ? 'N/A' : dtr.ccc,
                    color: colorScheme.primary,
                    isDarkMode: isDarkMode,
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                ),
                Expanded(
                  child: _buildModernDtrDetail(
                    icon: Icons.route_outlined,
                    label: 'Route',
                    value: '${routeLength.toStringAsFixed(0)} m',
                    color: Colors.green,
                    isDarkMode: isDarkMode,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDtrDetail({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDarkMode,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildModernEmptyStateWidget(bool isDarkMode, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [const Color(0xFF2D2D2D), const Color(0xFF252525)]
              : [Colors.white, const Color(0xFFFAFBFC)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withValues(alpha: 0.2)
                : colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary.withValues(alpha: 0.2),
                  colorScheme.primaryContainer.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.electrical_services_outlined,
              size: 48,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No DTRs Yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first DTR to get started with electrical management',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.pushNamed(context, AppConstants.dtrRoute);
              if (result != null) {
                _loadDTRs();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.add, size: 20),
            label: const Text(
              'Create First DTR',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernNoSearchResultsWidget(bool isDarkMode, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [const Color(0xFF2D2D2D), const Color(0xFF252525)]
              : [Colors.white, const Color(0xFFFAFBFC)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.search_off_outlined,
              size: 40,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Results Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search terms or filters',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _filteredDtrs = _dtrs;
                _isSearching = false;
                _searchText = '';
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.clear, size: 18),
            label: const Text(
              'Clear Search',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    // Set the controller text to the current search text
    _searchController.text = _searchText;
    
    // Add listener for real-time search
    void onTextChanged() {
      setState(() {
        _searchText = _searchController.text;
      });
      _performSearch(_searchText);
    }
    
    // Remove any existing listener to avoid duplicates
    _searchController.removeListener(onTextChanged);
    _searchController.addListener(onTextChanged);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Search DTRs',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              backgroundColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _searchController, // Use the class-level controller
                    autofocus: true,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by DTR code, village, location...',
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic_off : Icons.mic,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey,
                        ),
                        onPressed: () => _listen(setState, _searchController),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      filled: true,
                      fillColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[50],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_isListening)
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mic, color: Colors.red, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Listening...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Remove listener and close dialog
                    _searchController.removeListener(onTextChanged);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Remove listener, perform final search and close dialog
                    _searchController.removeListener(onTextChanged);
                    _performSearch(_searchText);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Search',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Ensure listener is removed when dialog is closed
      _searchController.removeListener(onTextChanged);
    });
  }

  void _listen(StateSetter setState, TextEditingController controller) async {
    if (!_isListening) {
      try {
        bool available = await _speech.initialize(
          onStatus: (status) {
            // Automatically stop listening when speech ends
            if (status == 'done') {
              setState(() {
                _isListening = false;
              });
            }
          },
          onError: (errorNotification) {
            setState(() {
              _isListening = false;
            });
            // Show error to user
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Speech error: ${errorNotification.errorMsg}')),
              );
            }
          },
        );
        
        if (available) {
          setState(() {
            _isListening = true;
          });
          
          _speech.listen(
            onResult: (result) {
              setState(() {
                controller.text = result.recognizedWords;
                _searchText = result.recognizedWords;
              });
              _performSearch(_searchText);
            },
          );
        }
      } catch (e) {
        setState(() {
          _isListening = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Speech recognition error: $e')),
          );
        }
      }
    } else {
      setState(() {
        _isListening = false;
      });
      _speech.stop();
    }
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredDtrs = _dtrs;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _filteredDtrs = _dtrs.where((dtr) {
        final searchTerm = query.toLowerCase();
        return dtr.dtrCode.toLowerCase().contains(searchTerm) ||
            dtr.village.toLowerCase().contains(searchTerm) ||
            dtr.location.toLowerCase().contains(searchTerm) ||
            dtr.ccc.toLowerCase().contains(searchTerm);
      }).toList();
    });
  }

  void _showModernDtrOptions(BuildContext context, DTR dtr, bool isDarkMode, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // DTR Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[850] : colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [colorScheme.primary, colorScheme.primaryContainer],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.electrical_services,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dtr.dtrCode,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${dtr.village}, ${dtr.location}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Actions
                  _buildModernOptionTile(
                    context,
                    icon: Icons.edit_outlined,
                    title: 'Edit DTR',
                    subtitle: 'Modify DTR details',
                    color: colorScheme.primary,
                    isDarkMode: isDarkMode,
                    onTap: () async {
                      Navigator.pop(context);
                      final result = await Navigator.pushNamed(
                        context,
                        AppConstants.dtrRoute,
                        arguments: dtr,
                      );
                      if (result != null) {
                        _loadDTRs();
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildModernOptionTile(
                    context,
                    icon: Icons.delete_outline,
                    title: 'Delete DTR',
                    subtitle: 'Remove permanently',
                    color: Colors.red,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      Navigator.pop(context);
                      _confirmDeleteDtr(context, dtr);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildModernOptionTile(
                    context,
                    icon: Icons.close,
                    title: 'Cancel',
                    subtitle: 'Close menu',
                    color: isDarkMode ? Colors.grey[500]! : Colors.grey,
                    isDarkMode: isDarkMode,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteDtr(BuildContext context, DTR dtr) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete DTR',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          backgroundColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
          content: Text(
            'Are you sure you want to delete DTR ${dtr.dtrCode}? This action cannot be undone.',
            style: TextStyle(
              color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Start the simple fade out animation
                _startDeleteAnimation(dtr);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
  
  void _startDeleteAnimation(DTR dtr) {
    setState(() {
      _deletingDtrId = dtr.id;
    });
  }
  
  Future<void> _deleteDtrPermanently(DTR dtr) async {
    try {
      await _dtrService.deleteDTR(dtr.id);
      await _loadDTRs();
      
      // Reset the deleting state
      if (mounted) {
        setState(() {
          _deletingDtrId = null;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('DTR deleted successfully')),
        );
      }
    } catch (e) {
      // Handle any errors during deletion
      if (mounted) {
        setState(() {
          _deletingDtrId = null;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete DTR')),
        );
      }
    }
  }
}