import 'package:flutter/material.dart';
import 'dart:ui';

class GlassWidget extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isDark;

  const GlassWidget({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.blur = 10,
    this.opacity = 0.2,
    this.borderColor,
    this.padding,
    this.margin,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur * 0.5, sigmaY: blur * 0.5),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDark
                      ? Colors.white.withOpacity(opacity * 0.08)
                      : Colors.white.withOpacity(opacity * 0.6),
                  isDark
                      ? Colors.white.withOpacity(opacity * 0.04)
                      : Colors.white.withOpacity(opacity * 0.3),
                ],
              ),
              border: Border.all(
                color:
                    borderColor ??
                    (isDark
                        ? Colors.white.withOpacity(0.15)
                        : Colors.white.withOpacity(0.25)),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class AnimatedGlassWidget extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isDark;
  final Duration duration;

  const AnimatedGlassWidget({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.blur = 10,
    this.opacity = 0.2,
    this.borderColor,
    this.padding,
    this.margin,
    required this.isDark,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedGlassWidget> createState() => _AnimatedGlassWidgetState();
}

class _AnimatedGlassWidgetState extends State<AnimatedGlassWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GlassWidget(
            borderRadius: widget.borderRadius,
            blur: widget.blur,
            opacity: widget.opacity,
            borderColor: widget.borderColor,
            padding: widget.padding,
            margin: widget.margin,
            isDark: widget.isDark,
            child: widget.child,
          ),
        );
      },
    );
  }
}

class GlassButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool isDark;
  final Color? color;

  const GlassButton({
    super.key,
    required this.child,
    this.onPressed,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    required this.isDark,
    this.color,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (widget.color ?? const Color(0xFF007AFF)).withOpacity(
                _isPressed ? 0.8 : 1.0,
              ),
              (widget.color ?? const Color(0xFF5AC8FA)).withOpacity(
                _isPressed ? 0.6 : 0.8,
              ),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: (widget.color ?? const Color(0xFF007AFF)).withOpacity(0.3),
              blurRadius: _isPressed ? 5 : 15,
              offset: Offset(0, _isPressed ? 2 : 8),
            ),
          ],
        ),
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: Colors.white.withOpacity(widget.isDark ? 0.05 : 0.15),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
