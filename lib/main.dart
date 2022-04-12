import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isFavourite = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: GestureDetector(
          onTap: () {
            print('onTap');
            print('new value = ${!isFavourite}');
            setState(() {
              isFavourite = !isFavourite;
            });
          },
          child: HeartAnimationCustom(isFavourite: isFavourite),
        ),
      ),
    );
  }
}

class HeartAnimationCustom extends StatefulWidget {
  const HeartAnimationCustom({Key? key, required this.isFavourite})
      : super(key: key);

  final bool isFavourite;

  @override
  State<HeartAnimationCustom> createState() => _HeartAnimationCustomState();
}

class _HeartAnimationCustomState extends State<HeartAnimationCustom>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _sizeAnimation, _colorForwardAnimation, _colorReverseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _sizeAnimation = TweenSequence(
      [
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 1),
      ],
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _colorForwardAnimation = TweenSequence(
      [
        TweenSequenceItem(
            tween:
                ColorTween(begin: Colors.transparent, end: Colors.transparent),
            weight: 1),
        TweenSequenceItem(
            tween: ColorTween(begin: Colors.transparent, end: Colors.red),
            weight: 1),
      ],
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _colorReverseAnimation = TweenSequence(
      [
        TweenSequenceItem(
            tween: ColorTween(begin: Colors.transparent, end: Colors.red),
            weight: 1),
        TweenSequenceItem(
            tween: ColorTween(begin: Colors.red, end: Colors.red), weight: 1),
      ],
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFavourite) {
      _controller.forward();
      print('forward');
    } else {
      _controller.reverse();
      print('reverse');
    }
    return AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, _) {
          return Center(
            child: SizedBox(
              width: 50.0,
              height: 50.0,
              child: Transform.scale(
                scale: _sizeAnimation.value,
                child: CustomPaint(
                  painter: HeartPainter(
                    color: widget.isFavourite
                        ? _colorForwardAnimation.value
                        : _colorReverseAnimation.value,
                  ),
                ),
              ),
            ),
          );
        });
  }
}

class HeartPainter extends CustomPainter {
  HeartPainter({required this.color});

  Color color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint border = Paint();
    border
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;

    Paint body = Paint();
    body
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 0;

    double width = size.width;
    double height = size.height;

    final Path path = Path();

    path.moveTo(0.5 * width, height);
    path.cubicTo(-0.45 * width, height * 0.6, 0.2 * width, height * -0.4,
        0.5 * width, height * 0.3);
    path.moveTo(0.5 * width, height);
    path.cubicTo(1.45 * width, height * 0.6, 0.8 * width, height * -0.4,
        0.5 * width, height * 0.3);

    canvas.drawPath(path, body);
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
