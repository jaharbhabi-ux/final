import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DashboardAwardsCard extends StatelessWidget {
  final List<({String label, String value, IconData icon, Color color})> awards;
  const DashboardAwardsCard({super.key, required this.awards});

  @override
  Widget build(BuildContext context) {
    bool looksLikeDate(String s) {
      final trimmed = s.trim();
      if (trimmed.isEmpty) return false;
      if (RegExp(r'^\d{1,2}[/\-.]\d{1,2}[/\-.]\d{2,4}$').hasMatch(trimmed)) {
        return true;
      }
      return false;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 3,
            decoration: const BoxDecoration(
              color: AppTheme.accentGold,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Row(
              children: [
                Icon(Icons.emoji_events_rounded,
                    size: 16, color: AppTheme.primaryColor),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'पुरस्कार एवं विवरण',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (awards.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  Icon(Icons.emoji_events_outlined,
                      size: 18, color: AppTheme.textHint),
                  SizedBox(width: 8),
                  Text(
                    'कोई पुरस्कार उपलब्ध नहीं',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textHint,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          else
            ...awards.map((a) {
              final datePart = looksLikeDate(a.value) ? a.value : null;
              final textPart = datePart != null ? '' : a.value;
              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 3, 12, 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(a.icon, size: 14, color: a.color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        a.label,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary),
                      ),
                    ),
                    if (datePart != null)
                      Text(datePart,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary)),
                    if (textPart.isNotEmpty)
                      Expanded(
                        child: Text(
                          textPart,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary),
                          textAlign: TextAlign.end,
                        ),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
