import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DashboardOtherDetailsCard extends StatelessWidget {
  final String content;
  const DashboardOtherDetailsCard({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final raw = content.trim();
    final isEmpty = raw.isEmpty;

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
              color: AppTheme.warningColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Row(
              children: [
                Icon(Icons.description_rounded,
                    size: 16, color: AppTheme.warningColor),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'अन्य विवरण',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          if (isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  Icon(Icons.description_outlined,
                      size: 18, color: AppTheme.textHint),
                  SizedBox(width: 8),
                  Text(
                    'कोई अतिरिक्त विवरण उपलब्ध नहीं',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textHint,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: SelectableText(
                raw,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textPrimary,
                    height: 1.5),
              ),
            ),
        ],
      ),
    );
  }
}
