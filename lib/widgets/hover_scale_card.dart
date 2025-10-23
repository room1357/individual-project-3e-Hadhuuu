// lib/widgets/hover_scale_card.dart

import 'package:flutter/material.dart';

class HoverScaleCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color? color;
  final BorderRadius? borderRadius;
  final ShapeBorder? shape;

  const HoverScaleCard({
    Key? key,
    required this.child,
    required this.onTap,
    this.color,
    this.borderRadius,
    this.shape,
  }) : super(key: key);

  @override
  _HoverScaleCardState createState() => _HoverScaleCardState();
}

class _HoverScaleCardState extends State<HoverScaleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 100),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse().then((_) {
      widget.onTap();
    });
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  void _onHover(bool isHovering) {
    setState(() {
      _isHovering = isHovering;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan skala berdasarkan hover (web) atau tap (mobile)
    final double scale = _isHovering ? 1.03 : _scaleAnimation.value;
    final double elevation = _isHovering ? 10 : 4; // Shadow lebih besar saat hover

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: AnimatedPhysicalModel(
            // Gunakan AnimatedPhysicalModel untuk shadow yang lebih halus
            duration: const Duration(milliseconds: 150),
            shape: BoxShape.rectangle,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            color: widget.color ?? Theme.of(context).cardColor,
            elevation: elevation,
            shadowColor: Theme.of(context).cardTheme.shadowColor ?? Colors.black.withOpacity(0.1),
            child: ClipRRect(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}