import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Modern information card — small colored icon + field title on top,
/// larger bold value below. Cards auto-size to their content (long text
/// like the address wraps instead of truncating).
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
    if (l.contains('पिता')) return Icons.person_rounded;
    if (l.contains('नामिनी') || l.contains('सम्बन्ध')) {
      return Icons.family_restroom_rounded;
    }
    if (l.contains('जन्म')) return Icons.calendar_month_rounded;
    if (l.contains('भर्ती')) return Icons.work_rounded;
    if (l.contains('जाति')) return Icons.groups_rounded;
    if (l.contains('उपजाति')) return Icons.badge_rounded;
    if (l.contains('जनपद') || l.contains('गृह')) {
      return Icons.location_on_rounded;
    }
    if (l.contains('पता')) return Icons.home_rounded;
    if (l.contains('योग्यता')) return Icons.school_rounded;
    if (l.contains('मोबाइल')) return Icons.phone_rounded;
    if (l.contains('पदोन्नति')) return Icons.trending_up_rounded;
    if (l.contains('नियुक्ति')) return Icons.business_rounded;
    return Icons.label_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIcon = icon ?? _iconForLabel(label);
    final isEmpty = value.trim().isEmpty;
    final displayValue = isEmpty ? 'उपलब्ध नहीं' : value;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(effectiveIcon, size: 16, color: AppTheme.secondaryColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          SelectableText(
            displayValue,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isEmpty ? AppTheme.textHint : AppTheme.textPrimary,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
