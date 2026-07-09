import 'package:flutter/material.dart';
import '../../core/core.dart';

class UPEmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback? onTap;
  final bool allowWrap;

  const UPEmployeeCard({
    super.key,
    required this.employee,
    this.onTap,
    this.allowWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = employee.isActive;
    final displayName = employee.name.isEmpty ? '-' : employee.name;

    return AppTheme.premiumCard(
      borderRadius: 10,
      padding: EdgeInsets.symmetric(
        horizontal: allowWrap ? 12 : 8,
        vertical: allowWrap ? 8 : 3,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppTheme.secondaryColor.withOpacity(0.05),
        splashColor: AppTheme.secondaryColor.withOpacity(0.1),
        child: Row(
          crossAxisAlignment: allowWrap
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Container(
              width: allowWrap ? 30 : 22,
              height: allowWrap ? 30 : 22,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  employee.name.isNotEmpty
                      ? employee.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: allowWrap ? 13 : 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: allowWrap ? 10 : 6),
            Flexible(
              fit: FlexFit.loose,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: TextStyle(
                      fontSize: allowWrap ? 14 : 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      height: 1.2,
                    ),
                    maxLines: allowWrap ? 2 : 1,
                    overflow: allowWrap
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'PNO: ${employee.pno}${employee.badgeNumber.isNotEmpty ? '  •  बैज: ${employee.badgeNumber}' : ''}',
                    style: TextStyle(
                      fontSize: allowWrap ? 12 : 10,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                      height: 1.2,
                    ),
                    maxLines: allowWrap ? 2 : 1,
                    overflow: allowWrap
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                  ),
                  if (allowWrap && employee.post.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      employee.post,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textHint,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 4),
            Tooltip(
              message: isActive ? 'सक्रिय' : 'निष्क्रिय',
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color:
                      (isActive ? AppTheme.successColor : AppTheme.errorColor)
                          .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: (isActive
                            ? AppTheme.successColor
                            : AppTheme.errorColor)
                        .withOpacity(0.5),
                    width: 0.6,
                  ),
                ),
                child: Icon(
                  Icons.circle,
                  size: 10,
                  color: isActive
                      ? AppTheme.successColor
                      : AppTheme.errorColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}