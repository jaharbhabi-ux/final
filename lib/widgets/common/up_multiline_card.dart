import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Compact multiline content card — minimal padding, no wasted space.
class UPMultilineCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String content;
  final bool showIfEmpty;

  const UPMultilineCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.content,
    this.showIfEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    if (content.trim().isEmpty && !showIfEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.6), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 5, 8, 3),
            child: Row(
              children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
            child: content.trim().isEmpty
                ? const Text(
                    '—',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textHint,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : _MultilineBody(content: content),
          ),
        ],
      ),
    );
  }
}

class _MultilineBody extends StatelessWidget {
  final String content;
  const _MultilineBody({required this.content});

  @override
  Widget build(BuildContext context) {
    final lines = content.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < lines.length; i++) ...[
          Text(
            lines[i],
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
              height: 1.4,
            ),
            softWrap: true,
          ),
          if (i < lines.length - 1) const SizedBox(height: 2),
        ],
      ],
    );
  }
}