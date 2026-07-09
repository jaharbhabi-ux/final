import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AppBranding extends StatelessWidget {
  final bool compact;
  const AppBranding({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withOpacity(0.10),
              AppTheme.primaryColor.withOpacity(0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.28), width: 0.8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Line 1 — logo + name (signature style)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: Image.asset(
                    'assets/images/icon.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 6),
                Text('Rachit Chauhan',
                    style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5)),
              ],
            ),
            const SizedBox(height: 5),
            // Line 2 — contact number
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.phone_rounded,
                    size: 13, color: AppTheme.primaryColor),
                const SizedBox(width: 5),
                Text('8273212381',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}