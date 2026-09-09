import 'package:flutter/material.dart';

/// Comprehensive responsive utilities for adaptive UI design
class ResponsiveUtils {
  /// Get responsive padding based on screen width
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 360) {
      // Very small phones
      return const EdgeInsets.all(8.0);
    } else if (width < 414) {
      // Standard phones
      return const EdgeInsets.all(12.0);
    } else if (width < 768) {
      // Large phones/phablets
      return const EdgeInsets.all(16.0);
    } else {
      // Tablets and larger screens
      return const EdgeInsets.all(20.0);
    }
  }

  /// Get responsive font size multiplier
  static double getResponsiveFontSizeMultiplier(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 360) {
      return 0.85; // Smaller text for very small screens
    } else if (width < 414) {
      return 0.95; // Standard size for phones
    } else if (width < 768) {
      return 1.0;  // Normal size for large phones
    } else {
      return 1.1;  // Slightly larger for tablets
    }
  }

  /// Get responsive card padding
  static EdgeInsets getResponsiveCardPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 360) {
      return const EdgeInsets.all(12.0);
    } else if (width < 414) {
      return const EdgeInsets.all(16.0);
    } else if (width < 768) {
      return const EdgeInsets.all(20.0);
    } else {
      return const EdgeInsets.all(24.0);
    }
  }

  /// Get responsive spacing between elements
  static double getResponsiveSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 360) {
      return 8.0;
    } else if (width < 414) {
      return 12.0;
    } else if (width < 768) {
      return 16.0;
    } else {
      return 20.0;
    }
  }

  /// Get responsive button height
  static double getResponsiveButtonHeight(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    
    if (height < 600) {
      return 40.0; // Smaller buttons for short screens
    } else if (height < 700) {
      return 48.0; // Standard button height
    } else {
      return 56.0; // Larger buttons for tall screens
    }
  }

  /// Check if screen is in landscape orientation
  static bool isLandscape(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.landscape;
  }

  /// Get safe area padding for notches and system bars
  static EdgeInsets getSafeAreaInsets(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Calculate maximum width for content to prevent stretching on large screens
  static double getMaxContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width > 600) {
      return 600; // Cap width on tablets/desktop for better readability
    }
    return width;
  }

  /// Get responsive column spacing for form fields
  static double getFieldSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 360) {
      return 12.0; // Tighter spacing for small screens
    } else if (width < 414) {
      return 16.0; // Standard spacing
    } else {
      return 20.0; // More breathing room on larger screens
    }
  }

  /// Scale values based on screen density
  static double scaleToDevice(BuildContext context, double value) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return value * (devicePixelRatio / 3.0); // Normalize to typical pixel ratio
  }
}

/// Responsive text widget that automatically scales
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  const ResponsiveText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final multiplier = ResponsiveUtils.getResponsiveFontSizeMultiplier(context);
    
    return Text(
      text,
      style: style?.copyWith(
        fontSize: style?.fontSize != null 
            ? style!.fontSize! * multiplier 
            : null,
      ),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}

/// Responsive container that adapts to screen size
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final BorderRadius? borderRadius;
  final double? maxWidth;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final responsivePadding = padding ?? ResponsiveUtils.getResponsivePadding(context);
    final responsiveMargin = margin ?? EdgeInsets.zero;
    final maxWidthConstraint = maxWidth ?? ResponsiveUtils.getMaxContentWidth(context);

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidthConstraint),
        margin: responsiveMargin,
        padding: responsivePadding,
        color: color,
        child: child,
      ),
    );
  }
}