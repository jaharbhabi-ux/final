import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AppBranding extends StatelessWidget {
  final bool compact;
  const AppBranding({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: compact ? 4 : 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_rounded, size: compact ? 10 : 12, color: AppTheme.primaryColor.withOpacity(0.6)),
          const SizedBox(width: 4),
          Text('Created by ', style: TextStyle(fontSize: compact ? 8 : 9, color: Colors.grey.shade500, fontWeight: FontWeight.w400)),
          Text('Rachit Kumar', style: TextStyle(fontSize: compact ? 8 : 9, color: AppTheme.primaryColor, fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          Icon(Icons.phone_rounded, size: compact ? 8 : 10, color: Colors.grey.shade400),
          const SizedBox(width: 2),
          Text('8273212381', style: TextStyle(fontSize: compact ? 8 : 9, color: Colors.grey.shade500, fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }
}