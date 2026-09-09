import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/responsive_utils.dart';

/// A responsive scaffold that automatically adapts to different screen sizes
class ResponsiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final List<Widget>? persistentFooterButtons;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final bool resizeToAvoidBottomInset;

  const ResponsiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.persistentFooterButtons,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: ResponsiveContainer(
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      persistentFooterButtons: persistentFooterButtons,
      drawer: drawer,
      endDrawer: endDrawer,
      bottomNavigationBar: bottomNavigationBar,
      backgroundColor: backgroundColor,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}

/// Responsive grid layout that adapts columns based on screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;
    
    if (screenWidth < 360) {
      crossAxisCount = 1; // Single column for very small screens
    } else if (screenWidth < 600) {
      crossAxisCount = 2; // Two columns for phones
    } else if (screenWidth < 1024) {
      crossAxisCount = 3; // Three columns for tablets
    } else {
      crossAxisCount = 4; // Four columns for large screens
    }

    if (crossAxisCount == 1) {
      // Use column layout for single column
      return Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisAlignment: mainAxisAlignment,
        children: List.generate(
          children.length,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: index < children.length - 1 ? spacing : 0),
            child: children[index],
          ),
        ),
      );
    } else {
      // Use GridView for multiple columns
      return GridView.count(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: children,
      );
    }
  }
}

/// Responsive button that adapts size and padding based on screen
class ResponsiveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool expanded;

  const ResponsiveButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = ResponsiveUtils.getResponsiveButtonHeight(context);
    
    Widget button = SizedBox(
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
    );

    if (expanded) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }
    
    return button;
  }
}

/// Responsive text field with adaptive sizing
class ResponsiveTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final VoidCallback? onFieldSubmitted;
  final bool isMandatory;

  const ResponsiveTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.readOnly = false,
    this.inputFormatters,
    this.focusNode,
    this.onFieldSubmitted,
    this.isMandatory = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      onFieldSubmitted: (value) {
        // Auto-fill mandatory empty fields with "0"
        if (isMandatory && value.isEmpty) {
          controller.text = '0';
        }
        
        // Call custom onFieldSubmitted if provided
        onFieldSubmitted?.call();
      },
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsiveSpacing(context) * 0.75,
          vertical: ResponsiveUtils.getResponsiveSpacing(context) * 0.8,
        ),
      ),
      validator: validator,
    );
  }
}