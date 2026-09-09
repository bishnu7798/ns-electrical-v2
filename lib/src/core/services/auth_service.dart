import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userEmail = '';
  String _userPassword = '';
  User? _firebaseUser;
  bool _firebaseInitialized = false;
  StreamSubscription<User?>? _authStateSubscription;
  
  bool get isLoggedIn => _isLoggedIn;
  String get userEmail => _userEmail;
  User? get firebaseUser => _firebaseUser;
  
  // Get user's initials from email
  String get userInitials {
    if (_userEmail.isEmpty) return 'U';
    final parts = _userEmail.split('@')[0].split('.');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].length >= 2) {
      return '${parts[0][0]}${parts[0][1]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0].toUpperCase();
    }
    return 'U';
  }
  
  // Initialize the auth service and check for saved login state
  Future<void> init() async {
    // Initialize Firebase
    try {
      // Check if Firebase is properly configured by trying to access the instance
      final firebaseInstance = FirebaseAuth.instance;
      
      // If we reach this point without exception, Firebase is initialized
      _firebaseInitialized = true;
      _firebaseUser = firebaseInstance.currentUser;
      
      if (_firebaseUser != null) {
        _isLoggedIn = true;
        _userEmail = _firebaseUser!.email ?? '';
      } else {
        final prefs = await SharedPreferences.getInstance();
        _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
        _userEmail = prefs.getString('userEmail') ?? '';
        _userPassword = prefs.getString('userPassword') ?? '';
      }
      
      // Listen for auth state changes to detect user deletion
      // This needs to be after we've checked the initial user state
      _authStateSubscription = firebaseInstance.authStateChanges().listen((User? user) {
        if (_firebaseInitialized && _isLoggedIn) {
          // If we were logged in but user is now null, the user was deleted
          if (user == null && _firebaseUser != null) {
            // User was deleted from Firebase, force logout
            _forceLogout();
          } else {
            // Update current user
            _firebaseUser = user;
            if (user != null) {
              _userEmail = user.email ?? '';
            }
          }
        }
      });
    } catch (e) {
      print('Firebase not properly configured: $e');
      print('Running in offline mode with local authentication');
      _firebaseInitialized = false;
      // Fallback to local storage
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _userEmail = prefs.getString('userEmail') ?? '';
      _userPassword = prefs.getString('userPassword') ?? '';
    }
    notifyListeners();
  }
  
  // Method to check if user is authenticated with Firebase
  bool isUserAuthenticatedWithFirebase() {
    return _firebaseInitialized && _firebaseUser != null;
  }
  
  // Method to check if Firebase is properly configured
  bool isFirebaseConfigured() {
    return _firebaseInitialized;
  }
  
  // Method to test Firebase connectivity
  Future<bool> testFirebaseConnection() async {
    if (!_firebaseInitialized) {
      return false;
    }
    
    try {
      // Try to access current user to test connection
      final currentUser = FirebaseAuth.instance.currentUser;
      // Connection is working if we can access the instance without error
      // Using currentUser to verify we can access the Firebase instance
      if (currentUser != null) {} // Use the variable to avoid warning
      return true;
    } catch (e) {
      print('Firebase connection test failed: $e');
      return false;
    }
  }
  
  // Validate current password (for Firebase, this is handled by Firebase Auth)
  bool validateCurrentPassword(String password) {
    // For Firebase, we'll rely on re-authentication
    return true;
  }
  
  // Change password with Firebase integration
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      // If using Firebase Auth and properly configured
      if (_firebaseInitialized && _firebaseUser != null) {
        // Re-authenticate user before changing password
        final credential = EmailAuthProvider.credential(
          email: _firebaseUser!.email!,
          password: currentPassword,
        );
        
        await _firebaseUser!.reauthenticateWithCredential(credential);
        
        // Change password in Firebase
        await _firebaseUser!.updatePassword(newPassword);
        
        // Update password in Firestore if needed
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_firebaseUser!.uid)
            .update({
          'password': newPassword,
          'lastPasswordChange': FieldValue.serverTimestamp(),
        });
        
        // Update local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userPassword', newPassword);
        
        _userPassword = newPassword;
        notifyListeners();
        return true;
      } else {
        // Fallback to local implementation
        if (currentPassword == _userPassword) {
          _userPassword = newPassword;
          
          // Save updated password
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userPassword', _userPassword);
          
          // Update in Firestore if Firebase is initialized
          if (_firebaseInitialized && _userEmail.isNotEmpty) {
            try {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(_userEmail)
                  .update({
                'password': newPassword,
                'lastPasswordChange': FieldValue.serverTimestamp(),
              });
            } catch (e) {
              print('Error updating Firestore: $e');
            }
          }
          
          notifyListeners();
          return true;
        }
        return false;
      }
    } catch (e) {
      print('Error changing password: $e');
      // Fallback to local implementation if Firebase fails
      if (currentPassword == _userPassword) {
        _userPassword = newPassword;
        
        // Save updated password
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userPassword', _userPassword);
        
        notifyListeners();
        return true;
      }
      return false;
    }
  }
  
  // Login function with Firebase integration
  Future<bool> login(String email, String password) async {
    try {
      // Check if Firebase is properly initialized
      if (_firebaseInitialized) {
        try {
          final userCredential = await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: password);
          
          _isLoggedIn = true;
          _userEmail = email;
          _userPassword = password;
          _firebaseUser = userCredential.user;
          notifyListeners();
          
          // Save login state
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userEmail', email);
          await prefs.setString('userPassword', password);
          
          // Save user data to Firestore
          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user!.uid)
                .set({
              'email': email,
              'uid': userCredential.user!.uid,
              'lastLogin': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          } catch (e) {
            print('Error saving to Firestore: $e');
          }
          
          return true;
        } catch (firebaseError) {
          // Handle specific Firebase Auth errors
          if (firebaseError is FirebaseAuthException) {
            print('Firebase Auth error: ${firebaseError.code} - ${firebaseError.message}');
            
            // Provide user-friendly error messages
            switch (firebaseError.code) {
              case 'user-not-found':
                print('No user found with this email.');
                break;
              case 'wrong-password':
                print('Wrong password provided.');
                break;
              case 'invalid-email':
                print('Invalid email format.');
                break;
              case 'user-disabled':
                print('This account has been disabled.');
                break;
              case 'too-many-requests':
                print('Too many attempts. Please try again later.');
                break;
              case 'network-request-failed':
                print('Network error. Please check your connection.');
                break;
              default:
                print('Login failed: ${firebaseError.message}');
            }
            return false;
          } else {
            print('Unexpected error during Firebase login: $firebaseError');
            return false;
          }
        }
      } else {
        // Fallback to local implementation when Firebase is not configured
        if (email.isNotEmpty && password.isNotEmpty) {
          _isLoggedIn = true;
          _userEmail = email;
          _userPassword = password;
          notifyListeners();
          
          // Save login state and user email
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userEmail', email);
          await prefs.setString('userPassword', password);
          
          return true;
        }
        return false;
      }
    } catch (generalError) {
      print('General error during login: $generalError');
      return false;
    }
  }
  
  // Signup function with Firebase integration
  Future<bool> signup(String email, String password) async {
    try {
      // Check if Firebase is properly initialized
      if (_firebaseInitialized) {
        try {
          final userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: password);
          
          _isLoggedIn = true;
          _userEmail = email;
          _userPassword = password;
          _firebaseUser = userCredential.user;
          notifyListeners();
          
          // Save login state
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userEmail', email);
          await prefs.setString('userPassword', password);
          
          // Save user data to Firestore
          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user!.uid)
                .set({
              'email': email,
              'uid': userCredential.user!.uid,
              'createdAt': FieldValue.serverTimestamp(),
            });
          } catch (e) {
            print('Error saving to Firestore: $e');
          }
          
          return true;
        } catch (firebaseError) {
          // Handle specific Firebase Auth errors
          if (firebaseError is FirebaseAuthException) {
            print('Firebase Signup error: ${firebaseError.code} - ${firebaseError.message}');
            
            // Provide user-friendly error messages
            switch (firebaseError.code) {
              case 'email-already-in-use':
                print('Email is already registered.');
                break;
              case 'invalid-email':
                print('Invalid email format.');
                break;
              case 'weak-password':
                print('Password is too weak. Use at least 6 characters.');
                break;
              case 'too-many-requests':
                print('Too many attempts. Please try again later.');
                break;
              case 'network-request-failed':
                print('Network error. Please check your connection.');
                break;
              default:
                print('Signup failed: ${firebaseError.message}');
            }
            return false;
          } else {
            print('Unexpected error during Firebase signup: $firebaseError');
            return false;
          }
        }
      } else {
        // Fallback to local implementation when Firebase is not configured
        if (email.isNotEmpty && password.isNotEmpty) {
          _isLoggedIn = true;
          _userEmail = email;
          notifyListeners();
          
          // Save login state and user email
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userEmail', email);
          
          return true;
        }
        return false;
      }
    } catch (generalError) {
      print('General error during signup: $generalError');
      return false;
    }
  }
  
  // Logout function with Firebase integration
  Future<void> logout() async {
    try {
      // Sign out from Firebase if user is signed in and Firebase is initialized
      if (_firebaseInitialized && _firebaseUser != null) {
        await FirebaseAuth.instance.signOut();
      }
    } catch (e) {
      print('Error signing out from Firebase: $e');
      // Continue with local logout even if Firebase sign out fails
    }
    
    _isLoggedIn = false;
    _userEmail = '';
    _userPassword = '';
    _firebaseUser = null;
    notifyListeners();
    
    // Clear local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.setString('userEmail', '');
    await prefs.setString('userPassword', '');
  }
  
  // Force logout when user is deleted from Firebase
  void _forceLogout() {
    _isLoggedIn = false;
    _userEmail = '';
    _userPassword = '';
    _firebaseUser = null;
    notifyListeners();
    
    // Clear local storage
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isLoggedIn', false);
      prefs.setString('userEmail', '');
      prefs.setString('userPassword', '');
    });
    
    // Navigate to login screen if we have access to navigator
    // This will be handled by the app's main widget listening to auth state
  }
  
  // Dispose of the auth state subscription
  @override
  void dispose() {
    // Cancel the auth state subscription if it was initialized
    _authStateSubscription?.cancel();
    super.dispose();
  }
  
  // Platform-specific considerations
  bool get isWeb => kIsWeb;
  
  // Get platform-specific greeting
  String get platformGreeting => kIsWeb ? 'Welcome to NS Electrical Web' : 'Welcome to NS Electrical';
}