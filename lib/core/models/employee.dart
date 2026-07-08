import '../constants/app_constants.dart';

/// कर्मचारी मॉडल - Employee Model
///
/// One row from the ALL or EXTRA sheet. Holds every typed field
/// consumed by the UI. Unknown / future columns flow into [rawData]
/// (mirrors the `additionalFields` pattern on sub-models).
///
/// Equality includes [rawData] — two employees with different unknown
/// columns are NOT equal.
class Employee {
  final String pno;
  final String badgeNumber;
  final String ehrms;
  final String name;
  final String post;
  final String fatherName;
  final String address;
  final String qualification;
  final String promotion;
  final String mobile;
  final String caste;
  final String subCaste;
  final String dob;
  final String recruitmentDate;
  final String homeDistrict;
  final String districtPosting;
  final String currentPosting;
  final String remark;
  final String minorPunishment;
  final String majorPunishment;
  final String integrity;
  final String cashReward;
  final String goodEntry;
  final String medal;
  final String otherDetails;
  final String nomineeName;
  final String previousPostings;
  final String fromDate;
  final String toDate;
  final String status; // Active / Inactive
  final String sourceSheet; // ALL / EXTRA

  /// ALL और EXTRA शीट्स के सभी मूल कॉलम — बिना किसी हानि के
  final Map<String, dynamic> rawData;

  Employee({
    required this.pno,
    required this.badgeNumber,
    this.ehrms = '',
    required this.name,
    this.post = '',
    this.fatherName = '',
    this.address = '',
    this.qualification = '',
    this.promotion = '',
    this.mobile = '',
    this.caste = '',
    this.subCaste = '',
    this.dob = '',
    this.recruitmentDate = '',
    this.homeDistrict = '',
    this.districtPosting = '',
    this.currentPosting = '',
    this.remark = '',
    this.minorPunishment = '',
    this.majorPunishment = '',
    this.integrity = '',
    this.cashReward = '',
    this.goodEntry = '',
    this.medal = '',
    this.otherDetails = '',
    this.nomineeName = '',
    this.previousPostings = '',
    this.fromDate = '',
    this.toDate = '',
    this.status = AppConstants.statusActive,
    this.sourceSheet = AppConstants.sheetAll,
    Map<String, dynamic>? rawData,
  }) : rawData = rawData ?? {};

  factory Employee.fromMap(Map<String, dynamic> map) {
    final raw = Map<String, dynamic>.fromEntries(
      map.entries.where((e) => !e.key.startsWith('__')),
    );

    return Employee(
      pno: _clean(map[AppConstants.keyPno] ?? ''),
      badgeNumber: _clean(
        map[AppConstants.keyBadge] ?? map[AppConstants.keyBadgeAlt] ?? '',
      ),
      ehrms: _cleanEhrms(
        map[AppConstants.keyEHRMS] ??
        map[AppConstants.keyEHRMSAlt1] ??
        map[AppConstants.keyEHRMSAlt2] ??
        map[AppConstants.keyEHRMSAlt3] ??
        // Last-resort: scan rawData for any key containing 'ehrms'
        map.entries.where((e) =>
          e.key.toLowerCase().replaceAll(RegExp(r'[\s.\-]'), '') == 'ehrms'
        ).map((e) => e.value).firstOrNull ?? '',
      ),
      name: map[AppConstants.keyName]?.toString().trim() ?? '',
      post: map[AppConstants.keyPost]?.toString().trim() ?? '',
      fatherName: map[AppConstants.keyFatherName]?.toString().trim() ?? '',
      address: map[AppConstants.keyAddress]?.toString().trim() ?? '',
      qualification:
          map[AppConstants.keyQualification]?.toString().trim() ?? '',
      promotion: map[AppConstants.keyPromotion]?.toString().trim() ?? '',
      mobile: map[AppConstants.keyMobile]?.toString().trim() ?? '',
      caste: map[AppConstants.keyCaste]?.toString().trim() ?? '',
      subCaste: map[AppConstants.keySubCaste]?.toString().trim() ?? '',
      dob: map[AppConstants.keyDob]?.toString().trim() ?? '',
      recruitmentDate:
          map[AppConstants.keyRecruitmentDate]?.toString().trim() ?? '',
      homeDistrict: map[AppConstants.keyHomeDistrict]?.toString().trim() ?? '',
      districtPosting:
          map[AppConstants.keyDistrictPosting]?.toString().trim() ?? '',
      currentPosting:
          map[AppConstants.keyCurrentPosting]?.toString().trim() ?? '',
      remark: map[AppConstants.keyRemark]?.toString().trim() ?? '',
      minorPunishment:
          map[AppConstants.keyMinorPunishment]?.toString().trim() ?? '',
      majorPunishment:
          map[AppConstants.keyMajorPunishment]?.toString().trim() ?? '',
      integrity: map[AppConstants.keyIntegrity]?.toString().trim() ?? '',
      cashReward: map[AppConstants.keyCashReward]?.toString().trim() ?? '',
      goodEntry: map[AppConstants.keyGoodEntry]?.toString().trim() ?? '',
      medal: map[AppConstants.keyMedal]?.toString().trim() ?? '',
      otherDetails: map[AppConstants.keyOtherDetails]?.toString().trim() ?? '',
      nomineeName: map[AppConstants.keyNomineeName]?.toString().trim() ?? '',
      previousPostings:
          map[AppConstants.keyPreviousPostings]?.toString().trim() ?? '',
      fromDate: map[AppConstants.keyFromDate]?.toString().trim() ?? '',
      toDate: map[AppConstants.keyToDate]?.toString().trim() ?? '',
      status:
          map[AppConstants.tagStatus]?.toString() ?? AppConstants.statusActive,
      sourceSheet:
          map[AppConstants.tagSourceSheet]?.toString() ?? AppConstants.sheetAll,
      rawData: raw,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      AppConstants.keyPno: pno,
      AppConstants.keyBadge: badgeNumber,
      AppConstants.keyEHRMS: ehrms,
      AppConstants.keyName: name,
      AppConstants.keyPost: post,
      AppConstants.keyFatherName: fatherName,
      AppConstants.keyAddress: address,
      AppConstants.keyQualification: qualification,
      AppConstants.keyPromotion: promotion,
      AppConstants.keyMobile: mobile,
      AppConstants.keyCaste: caste,
      AppConstants.keySubCaste: subCaste,
      AppConstants.keyDob: dob,
      AppConstants.keyRecruitmentDate: recruitmentDate,
      AppConstants.keyHomeDistrict: homeDistrict,
      AppConstants.keyDistrictPosting: districtPosting,
      AppConstants.keyCurrentPosting: currentPosting,
      AppConstants.keyRemark: remark,
      AppConstants.keyMinorPunishment: minorPunishment,
      AppConstants.keyMajorPunishment: majorPunishment,
      AppConstants.keyIntegrity: integrity,
      AppConstants.keyCashReward: cashReward,
      AppConstants.keyGoodEntry: goodEntry,
      AppConstants.keyMedal: medal,
      AppConstants.keyOtherDetails: otherDetails,
      AppConstants.keyNomineeName: nomineeName,
      AppConstants.keyPreviousPostings: previousPostings,
      AppConstants.keyFromDate: fromDate,
      AppConstants.keyToDate: toDate,
      AppConstants.tagStatus: status,
      AppConstants.tagSourceSheet: sourceSheet,
    };
  }

  bool get isActive => status == AppConstants.statusActive;

  Employee copyWith({
    String? pno,
    String? badgeNumber,
    String? ehrms,
    String? name,
    String? post,
    String? fatherName,
    String? address,
    String? qualification,
    String? promotion,
    String? mobile,
    String? caste,
    String? subCaste,
    String? dob,
    String? recruitmentDate,
    String? homeDistrict,
    String? districtPosting,
    String? currentPosting,
    String? remark,
    String? minorPunishment,
    String? majorPunishment,
    String? integrity,
    String? cashReward,
    String? goodEntry,
    String? medal,
    String? otherDetails,
    String? nomineeName,
    String? previousPostings,
    String? fromDate,
    String? toDate,
    String? status,
    String? sourceSheet,
    Map<String, dynamic>? rawData,
  }) {
    return Employee(
      pno: pno ?? this.pno,
      badgeNumber: badgeNumber ?? this.badgeNumber,
      ehrms: ehrms ?? this.ehrms,
      name: name ?? this.name,
      post: post ?? this.post,
      fatherName: fatherName ?? this.fatherName,
      address: address ?? this.address,
      qualification: qualification ?? this.qualification,
      promotion: promotion ?? this.promotion,
      mobile: mobile ?? this.mobile,
      caste: caste ?? this.caste,
      subCaste: subCaste ?? this.subCaste,
      dob: dob ?? this.dob,
      recruitmentDate: recruitmentDate ?? this.recruitmentDate,
      homeDistrict: homeDistrict ?? this.homeDistrict,
      districtPosting: districtPosting ?? this.districtPosting,
      currentPosting: currentPosting ?? this.currentPosting,
      remark: remark ?? this.remark,
      minorPunishment: minorPunishment ?? this.minorPunishment,
      majorPunishment: majorPunishment ?? this.majorPunishment,
      integrity: integrity ?? this.integrity,
      cashReward: cashReward ?? this.cashReward,
      goodEntry: goodEntry ?? this.goodEntry,
      medal: medal ?? this.medal,
      otherDetails: otherDetails ?? this.otherDetails,
      nomineeName: nomineeName ?? this.nomineeName,
      previousPostings: previousPostings ?? this.previousPostings,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      status: status ?? this.status,
      sourceSheet: sourceSheet ?? this.sourceSheet,
      rawData: rawData ?? this.rawData,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Employee &&
          other.pno == pno &&
          other.badgeNumber == badgeNumber &&
          other.ehrms == ehrms &&
          other.name == name &&
          other.post == post &&
          other.fatherName == fatherName &&
          other.address == address &&
          other.qualification == qualification &&
          other.promotion == promotion &&
          other.mobile == mobile &&
          other.caste == caste &&
          other.subCaste == subCaste &&
          other.dob == dob &&
          other.recruitmentDate == recruitmentDate &&
          other.homeDistrict == homeDistrict &&
          other.districtPosting == districtPosting &&
          other.currentPosting == currentPosting &&
          other.remark == remark &&
          other.minorPunishment == minorPunishment &&
          other.majorPunishment == majorPunishment &&
          other.integrity == integrity &&
          other.cashReward == cashReward &&
          other.goodEntry == goodEntry &&
          other.medal == medal &&
          other.otherDetails == otherDetails &&
          other.nomineeName == nomineeName &&
          other.previousPostings == previousPostings &&
          other.fromDate == fromDate &&
          other.toDate == toDate &&
          other.status == status &&
          other.sourceSheet == sourceSheet;

  @override
  int get hashCode => Object.hashAll([
        pno, badgeNumber, ehrms, name, post, fatherName, address,
        qualification, promotion, mobile, caste, subCaste, dob,
        recruitmentDate, homeDistrict, districtPosting, currentPosting,
        remark, minorPunishment, majorPunishment, integrity, cashReward,
        goodEntry, medal, otherDetails, nomineeName, previousPostings,
        fromDate, toDate, status, sourceSheet,
      ]);

  static String _clean(dynamic value) {
    return value
            ?.toString()
            .replaceAll('.0', '')
            .replaceAll(RegExp(r'\s+'), '')
            .trim() ??
        '';
  }

  /// Cleans an EHRMS field value.
  ///
  /// EHRMS IDs are long integers (e.g. 12345678901).
  /// Google Sheets stores them as numbers, so the CSV may deliver them as:
  ///   - Float string:       "12345678901.0"
  ///   - Scientific notation: "1.23456789E+10"
  ///   - Plain string:       "12345678901"
  ///
  /// Unlike [_clean], this never does a blanket `.replaceAll('.0', '')`
  /// because that can corrupt values like "10200456.0" → "102004560" wrong trim.
  static String _cleanEhrms(dynamic value) {
    if (value == null) return '';
    final s = value.toString().trim();
    if (s.isEmpty) return '';
    // Try parsing as a number (handles scientific notation and floats)
    final n = num.tryParse(s);
    if (n != null) return n.toInt().toString();
    // Not numeric — return as-is (e.g. alphanumeric EHRMS codes)
    return s;
  }
}