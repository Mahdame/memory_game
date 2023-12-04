import 'package:flutter/material.dart';

class InstructionsWidget extends StatelessWidget {
  final String instructions;
  final VoidCallback onClose;

  const InstructionsWidget({super.key, required this.instructions, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Instruções',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              instructions,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onClose,
              child: const Text('Fechar'),
            ),
          ],
        ),
      ),
    );
  }
}
