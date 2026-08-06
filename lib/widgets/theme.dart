import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeSection extends StatelessWidget {
  const ThemeSection({super.key});

  static const Color _background = Color(0xFF0B132B);
  static const Color _gold = Color(0xFFC9A86A);
  static const Color _white = Colors.white;
  static const Color _divider = Color(0xFF5C1A1B);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width < 700) {
          return _buildMobile();
        }

        if (width < 1200) {
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

              const SizedBox(height: 22),

              _buildSubtitle(
                fontSize: 30,
              ),

              const SizedBox(height: 42),

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

          const SizedBox(height: 20),

          _buildSubtitle(
            fontSize: 24,
          ),

          const SizedBox(height: 36),

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
        55,
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

          const SizedBox(height: 14),

          _buildSubtitle(
            fontSize: 17,
          ),

          const SizedBox(height: 28),

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
      'CONFERENCE THEME',
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
      'The G20 Summit',
      style: GoogleFonts.prata(
        color: _gold,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        height: 1.1,
      ),
    );
  }

  // ============================================================
  // SUBTITLE
  // ============================================================

  Widget _buildSubtitle({
    required double fontSize,
  }) {
    return Text(
      "Where the world's leading nations convene, "
      "and decisions carry weight.",
      style: GoogleFonts.prata(
        color: _gold,
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        height: 1.35,
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
    return Text(
      "JPUMUN'26 draws its identity from the prestige of the G20 Summit — "
      "a gathering where the world's most influential nations come together "
      "to deliberate on matters that shape the global order.\n\n"
      "The theme reflects the formality, discipline, and gravity of "
      "high-level diplomacy: measured words, calculated positions, and the "
      "understanding that every decision made echoes beyond the room.\n\n"
      "Delegates at JPUMUN'26 will step into this world of statecraft, "
      "representing their nations with the poise and precision expected at "
      "the world's highest tables.",
      style: GoogleFonts.ibmPlexSans(
        color: _white,
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        height: lineHeight,
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