// widgets/settings_slider_tile.dart
import 'package:flutter/material.dart';

class SettingsSliderTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final int? divisions;

  const SettingsSliderTile({
    Key? key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
              ),
              if (subtitle != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          CustomSettingsSlider(
              theme: theme,
              value: value,
              onChanged: onChanged,
              min: min,
              max: max),
        ],
      ),
    );
  }
}

class CustomSettingsSlider extends StatelessWidget {
  const CustomSettingsSlider({
    super.key,
    required this.theme,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
  });

  final ThemeData theme;
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        // Modern thumb design
        thumbShape: const CustomSliderThumb(
          thumbRadius: 12,
          pressedThumbRadius: 14,
        ),

        // Track styling
        trackHeight: 6,
        activeTrackColor: theme.colorScheme.primary,
        // inactiveTrackColor: theme.colorScheme.primary.withOpacity(0.2),

        // Overlay (ripple effect)
        overlayColor: theme.colorScheme.primary.withOpacity(0.1),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),

        // Tick marks
        tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 2),
        activeTickMarkColor: theme.colorScheme.primary,
        inactiveTickMarkColor: theme.colorScheme.outline.withOpacity(0.3),

        // Value indicator
        valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
        valueIndicatorColor: theme.colorScheme.primary,
        valueIndicatorTextStyle: TextStyle(
          color: theme.colorScheme.onPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        showValueIndicator: ShowValueIndicator.onlyForDiscrete,
      ),
      child: Slider(
        value: value,
        onChanged: onChanged,
        min: min,
        max: max,
        label: value.round().toString(),
        // divisions: divisions,
      ),
    );
  }
}

// Custom slider thumb with modern design
class CustomSliderThumb extends SliderComponentShape {
  final double thumbRadius;
  final double pressedThumbRadius;

  const CustomSliderThumb({
    this.thumbRadius = 12,
    this.pressedThumbRadius = 14,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(pressedThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final ColorTween colorTween = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.thumbColor,
    );

    final Color color = colorTween.evaluate(enableAnimation)!;
    final double radius = Tween<double>(
      begin: thumbRadius,
      end: pressedThumbRadius,
    ).evaluate(activationAnimation);

    // Shadow
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawCircle(
      center + const Offset(0, 1),
      radius,
      shadowPaint,
    );

    // Main thumb
    final Paint thumbPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, thumbPaint);

    // Inner highlight
    final Paint highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.4, highlightPaint);

    // Border
    final Paint borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, borderPaint);
  }
}
