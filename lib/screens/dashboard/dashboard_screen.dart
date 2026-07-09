import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../widgets/up_police_badge.dart';
import '../../widgets/common/up_loading_card.dart';
import '../../widgets/dashboard/up_stat_card.dart';
import '../../widgets/dashboard/up_employee_card.dart';
import '../profile/profile_screen.dart';
import '../transfer_classification_page.dart';

/// Dashboard - landing screen.
///
/// Performance: uses [Selector] for fine-grained rebuilds. Each stat
/// card rebuilds only when its specific count changes. The search bar
/// rebuilds only when the query string changes.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<EmployeeProvider>().searchEmployee('');
    _searchFocusNode.unfocus();
  }

  void _openProfile(Employee employee) {
    final provider = context.read<EmployeeProvider>();
    provider.selectEmployee(employee).then((_) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
      }
    });
  }

  String _prefixFor(String category) {
    // These prefixes MUST match the ones used by
    // EmployeeRepository.getStarCategory() so that the Aagman/Prasthan
    // order-number filter (`startsWith(prefix)`) returns the right rows.
    switch (category) {
      case 'DG':
        return 'डीजी-'; // DG HQ
      case 'BJD':
        return 'बीजैड-'; // BJD Zone
      case 'BR':
        return 'बीआर-'; // BR Range
      default:
        return ''; // empty prefix → no records, harmless
    }
  }

  /// Returns only valid employees - filters out blank/invalid records.
  static List<Employee> _validEmployees(List<Employee> list) {
    return list.where((e) => e.pno.trim().isNotEmpty && e.name.trim().isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Selector<EmployeeProvider, ({bool isLoading, bool isInitialLoadDone, String error})>(
          selector: (_, p) => (
            isLoading: p.isLoading,
            isInitialLoadDone: p.isInitialLoadDone,
            error: p.error,
          ),
          builder: (context, state, _) {
            if (!state.isInitialLoadDone) {
              return _buildInitialLoading(state.error);
            }
            return RefreshIndicator(
              onRefresh: () => context.read<EmployeeProvider>().refreshInBackground(),
              color: AppTheme.primaryColor,
              backgroundColor: AppTheme.cardColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 20 : 8,
                  vertical: 0,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 10),
                      _buildSearchBar(),
                      const SizedBox(height: 8),
                      // Search results — shown right below search bar
                      Selector<EmployeeProvider, String>(
                        selector: (_, p) => p.searchQuery,
                        builder: (context, query, _) {
                          if (query.isNotEmpty) {
                            return Column(
                              children: [
                                _buildSearchResults(isDesktop, isTablet),
                                const SizedBox(height: 10),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      _buildStatsRow(),
                      const SizedBox(height: 10),
                      _buildTransferCategories(),
                      const SizedBox(height: 10),
                      if (state.isLoading)
                        const Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: _InlineLoaderChip(),
                          ),
                        ),
                      // NOTE: Search results are rendered exactly ONCE —
                      // directly below the search bar (see _buildSearchBar
                      // + the `Selector<EmployeeProvider, String>` block
                      // above). Do NOT add a second `_buildSearchResults`
                      // call here; that would duplicate every result row.
                      const SizedBox(height: 12),
                      _buildBranding(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── HEADER ────────────────────────────────────────────────────
Widget _buildHeader() {
  return Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const UPPoliceBadge(size: 42),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'उत्तर प्रदेश पुलिस',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                height: 1.2,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              'प्रधान लिपिक शाखा जनपद बरेली',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.accentGold,
                height: 1.2,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  // ─── SEARCH BAR ────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return AppTheme.glassContainer(
      borderRadius: 12,
      bgColor: Colors.white,
      child: SizedBox(
        height: 46,
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search_rounded,
                color: AppTheme.secondaryColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  hintText: 'PNO, बैज नं0 या नाम दर्ज करें (Enter दबाएँ)',
                  hintStyle: TextStyle(
                    color: AppTheme.textHint,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                  filled: false,
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (q) {
                  final trimmed = q.trim();
                  if (trimmed.isEmpty) {
                    _clearSearch();
                    return;
                  }
                  // Smart search: pure digits ? route by length
                  if (RegExp(r'^\d+$').hasMatch(trimmed)) {
                    if (trimmed.length > 5) {
                      context.read<EmployeeProvider>().searchEmployeeByField(trimmed, 'pno');
                    } else {
                      context.read<EmployeeProvider>().searchEmployeeByField(trimmed, 'badge');
                    }
                  } else {
                    context.read<EmployeeProvider>().searchEmployee(trimmed);
                  }
                },
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, value, _) {
                if (value.text.isEmpty) return const SizedBox(width: 4);
                return GestureDetector(
                  onTap: _clearSearch,
                  child: Container(
                    margin: const EdgeInsets.only(right: 4),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppTheme.borderColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: AppTheme.textHint, size: 16),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── STAT CARDS ────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossCount = width > 1100
            ? 7
            : width > 850
                ? 6
                : width > 650
                    ? 5
                    : width > 480
                        ? 4
                        : width > 360
                            ? 3
                            : 2;
        final cardWidth = (width - (crossCount - 1) * 6) / crossCount;
        final cards = <Widget>[
          Selector<EmployeeProvider, int>(
            selector: (_, p) => p.totalEmployees,
            builder: (_, v, __) => UPStatCard(
              label: 'कुल कर्मचारी',
              value: '$v',
              icon: Icons.people_outline,
              color: AppTheme.secondaryColor,
            ),
          ),
          Selector<EmployeeProvider, int>(
            selector: (_, p) => p.activeEmployees,
            builder: (_, v, __) => UPStatCard(
              label: 'सक्रिय',
              value: '$v',
              icon: Icons.check_circle_outline,
              color: AppTheme.successColor,
            ),
          ),
          Selector<EmployeeProvider, int>(
            selector: (_, p) => p.inactiveEmployees,
            builder: (_, v, __) => UPStatCard(
              label: 'निष्क्रिय',
              value: '$v',
              icon: Icons.person_off_outlined,
              color: AppTheme.textHint,
            ),
          ),
          Selector<EmployeeProvider, int>(
            selector: (_, p) => p.hccpCount,
            builder: (_, v, __) => UPStatCard(
              label: 'मुख्य आरक्षी नागरिक पुलिस',
              value: '$v',
              icon: Icons.security_outlined,
              color: AppTheme.successColor,
            ),
          ),
          Selector<EmployeeProvider, int>(
            selector: (_, p) => p.lhccpCount,
            builder: (_, v, __) => UPStatCard(
              label: 'महिला मुख्य आरक्षी नागरिक पुलिस',
              value: '$v',
              icon: Icons.female_outlined,
              color: AppTheme.errorColor,
            ),
          ),
          Selector<EmployeeProvider, int>(
            selector: (_, p) => p.aagmanCount,
            builder: (_, v, __) => UPStatCard(
              label: 'आगमन',
              value: '$v',
              icon: Icons.login_outlined,
              color: AppTheme.infoColor,
            ),
          ),
          Selector<EmployeeProvider, int>(
            selector: (_, p) => p.prasthanCount,
            builder: (_, v, __) => UPStatCard(
              label: 'प्रस्थान',
              value: '$v',
              icon: Icons.logout_outlined,
              color: AppTheme.warningColor,
            ),
          ),
        ];
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: cards.map((c) => SizedBox(width: cardWidth, child: c)).toList(),
        );
      },
    );
  }

  // ─── TRANSFER CATEGORIES ───────────────────────────────────────
  Widget _buildTransferCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 4),
          child: Text(
            'आगमन / प्रस्थान वर्गीकरण',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTransferGroup(
              isAagman: true,
              color: AppTheme.infoColor,
              title: 'आगमन',
            ),
            const SizedBox(width: 8),
            _buildTransferGroup(
              isAagman: false,
              color: AppTheme.warningColor,
              title: 'प्रस्थान',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransferGroup({
    required bool isAagman,
    required Color color,
    required String title,
  }) {
    const categories = [
      ('मुख्यालय', 'DG'),
      ('ज़ोन', 'BJD'),
      ('परिक्षेत्र', 'BR'),
    ];
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.35), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                for (int i = 0; i < categories.length; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  _transferButton(
                    categories[i].$1,
                    categories[i].$2,
                    isAagman,
                    color,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _transferButton(String label, String category, bool isAagman, Color color) {
    return Expanded(
      child: Selector<EmployeeProvider, int>(
        selector: (_, p) {
          if (isAagman) {
            switch (category) {
              case 'DG': return p.aagmanDgCount;
              case 'BJD': return p.aagmanBjdCount;
              case 'BR': return p.aagmanBrCount;
              default: return 0;
            }
          } else {
            switch (category) {
              case 'DG': return p.prasthanDgCount;
              case 'BJD': return p.prasthanBjdCount;
              case 'BR': return p.prasthanBrCount;
              default: return 0;
            }
          }
        },
        builder: (context, count, _) {
          return AppTheme.glassContainer(
            borderRadius: 10,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            child: InkWell(
              onTap: () {
                final prefix = _prefixFor(category);
                if (prefix.isEmpty) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TransferClassificationPage(
                      title: '${isAagman ? 'आगमन' : 'प्रस्थान'} - $label',
                      isAagman: isAagman,
                      prefix: prefix,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(8),
              hoverColor: color.withOpacity(0.05),
              splashColor: color.withOpacity(0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: color,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── SEARCH RESULTS ────────────────────────────────────────────
  Widget _buildSearchResults(bool isDesktop, bool isTablet) {
    return Selector<EmployeeProvider, ({List<Employee> results, int count})>(
      selector: (_, p) => (results: p.filteredResults, count: p.filteredResults.length),
      builder: (context, data, _) {
        final valid = _validEmployees(data.results);
        if (valid.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  AppTheme.glassContainer(
                    borderRadius: 14,
                    padding: const EdgeInsets.all(12),
                    child: Icon(Icons.search_off_rounded,
                        size: 28,
                        color: AppTheme.errorColor.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'कोई कर्मचारी नहीं मिला',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'अन्य नाम या PNO से खोजें',
                    style: TextStyle(fontSize: 12, color: AppTheme.textHint),
                  ),
                ],
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text(
                '${valid.length} परिणाम मिले',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildEmployeeGrid(valid, isDesktop, isTablet, search: true),
          ],
        );
      },
    );
  }

  Widget _buildEmployeeGrid(List<Employee> employees, bool isDesktop, bool isTablet, {bool search = false}) {
    final crossAxisCount = search
        ? (isDesktop ? 6 : (isTablet ? 4 : 3))
        : (isDesktop ? 11 : (isTablet ? 8 : 5));
    final childAspectRatio = search
        ? (isDesktop ? 2.0 : (isTablet ? 1.9 : 1.15))
        : (isDesktop ? 2.5 : (isTablet ? 2.05 : 1.85));
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: employees.length,
      itemBuilder: (context, index) => UPEmployeeCard(
        employee: employees[index],
        onTap: () => _openProfile(employees[index]),
        allowWrap: search,
      ),
    );
  }

  // ─── BRANDING ──────────────────────────────────────────────────
  Widget _buildBranding() {
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
            // Line 1 — king's sign + name (signature style)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium_rounded,
                    size: 16, color: AppTheme.accentGold),
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
  // ─── INITIAL LOADING ──────────────────────────────────────────
  Widget _buildInitialLoading(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const UPLoadingCard(size: 36),
          if (error.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.errorColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    error,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.errorColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context
                          .read<EmployeeProvider>()
                          .loadAllData(forceRefresh: true),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('कोई परिणाम नहीं मिला'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

}
class _InlineLoaderChip extends StatelessWidget {
  const _InlineLoaderChip();

  @override
  Widget build(BuildContext context) {
    return AppTheme.glassContainer(
      borderRadius: 8,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
          SizedBox(width: 6),
          Text(
            'पृष्ठभूमि में डेटा लोड हो रहा है...',
            style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}