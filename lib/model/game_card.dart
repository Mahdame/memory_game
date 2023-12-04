import 'dart:math';

import 'package:flutter/material.dart';

class GameCard extends StatefulWidget {
  final String content; // Can be a path to an image or text
  final bool isFlipped;
  final bool isMatched;

  const GameCard({
    super.key,
    required this.content,
    required this.isFlipped,
    required this.isMatched,
  });

  @override
  State<GameCard> createState() => _GameCardState();

  GameCard copyWith({bool? isFlipped, bool? isMatched}) {
    return GameCard(
      key: key,
      content: content,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}

class _GameCardState extends State<GameCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void didUpdateWidget(GameCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Flip or reverse the flip animation when the isFlipped state changes
    if (widget.isFlipped != oldWidget.isFlipped) {
      widget.isFlipped ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint('Disposing GameCard: ${widget.key}');
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective
            ..rotateY(pi * _flipAnimation.value),
          alignment: Alignment.center,
          child: _flipAnimation.value < 0.5 ? _buildFrontSide() : _buildBackSide(),
        );
      },
    );
  }

  Widget _buildFrontSide() {
    return Container(
      color: Colors.red,
    ); // Design for the back of the card, maybe a plain color or a logo
  }

  Widget _buildBackSide() {
    return Image.asset(widget.content, fit: BoxFit.contain); // Display the image
  }
}
