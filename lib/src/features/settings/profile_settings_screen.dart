import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../core/services/auth_service.dart';
import '../../shared/constants/app_constants.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  
  String _initialName = '';
  String _initialEmail = '';
  String _initialPhone = '';
  
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userEmail = authService.userEmail;
    final userName = userEmail.split('@')[0];
    
    _initialName = userName;
    _initialEmail = userEmail;
    _initialPhone = '';
    
    _nameController = TextEditingController(text: _initialName);
    _emailController = TextEditingController(text: _initialEmail);
    _phoneController = TextEditingController(text: _initialPhone);
    
    // Add listeners to detect changes
    _nameController.addListener(_checkForChanges);
    _emailController.addListener(_checkForChanges);
    _phoneController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final hasChanges = _nameController.text != _initialName ||
        _emailController.text != _initialEmail ||
        _phoneController.text != _initialPhone;
    
    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_checkForChanges);
    _emailController.removeListener(_checkForChanges);
    _phoneController.removeListener(_checkForChanges);
    
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                _buildProfileSection(isDarkMode),
                const SizedBox(height: 32),
                
                // Editable Fields
                _buildEditableFields(isDarkMode),
                const SizedBox(height: 32),
                
                // Action Buttons
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(bool isDarkMode) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode 
                        ? Colors.white.withValues(alpha: 0.1) 
                        : Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: isDarkMode ? Colors.white : Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor,
                    border: Border.all(color: isDarkMode ? Colors.black : Colors.white, width: 2),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // Handle image change
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Change photo functionality would be implemented here'),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Edit your profile information',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableFields(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDarkMode 
                  ? Colors.black.withValues(alpha: 0.3) 
                  : Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Full Name Field
                _buildTextField(
                  controller: _nameController,
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: Icons.person_outline,
                  isDarkMode: isDarkMode,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Email Field
                _buildTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                  isDarkMode: isDarkMode,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Phone Number Field
                _buildTextField(
                  controller: _phoneController,
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                  prefixIcon: Icons.phone_outlined,
                  isDarkMode: isDarkMode,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value)) {
                        return 'Please enter a valid phone number';
                      }
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    required bool isDarkMode,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
        ),
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.grey[500]! : Colors.grey[400]!,
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
            width: 2,
          ),
        ),
        filled: true,
        fillColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[50],
      ),
      validator: validator,
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Save Changes Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _hasChanges ? _saveChanges : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey,
              disabledForegroundColor: Colors.grey[400],
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Logout Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _logout,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Colors.red, width: 2),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // In a real app, you would update the user profile here
      // For now, we'll just show a success message
      
      // Update initial values to reflect current values
      _initialName = _nameController.text;
      _initialEmail = _emailController.text;
      _initialPhone = _phoneController.text;
      
      setState(() {
        _hasChanges = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _logout() {
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
}