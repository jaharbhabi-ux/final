import 'package:flutter/material.dart';
import '../../core/models/hob.dart';
import '../../core/theme/app_theme.dart';

/// HOB (Headquarters Order Book) table matching Previous Postings design.
///
/// Features:
///   • Blue gradient header
///   • Zebra rows (white / light blue-tint alternating)
///   • Responsive: table on wide screens, cards on narrow (< 480 px)
///   • Full width with auto column widths
///   • Compact rows
///   • Multiline, selectable description text
///   • Empty state with icon + message
///
/// No model / API / logic changes — only UI.
class HobTable extends StatelessWidget {
  final List<Hob> hob;

  const HobTable({super.key, required this.hob});

  static const Color _oddRow = Color(0xFFF0F5FF);
  static const Color _evenRow = Colors.white;

  @override
  Widget build(BuildContext context) {
    if (hob.isEmpty) return _emptyState();

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
          Icon(Icons.book_rounded,
              size: 32, color: AppTheme.textHint.withOpacity(0.45)),
          const SizedBox(height: 8),
          const Text(
            'कोई HOB रिकॉर्ड नहीं',
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
          0: FixedColumnWidth(50), // HOB #
          1: FixedColumnWidth(72), // दिनांक
          2: FlexColumnWidth(), // विवरण (auto / expands)
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
          for (int i = 0; i < hob.length; i++) _dataRow(i, hob[i]),
        ],
      ),
    );
  }

  TableRow _headerRow() {
    const labels = ['HOB #', 'दिनांक', 'विवरण'];
    const aligns = [
      TextAlign.center,
      TextAlign.center,
      TextAlign.left,
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

  TableRow _dataRow(int index, Hob h) {
    final rowColor = index.isEven ? _evenRow : _oddRow;
    return TableRow(
      decoration: BoxDecoration(color: rowColor),
      children: [
        // HOB #
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Text(
            h.hobNumber.isEmpty ? '-' : h.hobNumber,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary),
          ),
        ),
        // Date
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Text(
            h.date.isEmpty ? '-' : h.date,
            textAlign: TextAlign.center,
            softWrap: false,
            overflow: TextOverflow.visible,
            style: const TextStyle(
                fontSize: 12, color: AppTheme.textSecondary, height: 1.3),
          ),
        ),
        // Description — multiline + selectable
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: SelectableText(
            h.description.isEmpty ? '-' : h.description,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
                height: 1.35),
          ),
        ),
      ],
    );
  }

  // ── Narrow card layout ───────────────────────────────────────────────────
  Widget _cardList() {
    return Column(
      children: [
        for (int i = 0; i < hob.length; i++) _card(i, hob[i]),
      ],
    );
  }

  Widget _card(int index, Hob h) {
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
                SelectableText(
                  h.description.isEmpty ? '-' : h.description,
                   style: const TextStyle(
                       fontSize: 14,
                       fontWeight: FontWeight.w600,
                       color: AppTheme.textPrimary,
                       height: 1.35),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _infoLabel(
                        'HOB #: ${h.hobNumber.isEmpty ? '-' : h.hobNumber}'),
                    _infoLabel('दिनांक: ${h.date.isEmpty ? '-' : h.date}'),
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
