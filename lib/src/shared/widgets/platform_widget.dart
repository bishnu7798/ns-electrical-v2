import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// A widget that shows different content based on the platform
class PlatformWidget extends StatelessWidget {
  final Widget mobile;
  final Widget web;
  final Widget? desktop;
  final Widget? tablet;

  const PlatformWidget({
    super.key,
    required this.mobile,
    required this.web,
    this.desktop,
    this.tablet,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return web;
    } else {
      // For mobile platforms, return mobile widget
      return mobile;
    }
  }
}

/// A widget that shows different content based on screen size
class AdaptiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const AdaptiveWidget({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return mobile;
        } else if (constraints.maxWidth < 1200) {
          return tablet;
        } else {
          return desktop;
        }
      },
    );
  }
}