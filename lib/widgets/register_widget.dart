import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class RegistrationSection extends StatelessWidget {
  const RegistrationSection({super.key});

  static const Color _background = Color(0xFF0B132B);
  static const Color _cardBackground = Color(0xFF1E1E1E);
  static const Color _gold = Color(0xFFC9A86A);
  static const Color _red = Color(0xFF5C1A1B);
  static const Color _white = Colors.white;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width < 700) {
          return _buildMobile(context);
        }

        if (width < 1200) {
          return _buildTablet(context);
        }

        return _buildDesktop(context);
      },
    );
  }

  // ============================================================
  // DESKTOP
  // ============================================================

  Widget _buildDesktop(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _background,
      padding: const EdgeInsets.fromLTRB(120, 100, 120, 120),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1696),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel(fontSize: 28, letterSpacing: 13),

              const SizedBox(height: 55),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _RegistrationCard(
                      title: 'Individual Delegation',
                      description:
                          'Register as an individual delegate and take your '
                          'place at the committee table.',
                      height: 520,
                      titleSize: 36,
                      bodySize: 20,
                      buttonHeight: 82,
                      buttonTextSize: 25,
                      padding: 32,
                      onRegister: () {
                        _openRegistration('individual');
                      },
                    ),
                  ),

                  const SizedBox(width: 40),

                  Expanded(
                    child: _RegistrationCard(
                      title: 'Institutional Delegation',
                      description:
                          'Represent your institution as a delegation at '
                          "JPUMUN'26.",
                      height: 520,
                      titleSize: 36,
                      bodySize: 20,
                      buttonHeight: 82,
                      buttonTextSize: 25,
                      padding: 32,
                      onRegister: () {
                        _openRegistration('institutional');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TABLET
  // ============================================================

  Widget _buildTablet(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _background,
      padding: const EdgeInsets.fromLTRB(60, 80, 60, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(fontSize: 21, letterSpacing: 9),

          const SizedBox(height: 45),

          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _RegistrationCard(
                  title: 'Individual Delegation',
                  description:
                      'Register as an individual delegate and take your '
                      'place at the committee table.',
                  height: 430,
                  titleSize: 28,
                  bodySize: 17,
                  buttonHeight: 68,
                  buttonTextSize: 20,
                  padding: 26,
                  onRegister: () {
                    _openRegistration('individual');
                  },
                ),
              ),

              const SizedBox(width: 24),

              Expanded(
                child: _RegistrationCard(
                  title: 'Institutional Delegation',
                  description:
                      'Represent your institution as a delegation at '
                      "JPUMUN'26.",
                  height: 430,
                  titleSize: 28,
                  bodySize: 17,
                  buttonHeight: 68,
                  buttonTextSize: 20,
                  padding: 26,
                  onRegister: () {
                    _openRegistration('institutional');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOBILE
  // ============================================================

  Widget _buildMobile(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _background,
      padding: const EdgeInsets.fromLTRB(24, 55, 24, 70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(fontSize: 11, letterSpacing: 5),

          const SizedBox(height: 32),

          _RegistrationCard(
            title: 'Individual Delegation',
            description:
                'Register as an individual delegate and take your '
                'place at the committee table.',
            height: 350,
            titleSize: 26,
            bodySize: 15,
            buttonHeight: 60,
            buttonTextSize: 18,
            padding: 22,
            onRegister: () {
              _openRegistration('individual');
            },
          ),

          const SizedBox(height: 22),

          _RegistrationCard(
            title: 'Institutional Delegation',
            description:
                'Represent your institution as a delegation at '
                "JPUMUN'26.",
            height: 350,
            titleSize: 26,
            bodySize: 15,
            buttonHeight: 60,
            buttonTextSize: 18,
            padding: 22,
            onRegister: () {
              _openRegistration('institutional');
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  Future<void> _openRegistration(
    String type,
  ) async {
    final String route = type == 'institutional'
        ? '/register-institute'
        : '/register';

    final Uri uri = Uri.base.resolve(route);

    await launchUrl(
      uri,
      webOnlyWindowName: '_blank',
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
      'REGISTRATION',
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

// ============================================================
// REGISTRATION CARD
// ============================================================

class _RegistrationCard extends StatefulWidget {
  const _RegistrationCard({
    required this.title,
    required this.description,
    required this.height,
    required this.titleSize,
    required this.bodySize,
    required this.buttonHeight,
    required this.buttonTextSize,
    required this.padding,
    required this.onRegister,
  });

  final String title;
  final String description;

  final double height;
  final double titleSize;
  final double bodySize;
  final double buttonHeight;
  final double buttonTextSize;
  final double padding;

  final VoidCallback onRegister;

  @override
  State<_RegistrationCard> createState() => _RegistrationCardState();
}

class _RegistrationCardState extends State<_RegistrationCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovering = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: double.infinity,
        height: widget.height,
        transform: Matrix4.translationValues(0, _hovering ? -4 : 0, 0),
        padding: EdgeInsets.all(widget.padding),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hovering
                ? const Color(0xFFC9A86A)
                : const Color(0xFFC9A86A).withValues(alpha: 0.75),
            width: 3,
          ),
          boxShadow: _hovering
              ? [
                  BoxShadow(
                    color: const Color(0xFFC9A86A).withValues(alpha: 0.10),
                    blurRadius: 22,
                    spreadRadius: 1,
                  ),
                ]
              : const [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // TITLE
            // ==================================================
            Text(
              widget.title,
              style: GoogleFonts.prata(
                color: Colors.white,
                fontSize: widget.titleSize,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),

            const SizedBox(height: 18),

            Container(width: 65, height: 2, color: const Color(0xFF5C1A1B)),

            // ==================================================
            // DESCRIPTION
            // ==================================================
            Expanded(
              child: Center(
                child: Text(
                  widget.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ibmPlexSans(
                    color: Colors.white,
                    fontSize: widget.bodySize,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ),
            ),

            // ==================================================
            // REGISTER BUTTON
            // ==================================================
            _RegisterButton(
              height: widget.buttonHeight,
              fontSize: widget.buttonTextSize,
              onTap: widget.onRegister,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// REGISTER BUTTON
// ============================================================

class _RegisterButton extends StatefulWidget {
  const _RegisterButton({
    required this.height,
    required this.fontSize,
    required this.onTap,
  });

  final double height;
  final double fontSize;
  final VoidCallback onTap;

  @override
  State<_RegisterButton> createState() => _RegisterButtonState();
}

class _RegisterButtonState extends State<_RegisterButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovering = false;
        });
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          height: widget.height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hovering
                ? const Color(0xFFD8B978)
                : const Color(0xFFC9A86A),
            borderRadius: BorderRadius.circular(18),
            boxShadow: _hovering
                ? [
                    BoxShadow(
                      color: const Color(0xFFC9A86A).withValues(alpha: 0.22),
                      blurRadius: 20,
                    ),
                  ]
                : const [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'REGISTER',
                style: GoogleFonts.prata(
                  color: const Color(0xFF0B132B),
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(width: 12),

              AnimatedSlide(
                duration: const Duration(milliseconds: 180),
                offset: _hovering ? const Offset(0.15, 0) : Offset.zero,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: const Color(0xFF0B132B),
                  size: widget.fontSize + 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
