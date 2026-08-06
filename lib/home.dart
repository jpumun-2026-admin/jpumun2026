import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jpumun_website/widgets/about.dart';
import 'package:jpumun_website/widgets/committees.dart';
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

        if (width < 700) {
          return _buildMobileHero(
            days: days,
            hours: hours,
            minutes: minutes,
            seconds: seconds,
          );
        }

        if (width < 1200) {
          return _buildTabletHero(
            days: days,
            hours: hours,
            minutes: minutes,
            seconds: seconds,
          );
        }

        return _buildDesktopHero(
          days: days,
          hours: hours,
          minutes: minutes,
          seconds: seconds,
        );
      },
    );
  }

  // ============================================================
  // DESKTOP
  // ============================================================

  Widget _buildDesktopHero({
    required int days,
    required int hours,
    required int minutes,
    required int seconds,
  }) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Container(
      width: double.infinity,
      height: screenHeight,
      constraints: const BoxConstraints(minHeight: 700),
      color: const Color(0xFF0C1630),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 76),
              child: Row(
                children: [
                  Expanded(
                    flex: 60,
                    child: Transform.translate(
                      offset: const Offset(0, -10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDesktopHeading(),

                          const SizedBox(height: 60),

                          _buildDesktopCountdown(
                            days: days,
                            hours: hours,
                            minutes: minutes,
                            seconds: seconds,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 50),

                  Expanded(flex: 40, child: _buildDesktopLogo()),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 27,
            left: 0,
            right: 0,
            child: _ScrollIndicator(onTap: _scrollDown),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopHeading() {
    return Text(
      'Join the experience before it\nbegins.',
      style: GoogleFonts.prata(
        color: const Color(0xFFF9F5F4),
        fontSize: 43,
        fontWeight: FontWeight.w400,
        height: 1.35,
      ),
    );
  }

  Widget _buildDesktopCountdown({
    required int days,
    required int hours,
    required int minutes,
    required int seconds,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CountdownBox(value: days.toString(), label: 'DAYS'),

        const _CountdownSeparator(),

        _CountdownBox(value: _twoDigits(hours), label: 'HOURS'),

        const _CountdownSeparator(),

        _CountdownBox(value: _twoDigits(minutes), label: 'MINUTES'),

        const _CountdownSeparator(),

        _CountdownBox(value: _twoDigits(seconds), label: 'SECONDS'),
      ],
    );
  }

  Widget _buildDesktopLogo() {
    return Transform.translate(
      offset: const Offset(0, 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'lib/assets/logo_hero.png',
            width: 512,
            height: 512,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOBILE
  // ============================================================

  Widget _buildTabletHero({
    required int days,
    required int hours,
    required int minutes,
    required int seconds,
  }) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return SizedBox(
      width: double.infinity,
      height: screenHeight < 800 ? 800 : screenHeight,
      child: ColoredBox(
        color: const Color(0xFF0C1630),
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(50, 45, 50, 100),
                child: Column(
                  children: [
                    // Logo
                    Image.asset(
                      'lib/assets/logo_hero.png',
                      width: 280,
                      height: 280,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 50),

                    // Heading
                    Text(
                      'Join the experience before it\nbegins.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.prata(
                        color: const Color(0xFFF9F5F4),
                        fontSize: 35,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Countdown
                    _buildTabletCountdown(
                      days: days,
                      hours: hours,
                      minutes: minutes,
                      seconds: seconds,
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 25,
              child: _ScrollIndicator(onTap: _scrollDown, mobile: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletCountdown({
    required int days,
    required int hours,
    required int minutes,
    required int seconds,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TabletCountdownBox(value: days.toString(), label: 'DAYS'),

        const _TabletCountdownSeparator(),

        _TabletCountdownBox(value: _twoDigits(hours), label: 'HOURS'),

        const _TabletCountdownSeparator(),

        _TabletCountdownBox(value: _twoDigits(minutes), label: 'MINUTES'),

        const _TabletCountdownSeparator(),

        _TabletCountdownBox(value: _twoDigits(seconds), label: 'SECONDS'),
      ],
    );
  }

  Widget _buildMobileHero({
    required int days,
    required int hours,
    required int minutes,
    required int seconds,
  }) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return SizedBox(
      width: double.infinity,
      height: screenHeight < 700 ? 700 : screenHeight,
      child: ColoredBox(
        color: const Color(0xFF0C1630),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Stack(
            children: [
              // Main content
              Positioned(
                top: 45,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Image.asset(
                      'lib/assets/logo_hero.png',
                      width: 310,
                      height: 310,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 70),

                    // Heading
                    Center(
                      child: Text(
                        'Join the experience before it begins.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.prata(
                          color: const Color(0xFFF9F5F4),
                          fontSize: 34,
                          fontWeight: FontWeight.w400,
                          height: 1.25,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Countdown
                    _buildMobileCountdown(
                      days: days,
                      hours: hours,
                      minutes: minutes,
                      seconds: seconds,
                    ),
                  ],
                ),
              ),

              // Scroll indicator stays at bottom of viewport
              Positioned(
                left: 0,
                right: 0,
                bottom: 24,
                child: _ScrollIndicator(onTap: _scrollDown, mobile: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCountdown({
    required int days,
    required int hours,
    required int minutes,
    required int seconds,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _MobileCountdownBox(value: days.toString(), label: 'DAYS'),
        ),

        const _MobileCountdownSeparator(),

        Expanded(
          child: _MobileCountdownBox(value: _twoDigits(hours), label: 'HOURS'),
        ),

        const _MobileCountdownSeparator(),

        Expanded(
          child: _MobileCountdownBox(
            value: _twoDigits(minutes),
            label: 'MINUTES',
          ),
        ),

        const _MobileCountdownSeparator(),

        Expanded(
          child: _MobileCountdownBox(
            value: _twoDigits(seconds),
            label: 'SECONDS',
          ),
        ),
      ],
    );
  }
}

// ============================================================
// DESKTOP COUNTDOWN
// ============================================================

class _CountdownBox extends StatelessWidget {
  const _CountdownBox({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 132,
          height: 110,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF181A1E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF792923), width: 4),
          ),
          child: Text(
            value,
            style: GoogleFonts.ibmPlexSans(
              color: const Color(0xFFDDBA77),
              fontSize: 56,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),

        const SizedBox(height: 10),

        Text(
          label,
          style: GoogleFonts.prata(
            color: const Color(0xFFF5F0F0),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _CountdownSeparator extends StatelessWidget {
  const _CountdownSeparator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 33),
      child: Text(
        ':',
        style: GoogleFonts.ibmPlexSans(
          color: const Color(0xFFF5F0F0),
          fontSize: 44,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );
  }
}

// ============================================================
// MOBILE AND TABLET COUNTDOWN
// ============================================================

class _TabletCountdownBox extends StatelessWidget {
  const _TabletCountdownBox({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 105,
          height: 90,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF181A1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF792923), width: 3),
          ),
          child: Text(
            value,
            style: GoogleFonts.ibmPlexSans(
              color: const Color(0xFFDDBA77),
              fontSize: 45,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),

        const SizedBox(height: 9),

        Text(
          label,
          style: GoogleFonts.prata(
            color: const Color(0xFFF5F0F0),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _TabletCountdownSeparator extends StatelessWidget {
  const _TabletCountdownSeparator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 9, right: 9, top: 27),
      child: Text(
        ':',
        style: GoogleFonts.ibmPlexSans(
          color: const Color(0xFFF5F0F0),
          fontSize: 34,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );
  }
}

class _MobileCountdownBox extends StatelessWidget {
  const _MobileCountdownBox({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF181A1E),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFF792923), width: 3),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  value,
                  style: GoogleFonts.ibmPlexSans(
                    color: const Color(0xFFDDBA77),
                    fontSize: 35,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: GoogleFonts.prata(
              color: const Color(0xFFF5F0F0),
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

class _MobileCountdownSeparator extends StatelessWidget {
  const _MobileCountdownSeparator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 18),
      child: Text(
        ':',
        style: GoogleFonts.ibmPlexSans(
          color: const Color(0xFFF5F0F0),
          fontSize: 27,
          fontWeight: FontWeight.w600,
          height: 1,
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
