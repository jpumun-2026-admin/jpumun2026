import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jpumun_website/widgets/about.dart';
import 'package:jpumun_website/widgets/committees.dart';
import 'package:jpumun_website/widgets/contact_section.dart';
import 'package:jpumun_website/widgets/register_widget.dart';
import 'package:jpumun_website/widgets/resources.dart';
import 'package:jpumun_website/widgets/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  late Timer _timer;
  late Duration _remaining;

  final DateTime _targetDate = DateTime(2026, 8, 31);

  @override
  void initState() {
    super.initState();

    _updateCountdown();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateCountdown(),
    );
  }

  void _updateCountdown() {
    final difference = _targetDate.difference(DateTime.now());

    if (!mounted) return;

    setState(() {
      _remaining = difference.isNegative ? Duration.zero : difference;
    });
  }

  void _scrollDown() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      MediaQuery.sizeOf(context).height,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _remaining.inDays;
    final hours = _remaining.inHours.remainder(24);
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

    return Scaffold(
      backgroundColor: const Color(0xFF0C1630),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _buildHeroSection(
              days: days,
              hours: hours,
              minutes: minutes,
              seconds: seconds,
            ),
            AboutSection(),
            ThemeSection(),
            CommitteesSection(),
            ResourcesSection(),
            RegistrationSection(),
            ContactSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection({
    required int days,
    required int hours,
    required int minutes,
    required int seconds,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < 700;
        final isTablet = width >= 700 && width < 1100;
        final screenHeight = MediaQuery.sizeOf(context).height;
        final heroHeight = isMobile
            ? (screenHeight < 760 ? 760.0 : screenHeight)
            : isTablet
            ? (screenHeight < 720 ? 720.0 : screenHeight)
            : (screenHeight < 700 ? 700.0 : screenHeight);

        return SizedBox(
          width: double.infinity,
          height: heroHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'lib/assets/hero_bg.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
              // A subtle overlay keeps text readable while preserving the
              // blur and tonal treatment baked into hero_bg.png.
              Container(color: const Color(0x22071320)),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 20 : 36,
                    isMobile ? 22 : 28,
                    isMobile ? 20 : 36,
                    isMobile ? 86 : 92,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1050),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'lib/assets/new_logo.png',
                            width: isMobile ? 250 : (isTablet ? 330 : 600),
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: isMobile ? 24 : 28),
                          Text(
                            'Join the experience before it begins.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.prata(
                              color: const Color(0xFFF9F5F4),
                              fontSize: isMobile ? 28 : (isTablet ? 36 : 55),
                              fontWeight: FontWeight.w400,
                              height: 1.25,
                              shadows: const [
                                Shadow(
                                  blurRadius: 10,
                                  color: Color(0x99000000),
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: isMobile ? 18 : 22),
                          Wrap(
                            alignment: WrapAlignment.center,
                            runAlignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 10,
                            children: const [
                              _HeroInfoPill(
                                icon: Icons.calendar_month_rounded,
                                text: '31st August - 1st September',
                              ),
                              _HeroInfoPill(
                                icon: Icons.location_on_rounded,
                                text: 'Jain University, Jayanagar',
                              ),
                            ],
                          ),
                          SizedBox(height: isMobile ? 24 : 30),
                          _ResponsiveCountdown(
                            days: days,
                            hours: hours,
                            minutes: minutes,
                            seconds: seconds,
                            compact: isMobile,
                          ),
                          SizedBox(height: isMobile ? 25 : 30),
                          _HeroRegisterButton(onTap: _scrollToRegistration),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: isMobile ? 14 : 18,
                child: _ScrollIndicator(onTap: _scrollDown, mobile: isMobile),
              ),
            ],
          ),
        );
      },
    );
  }

  void _scrollToRegistration() {
    if (!_scrollController.hasClients) return;

    // Registration is the sixth homepage section. This intentionally scrolls
    // to it rather than choosing individual/institutional registration for
    // the visitor.
    final viewport = MediaQuery.sizeOf(context).height;
    final target = (viewport * 5.0).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOutCubic,
    );
  }
}

// ============================================================
// HERO COMPONENTS
// ============================================================

class _HeroInfoPill extends StatelessWidget {
  const _HeroInfoPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xDD181A1E),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFC9A86A), width: 1.2),
        boxShadow: const [BoxShadow(color: Color(0x55C9A86A), blurRadius: 10)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: const Color(0xFFF9F5F4)),
          const SizedBox(width: 7),
          Text(
            text,
            style: GoogleFonts.ibmPlexSerif(
              color: const Color(0xFFF9F5F4),
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveCountdown extends StatelessWidget {
  const _ResponsiveCountdown({
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.compact,
  });

  final int days;
  final int hours;
  final int minutes;
  final int seconds;
  final bool compact;

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final veryNarrow = constraints.maxWidth < 390;
        final boxWidth = compact ? (veryNarrow ? 67.0 : 75.0) : 150.0;
        final boxHeight = compact ? (veryNarrow ? 65.0 : 72.0) : 130.0;
        final valueSize = compact ? (veryNarrow ? 29.0 : 33.0) : 45.0;
        final separatorSize = compact ? 28.0 : 38.0;
        final separatorPadding = compact ? (veryNarrow ? 4.0 : 6.0) : 10.0;

        Widget box(String value, String label) => _HeroCountdownBox(
          value: value,
          label: label,
          width: boxWidth,
          height: boxHeight,
          valueSize: valueSize,
          labelSize: compact ? 10 : 12,
        );

        Widget separator() => Padding(
          padding: EdgeInsets.fromLTRB(
            separatorPadding,
            compact ? 16 : 22,
            separatorPadding,
            0,
          ),
          child: Text(
            ':',
            style: GoogleFonts.ibmPlexSans(
              color: const Color(0xFFF9F5F4),
              fontSize: separatorSize,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        );

        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              box(days.toString(), 'DAYS'),
              separator(),
              box(_twoDigits(hours), 'HOURS'),
              separator(),
              box(_twoDigits(minutes), 'MINUTES'),
              separator(),
              box(_twoDigits(seconds), 'SECONDS'),
            ],
          ),
        );
      },
    );
  }
}

class _HeroCountdownBox extends StatelessWidget {
  const _HeroCountdownBox({
    required this.value,
    required this.label,
    required this.width,
    required this.height,
    required this.valueSize,
    required this.labelSize,
  });

  final String value;
  final String label;
  final double width;
  final double height;
  final double valueSize;
  final double labelSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xE8181A1E),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF792923), width: 3),
            boxShadow: const [
              BoxShadow(color: Color(0x33000000), blurRadius: 10),
            ],
          ),
          child: Text(
            value,
            style: GoogleFonts.ibmPlexSans(
              color: const Color(0xFFDDBA77),
              fontSize: valueSize,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.prata(
            color: const Color(0xFFF5F0F0),
            fontSize: labelSize,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _HeroRegisterButton extends StatefulWidget {
  const _HeroRegisterButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_HeroRegisterButton> createState() => _HeroRegisterButtonState();
}

class _HeroRegisterButtonState extends State<_HeroRegisterButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 250,
          height: 80,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hovering
                ? const Color(0xE62A2928)
                : const Color(0xE6181A1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFDDBA77), width: 1.5),
            boxShadow: const [
              BoxShadow(color: Color(0x33000000), blurRadius: 10),
            ],
          ),
          child: Text(
            'Register Now',
            style: GoogleFonts.prata(
              color: const Color(0xFFF9F5F4),
              fontSize: 24,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SCROLL INDICATOR
// ============================================================

class _ScrollIndicator extends StatefulWidget {
  const _ScrollIndicator({required this.onTap, this.mobile = false});

  final VoidCallback onTap;
  final bool mobile;

  @override
  State<_ScrollIndicator> createState() => _ScrollIndicatorState();
}

class _ScrollIndicatorState extends State<_ScrollIndicator> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MouseRegion(
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
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: _hovering ? 0.7 : 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SCROLL FOR MORE',
                  style: GoogleFonts.ibmPlexSans(
                    color: const Color(0xFFDDBA77),
                    fontSize: widget.mobile ? 12 : 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),

                SizedBox(height: widget.mobile ? 3 : 5),

                Text(
                  '⋮',
                  style: GoogleFonts.ibmPlexSans(
                    color: const Color(0xFFDDBA77),
                    fontSize: widget.mobile ? 24 : 30,
                    fontWeight: FontWeight.w700,
                    height: 0.65,
                  ),
                ),

                const SizedBox(height: 3),

                Icon(
                  Icons.arrow_downward_rounded,
                  color: const Color(0xFFDDBA77),
                  size: widget.mobile ? 34 : 45,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
