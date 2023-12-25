import 'package:flutter/material.dart';

class InstructionsDialog extends StatelessWidget {
  final String instructions;
  final VoidCallback onClose;

  const InstructionsDialog({super.key, required this.instructions, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20.0),
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
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.pink[300],
                elevation: 3.0,
                shadowColor: Colors.pink[300],
              ),
              onPressed: onClose,
              child: const Text('Fechar'),
            ),
          ],
        ),
      ),
    );
  }
}
