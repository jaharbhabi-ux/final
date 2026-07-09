import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DashboardRemarksTimeline extends StatelessWidget {
  final String content;
  const DashboardRemarksTimeline({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final raw = content.trim();
    final lines = raw.isEmpty
        ? const <String>[]
        : raw.split('\n').where((l) => l.trim().isNotEmpty).toList();

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
              color: AppTheme.infoColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Row(
              children: [
                Icon(Icons.notes_rounded, size: 16, color: AppTheme.infoColor),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'रिमार्क',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          if (lines.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  Icon(Icons.notes_rounded, size: 18, color: AppTheme.textHint),
                  SizedBox(width: 8),
                  Text(
                    'कोई रिमार्क उपलब्ध नहीं',
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
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: lines.length,
                separatorBuilder: (_, __) => const SizedBox(height: 0),
                itemBuilder: (context, index) {
                  final isLast = index == lines.length - 1;
                  final line = lines[index].trim();
                  final isYearLike = RegExp(r'^\d{4}$').hasMatch(line) ||
                      RegExp(r'^\d{1,2}[/\-.]\d{1,2}[/\-.]\d{2,4}$')
                          .hasMatch(line);

                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppTheme.infoColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            if (!isLast)
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: AppTheme.infoColor.withOpacity(0.25),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 0, bottom: 2),
                            child: Text(
                              line,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isYearLike
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: AppTheme.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
