import 'package:flutter/material.dart';
import '../../core/models/previous_posting.dart';
import '../../core/theme/app_theme.dart';

/// Redesigned Previous Postings table.
///
/// Features:
///   • Serial number column
///   • Blue gradient header
///   • Zebra rows (white / light-blue-tint alternating)
///   • Duration rendered as a blue chip
///   • Current posting ("वर्तमान") shown as a green badge chip
///   • Responsive: table on wide screens, cards on narrow (< 500 px)
///   • Illustrated empty state when no postings exist
///
/// No model / API / logic changes — only UI. Callers pass the already-resolved
/// [postings] list and the same [computeDuration] helper used before.
class PreviousPostingsTable extends StatelessWidget {
  final List<PreviousPosting> postings;

  /// Same pure function used by the parent screen — receives (fromRaw, toRaw)
  /// and returns a human-readable duration string.
  final String Function(String fromRaw, String toRaw) computeDuration;

  const PreviousPostingsTable({
    super.key,
    required this.postings,
    required this.computeDuration,
  });

  // ── Colours ─────────────────────────────────────────────────────────────
  static const Color _oddRow   = Color(0xFFF0F5FF); // light blue-tint zebra
  static const Color _evenRow  = Colors.white;
  static const Color _green    = Color(0xFF059669);
  static const Color _greenBg  = Color(0xFFD1FAE5);
  static const Color _greenBorder = Color(0xFF6EE7B7);

  @override
  Widget build(BuildContext context) {
    if (postings.isEmpty) return _emptyState();
    return LayoutBuilder(
      builder: (_, constraints) => constraints.maxWidth < 500
          ? _cardList()
          : _table(),
    );
  }

  // ── Empty state ──────────────────────────────────────────────────────────
  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_rounded,
              size: 36, color: AppTheme.textHint.withOpacity(0.45)),
          const SizedBox(height: 8),
          const Text(
            'कोई पूर्व नियुक्ति रिकॉर्ड नहीं',
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
          0: FixedColumnWidth(34),   // क्र.
          1: FlexColumnWidth(2.4),   // तैनाती
          2: FlexColumnWidth(1.25),  // कब से
          3: FlexColumnWidth(1.4),   // कब तक
          4: FlexColumnWidth(1.5),   // अवधि
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
          for (int i = 0; i < postings.length; i++)
            _dataRow(i, postings[i]),
        ],
      ),
    );
  }

  TableRow _headerRow() {
    const labels  = ['क्र.', 'तैनाती', 'कब से', 'कब तक', 'अवधि'];
    const aligns  = [
      TextAlign.center,
      TextAlign.left,
      TextAlign.center,
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

  TableRow _dataRow(int index, PreviousPosting p) {
    final avadhi   = computeDuration(p.fromDateRaw, p.isPresent ? '' : p.toDateRaw);
    final toText   = (p.toDateRaw.isEmpty || p.isPresent) ? 'वर्तमान' : p.toDateRaw;
    final rowColor = index.isEven ? _evenRow : _oddRow;

    return TableRow(
      decoration: BoxDecoration(color: rowColor),
      children: [
        // ① Serial
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Text(
            '${index + 1}',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary),
          ),
        ),

        // ② Location (selectable)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: SelectableText(
            p.location.isEmpty ? '-' : p.location,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
                height: 1.35),
          ),
        ),

        // ③ From date
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Text(
            p.fromDateRaw.isEmpty ? '-' : p.fromDateRaw,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
                height: 1.3),
          ),
        ),

        // ④ To date — green badge if current posting
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: p.isPresent
              ? Center(child: _greenBadge('वर्तमान'))
              : Text(
                  toText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                      height: 1.3),
                ),
        ),

        // ⑤ Duration chip
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: avadhi.isEmpty
              ? const Text('-',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppTheme.textHint))
              : Center(child: _durationChip(avadhi)),
        ),
      ],
    );
  }

  // ── Narrow card layout ───────────────────────────────────────────────────
  Widget _cardList() {
    return Column(
      children: [
        for (int i = 0; i < postings.length; i++) _card(i, postings[i]),
      ],
    );
  }

  Widget _card(int index, PreviousPosting p) {
    final avadhi   = computeDuration(p.fromDateRaw, p.isPresent ? '' : p.toDateRaw);
    final rowColor = index.isEven ? _evenRow : _oddRow;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
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
                  p.location.isEmpty ? '-' : p.location,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    // From date — always shown, '-' when empty
                    _infoLabel(
                      p.fromDateRaw.isEmpty
                          ? 'कब से: -'
                          : 'कब से: ${p.fromDateRaw}',
                    ),
                    // To date — green badge if present, label otherwise
                    if (p.isPresent)
                      _greenBadge('वर्तमान')
                    else
                      _infoLabel(
                        p.toDateRaw.isEmpty
                            ? 'कब तक: -'
                            : 'कब तक: ${p.toDateRaw}',
                      ),
                    // Duration chip — '-' chip when empty
                    avadhi.isEmpty
                        ? _infoLabel('अवधि: -')
                        : _durationChip(avadhi),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared chip / badge builders ─────────────────────────────────────────

  Widget _greenBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _greenBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _greenBorder, width: 0.8),
      ),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700, color: _green),
      ),
    );
  }

  Widget _durationChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.28), width: 0.8),
      ),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor),
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
            fontSize: 10,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500),
      ),
    );
  }
}
