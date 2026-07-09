import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Reusable loading card — replaces 3 inline copies (main.dart,
/// dashboard_screen.dart, transfer_classification_page.dart).
class UPLoadingCard extends StatelessWidget {
  final String message;
  final String subtitle;
  final double size;

  const UPLoadingCard({
    super.key,
    this.message = 'डेटा लोड हो रहा है...',
    this.subtitle = 'प्रधान लिपिक शाखा जनपद बरेली',
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return AppTheme.premiumCard(
      borderRadius: 20,
      padding: EdgeInsets.all(size),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              backgroundColor: AppTheme.borderColor.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact inline loading indicator — used for background-load
/// banners and inline section loaders.
class UPInlineLoader extends StatelessWidget {
  final String message;
  const UPInlineLoader({super.key, this.message = 'पृष्ठभूमि में डेटा लोड हो रहा है...'});

  @override
  Widget build(BuildContext context) {
    return AppTheme.premiumCard(
      borderRadius: 8,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
