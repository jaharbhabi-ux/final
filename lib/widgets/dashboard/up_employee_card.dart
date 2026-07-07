import 'package:flutter/material.dart';
import '../../core/core.dart';

/// Compact employee card for the dashboard grid.
///
/// Shows: avatar initial, name, PNO, badge (if present), post (if present),
/// and a colored dot indicating active/inactive status.
///
/// `const`-friendly — depends only on the [employee] passed in.
class UPEmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback? onTap;

  const UPEmployeeCard({
    super.key,
    required this.employee,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = employee.isActive;
    final displayName = employee.name.isEmpty ? '-' : employee.name;

    return AppTheme.glassContainer(
      borderRadius: 10,
      bgColor: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppTheme.secondaryColor.withOpacity(0.05),
        splashColor: AppTheme.secondaryColor.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    employee.name.isNotEmpty ? employee.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        height: 1.15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // PNO and Badge — each on its own line so badge is always visible
                    Text(
                      'PNO: ${employee.pno}',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (employee.badgeNumber.isNotEmpty)
                      Text(
                        'बैज: ${employee.badgeNumber}',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.secondaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (employee.post.isNotEmpty)
                      Text(
                        employee.post,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppTheme.textHint,
                          height: 1.15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              // Active/inactive status — colored dot + Hindi label
              Tooltip(
                message: isActive ? 'सक्रिय' : 'निष्क्रिय',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: (isActive
                            ? AppTheme.successColor
                            : AppTheme.errorColor)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: (isActive
                              ? AppTheme.successColor
                              : AppTheme.errorColor)
                          .withOpacity(0.4),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        isActive ? 'सक्रिय' : 'निष्क्रिय',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}