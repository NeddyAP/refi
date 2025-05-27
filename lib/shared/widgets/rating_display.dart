import 'package:flutter/material.dart';

class RatingDisplay extends StatelessWidget {
  final double rating;
  final double size;
  final bool showText;
  final Color? color;
  final int maxRating;

  const RatingDisplay({
    super.key,
    required this.rating,
    this.size = 16,
    this.showText = true,
    this.color,
    this.maxRating = 10,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalizedRating = (rating / maxRating) * 5; // Convert to 5-star scale
    final starColor = color ?? _getRatingColor(rating);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          size: size,
          color: starColor,
        ),
        if (showText) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: size * 0.75,
              color: starColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 8.0) {
      return Colors.green;
    } else if (rating >= 6.0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

class StarRating extends StatelessWidget {
  final double rating;
  final int starCount;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final Function(double)? onRatingChanged;

  const StarRating({
    super.key,
    required this.rating,
    this.starCount = 5,
    this.size = 24,
    this.activeColor,
    this.inactiveColor,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeStarColor = activeColor ?? theme.colorScheme.primary;
    final inactiveStarColor = inactiveColor ?? theme.colorScheme.outline;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        final starValue = index + 1;
        final isFilled = rating >= starValue;
        final isHalfFilled = rating >= starValue - 0.5 && rating < starValue;

        return GestureDetector(
          onTap: onRatingChanged != null
              ? () => onRatingChanged!(starValue.toDouble())
              : null,
          child: Icon(
            isFilled
                ? Icons.star
                : isHalfFilled
                    ? Icons.star_half
                    : Icons.star_border,
            size: size,
            color: isFilled || isHalfFilled ? activeStarColor : inactiveStarColor,
          ),
        );
      }),
    );
  }
}

class InteractiveStarRating extends StatefulWidget {
  final double initialRating;
  final int starCount;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final Function(double) onRatingChanged;

  const InteractiveStarRating({
    super.key,
    required this.initialRating,
    required this.onRatingChanged,
    this.starCount = 5,
    this.size = 32,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<InteractiveStarRating> createState() => _InteractiveStarRatingState();
}

class _InteractiveStarRatingState extends State<InteractiveStarRating> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeStarColor = widget.activeColor ?? theme.colorScheme.primary;
    final inactiveStarColor = widget.inactiveColor ?? theme.colorScheme.outline;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.starCount, (index) {
        final starValue = index + 1;
        final isFilled = _currentRating >= starValue;

        return GestureDetector(
          onTap: () {
            setState(() {
              _currentRating = starValue.toDouble();
            });
            widget.onRatingChanged(_currentRating);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              isFilled ? Icons.star : Icons.star_border,
              size: widget.size,
              color: isFilled ? activeStarColor : inactiveStarColor,
            ),
          ),
        );
      }),
    );
  }
}
