import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../core/services/auth_service.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/utils/responsive_utils.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start animations after a small delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authService = Provider.of<AuthService>(context, listen: false);
      
      try {
        final success = await authService.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
        
        if (success) {
          // Navigate to home screen
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        } else {
          if (mounted) {
            setState(() {
              if (!authService.isFirebaseConfigured()) {
                _errorMessage = 'Firebase not configured. Please check your google-services.json file.';
              } else {
                _errorMessage = 'Invalid email or password. Please check your credentials.';
              }
              _isLoading = false;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Authentication error: ${e.toString()}';
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 0.9),
              Theme.of(context).primaryColor.withValues(alpha: 0.7),
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center( // Changed from SingleChildScrollView to Center for better control
            child: SingleChildScrollView( // Added SingleChildScrollView as a child for small screens
              padding: ResponsiveUtils.getResponsivePadding(context),
              child: ConstrainedBox( // Added ConstrainedBox to limit width
                constraints: BoxConstraints(maxWidth: ResponsiveUtils.getMaxContentWidth(context)), // Set max width for larger screens
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo and App Name with enhanced design
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  // Made the background transparent
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 3,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/NSLOGO1.png',
                                    width: ResponsiveUtils.scaleToDevice(context, 120),
                                    height: ResponsiveUtils.scaleToDevice(context, 120),
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Fallback widget if image fails to load
                                      return Container(
                                        width: ResponsiveUtils.scaleToDevice(context, 120),
                                        height: ResponsiveUtils.scaleToDevice(context, 120),
                                        decoration: const BoxDecoration(
                                          color: Colors.blue,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.electrical_services,
                                          color: Colors.white,
                                          size: ResponsiveUtils.scaleToDevice(context, 60),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
                              Text(
                                AppConstants.appName,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 32,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withValues(alpha: 0.3),
                                          offset: const Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppConstants.appTitle,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Distribution Project Management System',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 48),
                        
                        // Enhanced Login Card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Header
                                  const Center(
                                    child: Text(
                                      'Sign In to Your Account',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Center(
                                    child: Text(
                                      'Enter your credentials to continue',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  
                                  // Error Message
                                  if (_errorMessage != null)
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50.withValues(alpha: 0.8),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.red.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.error_outline,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              _errorMessage!,
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (_errorMessage != null) const SizedBox(height: 24),
                                  
                                  // Email Field
                                  _buildEnhancedTextField(
                                    controller: _emailController,
                                    labelText: 'Email Address',
                                    hintText: 'Enter your email',
                                    prefixIcon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      // More permissive email validation
                                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // Password Field
                                  _buildEnhancedPasswordField(),
                                  const SizedBox(height: 24),
                                  
                                  // Forgot Password
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        // TODO: Implement forgot password functionality
                                      },
                                      child: const Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // Login Button
                                  SizedBox(
                                    height: 55,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).primaryColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        elevation: 5,
                                      ),
                                      child: _isLoading
                                          ? const CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            )
                                          : const Text(
                                              'Login',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Sign Up Option
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Don\'t have an account?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // TODO: Navigate to signup screen
                                },
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(
          prefixIcon,
          color: Theme.of(context).primaryColor,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      style: const TextStyle(
        fontSize: 16,
      ),
      validator: validator,
    );
  }

  Widget _buildEnhancedPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        prefixIcon: Icon(
          Icons.lock_outline,
          color: Theme.of(context).primaryColor,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      style: const TextStyle(
        fontSize: 16,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        // For demo purposes, accept any password with at least 1 character
        if (value.isEmpty) {
          return 'Password must be at least 1 character';
        }
        return null;
      },
    );
  }
}