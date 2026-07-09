import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class UPPoliceBadge extends StatelessWidget {
  final double size;

  const UPPoliceBadge({
    super.key,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/icon.png',
        fit: BoxFit.contain,
      ),
    );
  }
}
