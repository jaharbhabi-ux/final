import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Ultra-compact tile with auto-icon — only as tall as the text needs.
class FieldTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const FieldTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  static IconData _iconForLabel(String label) {
    final l = label.toLowerCase();
    if (l.contains('ehrms')) return Icons.fingerprint_rounded;
    if (l.contains('पिता')) return Icons.person_outline_rounded;
    if (l.contains('नामिनी') || l.contains('सम्बन्ध')) return Icons.family_restroom_rounded;
    if (l.contains('जन्म')) return Icons.cake_rounded;
    if (l.contains('भर्ती')) return Icons.event_rounded;
    if (l.contains('जाति') || l.contains('उपजाति')) return Icons.groups_rounded;
    if (l.contains('जनपद') || l.contains('गृह')) return Icons.location_city_rounded;
    if (l.contains('पता')) return Icons.home_rounded;
    if (l.contains('योग्यता')) return Icons.school_rounded;
    if (l.contains('मोबाइल')) return Icons.phone_rounded;
    if (l.contains('पदोन्नति') || l.contains('सेवा')) return Icons.trending_up_rounded;
    if (l.contains('नियुक्ति')) return Icons.work_outline_rounded;
    return Icons.label_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIcon = icon ?? _iconForLabel(label);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.5), width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: Row(
          children: [
            Icon(effectiveIcon, size: 11, color: AppTheme.secondaryColor.withOpacity(0.6)),
            const SizedBox(width: 3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                      height: 1.15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value.isEmpty ? '-' : value,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}