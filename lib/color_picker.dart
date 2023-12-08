import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ColorPickerScreen extends StatefulWidget {
  const ColorPickerScreen({super.key});

  @override
  State<ColorPickerScreen> createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends State<ColorPickerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _curve;
  final int numberOfContainers = 8;
  final double radius = 65.0;
  bool isFirst = true;
  bool hasFolded = false;
  Color initialColor = colors[0];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.forward ||
            status == AnimationStatus.reverse) {
          setState(() {
            isFirst = false;
          });
        } else {
          setState(() {
            //hasFolded = true;
            isFirst = true;
          });
        }
      });
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> animatedContainers =
        List.generate(numberOfContainers, (index) {
      double angle =
          (_curve.value * 2 * pi * index / numberOfContainers) - pi / 2;
      final double x = radius * cos(angle);
      final double y = radius * sin(angle);
      double rotationAngle = angle + pi / 2;
      if (index == 0) {
        return Transform.translate(
          offset: Offset(x, y),
          child: Transform.rotate(
            angle: rotationAngle,
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: /*isFirst ? 100 :*/ 72,
                height: 120.0,
                decoration: ShapeDecoration(
                    shape: /*hasFolded ? CircleBorder() :*/
                        const StadiumBorder(),
                    color: colors[index].withOpacity(0.9),
                    shadows: const [
                      BoxShadow(
                          blurRadius: 3,
                          color: Colors.black38,
                          spreadRadius: 0,
                          offset: Offset(0, 3))
                    ]
                    //borderRadius: isLastContainerCircle ? null : BorderRadius.circular(50),
                    )),
          ),
        );
      }
      return Transform.translate(
        offset: Offset(x, y),
        child: Transform.rotate(
          angle: rotationAngle,
          child: StadiumContainer(
            color: colors[index],
            onSelected: () {
              setState(() {
                initialColor = colors[index];
                _controller.reverse();
              });
            },
          ),
        ),
      );
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              initialColor.withAlpha(50),
              initialColor.withAlpha(100),
              initialColor.withAlpha(150),
              initialColor.withAlpha(200),
              initialColor.withAlpha(255),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                // alignment: Alignment.center,
                //clipBehavior: Clip.none,
                children: animatedContainers,
              ),
              const SizedBox(height: 160),
              ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(240, 48),
                      elevation: 5,
                      backgroundColor: initialColor,
                      foregroundColor: Colors.white),
                  child: const Text('Select a theme'))
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

List<Color> colors = [
  Colors.orange,
  Colors.yellow,
  Colors.green,
  Colors.blueAccent,
  Colors.blue,
  Colors.purple,
  Colors.pink,
  Colors.red
];

class StadiumContainer extends StatelessWidget {
  final void Function()? onSelected;
  final Color color;

  const StadiumContainer({super.key, required this.color, this.onSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        height: 120,
        width: 72,
        decoration: ShapeDecoration(
          color: color,
          shape: const StadiumBorder(),
          shadows: const [
            BoxShadow(
                blurRadius: 3,
                color: Colors.black38,
                spreadRadius: 0,
                offset: Offset(0, 3))
          ],
        ),
      ),
    );
  }
}
