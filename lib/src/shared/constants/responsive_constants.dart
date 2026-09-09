/// Responsive breakpoints for different screen sizes
class ResponsiveBreakpoints {
  /// Small screen (phones)
  static const double small = 600;

  /// Medium screen (tablets)
  static const double medium = 1024;

  /// Large screen (desktops)
  static const double large = 1440;

  /// Extra large screen
  static const double extraLarge = 1920;
}

/// Responsive layout helper
class ResponsiveLayout {
  /// Check if screen is mobile size
  static bool isMobile(double width) => width < ResponsiveBreakpoints.small;

  /// Check if screen is tablet size
  static bool isTablet(double width) =>
      width >= ResponsiveBreakpoints.small &&
      width < ResponsiveBreakpoints.medium;

  /// Check if screen is desktop size
  static bool isDesktop(double width) =>
      width >= ResponsiveBreakpoints.medium;
}