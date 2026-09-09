import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/services/sound_service.dart';

// Particle class to represent each ash particle
class AshParticle {
  Offset position;
  Offset velocity;
  double size;
  double opacity;
  Color color;

  AshParticle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.opacity,
    required this.color,
  });

  // Update particle position and properties
  void update() {
    position = Offset(position.dx + velocity.dx, position.dy + velocity.dy);
    opacity -= 0.008; // Gradually fade out faster
    // Add some horizontal drift
    velocity = Offset(velocity.dx * 0.98 + (Random().nextDouble() - 0.5) * 0.2, 
                     velocity.dy * 0.98 - 0.05); // Slow down and add slight upward force
  }

  // Check if particle is still visible
  bool get isVisible => opacity > 0 && position.dy > -50 && position.dy < 300;
}

// Custom painter for ash particles
class AshParticlePainter extends CustomPainter {
  final List<AshParticle> particles;

  AshParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final particle in particles) {
      if (particle.isVisible) {
        paint.color = particle.color.withOpacity(particle.opacity);
        canvas.drawCircle(particle.position, particle.size, paint);
        
        // Draw a subtle glow for ember particles
        if (particle.color == Colors.orangeAccent) {
          final glowPaint = Paint()
            ..color = Colors.orangeAccent.withOpacity(particle.opacity * 0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
          canvas.drawCircle(particle.position, particle.size * 2, glowPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Main ash particle animation widget
class AshParticleAnimation extends StatefulWidget {
  final VoidCallback onCompleted;
  final String message;
  final Widget cardWidget;
  final Size cardSize;

  const AshParticleAnimation({
    super.key,
    required this.onCompleted,
    this.message = 'Deleting...',
    required this.cardWidget,
    required this.cardSize,
  });

  @override
  State<AshParticleAnimation> createState() => _AshParticleAnimationState();
}

class _AshParticleAnimationState extends State<AshParticleAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _cardOpacityAnimation;
  late Animation<Offset> _cardOffsetAnimation;
  
  List<AshParticle> _particles = [];
  final Random _random = Random();
  bool _isDisintegrating = false;
  final SoundService _soundService = SoundService();

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Card fade out and move up animation
    _cardOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _cardOffsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.2),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Start the animation sequence
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Play delete sound effect
    _soundService.playDeleteSound();
    
    // First, fade out the card
    _controller.forward();
    
    // Wait for card to fade out, then start particle effect
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (mounted) {
      setState(() {
        _isDisintegrating = true;
        _generateParticles();
      });
      
      // Run particle animation
      _runParticleAnimation();
    }
  }

  void _generateParticles() {
    _particles = [];
    
    // Generate ash particles
    for (int i = 0; i < 120; i++) {
      final position = Offset(
        widget.cardSize.width / 2 + (_random.nextDouble() - 0.5) * widget.cardSize.width * 0.8,
        widget.cardSize.height / 2 + (_random.nextDouble() - 0.5) * widget.cardSize.height * 0.8,
      );
      
      // Random velocity with upward bias and some horizontal drift
      final velocity = Offset(
        (_random.nextDouble() - 0.5) * 3,
        -_random.nextDouble() * 4 - 1, // Mostly upward
      );
      
      // Random size
      final size = _random.nextDouble() * 2.5 + 0.5;
      
      // Most particles are gray, some are ember-colored
      final isEmber = _random.nextDouble() < 0.08; // 8% chance of being an ember
      final color = isEmber ? Colors.orangeAccent : Colors.grey.shade700;
      
      _particles.add(
        AshParticle(
          position: position,
          velocity: velocity,
          size: size,
          opacity: 1.0,
          color: color,
        ),
      );
    }
  }

  void _runParticleAnimation() async {
    // Animate particles for the remaining duration
    const particleAnimationDuration = Duration(milliseconds: 2200);
    final startTime = DateTime.now();
    
    while (DateTime.now().difference(startTime) < particleAnimationDuration && mounted) {
      await Future.delayed(const Duration(milliseconds: 16)); // ~60 FPS
      
      if (mounted) {
        setState(() {
          // Update all particles
          for (int i = _particles.length - 1; i >= 0; i--) {
            _particles[i].update();
            
            // Remove invisible particles
            if (!_particles[i].isVisible) {
              _particles.removeAt(i);
            }
          }
          
          // If all particles are gone, complete the animation
          if (_particles.isEmpty && _isDisintegrating) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.onCompleted();
            });
          }
        });
      }
    }
    
    // Animation complete
    if (mounted && _particles.isEmpty) {
      widget.onCompleted();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use the constrained dimensions if width is not infinity
        final width = widget.cardSize.width.isFinite 
            ? widget.cardSize.width 
            : constraints.maxWidth;
        
        return SizedBox(
          width: width,
          height: widget.cardSize.height + 1.0, // Add 1 pixel to prevent overflow
          child: Stack(
            children: [
              // Original card with fade out animation
              if (!_isDisintegrating)
                SlideTransition(
                  position: _cardOffsetAnimation,
                  child: FadeTransition(
                    opacity: _cardOpacityAnimation,
                    child: widget.cardWidget,
                  ),
                ),
              
              // Particle system
              if (_isDisintegrating)
                RepaintBoundary(
                  child: CustomPaint(
                    size: Size(width, widget.cardSize.height),
                    painter: AshParticlePainter(_particles),
                  ),
                ),
              
              // Message overlay
              if (_isDisintegrating)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 40,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.message,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }
    );
  }
}