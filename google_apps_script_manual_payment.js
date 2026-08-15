const CONFIG = {
  SPREADSHEET_ID: '1n-4HfM8EdugB0FSUiQGnVaZIDpgULi1U9PqLSwWJPT0',

  SHEETS: {
    INDIVIDUAL: 'Individual Registrations',
    INSTITUTIONAL: 'Institutional Registrations',
    DELEGATES: 'Institutional Delegates',
  },

  DRIVE: {
    ROOT_FOLDER: 'JPUMUN 2026',
    PAYMENT_FOLDER: 'Payment Screenshots',
    INDIVIDUAL_FOLDER: 'Individual',
    INSTITUTIONAL_FOLDER: 'Institutional',
  },

  PAYMENT: {
    MAX_FILE_SIZE_BYTES: 5 * 1024 * 1024,
    ALLOWED_MIME_TYPES: ['image/jpeg', 'image/png', 'image/webp'],
    STATUS_PENDING: 'PAYMENT_PENDING',
    STATUS_AWAITING: 'AWAITING_VERIFICATION',
    STATUS_VERIFIED: 'VERIFIED',
    STATUS_REJECTED: 'REJECTED',
  },
};

/* ============================================================
   WEB APP ENTRY POINTS
   ============================================================ */

function doGet() {
  return jsonResponse({
    success: true,
    message: 'JPUMUN 2026 Registration API is running.',
  });
}

function doPost(e) {
  const lock = LockService.getScriptLock();

  try {
    lock.waitLock(10000);

    if (!e || !e.postData || !e.postData.contents) {
      throw new Error('Request body is missing.');
    }

    const data = JSON.parse(e.postData.contents);
    const action = clean(data.action);

    if (action === 'upload_payment') {
      return handlePaymentUpload(data);
    }

    requireValue(data.registration_type, 'registration_type');

    switch (data.registration_type) {
      case 'individual':
        return handleIndividualRegistration(data);
      case 'institutional':
        return handleInstitutionalRegistration(data);
      default:
        throw new Error(
          'Invalid registration_type: ' + data.registration_type
        );
    }
  } catch (error) {
    console.error(error && error.message ? error.message : error);

    return jsonResponse({
      success: false,
      message: error.message || 'An unexpected server error occurred.',
    });
  } finally {
    try {
      lock.releaseLock();
    } catch (_) {}
  }
}

/* ============================================================
   REGISTRATION HANDLERS
   ============================================================ */

function handleIndividualRegistration(data) {
  validateIndividualRegistration(data);

  const sheet = getRegistrationSheet('individual');
  const registrationId = generateRegistrationId('IND');
  const timestamp = new Date();

  sheet.appendRow([
    registrationId,
    timestamp,
    clean(data.name),
    clean(data.email),
    clean(data.contact),
    clean(data.institution),
    clean(data.class),
    clean(data.mun_experience),
    clean(data.committee_preference_1),
    clean(data.committee_preference_2),
    clean(data.portfolio_preference_1),
    clean(data.portfolio_preference_2),
    booleanValue(data.declaration_information_accurate),
    booleanValue(data.declaration_code_of_conduct),
    booleanValue(data.declaration_allocation_policy),
    CONFIG.PAYMENT.STATUS_PENDING,
    '',
    '',
    '',
  ]);

  return jsonResponse({
    success: true,
    registration_id: registrationId,
    registration_type: 'individual',
    message: 'Individual registration submitted successfully.',
  });
}

function handleInstitutionalRegistration(data) {
  validateInstitutionalRegistration(data);

  const spreadsheet = getSpreadsheet();
  const institutionSheet = spreadsheet.getSheetByName(
    CONFIG.SHEETS.INSTITUTIONAL
  );
  const delegatesSheet = spreadsheet.getSheetByName(
    CONFIG.SHEETS.DELEGATES
  );

  if (!institutionSheet) {
    throw new Error(
      'Sheet "' + CONFIG.SHEETS.INSTITUTIONAL + '" was not found.'
    );
  }

  if (!delegatesSheet) {
    throw new Error(
      'Sheet "' + CONFIG.SHEETS.DELEGATES + '" was not found.'
    );
  }

  const registrationId = generateRegistrationId('INST');
  const timestamp = new Date();

  const facultyAdvisor = data.faculty_advisor || {};
  const headDelegate = data.head_delegate || {};
  const delegates = Array.isArray(data.delegates) ? data.delegates : [];

  institutionSheet.appendRow([
    registrationId,
    timestamp,
    clean(data.institution_name),
    clean(facultyAdvisor.name),
    clean(facultyAdvisor.contact),
    clean(headDelegate.name),
    clean(headDelegate.contact),
    numberValue(data.approximate_delegation_size),
    delegates.length,
    booleanValue(data.declaration_information_accurate),
    booleanValue(data.declaration_code_of_conduct),
    booleanValue(data.declaration_allocation_policy),
    CONFIG.PAYMENT.STATUS_PENDING,
    '',
    '',
    '',
  ]);

  const delegateRows = delegates.map(function(delegate, index) {
    return [
      registrationId,
      timestamp,
      index + 1,
      clean(data.institution_name),
      clean(delegate.full_name),
      clean(delegate.email),
      clean(delegate.contact),
      clean(delegate.class),
      clean(delegate.mun_experience),
      clean(delegate.committee_preference_1),
      clean(delegate.committee_preference_2),
      clean(delegate.portfolio_country_preference_1),
      clean(delegate.portfolio_country_preference_2),
    ];
  });

  if (delegateRows.length > 0) {
    delegatesSheet
      .getRange(
        delegatesSheet.getLastRow() + 1,
        1,
        delegateRows.length,
        delegateRows[0].length
      )
      .setValues(delegateRows);
  }

  return jsonResponse({
    success: true,
    registration_id: registrationId,
    registration_type: 'institutional',
    delegates_saved: delegates.length,
    message: 'Institutional registration submitted successfully.',
  });
}

/* ============================================================
   PAYMENT PROOF UPLOAD
   ============================================================ */

function handlePaymentUpload(data) {
  validatePaymentUpload(data);

  const sheet = getRegistrationSheet(data.registration_type);
  const headerMap = getHeaderMap(sheet);
  const rowIndex = findRowByRegistrationId(
    sheet,
    headerMap,
    data.registration_id
  );

  if (rowIndex === -1) {
    throw new Error('Registration ID not found.');
  }

  const paymentStatusColumn = getRequiredColumnIndex(
    headerMap,
    'Payment Status'
  );
  const paymentUtrColumn = getRequiredColumnIndex(headerMap, 'Payment UTR');
  const screenshotColumn = getRequiredColumnIndex(
    headerMap,
    'Payment Screenshot'
  );
  const submittedAtColumn = getRequiredColumnIndex(
    headerMap,
    'Payment Submitted At'
  );

  const currentStatus = clean(
    sheet.getRange(rowIndex, paymentStatusColumn).getDisplayValue()
  );

  if (currentStatus === CONFIG.PAYMENT.STATUS_VERIFIED) {
    throw new Error(
      'This registration has already been verified and cannot submit payment proof again.'
    );
  }

  const fileBytes = decodePaymentFile(data.file_data);
  const extension = fileExtensionFromMimeType(data.mime_type);
  const folder = getPaymentFolder(data.registration_type);
  const now = new Date();
  const timestamp = now.getTime();
  const fileName = sanitizeFileName(
    data.registration_id + '_payment_' + timestamp + '.' + extension
  );

  const screenshotCell = sheet.getRange(rowIndex, screenshotColumn);
  const previousFormula = screenshotCell.getFormula();
  const previousUrl = extractHyperlinkUrl(previousFormula);

  trashDriveFileIfPossible(previousUrl);

  const blob = Utilities.newBlob(fileBytes, data.mime_type, fileName);
  const file = folder.createFile(blob);
  const fileUrl = file.getUrl();
  const formula = '=HYPERLINK("' + escapeForFormula(fileUrl) + '","View Screenshot")';

  sheet.getRange(rowIndex, paymentStatusColumn).setValue(
    CONFIG.PAYMENT.STATUS_AWAITING
  );
  sheet.getRange(rowIndex, paymentUtrColumn).setValue(clean(data.utr));
  screenshotCell.setFormula(formula);
  sheet.getRange(rowIndex, submittedAtColumn).setValue(now);

  return jsonResponse({
    success: true,
    message: 'Payment proof submitted successfully.',
    registration_id: data.registration_id,
    payment_status: CONFIG.PAYMENT.STATUS_AWAITING,
  });
}

/* ============================================================
   VALIDATION
   ============================================================ */

function validateIndividualRegistration(data) {
  requireValue(data.name, 'name');
  requireValue(data.email, 'email');
  requireValue(data.contact, 'contact');
  requireValue(data.institution, 'institution');
  requireValue(data.class, 'class');
  requireValue(data.committee_preference_1, 'committee_preference_1');
  requireValue(data.committee_preference_2, 'committee_preference_2');
  requireValue(data.portfolio_preference_1, 'portfolio_preference_1');
  requireValue(data.portfolio_preference_2, 'portfolio_preference_2');

  if (data.committee_preference_1 === data.committee_preference_2) {
    throw new Error('Committee preferences must be different.');
  }

  validateDeclarations(data);
}

function validateInstitutionalRegistration(data) {
  requireValue(data.institution_name, 'institution_name');

  if (!data.faculty_advisor) {
    throw new Error('faculty_advisor is required.');
  }

  requireValue(data.faculty_advisor.name, 'faculty_advisor.name');
  requireValue(data.faculty_advisor.contact, 'faculty_advisor.contact');

  if (!data.head_delegate) {
    throw new Error('head_delegate is required.');
  }

  requireValue(data.head_delegate.name, 'head_delegate.name');
  requireValue(data.head_delegate.contact, 'head_delegate.contact');

  const delegationSize = Number(data.approximate_delegation_size);
  if (!Number.isInteger(delegationSize) || delegationSize <= 0) {
    throw new Error(
      'approximate_delegation_size must be a positive integer.'
    );
  }

  if (!Array.isArray(data.delegates) || data.delegates.length === 0) {
    throw new Error('At least one delegate is required.');
  }

  data.delegates.forEach(function(delegate, index) {
    const number = index + 1;

    requireValue(delegate.full_name, 'Delegate ' + number + ' full_name');
    requireValue(delegate.email, 'Delegate ' + number + ' email');
    requireValue(delegate.contact, 'Delegate ' + number + ' contact');
    requireValue(delegate.class, 'Delegate ' + number + ' class');
    requireValue(
      delegate.committee_preference_1,
      'Delegate ' + number + ' committee_preference_1'
    );
    requireValue(
      delegate.committee_preference_2,
      'Delegate ' + number + ' committee_preference_2'
    );
    requireValue(
      delegate.portfolio_country_preference_1,
      'Delegate ' + number + ' portfolio_country_preference_1'
    );
    requireValue(
      delegate.portfolio_country_preference_2,
      'Delegate ' + number + ' portfolio_country_preference_2'
    );

    if (delegate.committee_preference_1 === delegate.committee_preference_2) {
      throw new Error(
        'Delegate ' + number + ' committee preferences must be different.'
      );
    }
  });

  validateDeclarations(data);
}

function validatePaymentUpload(data) {
  requireValue(data.registration_type, 'registration_type');
  requireValue(data.registration_id, 'registration_id');
  requireValue(data.utr, 'utr');
  requireValue(data.file_name, 'file_name');
  requireValue(data.mime_type, 'mime_type');
  requireValue(data.file_data, 'file_data');

  if (!isValidRegistrationType(data.registration_type)) {
    throw new Error('Invalid registration_type: ' + data.registration_type);
  }

  if (CONFIG.PAYMENT.ALLOWED_MIME_TYPES.indexOf(data.mime_type) === -1) {
    throw new Error('Unsupported screenshot file type.');
  }

  const fileBytes = decodePaymentFile(data.file_data);
  if (fileBytes.length > CONFIG.PAYMENT.MAX_FILE_SIZE_BYTES) {
    throw new Error('Screenshot must be 5 MB or smaller.');
  }
}

function validateDeclarations(data) {
  if (
    data.declaration_information_accurate !== true ||
    data.declaration_code_of_conduct !== true ||
    data.declaration_allocation_policy !== true
  ) {
    throw new Error('All declarations must be accepted.');
  }
}

/* ============================================================
   SHEET INITIALIZATION
   ============================================================ */

function initializeSheets() {
  const spreadsheet = getSpreadsheet();

  const individual = getOrCreateSheet(
    spreadsheet,
    CONFIG.SHEETS.INDIVIDUAL
  );
  setHeaders(individual, [
    'Registration ID',
    'Timestamp',
    'Delegate Name',
    'Email',
    'Contact Number',
    'Institution',
    'Class',
    'MUN Experience',
    'Committee Preference 1',
    'Committee Preference 2',
    'Portfolio Preference 1',
    'Portfolio Preference 2',
    'Information Accurate',
    'Code of Conduct Accepted',
    'Allocation Policy Accepted',
    'Payment Status',
    'Payment UTR',
    'Payment Screenshot',
    'Payment Submitted At',
  ]);

  const institutional = getOrCreateSheet(
    spreadsheet,
    CONFIG.SHEETS.INSTITUTIONAL
  );
  setHeaders(institutional, [
    'Registration ID',
    'Timestamp',
    'Institution Name',
    'Faculty Advisor Name',
    'Faculty Advisor Contact',
    'Head Delegate Name',
    'Head Delegate Contact',
    'Approximate Delegation Size',
    'Delegates Submitted',
    'Information Accurate',
    'Code of Conduct Accepted',
    'Allocation Policy Accepted',
    'Payment Status',
    'Payment UTR',
    'Payment Screenshot',
    'Payment Submitted At',
  ]);

  const delegates = getOrCreateSheet(
    spreadsheet,
    CONFIG.SHEETS.DELEGATES
  );
  setHeaders(delegates, [
    'Registration ID',
    'Timestamp',
    'Delegate Number',
    'Institution Name',
    'Delegate Name',
    'Email',
    'Contact Number',
    'Class',
    'MUN Experience',
    'Committee Preference 1',
    'Committee Preference 2',
    'Portfolio Preference 1',
    'Portfolio Preference 2',
  ]);

  formatSheet(individual);
  formatSheet(institutional);
  formatSheet(delegates);

  console.log('JPUMUN registration sheets initialized.');
}

/* ============================================================
   HELPERS
   ============================================================ */

function getSpreadsheet() {
  return SpreadsheetApp.openById(CONFIG.SPREADSHEET_ID);
}

function getRegistrationSheet(registrationType) {
  const spreadsheet = getSpreadsheet();

  switch (registrationType) {
    case 'individual':
      return getExistingSheet(spreadsheet, CONFIG.SHEETS.INDIVIDUAL);
    case 'institutional':
      return getExistingSheet(spreadsheet, CONFIG.SHEETS.INSTITUTIONAL);
    default:
      throw new Error('Invalid registration_type: ' + registrationType);
  }
}

function getExistingSheet(spreadsheet, sheetName) {
  const sheet = spreadsheet.getSheetByName(sheetName);
  if (!sheet) {
    throw new Error('Sheet "' + sheetName + '" was not found.');
  }
  return sheet;
}

function getOrCreateSheet(spreadsheet, sheetName) {
  return spreadsheet.getSheetByName(sheetName) || spreadsheet.insertSheet(sheetName);
}

function setHeaders(sheet, headers) {
  const headerRange = sheet.getRange(1, 1, 1, headers.length);
  headerRange.setValues([headers]);

  if (sheet.getFrozenRows() < 1) {
    sheet.setFrozenRows(1);
  }
}

function formatSheet(sheet) {
  const lastColumn = sheet.getLastColumn();
  if (lastColumn === 0) return;

  const headerRange = sheet.getRange(1, 1, 1, lastColumn);
  headerRange
    .setFontWeight('bold')
    .setBackground('#d9e2f3')
    .setWrap(true);

  sheet.autoResizeColumns(1, lastColumn);
}

function getHeaderMap(sheet) {
  const lastColumn = sheet.getLastColumn();
  if (lastColumn === 0) {
    throw new Error('Sheet has no headers.');
  }

  const headers = sheet.getRange(1, 1, 1, lastColumn).getValues()[0];
  const map = {};

  headers.forEach(function(header, index) {
    map[String(header).trim()] = index + 1;
  });

  return map;
}

function getRequiredColumnIndex(headerMap, headerName) {
  const columnIndex = headerMap[headerName];
  if (!columnIndex) {
    throw new Error(
      'Required column "' + headerName + '" was not found in the sheet.'
    );
  }
  return columnIndex;
}

function findRowByRegistrationId(sheet, headerMap, registrationId) {
  const idColumn = getRequiredColumnIndex(headerMap, 'Registration ID');
  const lastRow = sheet.getLastRow();

  if (lastRow < 2) {
    return -1;
  }

  const values = sheet.getRange(2, idColumn, lastRow - 1, 1).getValues();

  for (var index = 0; index < values.length; index++) {
    if (clean(values[index][0]) === clean(registrationId)) {
      return index + 2;
    }
  }

  return -1;
}

function decodePaymentFile(base64Data) {
  try {
    return Utilities.base64Decode(base64Data);
  } catch (_) {
    throw new Error('Payment screenshot data is invalid.');
  }
}

function getPaymentFolder(registrationType) {
  const root = getOrCreateDriveFolder(CONFIG.DRIVE.ROOT_FOLDER);
  const paymentRoot = getOrCreateChildFolder(root, CONFIG.DRIVE.PAYMENT_FOLDER);

  switch (registrationType) {
    case 'individual':
      return getOrCreateChildFolder(
        paymentRoot,
        CONFIG.DRIVE.INDIVIDUAL_FOLDER
      );
    case 'institutional':
      return getOrCreateChildFolder(
        paymentRoot,
        CONFIG.DRIVE.INSTITUTIONAL_FOLDER
      );
    default:
      throw new Error('Invalid registration_type: ' + registrationType);
  }
}

function getOrCreateDriveFolder(folderName) {
  const folders = DriveApp.getFoldersByName(folderName);
  return folders.hasNext() ? folders.next() : DriveApp.createFolder(folderName);
}

function getOrCreateChildFolder(parentFolder, folderName) {
  const folders = parentFolder.getFoldersByName(folderName);
  return folders.hasNext()
    ? folders.next()
    : parentFolder.createFolder(folderName);
}

function trashDriveFileIfPossible(fileUrl) {
  if (!fileUrl) {
    return;
  }

  const fileId = extractDriveFileId(fileUrl);
  if (!fileId) {
    return;
  }

  try {
    DriveApp.getFileById(fileId).setTrashed(true);
  } catch (_) {}
}

function extractHyperlinkUrl(formula) {
  if (!formula) {
    return '';
  }

  const match = String(formula).match(/=HYPERLINK\("([^"]+)"/i);
  return match ? match[1] : '';
}

function extractDriveFileId(url) {
  if (!url) {
    return '';
  }

  const fileMatch = String(url).match(/[-\w]{25,}/);
  return fileMatch ? fileMatch[0] : '';
}

function fileExtensionFromMimeType(mimeType) {
  switch (mimeType) {
    case 'image/jpeg':
      return 'jpg';
    case 'image/png':
      return 'png';
    case 'image/webp':
      return 'webp';
    default:
      throw new Error('Unsupported screenshot file type.');
  }
}

function sanitizeFileName(fileName) {
  return String(fileName).replace(/[^a-zA-Z0-9._-]/g, '_');
}

function escapeForFormula(value) {
  return String(value).replace(/"/g, '""');
}

function generateRegistrationId(prefix) {
  const now = new Date();
  const stamp = Utilities.formatDate(
    now,
    Session.getScriptTimeZone(),
    'yyyyMMddHHmmss'
  );
  const random = Math.floor(Math.random() * 900 + 100);
  return prefix + '-' + stamp + '-' + random;
}

function requireValue(value, fieldName) {
  if (value === null || value === undefined || String(value).trim() === '') {
    throw new Error(fieldName + ' is required.');
  }
}

function isValidRegistrationType(registrationType) {
  return registrationType === 'individual' || registrationType === 'institutional';
}

function clean(value) {
  if (value === null || value === undefined) return '';
  return String(value).trim();
}

function booleanValue(value) {
  return value === true;
}

function numberValue(value) {
  const num = Number(value);
  return Number.isFinite(num) ? num : '';
}

function jsonResponse(payload) {
  return ContentService
    .createTextOutput(JSON.stringify(payload))
    .setMimeType(ContentService.MimeType.JSON);
}
