import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jpumun_website/app_config.dart';
import 'package:jpumun_website/services/registration_api.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({
    required this.registrationId,
    required this.registrationType,
    required this.amountPaise,
    super.key,
  });

  final String registrationId;
  final String registrationType;
  final int amountPaise;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  static const Color background = Color(0xFF0B132B);
  static const Color fieldBackground = Color(0xFF1E1E1E);
  static const Color gold = Color(0xFFC9A86A);
  static const Color red = Color(0xFF5C1A1B);
  static const Color white = Color(0xFFF9F5F4);
  static const Color surface = Color(0xFF111A33);

  final _utrController = TextEditingController();

  Uint8List? _selectedBytes;
  String? _selectedFileName;
  String? _selectedMimeType;
  int? _selectedFileSize;
  bool _isSubmitting = false;
  bool _submissionComplete = false;

  @override
  void dispose() {
    _utrController.dispose();
    super.dispose();
  }

  Future<void> _pickScreenshot() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      withData: true,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      _showMessage('Could not read the selected screenshot.');
      return;
    }

    if (bytes.length > kMaxPaymentScreenshotBytes) {
      _showMessage('Screenshot must be 5 MB or smaller.');
      return;
    }

    final mimeType = _mimeTypeFromName(file.name);
    if (mimeType == null) {
      _showMessage('Only JPG, JPEG, PNG, and WebP files are allowed.');
      return;
    }

    setState(() {
      _selectedBytes = bytes;
      _selectedFileName = file.name;
      _selectedMimeType = mimeType;
      _selectedFileSize = bytes.length;
    });
  }

  Future<void> _submitPaymentProof() async {
    if (_isSubmitting) {
      return;
    }

    final utr = _utrController.text.trim();
    if (utr.isEmpty) {
      _showMessage('Please enter your UTR / Transaction ID.');
      return;
    }

    if (_selectedBytes == null ||
        _selectedFileName == null ||
        _selectedMimeType == null) {
      _showMessage('Please upload your payment screenshot.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await RegistrationApi.uploadPaymentProof(
        registrationType: widget.registrationType,
        registrationId: widget.registrationId,
        utr: utr,
        fileName: _selectedFileName!,
        mimeType: _selectedMimeType!,
        fileData: base64Encode(_selectedBytes!),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _submissionComplete = true;
      });

      _showMessage(
        response['message']?.toString() ??
            'Payment proof submitted successfully.',
      );
    } on RegistrationApiException catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage(
        'Could not submit payment proof right now. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: fieldBackground,
        behavior: SnackBarBehavior.floating,
        content: Text(message, style: GoogleFonts.ibmPlexSans(color: white)),
      ),
    );
  }

  String? _mimeTypeFromName(String fileName) {
    final name = fileName.toLowerCase();
    if (name.endsWith('.jpg') || name.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (name.endsWith('.png')) {
      return 'image/png';
    }
    if (name.endsWith('.webp')) {
      return 'image/webp';
    }
    return null;
  }

  String _registrationTypeLabel() {
    switch (widget.registrationType) {
      case 'institutional':
        return 'Institutional Delegation';
      case 'individual':
      default:
        return 'Individual Delegate';
    }
  }

  String _fileSizeLabel(int bytes) {
    final kb = bytes / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(1)} KB';
    }
    return '${(kb / 1024).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 18 : 28,
            isMobile ? 20 : 28,
            isMobile ? 18 : 28,
            isMobile ? 42 : 60,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: _submissionComplete
                  ? _buildConfirmationView(isMobile: isMobile)
                  : _buildFormView(isMobile: isMobile),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded, color: gold),
          label: Text(
            'Back',
            style: GoogleFonts.ibmPlexSans(
              color: gold,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: isMobile ? 16 : 20),
        Text(
          'Payment Verification',
          style: GoogleFonts.prata(
            color: gold,
            fontSize: isMobile ? 34 : 48,
            fontWeight: FontWeight.w700,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Complete your UPI payment manually and submit the transaction proof for verification.',
          style: GoogleFonts.ibmPlexSans(
            color: white,
            fontSize: isMobile ? 15 : 18,
            height: 1.7,
          ),
        ),
        SizedBox(height: isMobile ? 26 : 34),
        Wrap(
          spacing: 18,
          runSpacing: 18,
          children: [
            _InfoCard(title: 'Registration ID', value: widget.registrationId),
            _InfoCard(
              title: 'Registration Type',
              value: _registrationTypeLabel(),
            ),
            _InfoCard(
              title: 'Registration Fee',
              value: formatInrFromPaise(widget.amountPaise),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 26 : 36),
        Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: isMobile ? 0 : 9,
              child: _buildQrPanel(isMobile: isMobile),
            ),
            SizedBox(width: isMobile ? 0 : 22, height: isMobile ? 22 : 0),
            Expanded(
              flex: isMobile ? 0 : 11,
              child: _buildSubmissionPanel(isMobile: isMobile),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQrPanel({required bool isMobile}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 28),
      decoration: BoxDecoration(
        color: fieldBackground,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: gold.withValues(alpha: 0.6), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UPI Payment',
            style: GoogleFonts.prata(
              color: gold,
              fontSize: isMobile ? 28 : 34,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Scan the QR code below or pay directly to the UPI ID shown here. Please complete the payment before submitting your UTR and screenshot.',
            style: GoogleFonts.ibmPlexSans(
              color: white,
              fontSize: 15,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: isMobile ? 240 : 300,
              height: isMobile ? 240 : 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Image.asset(
                kUpiQrAsset,
                fit: BoxFit.contain,
                errorBuilder: (_, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EEE4),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFC9A86A),
                        width: 1.2,
                      ),
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Center(
                      child: Text(
                        'Add your QR image at\n$kUpiQrAsset',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ibmPlexSans(
                          color: const Color(0xFF0B132B),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.6,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: red, width: 1.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UPI ID',
                  style: GoogleFonts.ibmPlexSans(
                    color: gold,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  kUpiId,
                  style: GoogleFonts.ibmPlexSans(
                    color: white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _InstructionLine(text: 'Pay the exact registration fee shown above.'),
          const SizedBox(height: 12),
          _InstructionLine(
            text: 'Keep your UTR / Transaction ID ready after payment.',
          ),
          const SizedBox(height: 12),
          _InstructionLine(
            text: 'Your payment will be manually verified by the Secretariat.',
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionPanel({required bool isMobile}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 28),
      decoration: BoxDecoration(
        color: fieldBackground,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: red, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Submit Payment Proof',
            style: GoogleFonts.prata(
              color: gold,
              fontSize: isMobile ? 28 : 34,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Enter the UTR / Transaction ID from your payment app and upload a screenshot of the successful payment.',
            style: GoogleFonts.ibmPlexSans(
              color: white,
              fontSize: 15,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'UTR / TRANSACTION ID',
            style: GoogleFonts.ibmPlexSans(
              color: gold,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.7,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _utrController,
            cursorColor: gold,
            style: GoogleFonts.ibmPlexSans(color: white, fontSize: 17),
            decoration: InputDecoration(
              hintText: 'Enter your UTR / Transaction ID',
              hintStyle: GoogleFonts.ibmPlexSans(
                color: white.withValues(alpha: 0.54),
                fontSize: 16,
              ),
              filled: true,
              fillColor: surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: red, width: 1.2),
                borderRadius: BorderRadius.circular(18),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: gold, width: 1.3),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'PAYMENT SCREENSHOT',
            style: GoogleFonts.ibmPlexSans(
              color: gold,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.7,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _isSubmitting ? null : _pickScreenshot,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              side: const BorderSide(color: gold, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              foregroundColor: gold,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.upload_file_rounded, size: 22),
                const SizedBox(width: 12),
                Text(
                  _selectedFileName == null
                      ? 'UPLOAD SCREENSHOT'
                      : 'CHANGE SCREENSHOT',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Accepted formats: JPG, JPEG, PNG, WebP. Maximum size: 5 MB.',
            style: GoogleFonts.ibmPlexSans(
              color: white.withValues(alpha: 0.78),
              fontSize: 13,
              height: 1.6,
            ),
          ),
          if (_selectedBytes != null) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: red, width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(
                      _selectedBytes!,
                      width: double.infinity,
                      height: isMobile ? 220 : 260,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _selectedFileName!,
                    style: GoogleFonts.ibmPlexSans(
                      color: white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_selectedFileSize != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _fileSizeLabel(_selectedFileSize!),
                      style: GoogleFonts.ibmPlexSans(color: gold, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 26),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0x1AF9F5F4),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0x335C1A1B)),
            ),
            child: Text(
              'Your payment proof will be reviewed manually. Your status will be marked as AWAITING VERIFICATION after submission.',
              style: GoogleFonts.ibmPlexSans(
                color: white,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitPaymentProof,
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: background,
                disabledBackgroundColor: gold.withValues(alpha: 0.55),
                disabledForegroundColor: background.withValues(alpha: 0.75),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: _isSubmitting
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(background),
                      ),
                    )
                  : Text(
                      'SUBMIT PAYMENT',
                      style: GoogleFonts.prata(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationView({required bool isMobile}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 24 : 34),
      decoration: BoxDecoration(
        color: fieldBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: red, width: 1.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Proof Submitted',
            style: GoogleFonts.prata(
              color: gold,
              fontSize: isMobile ? 34 : 44,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your registration has been recorded and your payment proof has been sent to the Secretariat for manual verification.',
            style: GoogleFonts.ibmPlexSans(
              color: white,
              fontSize: isMobile ? 15 : 18,
              height: 1.75,
            ),
          ),
          SizedBox(height: isMobile ? 24 : 30),
          Wrap(
            spacing: 18,
            runSpacing: 18,
            children: [
              _InfoCard(title: 'Registration ID', value: widget.registrationId),
              const _InfoCard(
                title: 'Payment Status',
                value: 'AWAITING VERIFICATION',
              ),
              _InfoCard(
                title: 'Amount Submitted',
                value: formatInrFromPaise(widget.amountPaise),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: gold.withValues(alpha: 0.4)),
            ),
            child: Text(
              'Please wait for the organizer to review your UTR and screenshot. You will not be marked as verified until the payment proof has been manually checked.',
              style: GoogleFonts.ibmPlexSans(
                color: white,
                fontSize: 15,
                height: 1.7,
              ),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/home', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: background,
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                'BACK TO HOME',
                style: GoogleFonts.prata(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      constraints: const BoxConstraints(minHeight: 108),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF5C1A1B), width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.ibmPlexSans(
              color: const Color(0xFFC9A86A),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.prata(
              color: const Color(0xFFF9F5F4),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionLine extends StatelessWidget {
  const _InstructionLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 7),
          decoration: const BoxDecoration(
            color: _PaymentPageState.gold,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.ibmPlexSans(
              color: const Color(0xFFF9F5F4),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
