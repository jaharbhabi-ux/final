import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';

/// Quick Entry Dialog — PNO type karo, employee data aaye,
/// phir HOB ya Basic Pay entry karo with date-based auto-routing.
class QuickEntryDialog extends StatefulWidget {
  const QuickEntryDialog({super.key});

  /// Static method to show the dialog.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const QuickEntryDialog(),
    );
    return result ?? false;
  }

  @override
  State<QuickEntryDialog> createState() => _QuickEntryDialogState();
}

class _QuickEntryDialogState extends State<QuickEntryDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _pnoController = TextEditingController();
  final TextEditingController _hobNumberController = TextEditingController();
  final TextEditingController _hobDateController = TextEditingController();
  final TextEditingController _hobDescController = TextEditingController();
  final TextEditingController _payMonthController = TextEditingController();
  final TextEditingController _payAmountController = TextEditingController();
  final TextEditingController _hobOtherController = TextEditingController();

  Employee? _foundEmployee;
  bool _isSearching = false;
  bool _isSubmitting = false;
  String? _submitMessage;
  bool _submitSuccess = false;

  final GasWriteService _writeService = GasWriteService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pnoController.addListener(_onPnoChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pnoController.removeListener(_onPnoChanged);
    _pnoController.dispose();
    _hobNumberController.dispose();
    _hobDateController.dispose();
    _hobDescController.dispose();
    _payMonthController.dispose();
    _payAmountController.dispose();
    _hobOtherController.dispose();

    super.dispose();
  }

  void _onPnoChanged() {
    final text = _pnoController.text.trim();
    if (text.length >= 3) {
      _searchEmployee(text);
    } else {
      if (mounted) {
        setState(() {
          _foundEmployee = null;
          _isSearching = false;
        });
      }
    }
  }

  void _searchEmployee(String pno) {
    setState(() => _isSearching = true);

    // Use the provider to find employee by PNO
    final provider = context.read<EmployeeProvider>();
    final all = provider.getAllEmployees();
    final cleanPno = pno.replaceAll(RegExp(r'\s+'), '').replaceAll('.0', '').toLowerCase();

    final found = all.where((e) {
      final epno = e.pno.replaceAll(RegExp(r'\s+'), '').replaceAll('.0', '').toLowerCase();
      return epno.contains(cleanPno);
    }).toList();

    if (mounted) {
      setState(() {
        _isSearching = false;
        _foundEmployee = found.isNotEmpty ? found.first : null;
      });
    }
  }

  Future<void> _submitHob() async {
    if (_foundEmployee == null) return;
    if (_hobNumberController.text.trim().isEmpty ||
        _hobDateController.text.trim().isEmpty) return;

    setState(() {
      _isSubmitting = true;
      _submitMessage = null;
    });

    final success = await _writeService.addHobEntry(
      pno: _foundEmployee!.pno,
      hobNumber: _hobNumberController.text.trim(),
      date: _hobDateController.text.trim(),
      description: _hobDescController.text.trim(),
      badge: _foundEmployee!.badgeNumber,
      post: _foundEmployee!.post,
      name: _foundEmployee!.name,
      otherDetails: _hobOtherController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _submitSuccess = success;
        _submitMessage = success
            ? 'HOB एंट्री सफलतापूर्वक जोड़ी गई'
            : 'एंट्री में त्रुटि — GAS URL या टोकन जाँचें';
      });

      if (success) {
        // Clear form after 1.5 seconds
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            _hobNumberController.clear();
            _hobDateController.clear();
            _hobDescController.clear();
            _hobOtherController.clear();
            setState(() => _submitMessage = null);
            // Refresh data to show new entry
            context.read<EmployeeProvider>().refreshInBackground();
          }
        });
      }
    }
  }

  Future<void> _submitBasicPay() async {
    if (_foundEmployee == null) return;
    if (_payMonthController.text.trim().isEmpty ||
        _payAmountController.text.trim().isEmpty) return;

    setState(() {
      _isSubmitting = true;
      _submitMessage = null;
    });

    final success = await _writeService.addBasicPayEntry(
      pno: _foundEmployee!.pno,
      incrementMonth: _payMonthController.text.trim(),
      basicPay: _payAmountController.text.trim(),
      badge: _foundEmployee!.badgeNumber,
      post: _foundEmployee!.post,
      name: _foundEmployee!.name,
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _submitSuccess = success;
        _submitMessage = success
            ? 'मूल वेतन एंट्री सफलतापूर्वक जोड़ी गई'
            : 'एंट्री में त्रुटि — GAS URL या टोकन जाँचें';
      });

      if (success) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            _payMonthController.clear();
            _payAmountController.clear();
            setState(() => _submitMessage = null);
            context.read<EmployeeProvider>().refreshInBackground();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width > 600 ? 80 : 16,
        vertical: 24,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              decoration: const BoxDecoration(
                gradient: AppTheme.headerGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit_note_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'त्वरित एंट्री',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.arrow_back_rounded, size: 14, color: Colors.white),
                              SizedBox(width: 3),
                              Text('वापस', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => Navigator.pop(context, false),
                        child: const Icon(Icons.close, color: Colors.white70, size: 20),
                      ),
                    ],
                  )
                ],
              ),
            ),

            // PNO Search
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PNO टाइप करें (कर्मचारी खोजें)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _pnoController,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'PNO यहाँ टाइप करें...',
                      prefixIcon: const Icon(Icons.badge_rounded, size: 18),
                      suffixIcon: _isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  if (_foundEmployee != null)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                _foundEmployee!.name.isNotEmpty
                                    ? _foundEmployee!.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _foundEmployee!.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'PNO: ${_foundEmployee!.pno}  •  ${_foundEmployee!.post}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.check_circle, color: AppTheme.successColor, size: 18),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.textSecondary,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'HOB एंट्री'),
                  Tab(text: 'मूल वेतन एंट्री'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHobForm(),
                  _buildBasicPayForm(),
                ],
              ),
            ),

            // Submit message
            if (_submitMessage != null)
              Container(
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _submitSuccess
                      ? AppTheme.successColor.withOpacity(0.1)
                      : AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      _submitSuccess ? Icons.check_circle : Icons.error,
                      size: 16,
                      color: _submitSuccess ? AppTheme.successColor : AppTheme.errorColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _submitMessage!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _submitSuccess ? AppTheme.successColor : AppTheme.errorColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHobForm() {
    final enabled = _foundEmployee != null && !_isSubmitting;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
      child: Column(
        children: [
          _field('HOB संख्या', 'जैसे: 01, 02...', _hobNumberController, enabled),
          const SizedBox(height: 8),
          _field('दिनांक', 'DD/MM/YYYY (साल से 2025/2026 में जाएगा)', _hobDateController, enabled),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'दिनांक 2025 ka hai to HOB 2025 sheet mein, 2026 ka hai to HOB 2026 mein',
                style: TextStyle(fontSize: 9, color: AppTheme.textHint),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _field('विवरण', 'HOB का विवरण लिखें...', _hobDescController, enabled,
              maxLines: 3),
          const SizedBox(height: 8),
          _field(
              'अन्य विवरण', 'अन्य विवरण लिखें (वैकल्पिक)...',
              _hobOtherController, enabled,
              maxLines: 2),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: enabled ? _submitHob : null,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded, size: 16),
              label: Text(_isSubmitting ? 'जोड़ रहा है...' : 'HOB एंट्री जोड़ें'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicPayForm() {
    final enabled = _foundEmployee != null && !_isSubmitting;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
      child: Column(
        children: [
          _field('वार्षिक वेतन वृद्धि माह', 'जैसे: जनवरी 2025, जुलाई 2025', _payMonthController, enabled),
          const SizedBox(height: 8),
          _field('मूल वेतन', 'राशि लिखें...', _payAmountController, enabled,
              keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: enabled ? _submitBasicPay : null,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded, size: 16),
              label: Text(_isSubmitting ? 'जोड़ रहा है...' : 'मूल वेतन एंट्री जोड़ें'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    String hint,
    TextEditingController controller,
    bool enabled, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 11, color: AppTheme.textHint.withOpacity(0.8)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          ),
        ),
      ],
    );
  }
}