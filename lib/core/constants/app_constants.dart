// Application Constants - App Constants
// All CSV URLs, Google Sheet IDs, and configuration live here.

class AppConstants {
  AppConstants._();

  // ──────────────────────────────────────────────
  // Google Sheets Configuration
  // ──────────────────────────────────────────────

  /// Google Spreadsheet ID
  static const String spreadsheetId =
      '1MDAeduHBz8M-uacNt-M7lKQyzMfN4R0-DCHW60n4KH8';

  /// Base URL for Google Sheets
  static const String gsheetsBaseUrl = 'https://docs.google.com/spreadsheets/d';

  // ──────────────────────────────────────────────
  // Google Apps Script Configuration
  // ──────────────────────────────────────────────

  /// Base URL for Google Apps Script Web App
  static const String gasBaseUrl =
      'https://script.google.com/macros/s/AKfycbxetjvsBdTLiRvnVd5js9DIJBczeirNIVz9P4VjOt-xXWaRARzIztwiLKzdGEGQBvev/exec';

  /// Security token — Google Apps Script validates this token on every write request.
  static const String apiToken = 'my_app_secret_2026';

  // ──────────────────────────────────────────────
  // Sheet Names & GIDs
  // ──────────────────────────────────────────────

  /// Main ALL Employees sheet
  static const String sheetAll = 'ALL';
  static const String sheetAllGid = '710993359';

  /// Extra Employees
  static const String sheetExtra = 'EXTRA';
  static const String sheetExtraGid = '1498691155';

  /// Arrivals (Aagman)
  static const String sheetAagman = 'aagman';
  static const String sheetAagmanGid = '298285047';

  /// Departures (Prasthan)
  static const String sheetPrasthan = 'prasthan';
  static const String sheetPrasthanGid = '2092410906';

  /// HOB 2025
  static const String sheetHob2025 = 'hob 2025';
  static const String sheetHob2025Gid = '2007446619';

  /// HOB 2026
  static const String sheetHob2026 = 'hob 2026';
  static const String sheetHob2026Gid = '765707211';

  /// Basic Pay
  static const String sheetBasicPay = 'BASIC PAY';
  static const String sheetBasicPayGid = '700203932';

  /// Sambadh (Relations / Family / Nominee details)
  static const String sheetSambadh = 'Sambadh';
  static const String sheetSambadhGid = '0';

  /// All sheets list for parallel loading.
  static const List<Map<String, String>> allSheets = [
    {'name': sheetAll, 'gid': sheetAllGid},
    {'name': sheetExtra, 'gid': sheetExtraGid},
    {'name': sheetAagman, 'gid': sheetAagmanGid},
    {'name': sheetPrasthan, 'gid': sheetPrasthanGid},
    {'name': sheetHob2025, 'gid': sheetHob2025Gid},
    {'name': sheetHob2026, 'gid': sheetHob2026Gid},
    {'name': sheetBasicPay, 'gid': sheetBasicPayGid},
    {'name': sheetSambadh, 'gid': sheetSambadhGid},
  ];

  /// Sheets whose GID is still placeholder
  static const Set<String> placeholderSheets = {sheetSambadh};

  // ──────────────────────────────────────────────
  // Sambadh (Relation) Keys
  // ──────────────────────────────────────────────
  static const String keyRelationType = 'सम्बन्ध';
  static const String keyRelationName = 'नाम';
  static const String keyRelationContact = 'सम्पर्क नं0';

  // ──────────────────────────────────────────────
  // CSV Header Keys (Hindi Unicode)
  // ──────────────────────────────────────────────
  static const String keyPno = 'पीएनओ';
  static const String keyBadge = 'बैज नं0';
  static const String keyBadgeAlt = 'बैज नंबर';
  static const String keyName = 'नाम';
  static const String keyPost = 'पद';
  static const String keyFatherName = 'पिता का नाम';
  static const String keyAddress = 'पता';
  static const String keyQualification = 'योग्यता';
  static const String keyPromotion = 'मु0आ0 पदोन्नति';
  static const String keyMobile = 'मोबाइल नं0';
  static const String keyCaste = 'जाति';
  static const String keySubCaste = 'उपजाति';
  static const String keyDob = 'जन्मतिथि';
  static const String keyRecruitmentDate = 'भर्ती तिथि';
  static const String keyHomeDistrict = 'गृह जनपद';
  static const String keyDistrictPosting = 'जनपद में नियुक्ति';
  static const String keyCurrentPosting = 'वर्तमान तैनाती';
  static const String keyRemark = 'रिमार्क';
  static const String keyMinorPunishment = 'लघु दण्ड';
  static const String keyMajorPunishment = 'छुद्र दण्ड';
  static const String keyIntegrity = 'सत्यनिष्ठा';
  static const String keyCashReward = 'नगद पुरूष्कार';
  static const String keyGoodEntry = 'गुड एन्ट्री';
  static const String keyMedal = 'पदक/पुरूष्कार';
  static const String keyOtherDetails = 'अन्य विवरण';
  static const String keyNomineeName = 'नामिनी का नाम/सम्बन्ध';
  static const String keyPreviousPostings = 'पूर्व नियुक्तियाँ';
  static const String keyFromDate = 'कब से';
  static const String keyToDate = 'कब तक';
  static const String keyEHRMS = 'E.HRMS';
  // Fallback header variants seen in some sheet exports
  static const String keyEHRMSAlt1 = 'EHRMS';
  static const String keyEHRMSAlt2 = 'E-HRMS';
  static const String keyEHRMSAlt3 = 'E HRMS';

  // Aagman / Prasthan keys
  static const String keySerialNo = 'क्र0 सं0';
  static const String keyOrderNumber = 'आदेश संख्या व दिनांक';
  static const String keyFileNumber = 'पत्रावली संख्या';
  static const String keyFromWhere = 'कहाँ से';
  static const String keyToWhere = 'कहाँ को';

  // HOB keys
  static const String keyHobNumber = 'एचओबी संख्या';
  static const String keyDate = 'दिनांक';
  static const String keyDescription = 'विवरण';

  /// HOB sheet me naya column — "रोल में entry" (Yes/No)
  static const String keyHobRollEntered = 'रोल में entry';
  static const String tagHobRollYes = 'Yes';
  static const String tagHobRollNo = 'No';

  // Basic Pay keys
  static const String keyBasicPay = 'मूल वेतन';
  static const String keyIncrementMonth = 'वार्षिक वेतन वृद्धि माह';

  // ──────────────────────────────────────────────
  // Internal Tags
  // ──────────────────────────────────────────────
  static const String tagSourceSheet = '__sourceSheet';
  static const String tagStatus = '__status';

  // ──────────────────────────────────────────────
  // Timeouts & Configuration
  // ──────────────────────────────────────────────
  static const Duration cacheDuration = Duration(hours: 1);
  static const Duration requestTimeout = Duration(seconds: 60);
  static const Duration searchDebounce = Duration(milliseconds: 300);

  // ──────────────────────────────────────────────
  // Employee Status
  // ──────────────────────────────────────────────
  static const String statusActive = 'Active';
  static const String statusInactive = 'Inactive';

  // ──────────────────────────────────────────────
  // Printing Configuration
  // ──────────────────────────────────────────────
  static const double printPageWidth = 793.7; // A4 in points
  static const double printPageHeight = 1122.5;
}