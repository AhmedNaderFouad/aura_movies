import 'package:flutter/material.dart';
import 'package:aura_movies/core/theme/app_colors.dart';

class ShimmerLoadingWidget extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoadingWidget({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  State<ShimmerLoadingWidget> createState() => _ShimmerLoadingWidgetState();
}

class _ShimmerLoadingWidgetState extends State<ShimmerLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                _animationController.value - 0.3,
                _animationController.value,
                _animationController.value + 0.3,
              ],
              colors: [
                AppColors.surface,
                AppColors.surface.withValues(alpha: 0.7),
                AppColors.surface,
              ],
            ),
          ),
        );
      },
    );
  }
}
