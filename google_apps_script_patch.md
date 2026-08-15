# Google Apps Script Update

Replace the following parts of your Apps Script with these updated versions so the individual registration flow stores two separate portfolio preferences.

## `handleIndividualRegistration(data)`

```javascript
function handleIndividualRegistration(data) {
  validateIndividualRegistration(data);

  const spreadsheet = getSpreadsheet();

  const sheet = spreadsheet.getSheetByName(
    CONFIG.SHEETS.INDIVIDUAL
  );

  if (!sheet) {
    throw new Error(
      'Sheet "' + CONFIG.SHEETS.INDIVIDUAL + '" was not found.'
    );
  }

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

    'Pending',
  ]);

  return jsonResponse({
    success: true,
    registration_id: registrationId,
    registration_type: 'individual',
    message: 'Individual registration submitted successfully.',
  });
}
```

## `validateIndividualRegistration(data)`

```javascript
function validateIndividualRegistration(data) {
  requireValue(data.name, 'name');
  requireValue(data.email, 'email');
  requireValue(data.contact, 'contact');
  requireValue(data.institution, 'institution');
  requireValue(data.class, 'class');

  requireValue(
    data.committee_preference_1,
    'committee_preference_1'
  );

  requireValue(
    data.committee_preference_2,
    'committee_preference_2'
  );

  requireValue(
    data.portfolio_preference_1,
    'portfolio_preference_1'
  );

  requireValue(
    data.portfolio_preference_2,
    'portfolio_preference_2'
  );

  if (
    data.committee_preference_1 ===
    data.committee_preference_2
  ) {
    throw new Error(
      'Committee preferences must be different.'
    );
  }

  validateDeclarations(data);
}
```

## Individual headers inside `initializeSheets()`

```javascript
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
]);
```

## Notes

- Institutional delegate handling already expects:
  - `portfolio_country_preference_1`
  - `portfolio_country_preference_2`
- The Flutter app has already been updated to send those keys.
- After updating the script, redeploy the Apps Script web app so the live endpoint uses the new version.
