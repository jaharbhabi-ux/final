import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Glassmorphism section container with icon + title + accent bar.
class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
  final List<Widget>? actions;

  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
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
                color: color.withOpacity(0.10),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Accent bar at top
              Container(
                height: 3,
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
                    Icon(icon, size: 14, color: color),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                    if (actions != null) ...actions!,
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
