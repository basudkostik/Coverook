
import 'package:flutter/material.dart';

class HighlightsTab extends StatelessWidget {
  const HighlightsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Highlights Content",
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}