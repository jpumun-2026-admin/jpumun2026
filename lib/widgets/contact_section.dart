import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  static const Color _background = Color(0xFF0B132B);
  static const Color _cardBackground = Color(0xFF1E1E1E);
  static const Color _gold = Color(0xFFC9A86A);
  static const Color _red = Color(0xFF792923);
  static const Color _white = Color(0xFFF9F5F4);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width < 700) {
          return _buildSection(
            horizontalPadding: 24,
            verticalPadding: 60,
            maxContentWidth: double.infinity,
            sectionFontSize: 14,
            sectionLetterSpacing: 7,
            cardPadding: 22,
            cardRadius: 16,
            cardGap: 32,
            titleFontSize: 24,
            bodyFontSize: 15,
          );
        }

        if (width < 1200) {
          return _buildSection(
            horizontalPadding: 60,
            verticalPadding: 75,
            maxContentWidth: 900,
            sectionFontSize: 17,
            sectionLetterSpacing: 9,
            cardPadding: 28,
            cardRadius: 17,
            cardGap: 42,
            titleFontSize: 27,
            bodyFontSize: 16,
          );
        }

        return _buildSection(
          horizontalPadding: 100,
          verticalPadding: 80,
          maxContentWidth: 1160,
          sectionFontSize: 18,
          sectionLetterSpacing: 10,
          cardPadding: 26,
          cardRadius: 17,
          cardGap: 48,
          titleFontSize: 28,
          bodyFontSize: 17,
        );
      },
    );
  }

  Widget _buildSection({
    required double horizontalPadding,
    required double verticalPadding,
    required double maxContentWidth,
    required double sectionFontSize,
    required double sectionLetterSpacing,
    required double cardPadding,
    required double cardRadius,
    required double cardGap,
    required double titleFontSize,
    required double bodyFontSize,
  }) {
    return Container(
      width: double.infinity,
      color: _background,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        verticalPadding,
        horizontalPadding,
        verticalPadding + 30,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel(
                fontSize: sectionFontSize,
                letterSpacing: sectionLetterSpacing,
              ),

              const SizedBox(height: 48),

              // General contact information
              _ContactCard(
                title: 'Get In Touch With JPUMUN',
                padding: cardPadding,
                radius: cardRadius,
                titleFontSize: titleFontSize,
                bodyFontSize: bodyFontSize,
                children: const [
                  _ContactLine(label: 'Email:', value: 'munsocjgi@gmail.com'),

                  SizedBox(height: 28),

                  _ContactLine(
                    label: 'Address:',
                    value:
                        'Jain University Jayanager. 44/4, District Fund Rd, '
                        'behind Smart Bazaar,\nKottapalya, Jayanagara 9th '
                        'Block, Jayanagar, Bengaluru, Karnataka 560069',
                  ),

                  SizedBox(height: 28),

                  _ContactLine(
                    label: 'Conference Dates:',
                    value: '31st August 2026 & 1st September 2026',
                  ),

                  SizedBox(height: 4),

                  _ContactLine(
                    label: 'Follow The MUN Society:',
                    value: '@themunsoc_jgi',
                  ),
                ],
              ),

              SizedBox(height: cardGap),

              // Coordinators
              _ContactCard(
                title: 'Student Coordinators & Faculty Coordinators',
                padding: cardPadding,
                radius: cardRadius,
                titleFontSize: titleFontSize,
                bodyFontSize: bodyFontSize,
                children: const [
                  _ContactLine(
                    label: 'Secretary General:',
                    value: 'Pratima M (+91 8660843813)',
                  ),

                  SizedBox(height: 4),

                  _ContactLine(
                    label: 'Director General:',
                    value: 'Yasar Zayan (+91 6360172656)',
                  ),

                  SizedBox(height: 28),

                  _ContactLine(
                    label: 'Faculty Coordinator:',
                    value: 'Ms Minu Xalxo (+91 7992348597)',
                  ),

                  SizedBox(height: 4),

                  _ContactLine(
                    label: 'Faculty Coordinator:',
                    value: 'Ms Lavanya (+91 7010013710)',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel({
    required double fontSize,
    required double letterSpacing,
  }) {
    return Text(
      'CONTACT',
      style: GoogleFonts.ibmPlexSans(
        color: _gold,
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        letterSpacing: letterSpacing,
        height: 1.2,
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.title,
    required this.children,
    required this.padding,
    required this.radius,
    required this.titleFontSize,
    required this.bodyFontSize,
  });

  final String title;
  final List<Widget> children;
  final double padding;
  final double radius;
  final double titleFontSize;
  final double bodyFontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(padding, padding, padding, padding + 2),
      decoration: BoxDecoration(
        color: ContactSection._cardBackground,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: ContactSection._red, width: 1.5),
      ),
      child: DefaultTextStyle(
        style: GoogleFonts.ibmPlexSans(
          color: ContactSection._white,
          fontSize: bodyFontSize,
          fontWeight: FontWeight.w400,
          height: 1.55,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.ibmPlexSerif(
                color: ContactSection._gold,
                fontSize: titleFontSize,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 22),

            ...children,
          ],
        ),
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context).style;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: defaultStyle.copyWith(
              color: const Color(0xFFD0C3C3),
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: value,
            style: defaultStyle.copyWith(
              color: ContactSection._white,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
