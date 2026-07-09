import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

class UPAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showLogo;
  final Color? backgroundColor;
  final bool centerTitle;

  const UPAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showLogo = true,
    this.backgroundColor,
    this.centerTitle = true,
  });

Widget _buildLogo() {
  return SizedBox(
    width: 28,
    height: 28,
    child: Image.asset(
      'assets/images/icon.png',
      fit: BoxFit.contain,
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
        return const Icon(Icons.error, color: Colors.red);
      },
    ),
  );
}

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final titleText = Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
        height: 1.1,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    final titleWidget = showLogo
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLogo(),
              const SizedBox(width: 8),
              titleText,
            ],
          )
        : titleText;

    return AppBar(
      backgroundColor: backgroundColor ?? AppTheme.cardColor,
      foregroundColor: AppTheme.textPrimary,
      elevation: 0,
      centerTitle: centerTitle,
      leading: leading,
      title: titleWidget,
      actions: actions,
      bottomOpacity: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }
}