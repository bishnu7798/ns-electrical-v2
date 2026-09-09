import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// A widget that shows a connectivity status indicator banner
class ConnectivityBanner extends StatefulWidget {
  final Widget child;
  
  const ConnectivityBanner({super.key, required this.child});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  bool _isConnected = true;
  bool _showBanner = false;

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _listenToConnectivityChanges();
  }

  Future<void> _checkInitialConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() {
        _isConnected = connectivityResult != ConnectivityResult.none;
        _showBanner = !_isConnected;
      });
    }
  }

  void _listenToConnectivityChanges() {
    // Updated for newer connectivity_plus API
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (mounted) {
        final isConnected = result != ConnectivityResult.none;
        setState(() {
          _isConnected = isConnected;
          _showBanner = !isConnected;
        });
        
        // Auto-hide banner after 3 seconds when connection is restored
        if (isConnected) {
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _showBanner = false;
              });
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showBanner)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isConnected ? Colors.green : Colors.red,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      _isConnected ? Icons.wifi : Icons.wifi_off,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isConnected 
                            ? 'Internet connection restored' 
                            : 'No internet connection',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (!_isConnected)
                      TextButton(
                        onPressed: () async {
                          final connectivityResult = await Connectivity().checkConnectivity();
                          if (mounted) {
                            setState(() {
                              _isConnected = connectivityResult != ConnectivityResult.none;
                              _showBanner = !_isConnected;
                            });
                          }
                        },
                        child: const Text(
                          'Retry',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}