import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mashwar_core/mashwar_core.dart';

class StarRatingRow extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const StarRatingRow({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final starIndex = i + 1;
        final filled = starIndex <= value;
        return _AnimatedStar(
          key: ValueKey('star-$starIndex'),
          filled: filled,
          color: colors.accent,
          outlineColor: colors.border,
          onTap: () => onChanged(starIndex),
        );
      }),
    );
  }
}

class _AnimatedStar extends StatefulWidget {
  final bool filled;
  final Color color;
  final Color outlineColor;
  final VoidCallback onTap;

  const _AnimatedStar({
    super.key,
    required this.filled,
    required this.color,
    required this.outlineColor,
    required this.onTap,
  });

  @override
  State<_AnimatedStar> createState() => _AnimatedStarState();
}

class _AnimatedStarState extends State<_AnimatedStar> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );
  late final _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: 1.3).chain(CurveTween(curve: Curves.easeOut)),
      weight: 45,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 1.3, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
      weight: 55,
    ),
  ]).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onTap();
        _controller.forward(from: 0);
      },
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: 44.w,
        height: 44.w,
        child: Center(
          child: AnimatedBuilder(
            animation: _scale,
            builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
            child: Icon(
              widget.filled ? Icons.star_rounded : Icons.star_border_rounded,
              size: 27.sp,
              color: widget.filled ? widget.color : widget.outlineColor,
            ),
          ),
        ),
      ),
    );
  }
}
