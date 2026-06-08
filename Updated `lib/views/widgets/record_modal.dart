import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecordModal extends StatefulWidget {
  final String? data;

  const RecordModal({this.data, super.key});

  @override
  State<RecordModal> createState() => _RecordModalState();
}

class _RecordModalState extends State<RecordModal> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Record',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16.0),
          if (widget.data != null)
            Text(
              widget.data!,
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            const Text('No data available.'),
        ],
      ),
    );
  }
}
