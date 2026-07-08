import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DashboardRemarksTimeline extends StatelessWidget {
  final String content;
  const DashboardRemarksTimeline({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final raw = content.trim();
    final lines = raw.isEmpty ? const <String>[] : raw.split('\n').toList();

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: AppTheme.infoColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Row(
              children: [
                Icon(Icons.notes_rounded, size: 16, color: AppTheme.infoColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'रिमार्क',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          if (lines.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  Icon(Icons.notes_rounded, size: 18, color: AppTheme.textHint),
                  const SizedBox(width: 8),
                  Text(
                    'कोई रिमार्क उपलब्ध नहीं',
                    style: TextStyle(fontSize: 13, color: AppTheme.textHint, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: lines.length,
                separatorBuilder: (_, __) => SizedBox(height: lines.length > 1 ? 10 : 0),
                itemBuilder: (context, index) {
                  final isLast = index == lines.length - 1;
                  final line = lines[index].trim();
                  final isYearLike = RegExp(r'^\d{4}$').hasMatch(line) || RegExp(r'^\d{1,2}[/\-.]\d{1,2}[/\-.]\d{2,4}$').hasMatch(line);

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppTheme.infoColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 20,
                              color: AppTheme.infoColor.withOpacity(0.25),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 2, bottom: isLast ? 2 : 0),
                          child: Text(
                            line,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isYearLike ? FontWeight.w600 : FontWeight.w400,
                              color: AppTheme.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
