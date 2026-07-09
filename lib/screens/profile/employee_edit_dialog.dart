import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';

class EmployeeEditDialog extends StatefulWidget {
  final Employee employee;
  final bool isNew;
  const EmployeeEditDialog(
      {super.key, required this.employee, this.isNew = false});

  static Future<bool> showEdit(BuildContext context, Employee employee) async {
    final r = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => EmployeeEditDialog(employee: employee));
    return r ?? false;
  }

  static Future<bool> showNew(BuildContext context) async {
    final r = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => EmployeeEditDialog(
            employee: Employee(pno: '', badgeNumber: '', name: ''),
            isNew: true));
    return r ?? false;
  }

  @override
  State<EmployeeEditDialog> createState() => _EmployeeEditDialogState();
}

class _EmployeeEditDialogState extends State<EmployeeEditDialog> {
  late final TextEditingController _pnoCtrl;
  late final Map<String, TextEditingController> _ctrl;
  late final Map<String, String> _orig;
  late final List<FocusNode> _focusNodes;
  bool _saving = false;
  String? _msg;
  bool _ok = false;

  static const _labels = [
    'EHRMS',
    'बैज नं0',
    'नाम',
    'पद',
    'पिता का नाम',
    'पता',
    'योग्यता',
    'मौ0आ0 पदोन्नति',
    'मोबाइल नं0',
    'जाति',
    'उपजाति',
    'जन्मतिथि',
    'भर्ती तिथि',
    'गृह जनपद',
    'जनपद में नियुक्ति',
    'वर्तमान तैनाती',
    'रिमार्क',
    'लघु दण्ड',
    'छोड़ दण्ड',
    'सत्यनिष्ठा',
    'नगद पुरस्कार',
    'गुड एंट्री',
    'पदक/पुरस्कार',
    'अन्य विवरण',
    'नामिनी का नाम/सम्बन्ध'
  ];
  static const _keys = [
    'ehrms',
    'badgeNumber',
    'name',
    'post',
    'fatherName',
    'address',
    'qualification',
    'promotion',
    'mobile',
    'caste',
    'subCaste',
    'dob',
    'recruitmentDate',
    'homeDistrict',
    'districtPosting',
    'currentPosting',
    'remark',
    'minorPunishment',
    'majorPunishment',
    'integrity',
    'cashReward',
    'goodEntry',
    'medal',
    'otherDetails',
    'nomineeName'
  ];
  static const _multi = [
    'remark',
    'minorPunishment',
    'majorPunishment',
    'otherDetails',
    'promotion'
  ];
  static const _postLabels = ['तैनाती', 'कब से', 'कब तक'];
  static const _postKeys = ['previousPostings', 'fromDate', 'toDate'];

  String _v(String f) {
    final e = widget.employee;
    switch (f) {
      case 'ehrms':
        return e.ehrms;
      case 'badgeNumber':
        return e.badgeNumber;
      case 'name':
        return e.name;
      case 'post':
        return e.post;
      case 'fatherName':
        return e.fatherName;
      case 'address':
        return e.address;
      case 'qualification':
        return e.qualification;
      case 'promotion':
        return e.promotion;
      case 'mobile':
        return e.mobile;
      case 'caste':
        return e.caste;
      case 'subCaste':
        return e.subCaste;
      case 'dob':
        return e.dob;
      case 'recruitmentDate':
        return e.recruitmentDate;
      case 'homeDistrict':
        return e.homeDistrict;
      case 'districtPosting':
        return e.districtPosting;
      case 'currentPosting':
        return e.currentPosting;
      case 'remark':
        return e.remark;
      case 'minorPunishment':
        return e.minorPunishment;
      case 'majorPunishment':
        return e.majorPunishment;
      case 'integrity':
        return e.integrity;
      case 'cashReward':
        return e.cashReward;
      case 'goodEntry':
        return e.goodEntry;
      case 'medal':
        return e.medal;
      case 'otherDetails':
        return e.otherDetails;
      case 'nomineeName':
        return e.nomineeName;
      case 'previousPostings':
        return e.previousPostings;
      case 'fromDate':
        return e.fromDate;
      case 'toDate':
        return e.toDate;
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
    _pnoCtrl = TextEditingController(text: widget.employee.pno);
    _ctrl = {};
    _orig = {};
    // Total fields: PNO + _keys.length + 3 posting = 1 + 25 + 3 = 29
    _focusNodes =
        List.generate(1 + _keys.length + _postKeys.length, (_) => FocusNode());
    _ctrl['pno'] = _pnoCtrl;
    _orig['pno'] = widget.employee.pno;
    for (int i = 0; i < _keys.length; i++) {
      final val = _v(_keys[i]);
      _ctrl[_keys[i]] = TextEditingController(text: val);
      _orig[_keys[i]] = val;
    }
    for (int i = 0; i < _postKeys.length; i++) {
      final val = _v(_postKeys[i]);
      _ctrl[_postKeys[i]] = TextEditingController(text: val);
      _orig[_postKeys[i]] = val;
    }
    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _ctrl.values) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _nextField(int index) {
    if (index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _save();
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    if (widget.isNew) {
      final pno = _pnoCtrl.text.trim();
      if (pno.isEmpty) {
        setState(() {
          _msg = 'PNO जरूरी है';
          _ok = false;
        });
        return;
      }
      final data = <String, String>{'pno': pno};
      for (int i = 0; i < _keys.length; i++) {
        data[_keys[i]] = _ctrl[_keys[i]]!.text.trim();
      }
      for (int i = 0; i < _postKeys.length; i++) {
        data[_postKeys[i]] = _ctrl[_postKeys[i]]!.text.trim();
      }
      setState(() {
        _saving = true;
        _msg = null;
      });
      final s = await GasWriteService().addNewEmployee(data);
      if (mounted) {
        setState(() {
          _saving = false;
          _ok = s;
          _msg = s ? 'कर्मचारी जोड़ा गया' : 'जोड़ने में त्रुटि';
        });
        if (s)
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) Navigator.pop(context, true);
          });
      }
    } else {
      final changed = <String, String>{'pno': widget.employee.pno};
      for (int i = 0; i < _keys.length; i++) {
        final cur = _ctrl[_keys[i]]!.text.trim();
        if (cur != (_orig[_keys[i]] ?? '')) changed[_keys[i]] = cur;
      }
      for (int i = 0; i < _postKeys.length; i++) {
        final cur = _ctrl[_postKeys[i]]!.text.trim();
        if (cur != (_orig[_postKeys[i]] ?? '')) changed[_postKeys[i]] = cur;
      }
      if (changed.length <= 1) {
        setState(() {
          _msg = 'कोई बदलाव नहीं';
          _ok = false;
        });
        return;
      }
      setState(() {
        _saving = true;
        _msg = null;
      });
      final s = await GasWriteService().updateEmployee(changed);
      if (mounted) {
        setState(() {
          _saving = false;
          _ok = s;
          _msg = s ? 'सफलतापूर्वक अपडेट हो गया' : 'अपडेट में त्रुटि';
        });
        if (s) {
          await context.read<EmployeeProvider>().refreshInBackground();
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) Navigator.pop(context, true);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (e) {
        if (e.logicalKey == LogicalKeyboardKey.escape)
          Navigator.pop(context, false);
      },
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width > 600 ? 60 : 16,
            vertical: 20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 780),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                  gradient: AppTheme.headerGradient,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(14))),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6)),
                  child: const Icon(Icons.shield_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(
                          widget.isNew
                              ? 'नया कर्मचारी जोड़ें'
                              : 'कर्मचारी संपादन — PNO: ${widget.employee.pno}',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      const Text('प्रधान लिपिक शाखा जनपद बरेली',
                          style:
                              TextStyle(fontSize: 10, color: Colors.white70)),
                    ])),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back_rounded,
                                size: 12, color: Colors.white),
                            SizedBox(width: 3),
                            Text('वापस',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('ESC बंद',
                        style: TextStyle(fontSize: 9, color: Colors.white54)),
                  ],
                ),
              ]),
            ),
            // Fields
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _f('PNO', _ctrl['pno']!, 0, 1, widget.isNew),
                      const SizedBox(height: 8),
                      LayoutBuilder(builder: (context, c) {
                        final cross = c.maxWidth > 600 ? 2 : 1;
                        final w = (c.maxWidth - (cross > 1 ? 8 : 0)) / cross;
                        return Wrap(spacing: 8, runSpacing: 8, children: [
                          for (int i = 0; i < _keys.length; i++)
                            SizedBox(
                                width: w,
                                child: _f(_labels[i], _ctrl[_keys[i]]!, i + 1,
                                    _multi.contains(_keys[i]) ? 3 : 1, true))
                        ]);
                      }),
                      const SizedBox(height: 10),
                      const Divider(color: Color(0xFFE0E0E0)),
                      const SizedBox(height: 6),
                      const Text('पूर्व नियुक्तियाँ (Enter = नई लाइन)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary)),
                      const SizedBox(height: 6),
                      for (int i = 0; i < _postKeys.length; i++) ...[
                        _f(_postLabels[i], _ctrl[_postKeys[i]]!,
                            _keys.length + 1 + i, 4, true),
                        if (i < _postKeys.length - 1) const SizedBox(height: 6),
                      ],
                      const SizedBox(height: 12),
                    ]),
              ),
            ),
            // Footer with branding
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(14)),
                  border: Border(top: BorderSide(color: Colors.grey.shade200))),
              child: Column(children: [
                // Save button + message
                Row(children: [
                  if (_msg != null)
                    Expanded(
                        child: Row(children: [
                      Icon(_ok ? Icons.check_circle : Icons.error,
                          size: 16,
                          color: _ok
                              ? AppTheme.successColor
                              : AppTheme.errorColor),
                      const SizedBox(width: 4),
                      Expanded(
                          child: Text(_msg!,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: _ok
                                      ? AppTheme.successColor
                                      : AppTheme.errorColor))),
                    ])),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save_rounded, size: 15),
                    label: Text(_saving ? 'सेव हो रहा है...' : 'सेव करें'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8)),
                  ),
                ]),
                const SizedBox(height: 6),
                // Branding — stylish footer
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.10),
                          AppTheme.primaryColor.withOpacity(0.03),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.28),
                          width: 0.8),
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
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _f(String label, TextEditingController c, int fIndex, int lines,
      bool enabled) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary)),
      const SizedBox(height: 2),
      TextField(
        controller: c,
        focusNode: _focusNodes[fIndex],
        enabled: enabled,
        maxLines: lines,
        textInputAction:
            lines > 1 ? TextInputAction.newline : TextInputAction.next,
        onSubmitted: (_) => _nextField(fIndex),
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide:
                  const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
        ),
      ),
    ]);
  }
}
