import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/core.dart';
import '../widgets/common/up_data_table.dart';

/// Transfer Classification page — lists either Aagman (arrival) or
/// Prasthan (departure) records filtered by the DG / BJD / BR prefix.
///
/// Responsive: the table uses [UPDataTable] which lays out columns with
/// `FlexColumnWidth`, so it always fits the available width on mobile,
/// web, and desktop. Long text wraps into multiple lines instead of
/// being cut.
class TransferClassificationPage extends StatelessWidget {
  final String title;
  final bool isAagman;
  final String prefix;

  const TransferClassificationPage({
    super.key,
    required this.title,
    required this.isAagman,
    required this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.cardColor,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        leading: IconButton(
          tooltip: 'वापस',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Consumer<EmployeeProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && !provider.isInitialLoadDone) {
              return _buildLoadingScreen();
            }

            // Filter transfer records based on the prefix
            final filteredRecords =
                _filterTransferRecordsByPrefix(provider, prefix, isAagman);

            return RefreshIndicator(
              onRefresh: () => provider.refreshInBackground(),
              color: AppTheme.primaryColor,
              backgroundColor: AppTheme.cardColor,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '${filteredRecords.length} रिकॉर्ड मिले',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  if (filteredRecords.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppTheme.glassContainer(
                              borderRadius: 16,
                              padding: const EdgeInsets.all(16),
                              child: Icon(Icons.search_off_rounded,
                                  size: 32,
                                  color: AppTheme.errorColor.withOpacity(0.6)),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'कोई रिकॉर्ड नहीं मिला',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'इस श्रेणी में कोई आगमन/प्रस्थान नहीं है',
                              style: TextStyle(
                                  fontSize: 13, color: AppTheme.textHint),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _buildDataTable(filteredRecords),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<dynamic> _filterTransferRecordsByPrefix(
      EmployeeProvider provider, String prefix, bool isAagman) {
    // Use the new provider method to get transfer records by order prefix
    return provider.getTransferRecordsByOrderPrefix(prefix, isAagman);
  }

  /// Responsive table — uses [UPDataTable] which:
  ///   • fits the screen width (FlexColumnWidth columns)
  ///   • wraps long text into multiple lines (no ellipsis cut)
  ///   • works on mobile, web, and desktop without horizontal scroll
  Widget _buildDataTable(List<dynamic> records) {
    final rows = <List<String>>[];
    for (int i = 0; i < records.length; i++) {
      final record = records[i];
      if (record is! Aagman && record is! Prasthan) continue;
      final isArrival = record is Aagman;
      final String pno = isArrival ? (record).pno : (record as Prasthan).pno;
      final String employeeName =
          isArrival ? (record).employeeName : (record as Prasthan).employeeName;
      final String orderNumber =
          isArrival ? (record).orderNumber : (record as Prasthan).orderNumber;
      final String fileNumber =
          isArrival ? (record).fileNumber : (record as Prasthan).fileNumber;
      final String fromWhere =
          isArrival ? (record).fromWhere : (record as Prasthan).fromWhere;
      final String toWhere =
          isArrival ? (record).toWhere : (record as Prasthan).toWhere;
      rows.add([
        '${i + 1}',
        pno,
        employeeName,
        orderNumber,
        fileNumber,
        fromWhere,
        toWhere,
      ]);
    }

    return UPDataTable(
      headers: const [
        'क्रम',
        'PNO',
        'नाम',
        'आदेश सं0 व दिनांक',
        'पत्रावली संख्या',
        AppConstants.keyFromWhere,
        AppConstants.keyToWhere,
      ],
      rows: rows,
      // Proportional widths — table always fits the parent width.
      columnWidths: const [0.5, 1.0, 1.6, 2.0, 1.4, 1.4, 1.4],
      // No columnMaxLines -> long text wraps freely without being cut.
      columnAlignments: const [
        TextAlign.center,
        TextAlign.center,
        TextAlign.left,
        TextAlign.left,
        TextAlign.left,
        TextAlign.left,
        TextAlign.left,
      ],
      cellPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppTheme.glassContainer(
            borderRadius: 20,
            padding: const EdgeInsets.all(36),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  strokeWidth: 3,
                ),
                SizedBox(height: 20),
                Text(
                  'डेटा लोड हो रहा है...',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'कर्मचारी प्रबंधन प्रणाली',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
