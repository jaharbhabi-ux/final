import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Compact section container with icon + title + thin accent bar.
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
          // Thin accent bar at top
          Container(
            height: 2.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.3)],
                stops: const [0.0, 1.0],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 5, 8, 3),
            child: Row(
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
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
    );
  }
}