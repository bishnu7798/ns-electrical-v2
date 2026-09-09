import 'package:flutter/material.dart';
import '../constants/responsive_constants.dart';

/// A widget that builds different layouts based on screen size
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, bool isMobile, bool isTablet, bool isDesktop) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = ResponsiveLayout.isMobile(width);
        final isTablet = ResponsiveLayout.isTablet(width);
        final isDesktop = ResponsiveLayout.isDesktop(width);
        
        return builder(context, isMobile, isTablet, isDesktop);
      },
    );
  }
}

/// A widget that shows different widgets based on screen size
class ScreenTypeLayout extends StatelessWidget {
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? watch;

  const ScreenTypeLayout({
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
    this.watch,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        
        if (width >= ResponsiveBreakpoints.large && desktop != null) {
          return desktop!;
        } else if (width >= ResponsiveBreakpoints.small && tablet != null) {
          return tablet!;
        } else if (mobile != null) {
          return mobile!;
        } else {
          // Default to mobile if no widget is provided
          return Container();
        }
      },
    );
  }
}