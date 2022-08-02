import 'package:flutter/material.dart';

class AnimatedHeartIconButton extends StatefulWidget {
  /// Создает анимированный виджет сердечка, при нажати на которое
  /// происходит смена начального цвета [notFavouriteColor] на конечный
  /// цвет [favouriteColor] и анимация увеличения на заданый процент
  /// [scalePercentage] и возвращение в исходное состояние
  ///
  /// Аргумент [isFavourite] не должен быть null
  const AnimatedHeartIconButton({
    Key? key,
    required this.isFavourite,
    this.onTap,
    this.size = 24.0,
    this.favouriteColor = Colors.red,
    this.notFavouriteColor = Colors.transparent,
    this.outlineColor = Colors.white,
    this.duration = const Duration(
      milliseconds: 250,
    ),
    this.scalePercentage = 1.2,
    this.outlineWidth = 2.0,
  }) : super(key: key);

  final bool isFavourite;
  final VoidCallback? onTap;
  final Color favouriteColor;
  final Color notFavouriteColor;
  final Color outlineColor;
  final Duration duration;
  final double scalePercentage;
  final double size;
  final double outlineWidth;

  @override
  State<AnimatedHeartIconButton> createState() =>
      _AnimatedHeartIconButtonState();
}

class _AnimatedHeartIconButtonState extends State<AnimatedHeartIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _sizeAnimation, _colorForwardAnimation, _colorReverseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _sizeAnimation = TweenSequence(
      [
        TweenSequenceItem(
            tween: Tween(begin: 1.0, end: widget.scalePercentage), weight: 1),
        TweenSequenceItem(
            tween: Tween(begin: widget.scalePercentage, end: 1.0), weight: 1),
      ],
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _colorForwardAnimation =
        ColorTween(begin: widget.notFavouriteColor, end: widget.favouriteColor)
            .animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.5,
        1.0,
        curve: Curves.easeIn,
      ),
    ));

    _colorReverseAnimation =
        ColorTween(begin: widget.notFavouriteColor, end: widget.favouriteColor)
            .animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.0,
        0.5,
        curve: Curves.easeIn,
      ),
    ));

    //set initial animation position
    if (widget.isFavourite) {
      _controller.value = 1;
    } else {
      _controller.value = 0;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedHeartIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavourite == widget.isFavourite) return;
    if (widget.isFavourite) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedHeart(
        controller: _controller,
        sizeAnimation: _sizeAnimation,
        colorForwardAnimation: _colorForwardAnimation,
        colorReverseAnimation: _colorReverseAnimation,
        outlineColor: widget.outlineColor,
        outlineWidth: widget.outlineWidth,
        size: Size.square(widget.size),
        isFavourite: widget.isFavourite,
      ),
    );
  }
}

class AnimatedHeart extends StatelessWidget {
  const AnimatedHeart({
    Key? key,
    required this.controller,
    required this.sizeAnimation,
    required this.colorForwardAnimation,
    required this.colorReverseAnimation,
    required this.size,
    required this.isFavourite,
    required this.outlineColor,
    required this.outlineWidth,
  }) : super(key: key);

  final AnimationController controller;
  final Animation sizeAnimation;
  final Animation colorForwardAnimation;
  final Animation colorReverseAnimation;
  final Size size;
  final bool isFavourite;
  final Color outlineColor;
  final double outlineWidth;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          return Transform.scale(
            scale: sizeAnimation.value,
            child: CustomPaint(
              size: size,
              painter: HeartPainter(
                fillColor: isFavourite
                    ? colorForwardAnimation.value
                    : colorReverseAnimation.value,
                outlineColor: outlineColor,
                outlineWidth: outlineWidth,
              ),
            ),
          );
        });
  }
}

class HeartPainter extends CustomPainter {
  HeartPainter(
      {required this.fillColor,
      required this.outlineColor,
      required this.outlineWidth});

  Color fillColor;
  Color outlineColor;
  double outlineWidth;

  @override
  void paint(Canvas canvas, Size size) {
    Paint border = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = outlineWidth;

    Paint body = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    double width = size.width;
    double height = size.height;

    //рисуем сердечко из линий и дуг
    final Path heartLineArc = Path()
      ..moveTo(0.5 * width, height)
      ..lineTo(width * 0.06, height * 0.45)
      ..arcToPoint(Offset(0.5 * width, height * 0.12),
          radius: const Radius.circular(1))
      ..moveTo(0.5 * width, height)
      ..lineTo(width * 0.94, height * 0.45)
      ..arcToPoint(Offset(0.5 * width, height * 0.12),
          radius: const Radius.circular(1), clockwise: false);

    //вариант более гладкого сердечка
    final Path heartCubic = Path()
      ..moveTo(0.5 * width, height)
      ..cubicTo(-0.45 * width, height * 0.5, 0.2 * width, height * -0.4,
          0.5 * width, height * 0.3)
      ..moveTo(0.5 * width, height)
      ..cubicTo(1.45 * width, height * 0.5, 0.8 * width, height * -0.4,
          0.5 * width, height * 0.3);

    canvas
      ..drawPath(heartLineArc, body)
      ..drawPath(heartLineArc, border);
  }

  @override
  bool shouldRepaint(HeartPainter oldDelegate) =>
      oldDelegate.fillColor != fillColor;
}
