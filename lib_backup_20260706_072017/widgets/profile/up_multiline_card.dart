import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Glassy multiline content card with gradient accent.
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
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
          // Gradient accent bar
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.3)],
                stops: const [0.0, 1.0],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 13, color: Colors.white),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF8FAFC),
                    const Color(0xFFF1F5F9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: AppTheme.borderColor.withOpacity(0.6), width: 0.7),
              ),
              child: content.trim().isEmpty
                  ? const Text(
                      '—',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textHint,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  : _MultilineBody(content: content),
            ),
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
      children: [
        for (int i = 0; i < lines.length; i++) ...[
          Text(
            lines[i],
            style: const TextStyle(
              fontSize: 12,
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