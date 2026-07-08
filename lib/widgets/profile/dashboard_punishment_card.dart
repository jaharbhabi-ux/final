import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DashboardPunishmentCard extends StatelessWidget {
  final String title;
  final String content;
  final Color color;
  final IconData icon;

  const DashboardPunishmentCard({
    super.key,
    required this.title,
    required this.content,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final raw = content.trim();
    final lines = raw.isEmpty ? const <String>[] : raw.split('\n').where((s) => s.trim().isNotEmpty).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
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
                  Icon(Icons.block_rounded, size: 18, color: AppTheme.textHint),
                  const SizedBox(width: 8),
                  Text(
                    'कोई रिकॉर्ड उपलब्ध नहीं',
                    style: TextStyle(fontSize: 13, color: AppTheme.textHint, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                itemCount: lines.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final line = lines[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('•', style: TextStyle(fontSize: 16, color: color, height: 1.2)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SelectableText(
                          line,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textPrimary, height: 1.3),
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
