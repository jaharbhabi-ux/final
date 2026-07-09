import 'package:flutter/material.dart';

/// Premium Modern Eye-Comfort Theme — UP Police HRMS
/// Clean white cards on soft light background with excellent contrast.
class AppTheme {
  AppTheme._();

  // ──────────────────────────────────────────────
  // 🎨 Color Palette - Premium Eye-Comfort Theme
  // ──────────────────────────────────────────────
  static const Color primaryColor = Color(0xFF14B8A6); // Primary Accent
  static const Color secondaryColor = Color(0xFF0F766E); // Card Title / Header
  static const Color primaryDark = Color(0xFF0F3D33); // Dark Background (not used in light theme)
  static const Color accentGold = Color(0xFFF59E0B); // Warning
  static const Color accentPurple = Color(0xFF10B981); // Success
  static const Color accentTeal = Color(0xFF10B981); // Success (for consistency)

  // Surfaces - Premium Light Theme
  static const Color backgroundColor = Color(0xFFF8FAFC); // Soft light background
  static const Color surfaceColor = Color(0xFFF8FAFC); // Light surface
  static const Color cardColor = Colors.white; // White cards
  static const Color borderColor = Color(0xFFE2E8F0); // Borders

  // Text - High contrast, readable
  static const Color textPrimary = Color(0xFF1E293B); // Primary text (dark gray)
  static const Color textSecondary = Color(0xFF64748B); // Secondary text
  static const Color textHint = Color(0xFF9CA3AF); // Hints/light text
  static const Color sectionHeader = Color(0xFF0F766E); // Card titles / Header

  // Status - Semantic colors
  static const Color successColor = Color(0xFF22C55E); // Green - Success
  static const Color warningColor = Color(0xFFF59E0B); // Orange - Warning
  static const Color errorColor = Color(0xFFEF4444); // Red - Error
  static const Color infoColor = Color(0xFF3B82F6); // Blue - Info

  // ──────────────────────────────────────────────
  // 📐 Typography
  // ──────────────────────────────────────────────
  static TextStyle get heading1 => const TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      letterSpacing: 0.3,
      height: 1.2);
  static TextStyle get heading2 => const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      height: 1.3);
  static TextStyle get heading3 => const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      height: 1.3);
  static TextStyle get subtitle1 => const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      height: 1.4);
  static TextStyle get subtitle2 => const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: textSecondary,
      height: 1.4);
  static TextStyle get bodyText1 => const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: textPrimary,
      height: 1.5);
  static TextStyle get bodyText2 => const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: textPrimary,
      height: 1.5);
  static TextStyle get caption => const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: textSecondary,
      height: 1.4);
  static TextStyle get statNumber => const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w800,
      color: secondaryColor,
      height: 1.1);
  static TextStyle get statLabel => const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: textSecondary,
      height: 1.2);

  // ──────────────────────────────────────────────
  // 🌐 Locale
  // ──────────────────────────────────────────────
  static const Locale hindiLocale = Locale('hi', 'IN');
  static const List<Locale> supportedLocales = [
    hindiLocale,
    Locale('en', 'US')
  ];

  // ──────────────────────────────────────────────
  // 🎨 Gradients
  // ──────────────────────────────────────────────

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF8FAFC), // Soft light background
      Color(0xFFF1F5F9), // Slightly darker light
    ],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, secondaryColor],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryColor, Color(0xFF065F46)],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
  );

  // ──────────────────────────────────────────────
  // 🎨 Light Theme
  // ──────────────────────────────────────────────
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: secondaryColor,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: secondaryColor,
          letterSpacing: 0.3),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.06),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: borderColor, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor)),
      hintStyle: const TextStyle(fontSize: 14, color: textHint),
      labelStyle: const TextStyle(fontSize: 13, color: textSecondary),
    ),
    textTheme: TextTheme(
      displayLarge: heading1,
      displayMedium: heading2,
      displaySmall: heading3,
      headlineMedium: subtitle1,
      titleLarge: subtitle1,
      titleMedium: subtitle2,
      bodyLarge: bodyText1,
      bodyMedium: bodyText2,
      bodySmall: caption,
    ),
    dividerTheme:
        const DividerThemeData(color: borderColor, thickness: 1, space: 1),
    chipTheme: ChipThemeData(
      backgroundColor: primaryColor.withOpacity(0.08),
      labelStyle: const TextStyle(
          fontSize: 12, color: primaryColor, fontWeight: FontWeight.w600),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor, linearTrackColor: borderColor),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: secondaryColor,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  // ──────────────────────────────────────────────
  // 📅 Hindi Date Formatting
  // ──────────────────────────────────────────────
  static const Map<String, String> hindiMonths = {
    '01': 'जनवरी',
    '02': 'फरवरी',
    '03': 'मार्च',
    '04': 'अप्रैल',
    '05': 'मई',
    '06': 'जून',
    '07': 'जुलाई',
    '08': 'अगस्त',
    '09': 'सितंबर',
    '10': 'अक्टूबर',
    '11': 'नवंबर',
    '12': 'दिसंबर',
  };

// ──────────────────────────────────────────────
  // 🪟 Premium Card Helper
  // Creates elegant white cards with subtle shadows for eye comfort
  // ──────────────────────────────────────────────
  static Widget premiumCard({
    required Widget child,
    double borderRadius = 16,
    EdgeInsetsGeometry? padding,
    List<BoxShadow>? boxShadow,
    Color? cardBorderColor,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: cardBorderColor ?? borderColor,
          width: 1,
        ),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
      ),
child: child,
    );
  }

  @Deprecated('Use premiumCard instead for the new eye-comfort theme')
  static Widget glassContainer({
    required Widget child,
    double borderRadius = 16,
    double blurSigma = 12.0,
    Color? bgColor,
    EdgeInsetsGeometry? padding,
    List<BoxShadow>? boxShadow,
  }) {
    return premiumCard(
      child: child,
      borderRadius: borderRadius,
      padding: padding,
      boxShadow: boxShadow,
      cardBorderColor: bgColor?.withOpacity(0.5) ?? borderColor,
    );
  }

  // ──────────────────────────────────────────────
  // 🏷️ Field Icon Mapping
  // ──────────────────────────────────────────────
  static IconData iconForField(String key) {
    final lower = key.toLowerCase();
    if (lower.contains('पीएनओ') || lower.contains('pno'))
      return Icons.badge_rounded;
    if (lower.contains('नाम') &&
        !lower.contains('पिता') &&
        !lower.contains('नामिनी')) return Icons.person_rounded;
    if (lower.contains('पिता')) return Icons.people_rounded;
    if (lower.contains('मोबाइल') || lower.contains('mobile'))
      return Icons.phone_rounded;
    if (lower.contains('जन्म') ||
        lower.contains('dob') ||
        lower.contains('तिथि')) return Icons.calendar_month_rounded;
    if (lower.contains('गृह') ||
        lower.contains('जनपद') ||
        lower.contains('district') ||
        lower.contains('तैनाती') ||
        lower.contains('posting')) return Icons.location_on_rounded;
    if (lower.contains('योग्यता') || lower.contains('qualification'))
      return Icons.school_rounded;
    if (lower.contains('पद') && !lower.contains('posting'))
      return Icons.work_rounded;
    if (lower.contains('बैज') || lower.contains('badge'))
      return Icons.verified_rounded;
    if (lower.contains('जाति') || lower.contains('cast'))
      return Icons.category_rounded;
    if (lower.contains('भर्ती') || lower.contains('recruit'))
      return Icons.how_to_reg_rounded;
    if (lower.contains('नामिनी') || lower.contains('nominee'))
      return Icons.contact_emergency_rounded;
    if (lower.contains('पदक') ||
        lower.contains('medal') ||
        lower.contains('पुरूष्कार')) return Icons.emoji_events_rounded;
    if (lower.contains('विवरण') || lower.contains('detail'))
      return Icons.description_rounded;
    if (lower.contains('पदोन्नति') || lower.contains('promotion'))
      return Icons.trending_up_rounded;
    if (lower.contains('पता') || lower.contains('address'))
      return Icons.home_rounded;
    if (lower.contains('दण्ड') || lower.contains('punishment'))
      return Icons.gavel_rounded;
    if (lower.contains('सत्यनिष्ठा')) return Icons.verified_user_rounded;
    if (lower.contains('नगद') || lower.contains('cash'))
      return Icons.card_giftcard_rounded;
    if (lower.contains('गुड') || lower.contains('good'))
      return Icons.star_rounded;
    if (lower.contains('पूर्व') ||
        lower.contains('previous') ||
        lower.contains('नियुक्ति')) return Icons.history_rounded;
    if (lower.contains('ehrms')) return Icons.fingerprint_rounded;
    return Icons.info_outline_rounded;
  }
}
