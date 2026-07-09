import 'package:flutter/material.dart';
import '../../core/models/basic_pay.dart';
import '../../core/theme/app_theme.dart';

/// Salary table matching Previous Postings design.
///
/// Features:
///   • Blue gradient header
///   • Zebra rows (white / light blue-tint alternating)
///   • Responsive: table on wide screens, cards on narrow (< 480 px)
///   • Full width with auto column widths
///   • Right-aligned salary column
///   • Compact rows
///   • Empty state with icon + message
///
/// No model / API / logic changes — only UI.
class SalaryTable extends StatelessWidget {
  final List<BasicPay> pay;

  const SalaryTable({super.key, required this.pay});

  static const Color _oddRow = Color(0xFFF0F5FF);
  static const Color _evenRow = Colors.white;

  @override
  Widget build(BuildContext context) {
    if (pay.isEmpty) return _emptyState();

    return LayoutBuilder(
      builder: (_, constraints) =>
          constraints.maxWidth < 480 ? _cardList() : _table(),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.currency_rupee_rounded,
              size: 32, color: AppTheme.textHint.withOpacity(0.45)),
          const SizedBox(height: 8),
          const Text(
            'कोई वेतन रिकॉर्ड नहीं',
            style: TextStyle(color: AppTheme.textHint, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── Wide table layout ────────────────────────────────────────────────────
  Widget _table() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.2), // माह
          1: FlexColumnWidth(1.0), // मूल वेतन
        },
        border: TableBorder(
          horizontalInside: BorderSide(
              color: AppTheme.borderColor.withOpacity(0.45), width: 0.5),
          verticalInside: BorderSide(
              color: AppTheme.borderColor.withOpacity(0.25), width: 0.5),
          bottom: BorderSide(
              color: AppTheme.borderColor.withOpacity(0.45), width: 0.5),
          left: BorderSide(
              color: AppTheme.borderColor.withOpacity(0.45), width: 0.5),
          right: BorderSide(
              color: AppTheme.borderColor.withOpacity(0.45), width: 0.5),
        ),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          _headerRow(),
          for (int i = 0; i < pay.length; i++) _dataRow(i, pay[i]),
        ],
      ),
    );
  }

  TableRow _headerRow() {
    const labels = ['माह', 'मूल वेतन'];
    const aligns = [
      TextAlign.center,
      TextAlign.center,
    ];
    return TableRow(
      decoration: const BoxDecoration(gradient: AppTheme.headerGradient),
      children: List.generate(labels.length, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: Text(
            labels[i],
            textAlign: aligns[i],
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        );
      }),
    );
  }

  TableRow _dataRow(int index, BasicPay p) {
    final rowColor = index.isEven ? _evenRow : _oddRow;
    return TableRow(
      decoration: BoxDecoration(color: rowColor),
      children: [
        // Month
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            p.incrementMonth.isEmpty ? '-' : p.incrementMonth,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
                height: 1.3),
          ),
        ),
        // Salary — right-aligned
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            p.basicPay.isEmpty ? '-' : p.basicPay,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                height: 1.3),
          ),
        ),
      ],
    );
  }

  // ── Narrow card layout ───────────────────────────────────────────────────
  Widget _cardList() {
    return Column(
      children: [
        for (int i = 0; i < pay.length; i++) _card(i, pay[i]),
      ],
    );
  }

  Widget _card(int index, BasicPay p) {
    final rowColor = index.isEven ? _evenRow : _oddRow;
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: rowColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular serial badge
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 10, top: 1),
            decoration: const BoxDecoration(
              gradient: AppTheme.headerGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.incrementMonth.isEmpty ? '-' : p.incrementMonth,
                   style: const TextStyle(
                       fontSize: 14,
                       fontWeight: FontWeight.w600,
                       color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _infoLabel(
                        'मूल वेतन: ${p.basicPay.isEmpty ? '-' : p.basicPay}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoLabel(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.borderColor.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500),
      ),
    );
  }
}
