import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import 'employee_edit_dialog.dart';
import '../../widgets/up_police_badge.dart';
import '../../widgets/common/up_data_table.dart';
import '../../widgets/profile/section_card.dart';
import '../../widgets/profile/field_tile.dart';
import '../../widgets/profile/dashboard_awards_card.dart';
import '../../widgets/profile/dashboard_punishment_card.dart';
import '../../widgets/profile/dashboard_remarks_timeline.dart';
import '../../widgets/profile/dashboard_other_details_card.dart';
import '../print/print_helper.dart';
import '../../utils/print_shortcut.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _fadeController.forward();
    setupCtrlPShortcut(_printCurrentProfile);
    // Windows / desktop Escape key -> navigate back, mirroring the
    // Android back button and the AppBar back arrow.
    HardwareKeyboard.instance.addHandler(_onKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKeyEvent);
    _searchCtrl.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  /// Returns `true` if the key event was handled (Escape -> pop).
  bool _onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      if (mounted) _handleBack();
      return true;
    }
    return false;
  }

  /// Unified back-navigation handler -- used by the AppBar back arrow,
  /// the in-page back button, the Android back button, and the
  /// Windows Escape key. Clears the selected employee (so the dashboard
  /// search box is reset) and pops the route.
  void _handleBack() {
    final provider = context.read<EmployeeProvider>();
    provider.clearSelection();
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  /// Triggered by Ctrl+P / Cmd+P keyboard shortcut on web.
  /// Falls through to PrintHelper which generates an A4 PDF and
  /// opens the native print dialog (no screenshot).
  void _printCurrentProfile() {
    final provider = context.read<EmployeeProvider>();
    final employee = provider.selectedEmployee;
    if (employee == null) return;
    PrintHelper.printProfile(
      employee: employee,
      profile: provider.selectedProfile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'वापस',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _handleBack,
        ),
        title: const Text(
          'कर्मचारी विवरण',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Consumer<EmployeeProvider>(
          builder: (context, provider, _) {
            final employee = provider.selectedEmployee;
            final profile = provider.selectedProfile;

            if (employee == null) {
              return const Center(
                child: Text('कोई कर्मचारी चुना नहीं गया',
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
              );
            }

            return FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(context, employee),
                    const SizedBox(height: 4),

                    // SEARCH BAR
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppTheme.borderColor.withOpacity(0.6),
                            width: 0.8),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 1))
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded,
                              size: 18, color: AppTheme.textHint),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              style: const TextStyle(
                                  fontSize: 13, color: AppTheme.textPrimary),
                              decoration: const InputDecoration(
                                isDense: true,
                                hintText: 'PNO / बैज / नाम से खोजें...',
                                hintStyle: TextStyle(
                                    fontSize: 12, color: AppTheme.textHint),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                              ),
                              onSubmitted: (q) {
                                final trimmed = q.trim();
                                if (trimmed.isEmpty) {
                                  provider.clearSelection();
                                  return;
                                }
                                if (RegExp(r'^\d+$').hasMatch(trimmed)) {
                                  if (trimmed.length <= 4) {
                                    provider.searchEmployeeByField(
                                        trimmed, 'badge');
                                  } else {
                                    provider.searchEmployeeByField(
                                        trimmed, 'pno');
                                  }
                                } else {
                                  provider.searchEmployee(trimmed);
                                }
                                if (provider.filteredResults.length == 1) {
                                  provider.selectEmployee(
                                      provider.filteredResults.first);
                                  _searchCtrl.clear();
                                }
                              },
                            ),
                          ),
                          if (provider.filteredResults.isNotEmpty) ...[
                            Container(
                              height: 28,
                              decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6)),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Center(
                                  child: Text(
                                      '${provider.filteredResults.length}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.primaryColor))),
                            ),
                            const SizedBox(width: 6),
                          ],
                          IconButton(
                            icon: const Icon(Icons.close_rounded,
                                size: 16, color: AppTheme.textHint),
                            onPressed: () {
                              _searchCtrl.clear();
                              provider.clearSelection();
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 28, minHeight: 28),
                          ),
                        ],
                      ),
                    ),

                    // SEARCH RESULTS
                    if (provider.filteredResults.isNotEmpty &&
                        _searchCtrl.text.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        constraints: const BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              width: 1),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3))
                          ],
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(4),
                          itemCount: provider.filteredResults.length,
                          itemBuilder: (_, i) {
                            final e = provider.filteredResults[i];
                            return InkWell(
                              onTap: () {
                                provider.selectEmployee(e);
                                _searchCtrl.clear();
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.primaryColor.withOpacity(0.03),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color:
                                          AppTheme.borderColor.withOpacity(0.4),
                                      width: 0.5),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                        radius: 20,
                                        backgroundColor: AppTheme.primaryColor
                                            .withOpacity(0.12),
                                        child: Text(
                                            e.name.isNotEmpty
                                                ? e.name[0].toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.primaryColor))),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(e.name,
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppTheme.textPrimary,
                                                    height: 1.3),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            const SizedBox(height: 3),
                                            Row(children: [
                                              const Icon(Icons.badge_rounded,
                                                  size: 11,
                                                  color: AppTheme.textHint),
                                              const SizedBox(width: 3),
                                              Text('PNO: ${e.pno}',
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: AppTheme
                                                          .textSecondary)),
                                              const SizedBox(width: 12),
                                              const Icon(Icons.verified_rounded,
                                                  size: 11,
                                                  color: AppTheme.textHint),
                                              const SizedBox(width: 3),
                                              Text('बैज: ${e.badgeNumber}',
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: AppTheme
                                                          .textSecondary)),
                                            ]),
                                          ]),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: e.isActive
                                              ? AppTheme.successColor
                                                  .withOpacity(0.15)
                                              : AppTheme.errorColor
                                                  .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Text(
                                          e.isActive ? 'सक्रिय' : 'निष्क्रिय',
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: e.isActive
                                                  ? AppTheme.successColor
                                                  : AppTheme.errorColor)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    _buildProfileHeader(employee),
                    const SizedBox(height: 2),
                    _buildResponsiveBody(employee, profile),
                    const SizedBox(height: 16),

                    // BRANDING
                    const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.code_rounded,
                              size: 11, color: AppTheme.textHint),
                          SizedBox(width: 4),
                          Text('Created by Rachit Chauhan',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: AppTheme.textHint,
                                  fontWeight: FontWeight.w500)),
                          SizedBox(width: 8),
                          Icon(Icons.phone_rounded,
                              size: 10, color: AppTheme.textHint),
                          SizedBox(width: 3),
                          Text('8273212381',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: AppTheme.textHint,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, Employee employee) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: AppTheme.borderColor.withOpacity(0.5), width: 0.5)),
      child: Row(
        children: [
          GestureDetector(
            onTap: _handleBack,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_rounded,
                    color: AppTheme.textSecondary, size: 18),
                SizedBox(width: 4),
                Text('वापस',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary)),
              ],
            ),
          ),
          const Spacer(),
          _EditButton(employee: employee),
          _NewEmployeeButton(),
          _PrintButton(employee: employee),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Employee employee) {
    final isActive = employee.isActive;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 160),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppTheme.headerGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── TOP ROW: avatar+identity (left) · status+shield (right) ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT — circular avatar + name / designation / posting
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withOpacity(0.18),
                child: employee.name.isNotEmpty
                    ? Text(
                        employee.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.person_rounded,
                        size: 30, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.name.isEmpty ? '-' : employee.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (employee.post.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        employee.post,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (employee.currentPosting.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              size: 13, color: Colors.white70),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              employee.currentPosting,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.white70,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // RIGHT — active/inactive badge + police shield
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppTheme.successColor.withOpacity(0.25)
                          : AppTheme.errorColor.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isActive
                            ? AppTheme.successColor.withOpacity(0.5)
                            : AppTheme.errorColor.withOpacity(0.5),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      isActive ? 'सक्रिय' : 'निष्क्रिय',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const UPPoliceBadge(size: 34),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // ── CENTER — identity chips (wrap on narrow screens) ──
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _headerChip(Icons.badge_rounded, 'PNO: ${employee.pno}'),
              if (employee.badgeNumber.isNotEmpty)
                _headerChip(
                    Icons.verified_rounded, 'बैज: ${employee.badgeNumber}'),
              if (employee.ehrms.isNotEmpty)
                _headerChip(
                    Icons.fingerprint_rounded, 'EHRMS: ${employee.ehrms}'),
              if (employee.mobile.isNotEmpty)
                _headerChip(Icons.phone_rounded, employee.mobile),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(4),
          border:
              Border.all(color: Colors.white.withOpacity(0.15), width: 0.5)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: Colors.white.withOpacity(0.9)),
        const SizedBox(width: 5),
        Text(text,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.9)))
      ]),
    );
  }

  Widget _buildResponsiveBody(Employee employee, EmployeeProfile? profile) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final isWide = width > 900;
      if (isWide) {
        return Column(children: [
          _buildPersonalDetails(employee, profile), const SizedBox(height: 2),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 1, child: _buildAwards(employee)),
            const SizedBox(width: 2),
            Expanded(flex: 1, child: _buildPunishments(employee)),
            const SizedBox(width: 2),
            Expanded(flex: 2, child: _buildRemarksAndOther(employee)),
          ]),
          const SizedBox(height: 2),
          _buildPreviousPostings(profile, employee), const SizedBox(height: 2),
          _buildTransfers(profile), const SizedBox(height: 2),
          // HOB takes full width so description text doesn't wrap
          _buildHob(profile), const SizedBox(height: 2),
          _buildSalary(profile),
        ]);
      }
      return Column(children: [
        _buildPersonalDetails(employee, profile),
        const SizedBox(height: 2),
        _buildAwards(employee),
        const SizedBox(height: 2),
        _buildPunishments(employee),
        const SizedBox(height: 2),
        _buildRemarksAndOther(employee),
        const SizedBox(height: 2),
        _buildPreviousPostings(profile, employee),
        const SizedBox(height: 2),
        _buildTransfers(profile),
        const SizedBox(height: 2),
        _buildHob(profile),
        const SizedBox(height: 2),
        _buildSalary(profile),
      ]);
    });
  }

  Widget _buildPersonalDetails(Employee employee, EmployeeProfile? profile) {
    // Personal + Service details are shown together under a single
    // "व्यक्तिगत विवरण" heading (service fields merged in). Empty values
    // are kept so the card can render its "उपलब्ध नहीं" placeholder.
    final fields = <(String, String)>[
      ('EHRMS', employee.ehrms),
      ('पिता का नाम', employee.fatherName),
      ('नामिनी', employee.nomineeName),
      ('जन्मतिथि', employee.dob),
      ('भर्ती तिथि', employee.recruitmentDate),
      ('जाति', employee.caste),
      ('उपजाति', employee.subCaste),
      ('गृह जनपद', employee.homeDistrict),
      ('पता', employee.address),
      ('योग्यता', employee.qualification),
      ('मोबाइल', employee.mobile),
      ('मु0आ0 पदोन्नति', employee.promotion),
      ('जनपद में नियुक्ति', employee.districtPosting),
    ];
    if (profile != null && profile.relations.isNotEmpty) {
      for (final r in profile.relations) {
        final label = r.relationType.isEmpty ? 'सम्बन्ध' : r.relationType;
        final value = r.contact.isEmpty ? r.name : '${r.name} (${r.contact})';
        if (value.isNotEmpty) fields.add((label, value));
      }
    }
    if (fields.isEmpty) return const SizedBox.shrink();
    return SectionCard(
        title: 'व्यक्तिगत विवरण',
        icon: Icons.person_rounded,
        color: AppTheme.secondaryColor,
        child: LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
          int cross = 1;
          if (w > 1000) {
            cross = 5; // desktop: 5 per row
          } else if (w > 680) {
            cross = 3; // tablet: 3 per row
          } else if (w > 420) {
            cross = 2; // mobile: 2 per row
          }
      const spacing = 10.0;
      final cardWidth = (w - (cross - 1) * spacing) / cross;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (int i = 0; i < fields.length; i++)
            SizedBox(
              width: cardWidth,
              child: FieldTile(
                label: fields[i].$1,
                value: fields[i].$2,
              ),
            ),
        ],
      );
    }));
  }

  Widget _buildAwards(Employee employee) {
    final awards = <(String, String, IconData, Color)>[
      (
        'गुड एन्ट्री',
        employee.goodEntry,
        Icons.star_rounded,
        AppTheme.warningColor
      ),
      (
        'नगद पुरूष्कार',
        employee.cashReward,
        Icons.card_giftcard_rounded,
        AppTheme.successColor
      ),
      ('पदक', employee.medal, Icons.emoji_events_rounded, AppTheme.accentGold),
      (
        'सत्यनिष्ठा',
        employee.integrity,
        Icons.verified_user_rounded,
        AppTheme.infoColor
      ),
      (
        'अन्य विवरण',
        employee.otherDetails,
        Icons.description_rounded,
        AppTheme.textSecondary
      ),
    ].where((e) => e.$2.isNotEmpty).toList();
    return DashboardAwardsCard(
      awards: awards
          .map((a) => (label: a.$1, value: a.$2, icon: a.$3, color: a.$4))
          .toList(),
    );
  }

  Widget _buildPunishments(Employee employee) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardPunishmentCard(
              title: 'लघु दण्ड',
              icon: Icons.gavel_rounded,
              color: AppTheme.errorColor,
              content: employee.minorPunishment),
          const SizedBox(height: 8),
          DashboardPunishmentCard(
              title: 'क्षुद्र दण्ड',
              icon: Icons.block_rounded,
              color: AppTheme.errorColor,
              content: employee.majorPunishment),
        ]);
  }

  Widget _buildRemarksAndOther(Employee employee) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardRemarksTimeline(content: employee.remark),
          const SizedBox(height: 8),
          DashboardOtherDetailsCard(content: employee.otherDetails),
        ]);
  }

  static DateTime? _parseDate(String s) {
    final t = s.trim();
    if (t.isEmpty) return null;
    final lower = t.toLowerCase();
    if (lower == 'वर्तमान' ||
        lower == 'से लगातार' ||
        lower == 'current' ||
        lower == 'present') return DateTime.now();
    final parts = t.split(RegExp(r'[/\-.]'));
    if (parts.length == 3) {
      try {
        return DateTime(
            int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      } catch (_) {}
    }
    return null;
  }

  static String _computeDuration(String fromRaw, String toRaw) {
    final from = _parseDate(fromRaw);
    if (from == null) return '';
    final to = _parseDate(toRaw) ?? DateTime.now();
    if (to.isBefore(from)) return '';
    int years = to.year - from.year;
    int months = to.month - from.month;
    int days = to.day - from.day;
    if (days < 0) {
      months--;
      final prevMonth = DateTime(to.year, to.month, 0);
      days += prevMonth.day;
    }
    if (months < 0) {
      years--;
      months += 12;
    }
    final parts = <String>[];
    if (years > 0) parts.add('$years वर्ष');
    if (months > 0) parts.add('$months माह');
    if (days > 0 && years == 0 && months == 0) parts.add('$days दिन');
    return parts.isEmpty ? '0 दिन' : parts.join(' ');
  }

  Widget _buildPreviousPostings(EmployeeProfile? profile, Employee employee) {
    List<PreviousPosting> postings = profile?.previousPostings ?? const [];
    final hasAnyDate =
        postings.any((p) => p.fromDateRaw.isNotEmpty || p.toDateRaw.isNotEmpty);
    if (postings.isEmpty || !hasAnyDate) {
      final locLines = employee.previousPostings
          .split(RegExp(r'\r?\n'))
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim())
          .toList();
      final fromLines = employee.fromDate
          .split(RegExp(r'\r?\n'))
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim())
          .toList();
      final toLines = employee.toDate
          .split(RegExp(r'\r?\n'))
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim())
          .toList();
      if (locLines.isNotEmpty || fromLines.isNotEmpty || toLines.isNotEmpty) {
        final count = [locLines.length, fromLines.length, toLines.length]
            .reduce((a, b) => a > b ? a : b);
        postings = List.generate(
            count,
            (i) => PreviousPosting(
                pno: employee.pno,
                location: i < locLines.length ? locLines[i] : '',
                fromDateRaw: i < fromLines.length ? fromLines[i] : '',
                toDateRaw: i < toLines.length ? toLines[i] : ''));
      }
    }
    if (postings.isEmpty) {
      return const SectionCard(
          title: 'पूर्व नियुक्तियाँ',
          icon: Icons.history_rounded,
          color: AppTheme.warningColor,
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Center(
                  child: Text('कोई पूर्व नियुक्ति रिकॉर्ड नहीं',
                      style:
                          TextStyle(color: AppTheme.textHint, fontSize: 12)))));
    }
    return SectionCard(
        title: 'पूर्व नियुक्तियाँ',
        icon: Icons.history_rounded,
        color: AppTheme.warningColor,
        child: UPDataTable(
            headers: const ['तैनाती', 'कब से', 'कब तक', 'अवधि'],
            rows: postings.map((p) {
              final toDisplay = (p.toDateRaw.isEmpty || p.isPresent)
                  ? 'वर्तमान'
                  : p.toDateRaw;
              final avadhi = _computeDuration(
                  p.fromDateRaw, toDisplay == 'वर्तमान' ? '' : p.toDateRaw);
              return [
                p.location,
                p.fromDateRaw.isEmpty ? '-' : p.fromDateRaw,
                toDisplay,
                avadhi.isEmpty ? '-' : avadhi
              ];
            }).toList(),
            columnWidths: const [2.2, 1.3, 1.3, 1.4],
            columnAlignments: const [
              TextAlign.left,
              TextAlign.center,
              TextAlign.center,
              TextAlign.center
            ]));
  }

  Widget _buildTransfers(EmployeeProfile? profile) {
    final transfers = profile?.transfers ?? const [];
    if (transfers.isEmpty) {
      return const SectionCard(
          title: 'स्थानांतरण विवरण',
          icon: Icons.transfer_within_a_station_rounded,
          color: AppTheme.warningColor,
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Center(
                  child: Text('कोई स्थानांतरण रिकॉर्ड नहीं',
                      style:
                          TextStyle(color: AppTheme.textHint, fontSize: 12)))));
    }
    return SectionCard(
        title: 'स्थानांतरण विवरण',
        icon: Icons.transfer_within_a_station_rounded,
        color: AppTheme.warningColor,
        child: UPDataTable(
            headers: const [
              'आगमन/प्रस्थान',
              'कहाँ से',
              'कहाँ को',
              'आदेश संख्या',
              'पत्रावली संख्या',
              'अन्य विवरण'
            ],
            rows: transfers
                .map((t) => [
                      t.directionLabel,
                      t.fromLocation,
                      t.toLocation,
                      t.orderNumber,
                      t.fileNumber,
                      t.otherDetails
                    ])
                .toList(),
            columnWidths: const [1.0, 1.3, 1.3, 1.8, 1.6, 1.8],
            columnAlignments: const [
              TextAlign.center,
              TextAlign.left,
              TextAlign.left,
              TextAlign.left,
              TextAlign.left,
              TextAlign.left
            ]));
  }

  Widget _buildHob(EmployeeProfile? profile) {
    final hob = profile?.allHob ?? const [];
    if (hob.isEmpty) {
      return const SectionCard(
          title: 'HOB रिकॉर्ड',
          icon: Icons.book_rounded,
          color: AppTheme.successColor,
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Center(
                  child: Text('कोई HOB रिकॉर्ड नहीं',
                      style:
                          TextStyle(color: AppTheme.textHint, fontSize: 12)))));
    }
    // HOB table — 3 columns (अन्य विवरण removed per user request):
    //   HOB Number | Date | Description
    // Long text wraps freely; table fits screen width via FlexColumnWidth.
    return SectionCard(
        title: 'HOB रिकॉर्ड (${hob.length})',
        icon: Icons.book_rounded,
        color: AppTheme.successColor,
        child: UPDataTable(
          headers: const ['HOB #', 'दिनांक', 'विवरण'],
          rows: hob.map((h) => [h.hobNumber, h.date, h.description]).toList(),
          columnWidths: const [1.0, 1.4, 6.0],
          columnAlignments: const [
            TextAlign.center,
            TextAlign.center,
            TextAlign.left
          ],
        ));
  }

  Widget _buildSalary(EmployeeProfile? profile) {
    final pay = profile?.basicPay ?? const [];
    if (pay.isEmpty) {
      return const SectionCard(
          title: 'वेतन विवरण',
          icon: Icons.currency_rupee_rounded,
          color: AppTheme.warningColor,
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Center(
                  child: Text('वेतन रिकॉर्ड अनुपलब्ध',
                      style:
                          TextStyle(color: AppTheme.textHint, fontSize: 12)))));
    }
    return SectionCard(
        title: 'वेतन विवरण (${pay.length})',
        icon: Icons.currency_rupee_rounded,
        color: AppTheme.warningColor,
        child: UPDataTable(
            headers: const ['माह', 'मूल वेतन'],
            rows: pay
                .where(
                    (p) => p.incrementMonth.isNotEmpty || p.basicPay.isNotEmpty)
                .map((p) => [
                      p.incrementMonth.isEmpty ? '-' : p.incrementMonth,
                      p.basicPay.isEmpty ? '-' : p.basicPay
                    ])
                .toList(),
            columnWidths: const [1.0, 1.6],
            columnAlignments: const [TextAlign.center, TextAlign.right],
            cellPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5)));
  }
}

class _PrintButton extends StatelessWidget {
  final Employee employee;
  const _PrintButton({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Consumer<EmployeeProvider>(builder: (context, provider, _) {
      return ElevatedButton.icon(
        onPressed: () async {
          final profile = provider.selectedProfile;
          await PrintHelper.printProfile(employee: employee, profile: profile);
        },
        icon: const Icon(Icons.print_rounded, size: 16),
        label: const Text('प्रिंट'),
        style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            minimumSize: const Size(0, 28)),
      );
    });
  }
}

class _NewEmployeeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        await EmployeeEditDialog.showNew(context);
      },
      icon: const Icon(Icons.person_add_rounded, size: 16),
      label: const Text('नया कर्मचारी'),
      style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.successColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          minimumSize: const Size(0, 28)),
    );
  }
}

class _EditButton extends StatelessWidget {
  final Employee employee;
  const _EditButton({required this.employee});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        await EmployeeEditDialog.showEdit(context, employee);
      },
      icon: const Icon(Icons.edit_rounded, size: 16),
      label: const Text('संपादित करें'),
      style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.warningColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          minimumSize: const Size(0, 28)),
    );
  }
}
