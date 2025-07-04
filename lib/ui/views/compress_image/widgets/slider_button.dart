import 'package:flutter/material.dart';

class SwipeToCompressWidget extends StatefulWidget {
  final VoidCallback onCompress;
  final double height;
  final Color backgroundColor;
  final Color sliderColor;
  final Color textColor;
  final String text;
  final IconData icon;

  const SwipeToCompressWidget({
    Key? key,
    required this.onCompress,
    this.height = 70,
    this.backgroundColor = const Color(0xFF2196F3),
    this.sliderColor = Colors.white,
    this.textColor = Colors.white,
    this.text = "Swipe to Compress",
    this.icon = Icons.compress_rounded,
  }) : super(key: key);

  @override
  State<SwipeToCompressWidget> createState() => _SwipeToCompressWidgetState();
}

class _SwipeToCompressWidgetState extends State<SwipeToCompressWidget>
    with TickerProviderStateMixin {
  double _dragPosition = 0;
  bool _isCompleted = false;
  bool _isDragging = false;

  late AnimationController _pulseController;
  late AnimationController _resetController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _resetAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _resetController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _resetAnimation = Tween<double>(
      begin: _dragPosition,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _resetController,
      curve: Curves.elasticOut,
    ));

    // Start pulse animation
    _pulseController.repeat(reverse: true);

    _resetController.addListener(() {
      setState(() {
        _dragPosition = _resetAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _resetController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
    _pulseController.stop();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final containerWidth = context.size?.width ?? 0;
    final maxDrag = containerWidth - widget.height;

    setState(() {
      _dragPosition = (_dragPosition + details.delta.dx).clamp(0.0, maxDrag);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final containerWidth = context.size?.width ?? 0;
    final threshold = containerWidth * 0.8;

    setState(() {
      _isDragging = false;
    });

    if (_dragPosition >= threshold) {
      _completeAction();
    } else {
      _resetPosition();
    }
  }

  void _completeAction() {
    setState(() {
      _isCompleted = true;
    });

    // Trigger haptic feedback
    // HapticFeedback.heavyImpact();

    // Call the compress function
    widget.onCompress();

    // Reset after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isCompleted = false;
        });
        _resetPosition();
      }
    });
  }

  void _resetPosition() {
    _resetAnimation = Tween<double>(
      begin: _dragPosition,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _resetController,
      curve: Curves.elasticOut,
    ));

    _resetController.forward(from: 0).then((_) {
      if (mounted && !_isDragging) {
        _pulseController.repeat(reverse: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.height / 2),
        boxShadow: [
          BoxShadow(
            color: widget.backgroundColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Stack(
          children: [
            // Background text
            Center(
              child: AnimatedOpacity(
                opacity: _isCompleted ? 0.0 : (_isDragging ? 0.7 : 1.0),
                duration: const Duration(milliseconds: 200),
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isDragging ? 1.0 : _pulseAnimation.value,
                      child: Text(
                        _isCompleted ? "Compressing..." : widget.text,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: widget.textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Draggable slider
            Positioned(
              left: _dragPosition,
              top: 4,
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: AnimatedContainer(
                  duration: _isDragging
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
                  width: widget.height - 8,
                  height: widget.height - 8,
                  decoration: BoxDecoration(
                    color: widget.sliderColor,
                    borderRadius:
                        BorderRadius.circular((widget.height - 8) / 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: AnimatedRotation(
                    turns: _isDragging ? _dragPosition / 150 : 0,
                    duration: Duration.zero,
                    child: Icon(
                      _isCompleted ? Icons.check_rounded : widget.icon,
                      color: widget.backgroundColor,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),

            // Progress indicator
            if (_isDragging)
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: _dragPosition + widget.height,
                  height: widget.height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.backgroundColor.withOpacity(0.8),
                        widget.backgroundColor.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(widget.height / 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
