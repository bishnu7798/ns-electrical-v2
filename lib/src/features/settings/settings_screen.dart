import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/auth_service.dart';
import '../../shared/constants/app_constants.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/language_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedTheme = 'Default';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTheme = prefs.getString('selected_theme') ?? 'Default';
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _saveThemePreference(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_theme', theme);
  }

  void _applyTheme(String theme) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    switch (theme) {
      case 'Blue':
        themeProvider.setPrimaryColor(Colors.blue);
        break;
      case 'Green':
        themeProvider.setPrimaryColor(Colors.green);
        break;
      case 'Red':
        themeProvider.setPrimaryColor(Colors.red);
        break;
      case 'Purple':
        themeProvider.setPrimaryColor(Colors.purple);
        break;
      case 'Orange':
        themeProvider.setPrimaryColor(Colors.orange);
        break;
      case 'Pink':
        themeProvider.setPrimaryColor(Colors.pink);
        break;
      case 'Teal':
        themeProvider.setPrimaryColor(Colors.teal);
        break;
      case 'Indigo':
        themeProvider.setPrimaryColor(Colors.indigo);
        break;
      case 'Amber':
        themeProvider.setPrimaryColor(Colors.amber);
        break;
      case 'Lime':
        themeProvider.setPrimaryColor(Colors.lime);
        break;
      case 'Cyan':
        themeProvider.setPrimaryColor(Colors.cyan);
        break;
      case 'DeepPurple':
        themeProvider.setPrimaryColor(Colors.deepPurple);
        break;
      case 'LightBlue':
        themeProvider.setPrimaryColor(Colors.lightBlue);
        break;
      case 'DeepOrange':
        themeProvider.setPrimaryColor(Colors.deepOrange);
        break;
      default:
        // Default theme
        themeProvider.setPrimaryColor(Colors.blue);
    }
  }

  Future<void> _saveNotificationPreference(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              _buildSectionHeader('Profile', isDarkMode),
              _buildProfileCard(isDarkMode),
              const SizedBox(height: 24),
              
              // Preferences Section
              _buildSectionHeader('Preferences', isDarkMode),
              _buildSettingsCard(
                title: 'Notifications',
                subtitle: 'Enable or disable notifications',
                isDarkMode: isDarkMode,
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    _saveNotificationPreference(value);
                  },
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingsCard(
                title: 'Dark Mode',
                subtitle: 'Enable dark theme',
                isDarkMode: isDarkMode,
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingsCard(
                title: 'Language',
                subtitle: 'Select app language',
                isDarkMode: isDarkMode,
                trailing: DropdownButton<String>(
                  value: languageProvider.selectedLanguage,
                  items: const [
                    DropdownMenuItem(value: 'English', child: Text('English')),
                    DropdownMenuItem(value: 'Spanish', child: Text('Spanish')),
                    DropdownMenuItem(value: 'French', child: Text('French')),
                    DropdownMenuItem(value: 'Bengali', child: Text('Bengali')),
                    DropdownMenuItem(value: 'Hindi', child: Text('Hindi')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      languageProvider.setLanguage(value);
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingsCard(
                title: 'Theme',
                subtitle: 'Select app theme',
                isDarkMode: isDarkMode,
                trailing: DropdownButton<String>(
                  value: _selectedTheme,
                  items: const [
                    DropdownMenuItem(value: 'Default', child: Text('Default')),
                    DropdownMenuItem(value: 'Blue', child: Text('Blue')),
                    DropdownMenuItem(value: 'Green', child: Text('Green')),
                    DropdownMenuItem(value: 'Red', child: Text('Red')),
                    DropdownMenuItem(value: 'Purple', child: Text('Purple')),
                    DropdownMenuItem(value: 'Orange', child: Text('Orange')),
                    DropdownMenuItem(value: 'Pink', child: Text('Pink')),
                    DropdownMenuItem(value: 'Teal', child: Text('Teal')),
                    DropdownMenuItem(value: 'Indigo', child: Text('Indigo')),
                    DropdownMenuItem(value: 'Amber', child: Text('Amber')),
                    DropdownMenuItem(value: 'Lime', child: Text('Lime')),
                    DropdownMenuItem(value: 'Cyan', child: Text('Cyan')),
                    DropdownMenuItem(value: 'DeepPurple', child: Text('Deep Purple')),
                    DropdownMenuItem(value: 'LightBlue', child: Text('Light Blue')),
                    DropdownMenuItem(value: 'DeepOrange', child: Text('Deep Orange')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedTheme = value;
                      });
                      _saveThemePreference(value);
                      _applyTheme(value);
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              // Account Section
              _buildSectionHeader('Account', isDarkMode),
              _buildSettingsCard(
                title: 'Change Password',
                subtitle: 'Update your password',
                isDarkMode: isDarkMode,
                onTap: () {
                  // Navigate to change password screen
                  Navigator.pushNamed(context, AppConstants.changePasswordRoute);
                },
              ),
              const SizedBox(height: 12),
              _buildSettingsCard(
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                isDarkMode: isDarkMode,
                onTap: () {
                  // Navigate to privacy policy screen
                  Navigator.pushNamed(context, '/privacy-policy');
                },
              ),
              const SizedBox(height: 12),
              _buildSettingsCard(
                title: 'Terms of Service',
                subtitle: 'Read our terms of service',
                isDarkMode: isDarkMode,
                onTap: () {
                  // Navigate to terms of service screen
                  Navigator.pushNamed(context, '/terms-of-service');
                },
              ),
              const SizedBox(height: 24),
              
              // Danger Zone
              _buildSectionHeader('Danger Zone', isDarkMode),
              _buildSettingsCard(
                title: 'Delete Account',
                subtitle: 'Permanently delete your account',
                isDarkMode: isDarkMode,
                textColor: Colors.red,
                onTap: () {
                  _showDeleteAccountConfirmation();
                },
              ),
              const SizedBox(height: 24),
              
              // Logout Button
              Center(
                child: ElevatedButton(
                  onPressed: _showLogoutConfirmation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.blue[300]! : Colors.blue,
        ),
      ),
    );
  }

  Widget _buildProfileCard(bool isDarkMode) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userEmail = authService.userEmail;
    final userInitials = authService.userInitials;

    return Card(
      elevation: 2,
      color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: isDarkMode ? Colors.black : Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode 
                      ? Colors.white.withValues(alpha: 0.1) 
                      : Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  userInitials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userEmail.split('@')[0],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Navigate to profile settings screen
                Navigator.pushNamed(context, AppConstants.profileSettingsRoute);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required String subtitle,
    required bool isDarkMode,
    Widget? trailing,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor ?? (isDarkMode ? Colors.white : Colors.black),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor ?? (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
              if (onTap != null && trailing == null)
                Icon(Icons.arrow_forward_ios, size: 16, color: isDarkMode ? Colors.grey[400] : Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                // Perform logout
                final authService = Provider.of<AuthService>(context, listen: false);
                await authService.logout();
                
                // Navigate to login screen
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppConstants.loginRoute,
                    (route) => false,
                  );
                }
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Perform account deletion
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account deleted successfully')),
                );
                // Navigate to login screen
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppConstants.loginRoute,
                  (route) => false,
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}