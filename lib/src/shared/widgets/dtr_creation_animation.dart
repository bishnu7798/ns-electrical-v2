import 'package:flutter/material.dart';

class DTRCreationAnimation extends StatefulWidget {
  final Widget child;
  final Function onAnimationComplete;

  const DTRCreationAnimation({
    super.key,
    required this.child,
    required this.onAnimationComplete,
  });

  @override
  State<DTRCreationAnimation> createState() => _DTRCreationAnimationState();
}

class _DTRCreationAnimationState extends State<DTRCreationAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Opacity animation
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Vertical slide animation from bottom
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward().then((_) {
      // Delay slightly before calling completion callback
      Future.delayed(const Duration(milliseconds: 100), () {
        widget.onAnimationComplete();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _opacityAnimation,
          child: SlideTransition(
            position: _offsetAnimation,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}