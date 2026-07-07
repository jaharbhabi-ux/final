import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Glassmorphism multiline content card — minimal padding, no wasted space.
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.88),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.70), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thin accent bar
              Container(
                height: 2.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.3)],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                ),
              ),
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
        ),
      ),
    );
  }
}

class _MultilineBody extends StatelessWidget {
  final String content;
  const _MultilineBody({required this.content});

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      content,
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
        color: AppTheme.textPrimary,
        height: 1.4,
      ),
    );
  }
}
