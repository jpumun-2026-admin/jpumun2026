import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  static const Color _background = Color(0xFF0B132B);
  static const Color _gold = Color(0xFFC9A86A);
  static const Color _white = Colors.white;
  static const Color _divider = Color(0xFF5C1A1B);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final bool isMobile = width < 700;
        final bool isTablet = width >= 700 && width < 1200;

        if (isMobile) {
          return _buildMobile();
        }

        if (isTablet) {
          return _buildTablet();
        }

        return _buildDesktop();
      },
    );
  }

  // ============================================================
  // DESKTOP
  // ============================================================

  Widget _buildDesktop() {
    return Container(
      width: double.infinity,
      color: _background,
      padding: const EdgeInsets.fromLTRB(
        120,
        100,
        120,
        100,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1696,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel(
                fontSize: 28,
                letterSpacing: 13,
              ),

              const SizedBox(height: 18),

              _buildTitle(
                fontSize: 76,
              ),

              const SizedBox(height: 32),

              _buildBody(
                fontSize: 30,
                lineHeight: 1.45,
              ),

              const SizedBox(height: 100),

              _buildDivider(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TABLET
  // ============================================================

  Widget _buildTablet() {
    return Container(
      width: double.infinity,
      color: _background,
      padding: const EdgeInsets.fromLTRB(
        60,
        80,
        60,
        80,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(
            fontSize: 21,
            letterSpacing: 9,
          ),

          const SizedBox(height: 18),

          _buildTitle(
            fontSize: 58,
          ),

          const SizedBox(height: 28),

          _buildBody(
            fontSize: 24,
            lineHeight: 1.45,
          ),

          const SizedBox(height: 80),

          _buildDivider(),
        ],
      ),
    );
  }

  // ============================================================
  // MOBILE
  // ============================================================

  Widget _buildMobile() {
    return Container(
      width: double.infinity,
      color: _background,
      padding: const EdgeInsets.fromLTRB(
        24,
        60,
        24,
        55,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(
            fontSize: 11,
            letterSpacing: 5,
          ),

          const SizedBox(height: 16),

          _buildTitle(
            fontSize: 32,
          ),

          const SizedBox(height: 22),

          _buildBody(
            fontSize: 15,
            lineHeight: 1.5,
          ),

          const SizedBox(height: 55),

          _buildDivider(),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION LABEL
  // ============================================================

  Widget _buildSectionLabel({
    required double fontSize,
    required double letterSpacing,
  }) {
    return Text(
      'ABOUT JPUMUN 2026',
      style: GoogleFonts.ibmPlexSans(
        color: _gold,
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        letterSpacing: letterSpacing,
        height: 1.2,
      ),
    );
  }

  // ============================================================
  // TITLE
  // ============================================================

  Widget _buildTitle({
    required double fontSize,
  }) {
    return Text(
      'The MUN Society',
      style: GoogleFonts.prata(
        color: _gold,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        height: 1.1,
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody({
    required double fontSize,
    required double lineHeight,
  }) {
    final bodyStyle = GoogleFonts.ibmPlexSans(
      color: _white,
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      height: lineHeight,
    );

    return Text.rich(
      TextSpan(
        style: bodyStyle,
        children: const [
          TextSpan(
            text:
                "JPUMUN'26 is the inaugural edition of the Model United "
                "Nations conference organized by the Jain PU College "
                "MUN Society.\n\n",
          ),
          TextSpan(
            text:
                "The conference brings together young delegates to engage "
                "in debate, negotiation, and diplomacy, exploring the space "
                "between public discourse and the decisions that truly shape "
                "outcomes, where every alliance carries a cost, and every "
                "vote is preceded by quieter negotiations.\n\n",
          ),
          TextSpan(
            text:
                "As the first edition hosted by The MUN Society, JPUMUN'26 "
                "marks the beginning of what we hope will become a lasting "
                "tradition of debate and diplomacy at Jain PU College, "
                "Jaynagar.",
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 1,
      decoration: BoxDecoration(
        color: _divider,
        boxShadow: [
          BoxShadow(
            color: _divider.withValues(alpha: 0.45),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}