import 'package:flutter/material.dart';

class ShinyMetalCard extends StatelessWidget {
  const ShinyMetalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: const Duration(seconds: 3),
      tween: Tween(begin: -0.5, end: 1.5),
      builder: (context, double value, child) {
        return Card(
          elevation: 5.0,
          child: Container(
            width: 300,
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey[700]!,
                  Colors.grey[300]!.withOpacity(0.5),
                  Colors.grey[700]!,
                ],
                stops: [value - 0.3, value, value + 0.3],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                tileMode: TileMode.repeated,
              ),
            ),
            child: const Center(
              child: Text(
                '',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
