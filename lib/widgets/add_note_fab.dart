import 'package:flutter/material.dart';

class AddNoteFab extends StatelessWidget {
  final VoidCallback onPressed;

  const AddNoteFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.blue,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}
