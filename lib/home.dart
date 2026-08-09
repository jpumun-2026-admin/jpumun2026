import 'dart:async';
import 'dart:ui';

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
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _committeesKey = GlobalKey();
  final GlobalKey _resourcesKey = GlobalKey();
  final GlobalKey _registrationKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  late Timer _timer;
  late Duration _remaining;

  final DateTime _targetDate = DateTime(2026, 8, 31);

  static const List<_NavItemData> _navItems = [
    _NavItemData(label: 'HOME', section: _HomeSection.home),
    _NavItemData(label: 'ABOUT', section: _HomeSection.about),
    _NavItemData(label: 'COMMITTEES', section: _HomeSection.committees),
    _NavItemData(label: 'RESOURCES', section: _HomeSection.resources),
    _NavItemData(label: 'REGISTRATION', section: _HomeSection.registration),
    _NavItemData(label: 'CONTACT', section: _HomeSection.contact),
  ];

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
    _scrollToSection(_HomeSection.about);
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
    final isMobile = MediaQuery.sizeOf(context).width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFF0C1630),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                KeyedSubtree(
                  key: _homeKey,
                  child: _buildHeroSection(
                    days: days,
                    hours: hours,
                    minutes: minutes,
                    seconds: seconds,
                  ),
                ),
                KeyedSubtree(key: _aboutKey, child: AboutSection()),
                ThemeSection(),
                KeyedSubtree(key: _committeesKey, child: CommitteesSection()),
                KeyedSubtree(key: _resourcesKey, child: ResourcesSection()),
                KeyedSubtree(
                  key: _registrationKey,
                  child: RegistrationSection(),
                ),
                KeyedSubtree(key: _contactKey, child: ContactSection()),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 16 : 24,
                isMobile ? 14 : 20,
                isMobile ? 16 : 24,
                0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: isMobile
                    ? _MobileNavigationBar(
                        items: _navItems,
                        onSelected: _handleMobileNavSelection,
                      )
                    : _DesktopFloatingAppBar(
                        items: _navItems,
                        onSelected: _scrollToSection,
                      ),
              ),
            ),
          ),
        ],
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
    _scrollToSection(_HomeSection.registration);
  }

  Future<void> _handleMobileNavSelection(_HomeSection section) async {
    Navigator.of(context).maybePop();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _scrollToSection(section);
  }

  void _scrollToSection(_HomeSection section) {
    final targetKey = switch (section) {
      _HomeSection.home => _homeKey,
      _HomeSection.about => _aboutKey,
      _HomeSection.committees => _committeesKey,
      _HomeSection.resources => _resourcesKey,
      _HomeSection.registration => _registrationKey,
      _HomeSection.contact => _contactKey,
    };

    final targetContext = targetKey.currentContext;
    if (targetContext == null) return;

    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 850),
      curve: Curves.easeInOutCubic,
      alignment: 0,
    );
  }
}

enum _HomeSection { home, about, committees, resources, registration, contact }

class _NavItemData {
  const _NavItemData({required this.label, required this.section});

  final String label;
  final _HomeSection section;
}

class _DesktopFloatingAppBar extends StatelessWidget {
  const _DesktopFloatingAppBar({required this.items, required this.onSelected});

  final List<_NavItemData> items;
  final ValueChanged<_HomeSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xCC081224),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0x66C9A86A)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x44000000),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _NavPillButton(
                    label: item.label,
                    onTap: () => onSelected(item.section),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileNavigationBar extends StatelessWidget {
  const _MobileNavigationBar({required this.items, required this.onSelected});

  final List<_NavItemData> items;
  final ValueChanged<_HomeSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xE6081224),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x55C9A86A)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'JPUMUN 2026',
              style: GoogleFonts.ibmPlexSans(
                color: const Color(0xFFF9F5F4),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.8,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => _openMenu(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0x55C9A86A)),
                ),
                child: const Icon(
                  Icons.menu_rounded,
                  color: Color(0xFFC9A86A),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMenu(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xAA000000),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xF20B132B),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0x66C9A86A)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 18),
                      Container(
                        width: 46,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0x55F9F5F4),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 18),
                      for (final item in items)
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 4,
                          ),
                          title: Text(
                            item.label,
                            style: GoogleFonts.ibmPlexSans(
                              color: const Color(0xFFF9F5F4),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.4,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_outward_rounded,
                            color: Color(0xFFC9A86A),
                            size: 18,
                          ),
                          onTap: () => onSelected(item.section),
                        ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavPillButton extends StatefulWidget {
  const _NavPillButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_NavPillButton> createState() => _NavPillButtonState();
}

class _NavPillButtonState extends State<_NavPillButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _hovering ? const Color(0x26C9A86A) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                widget.label,
                style: GoogleFonts.ibmPlexSans(
                  color: const Color(0xFFF9F5F4),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.6,
                ),
              ),
            ),
          ),
        ),
      ),
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
