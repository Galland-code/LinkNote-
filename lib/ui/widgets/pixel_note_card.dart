import 'package:flutter/material.dart';
import '../../core/models/note_model.dart';

/// A card that displays note information
class PixelNoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;

  const PixelNoteCard({
    Key? key,
    required this.note,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (note.icon != null)
                  Image.asset(
                    note.icon!,
                    width: 12,
                    height: 12,
                  ),
                const SizedBox(width: 4),
                Text(
                  note.date,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}