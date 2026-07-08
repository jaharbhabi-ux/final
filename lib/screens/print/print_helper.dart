import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/core.dart';

class PrintHelper {
  static pw.Font? _reg;
  static pw.Font? _bold;
  PrintHelper._();

  /// Loads Devanagari fonts from Google Fonts at runtime via the
  /// printing package's PdfGoogleFonts helper. This avoids shipping
  /// TTF files in assets (which were getting corrupted/placeholder)
  /// and avoids the ttf_parser failure we were hitting.
  static Future<void> _loadFonts() async {
    if (_reg != null && _bold != null) return;
    try {
      final results = await Future.wait([
        PdfGoogleFonts.notoSansDevanagariRegular(),
        PdfGoogleFonts.notoSansDevanagariBold(),
      ]);
      _reg = results[0];
      _bold = results[1];
    } catch (e) {
      // Last-resort fallback: Helvetica (built-in). Devanagari chars
      // won't render but at least the PDF will generate instead of
      // crashing the whole app.
      _reg = pw.Font.helvetica();
      _bold = pw.Font.helvetica();
    }
  }

  static Future<void> printProfile(
      {required Employee employee, EmployeeProfile? profile}) async {
    await _loadFonts();
    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      header: (c) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('प्रधान लिपिक शाखा जनपद बरेली',
              style: pw.TextStyle(
                  font: _bold, fontSize: 9, color: PdfColors.grey700)),
          pw.Text('PNO: ${employee.pno}',
              style: pw.TextStyle(
                  font: _reg, fontSize: 8, color: PdfColors.grey500)),
        ],
      ),
      footer: (c) => pw.Column(children: [
        pw.Divider(height: 8, thickness: 0.4),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('Created by Rachit Chauhan | 8273212381',
              style: pw.TextStyle(
                  font: _reg, fontSize: 6, color: PdfColors.grey500)),
          pw.Text('पृष्ठ ${c.pageNumber}',
              style: pw.TextStyle(
                  font: _reg, fontSize: 7, color: PdfColors.grey500)),
        ]),
      ]),
      build: (c) => [
        _statusCard(employee),
        pw.SizedBox(height: 12),
        _sec('व्यक्तिगत विवरण'),
        pw.SizedBox(height: 4),
        _detTable(_personal(employee)),
        pw.SizedBox(height: 12),
        _sec('सेवा विवरण'),
        pw.SizedBox(height: 4),
        _detTable(_service(employee)),
        pw.SizedBox(height: 12),
        _sec('पुरस्कार एवं विवरण'),
        pw.SizedBox(height: 4),
        _detTable(_awards(employee)),
        pw.SizedBox(height: 12),
        if (employee.minorPunishment.trim().isNotEmpty) ...[
          _sec('लघु दण्ड'),
          pw.SizedBox(height: 4),
          _multi(employee.minorPunishment),
          pw.SizedBox(height: 12)
        ],
        if (employee.majorPunishment.trim().isNotEmpty) ...[
          _sec('छुद्र दण्ड'),
          pw.SizedBox(height: 4),
          _multi(employee.majorPunishment),
          pw.SizedBox(height: 12)
        ],
        if (employee.remark.trim().isNotEmpty) ...[
          _sec('रिमार्क'),
          pw.SizedBox(height: 4),
          _multi(employee.remark),
          pw.SizedBox(height: 12)
        ],
        if (employee.otherDetails.trim().isNotEmpty) ...[
          _sec('अन्य विवरण'),
          pw.SizedBox(height: 4),
          _multi(employee.otherDetails),
          pw.SizedBox(height: 12)
        ],
        if (profile != null) ...[
          if (profile.previousPostings.isNotEmpty) ...[
            _sec('पूर्व नियुक्तियाँ'),
            pw.SizedBox(height: 4),
            _postTable(profile.previousPostings),
            pw.SizedBox(height: 12)
          ],
          if (profile.transfers.isNotEmpty) ...[
            _sec('स्थानांतरण विवरण'),
            pw.SizedBox(height: 4),
            _transTable(profile.transfers),
            pw.SizedBox(height: 12)
          ],
          if (profile.allHob.isNotEmpty) ...[
            _sec('HOB रिकॉर्ड (${profile.allHob.length})'),
            pw.SizedBox(height: 4),
            _hobTable(profile.allHob),
            pw.SizedBox(height: 12)
          ],
          if (profile.basicPay.isNotEmpty) ...[
            _sec('वेतन विवरण (${profile.basicPay.length})'),
            pw.SizedBox(height: 4),
            ...profile.basicPay.expand(_salBlocks)
          ],
        ],
      ],
    ));

    final bytes = await pdf.save();
    // Always use layoutPdf — opens native print dialog (Ctrl+P-like)
    // on both web and desktop. sharePdf would just download a file.
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: 'UP_Police_.pdf',
    );
  }

  static pw.Widget _statusCard(Employee e) {
    final a = e.isActive;
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
          color: a ? PdfColors.green50 : PdfColors.red50,
          borderRadius: pw.BorderRadius.circular(6),
          border:
              pw.Border.all(color: a ? PdfColors.green300 : PdfColors.red300)),
      child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Container(
            width: 40,
            height: 40,
            decoration: pw.BoxDecoration(
                color: a ? PdfColors.green100 : PdfColors.red100,
                borderRadius: pw.BorderRadius.circular(6)),
            child: pw.Center(
                child: pw.Text(
                    e.name.isNotEmpty ? e.name[0].toUpperCase() : '?',
                    style: pw.TextStyle(
                        font: _bold,
                        fontSize: 18,
                        color: a ? PdfColors.green700 : PdfColors.red700)))),
        pw.SizedBox(width: 12),
        pw.Expanded(
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
              pw.Text(e.name.isEmpty ? '-' : e.name,
                  style: pw.TextStyle(
                      font: _bold, fontSize: 14, color: PdfColors.grey900)),
              pw.SizedBox(height: 2),
              pw.Text(e.post,
                  style: pw.TextStyle(
                      font: _reg, fontSize: 10, color: PdfColors.grey600)),
              pw.SizedBox(height: 3),
              pw.Text('बैज: ${e.badgeNumber}  |  तैनाती: ${e.currentPosting}',
                  style: pw.TextStyle(
                      font: _reg, fontSize: 9, color: PdfColors.grey700)),
            ])),
        pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: pw.BoxDecoration(
                color: a ? PdfColors.green100 : PdfColors.red100,
                borderRadius: pw.BorderRadius.circular(4)),
            child: pw.Text(a ? 'सक्रिय' : 'निष्क्रिय',
                style: pw.TextStyle(
                    font: _bold,
                    fontSize: 9,
                    color: a ? PdfColors.green700 : PdfColors.red700))),
      ]),
    );
  }

  static pw.Widget _sec(String t) => pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 3),
      decoration: const pw.BoxDecoration(
          border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.blue700, width: 1))),
      child: pw.Text(t,
          style: pw.TextStyle(
              font: _bold, fontSize: 12, color: PdfColors.blue700)));

  static pw.Widget _detTable(List<MapEntry<String, String>> f) {
    if (f.isEmpty)
      return pw.Text('—', style: pw.TextStyle(font: _reg, fontSize: 8));
    return pw.Table(columnWidths: const {
      0: pw.FlexColumnWidth(2),
      1: pw.FlexColumnWidth(3)
    }, children: [
      for (int i = 0; i < f.length; i += 2)
        pw.TableRow(
            decoration: (i ~/ 2).isEven
                ? const pw.BoxDecoration(color: PdfColors.grey50)
                : null,
            verticalAlignment: pw.TableCellVerticalAlignment.middle,
            children: [
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: _cell(f[i].key, f[i].value)),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: i + 1 < f.length
                      ? _cell(f[i + 1].key, f[i + 1].value)
                      : pw.SizedBox()),
            ]),
    ]);
  }

  static pw.Widget _cell(String l, String v) =>
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(l,
            style: pw.TextStyle(
                font: _bold, fontSize: 7, color: PdfColors.grey600)),
        pw.SizedBox(height: 1),
        pw.Text(v.isEmpty ? '-' : v,
            style:
                pw.TextStyle(font: _reg, fontSize: 8, color: PdfColors.grey900))
      ]);

  static pw.Widget _multi(String c) {
    final lines = c.split('\n');
    return pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
            color: PdfColors.grey50,
            borderRadius: pw.BorderRadius.circular(4),
            border: pw.Border.all(color: PdfColors.grey300)),
        child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < lines.length; i++) ...[
                pw.Text(lines[i].isEmpty ? ' ' : lines[i],
                    style: pw.TextStyle(
                        font: _reg, fontSize: 8, color: PdfColors.grey900)),
                if (i < lines.length - 1) pw.SizedBox(height: 2)
              ]
            ]));
  }

  static pw.Widget _postTable(List<PreviousPosting> p) => _grid(
      ['तैनाती', 'कब से', 'कब तक', 'अवधि'],
      p
          .map((e) => [
                e.location,
                e.fromDateRaw,
                e.toDateRaw.isEmpty ? 'वर्तमान' : e.toDateRaw,
                e.duration
              ])
          .toList(),
      [3, 1.2, 1.2, 1.4]);

  static pw.Widget _transTable(List<TransferRecord> t) => _grid(
      ['प्रकार', 'जिला', 'आदेश संख्या', 'पत्रावली'],
      t
          .map((e) =>
              [e.directionLabel, e.toLocation, e.orderNumber, e.fileNumber])
          .toList(),
      [1, 1.5, 2.5, 2]);

  // अन्य विवरण column removed; description gets extra width so it doesn't wrap.
  static pw.Widget _hobTable(List<Hob> h) => _grid(
      ['HOB #', 'दिनांक', 'विवरण'],
      h.map((e) => [e.hobNumber, e.date, e.description]).toList(),
      [1, 1.4, 6.0]);

  static List<pw.Widget> _salBlocks(BasicPay p) {
    final f = p.allFields;
    if (f.isEmpty) return const [];
    return [
      _grid(
          ['विवरण', 'मान'], f.map((e) => [e.key, e.value]).toList(), [1.5, 2]),
      pw.SizedBox(height: 8)
    ];
  }

  static pw.Widget _grid(
          List<String> h, List<List<String>> rows, List<double> w) =>
      pw.Table(columnWidths: {
        for (int i = 0; i < w.length; i++) i: pw.FlexColumnWidth(w[i])
      }, children: [
        pw.TableRow(
            decoration: const pw.BoxDecoration(
                color: PdfColors.blue700,
                borderRadius: pw.BorderRadius.only(
                    topLeft: pw.Radius.circular(4),
                    topRight: pw.Radius.circular(4))),
            children: [
              for (final x in h)
                pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 5, vertical: 4),
                    child: pw.Text(x,
                        style: pw.TextStyle(
                            font: _bold, fontSize: 7, color: PdfColors.white)))
            ]),
        for (int r = 0; r < rows.length; r++)
          pw.TableRow(
              decoration: r.isEven
                  ? const pw.BoxDecoration(color: PdfColors.grey50)
                  : null,
              children: [
                for (final x in rows[r])
                  pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 5, vertical: 3),
                      child: pw.Text(x.isEmpty ? '-' : x,
                          style: pw.TextStyle(
                              font: _reg,
                              fontSize: 7,
                              color: PdfColors.grey800)))
              ]),
      ]);

  static List<MapEntry<String, String>> _personal(Employee e) => [
        MapEntry('EHRMS', e.ehrms),
        MapEntry('पिता का नाम', e.fatherName),
        MapEntry('नामिनी', e.nomineeName),
        MapEntry('जन्मतिथि', e.dob),
        MapEntry('भर्ती तिथि', e.recruitmentDate),
        MapEntry('जाति', e.caste),
        MapEntry('उपजाति', e.subCaste),
        MapEntry('गृह जनपद', e.homeDistrict),
        MapEntry('पता', e.address),
        MapEntry('योग्यता', e.qualification),
        MapEntry('मोबाइल', e.mobile)
      ].where((e) => e.value.isNotEmpty).toList();

  static List<MapEntry<String, String>> _service(Employee e) => [
        MapEntry('पद', e.post),
        MapEntry('मु0आ0 पदोन्नति', e.promotion),
        MapEntry('जनपद में नियुक्ति', e.districtPosting),
        MapEntry('वर्तमान तैनाती', e.currentPosting),
        MapEntry('गृह जनपद', e.homeDistrict)
      ].where((e) => e.value.isNotEmpty).toList();

  static List<MapEntry<String, String>> _awards(Employee e) => [
        MapEntry('गुड एन्ट्री', e.goodEntry),
        MapEntry('नगद पुरूष्कार', e.cashReward),
        MapEntry('पदक', e.medal),
        MapEntry('सत्यनिष्ठा', e.integrity),
        MapEntry('अन्य विवरण', e.otherDetails)
      ].where((e) => e.value.isNotEmpty).toList();
}
