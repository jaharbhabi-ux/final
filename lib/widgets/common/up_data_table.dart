import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Responsive data table with wrapping cells.
///
/// Behaviour rules (per audit):
///   • Long text WRAPS into multiple lines — it is never cut with `…`
///     or hard-clipped. This applies to both header and body cells.
///   • Column widths are proportional (`FlexColumnWidth`), so the table
///     always fits the available horizontal space — no horizontal
///     scrolling required, works on mobile / web / desktop.
///   • `columnMaxLines` (if provided) is treated as a SOFT hint — when
///     set, the cell will wrap up to that many lines before applying
///     ellipsis. When null/0, the cell wraps without limit.
class UPDataTable extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> rows;
  final List<double>? columnWidths;
  final List<int?>? columnMaxLines;
  final List<TextAlign>? columnAlignments;
  final Color headerColor;
  final Color evenRowColor;
  final Color oddRowColor;
  final EdgeInsets cellPadding;
  final TextStyle? headerStyle;
  final TextStyle? cellStyle;
  final int Function(List<String> a, List<String> b)? sortComparator;

  const UPDataTable({
    super.key,
    required this.headers,
    required this.rows,
    this.columnWidths,
    this.columnMaxLines,
    this.columnAlignments,
    this.headerColor = const Color(0xFF0D47A1),
    this.evenRowColor = Colors.white,
    this.oddRowColor = const Color(0xFFF8FAFC),
    this.cellPadding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    this.headerStyle,
    this.cellStyle,
    this.sortComparator,
  })  : assert(columnWidths == null || columnWidths.length == headers.length),
        assert(columnMaxLines == null || columnMaxLines.length == headers.length),
        assert(columnAlignments == null || columnAlignments.length == headers.length);

  @override
  Widget build(BuildContext context) {
    List<List<String>> sortedRows;
    if (sortComparator != null) {
      sortedRows = List<List<String>>.from(rows);
      sortedRows.sort(sortComparator!);
    } else {
      sortedRows = rows;
    }

    final colCount = headers.length;
    final widths = columnWidths ?? List<double>.filled(colCount, 1.0);
    final maxLines = columnMaxLines ?? List<int?>.filled(colCount, null);
    final aligns = columnAlignments ?? List<TextAlign>.filled(colCount, TextAlign.left);

    return SingleChildScrollView(
      // Vertical scroll ONLY — never horizontal. The Table inside uses
      // FlexColumnWidth so it always fits the parent's width and lets
      // long-text cells grow taller instead of overflowing sideways.
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      child: Table(
        columnWidths: {
          for (int i = 0; i < colCount; i++) i: FlexColumnWidth(widths[i]),
        },
        border: TableBorder.all(
          color: AppTheme.borderColor.withOpacity(0.6),
          width: 0.5,
        ),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            decoration: const BoxDecoration(
              color: Color(0xFF0D47A1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            children: [
              for (int i = 0; i < colCount; i++)
                Padding(
                  padding: cellPadding,
                  child: Text(
                    headers[i],
                    style: headerStyle ?? const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                      height: 1.25,
                    ),
                    textAlign: aligns[i],
                    softWrap: true,
                  ),
                ),
            ],
          ),
          for (int r = 0; r < sortedRows.length; r++)
            TableRow(
              decoration: BoxDecoration(
                color: r.isEven ? evenRowColor : oddRowColor,
              ),
              children: [
                for (int c = 0; c < colCount; c++)
                Padding(
                  padding: cellPadding,
                  child: Text(
                    sortedRows[r][c].isEmpty ? '-' : sortedRows[r][c],
                    style: cellStyle ?? const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                      height: 1.3,
                    ),
                    textAlign: aligns[c],
                    // Wrap long text into multiple lines instead of
                    // clipping. `softWrap: true` is the default but we
                    // set it explicitly for clarity. `maxLines` is only
                    // applied when the caller explicitly asked for it
                    // (e.g. compact stat cells); otherwise the cell
                    // grows as tall as the content needs.
                    softWrap: true,
                    maxLines: (maxLines[c] != null && maxLines[c]! > 0)
                        ? maxLines[c]
                        : null,
                    overflow: (maxLines[c] != null && maxLines[c]! > 0)
                        ? TextOverflow.ellipsis
                        : TextOverflow.visible,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
