import 'dart:math';

import 'package:color_picker/color_picker.dart';
import 'package:flutter/material.dart';

class ColorPickerScreen extends StatefulWidget {
  const ColorPickerScreen({super.key});

  @override
  State<ColorPickerScreen> createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends State<ColorPickerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final int numberOfContainers = 8;
  final double radius = 80.0;
  bool isFirst = true;
  bool hasFolded = false;
  Color initialColor = colors[0];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )
      ..addListener(() {
        setState(() {}); // Calls build() method for each animation tick
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.forward ||
            status == AnimationStatus.reverse) {
          setState(() {
            isFirst = false; // Last container becomes a StadiumContainer
          });
        } else {
          setState(() {
            //hasFolded = true;
            isFirst = true; // Last container reverts to a circle
          });
        }
      });

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> animatedContainers =
        List.generate(numberOfContainers, (index) {
      // Adjusting the angle calculation for 8 containers
      double angle =
          (_controller.value * 2 * pi * index / numberOfContainers) - pi / 2;
      final double x = radius * cos(angle);
      final double y = radius * sin(angle);
      // Calculate rotation angle so that the StadiumContainer is tangent to the circle
      double rotationAngle =
          angle + pi / 2; // This corrects the alignment to be tangent
      if (index == 0) {
        return Transform.translate(
          offset: Offset(x, y),
          child: Transform.rotate(
            angle: rotationAngle,
            child: AnimatedContainer(
                duration: Duration(milliseconds: 1500),
                width: isFirst ? 100 : 64,
                height: 100.0,
                decoration: ShapeDecoration(
                  shape: hasFolded ? CircleBorder() : StadiumBorder(),
                  color: Colors.blue[(index + 1) * 100],

                  //borderRadius: isLastContainerCircle ? null : BorderRadius.circular(50),
                )),
          ),
        );
      }
      return Transform.translate(
        offset: Offset(x, y),
        child: Transform.rotate(
          angle: rotationAngle,
          child: StadiumContainer(color: colors[index]),
        ),
      );
    });

    return Scaffold(
      body: Container(decoration: BoxDecoration(
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
        child: Stack(
          alignment: Alignment.center,
          children: animatedContainers,
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

class AnotherTest extends StatefulWidget {
  const AnotherTest({super.key});

  @override
  State<AnotherTest> createState() => _AnotherTestState();
}

class _AnotherTestState extends State<AnotherTest>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 20));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  double angle = pi * _controller.value;
                  return CustomContainer(
                    controller: _controller,
                    index: 0,
                  )
                      /*Stack(
                    children: [
                      ...List.generate(
                          colors.length,
                          (index) => Transform.rotate(
                                angle: angle + (2 * pi / colors.length) * index,
                                child: Transform.translate(
                                    offset: Offset(
                                      70 * sin(angle),
                                      70 * cos(angle),
                                    ),
                                    child: Opacity(
                                        opacity: 1,
                                        child: StadiumContainer(
                                            color: colors[index]))),
                              )).toList()
                    ],
                  )*/
                      ;
                }),
          ],
        ),
      ),
    );
  }
}

class CustomContainer extends StatefulWidget {
  final AnimationController controller;
  final int index;

  const CustomContainer(
      {super.key, required this.controller, required this.index});

  @override
  State<CustomContainer> createState() => _CustomContainerState();
}

class _CustomContainerState extends State<CustomContainer>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animation = Tween<double>(begin: 0, end: 2 * pi).animate(widget.controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          widget.controller.forward();
        }
      });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double radius = 100.0; // Radius of the circle
    final double x = radius * cos(animation.value);
    final double y = radius * sin(animation.value);
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        double angle = pi * widget.controller.value;
        return Transform.translate(
          offset: Offset(x, y),
          child: Transform.rotate(
            angle: angle + (2 * pi / colors.length) * (widget.index),
            child: StadiumContainer(
              color: colors[widget.index],
            ),
          ),
        );
      },
    );
  }
}
