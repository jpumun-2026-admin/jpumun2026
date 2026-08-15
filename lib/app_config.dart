const String kRegistrationApiUrl =
    'hhttps://script.google.com/macros/s/AKfycbyr7qpodZ6CBgz70Rge_hT1FV6On6Ll2ELlgELXbvcp2tod9Lj6T_JP1Tl9E8AGVr6p/exec';

const int kIndividualRegistrationFeePaise = 95000;
const int kInstitutionalRegistrationFeePerDelegatePaise = 95000;

const String kUpiId = 'REPLACE_WITH_JPUMUN_UPI_ID';
const String kUpiQrAsset = 'lib/assets/upi_qr.png';

const int kMaxPaymentScreenshotBytes = 5 * 1024 * 1024;

String formatInrFromPaise(int amountPaise) {
  final rupees = amountPaise ~/ 100;
  final paise = amountPaise % 100;
  final rupeeText = rupees.toString();

  if (paise == 0) {
    return 'INR $rupeeText';
  }

  return 'INR $rupeeText.${paise.toString().padLeft(2, '0')}';
}
