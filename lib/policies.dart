import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PoliciesPage extends StatelessWidget {
  const PoliciesPage({super.key});

  static const Color _background = Color(0xFF0B132B);
  static const Color _surface = Color(0xFF111A33);
  static const Color _gold = Color(0xFFC9A86A);
  static const Color _red = Color(0xFF5C1A1B);
  static const Color _white = Color(0xFFF9F5F4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).maybePop();
                      },
                      icon: const Icon(Icons.arrow_back_rounded, color: _gold),
                      label: Text(
                        'Back',
                        style: GoogleFonts.ibmPlexSans(
                          color: _gold,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Terms and Conditions',
                      style: GoogleFonts.prata(
                        color: _gold,
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'JPUMUN 2026 Registration Policies',
                      style: GoogleFonts.ibmPlexSans(
                        color: _white,
                        fontSize: 18,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _PolicyCard(
                      title: 'Terms and Conditions',
                      paragraphs: const [
                        'By submitting a registration for JPUMUN 2026, the participant or institution confirms that all information provided is accurate and complete.',
                        'Registration is valid only after the registration form is submitted, payment proof is uploaded, and the payment is manually verified by the Secretariat.',
                        'Each delegate must submit two committee preferences and the corresponding portfolio preferences in the registration form.',
                        'The Secretariat reserves the right to verify submitted information and communicate allocations, updates, and logistical details through the provided contact information.',
                        'Committee and portfolio allocations remain subject to availability and the discretion of the Secretariat and are not guaranteed to match the submitted preferences.',
                      ],
                    ),
                    const SizedBox(height: 22),
                    _PolicyCard(
                      title: 'Refund and Cancellation Policy',
                      paragraphs: const [
                        'All registration fees paid for JPUMUN 2026 are final.',
                        'No refund is possible for any registration fee paid under any circumstance.',
                        'No cancellation is possible once a registration fee has been paid.',
                        'Participants and institutions should review all registration details, including committee and portfolio preferences, carefully before proceeding to payment.',
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  const _PolicyCard({required this.title, required this.paragraphs});

  final String title;
  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 26),
      decoration: BoxDecoration(
        color: PoliciesPage._surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PoliciesPage._red, width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.prata(
              color: PoliciesPage._gold,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          for (final paragraph in paragraphs) ...[
            Text(
              paragraph,
              style: GoogleFonts.ibmPlexSans(
                color: PoliciesPage._white,
                fontSize: 16,
                height: 1.7,
              ),
            ),
            if (paragraph != paragraphs.last) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}
