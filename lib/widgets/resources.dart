import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourcesSection extends StatelessWidget {
  const ResourcesSection({super.key});

  static const Color _background = Color(0xFF0B132B);
  static const Color _cardBackground = Color(0xFF1E1E1E);
  static const Color _gold = Color(0xFFC9A86A);
  static const Color _red = Color(0xFF5C1A1B);

  static const List<_ResourceData> _resources = [
    _ResourceData(
      title: 'DELEGATE\nPORTFOLIO MATRIX',
      icon: Icons.grid_view_rounded,
      url:
          'https://docs.google.com/spreadsheets/d/1laEWEZyEpr1hGRf1Pp0cWSIGkmHdVnPqnp4GlLLa-Wo/edit?usp=sharing',
    ),
    _ResourceData(
      title: 'JPUMUN\nBROCHURE',
      icon: Icons.menu_book_rounded,
      url:
          'https://drive.google.com/file/d/1pbjOlMUXGBXQ5FNFJ8qOWCxMxJOLNcCy/view?usp=sharing',
    ),
    _ResourceData(
      title: 'BACKGROUND\nGUIDE',
      icon: Icons.description_outlined,
      url:
          'https://drive.google.com/drive/folders/1xhtjrRuZZacestf1pOFSovAnhenCfzbx?usp=sharing',
    ),
  ];

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
      padding: const EdgeInsets.fromLTRB(120, 100, 120, 100),
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
                  for (int i = 0; i < _resources.length; i++) ...[
                    Expanded(
                      child: _ResourceCard(
                        resource: _resources[i],
                        height: 560,
                        iconSize: 100,
                        titleSize: 32,
                        padding: 30,
                        onTap: () {
                          _handleResourceTap(context, _resources[i]);
                        },
                      ),
                    ),

                    if (i != _resources.length - 1) const SizedBox(width: 30),
                  ],
                ],
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

  Widget _buildTablet(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _background,
      padding: const EdgeInsets.fromLTRB(60, 80, 60, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(fontSize: 21, letterSpacing: 9),

          const SizedBox(height: 45),

          LayoutBuilder(
            builder: (context, constraints) {
              // At wider tablet sizes we can fit three cards.
              if (constraints.maxWidth >= 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < _resources.length; i++) ...[
                      Expanded(
                        child: _ResourceCard(
                          resource: _resources[i],
                          height: 440,
                          iconSize: 78,
                          titleSize: 24,
                          padding: 24,
                          onTap: () {
                            _handleResourceTap(context, _resources[i]);
                          },
                        ),
                      ),

                      if (i != _resources.length - 1) const SizedBox(width: 20),
                    ],
                  ],
                );
              }

              // Narrower portrait tablets.
              return Column(
                children: [
                  for (int i = 0; i < _resources.length; i++) ...[
                    _ResourceCard(
                      resource: _resources[i],
                      height: 260,
                      iconSize: 65,
                      titleSize: 26,
                      padding: 28,
                      horizontal: true,
                      onTap: () {
                        _handleResourceTap(context, _resources[i]);
                      },
                    ),

                    if (i != _resources.length - 1) const SizedBox(height: 22),
                  ],
                ],
              );
            },
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

  Widget _buildMobile(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _background,
      padding: const EdgeInsets.fromLTRB(24, 55, 24, 55),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(fontSize: 11, letterSpacing: 5),

          const SizedBox(height: 32),

          for (int i = 0; i < _resources.length; i++) ...[
            _ResourceCard(
              resource: _resources[i],
              height: 190,
              iconSize: 48,
              titleSize: 20,
              padding: 20,
              horizontal: true,
              onTap: () {
                _handleResourceTap(context, _resources[i]);
              },
            ),

            if (i != _resources.length - 1) const SizedBox(height: 18),
          ],

          const SizedBox(height: 55),

          _buildDivider(),
        ],
      ),
    );
  }

  // ============================================================
  // RESOURCE ACTION
  // ============================================================

  Future<void> _handleResourceTap(
    BuildContext context,
    _ResourceData resource,
  ) async {
    final uri = Uri.parse(resource.url);
    final didLaunch = await launchUrl(
      uri,
      mode: LaunchMode.platformDefault,
      webOnlyWindowName: '_blank',
    );

    if (didLaunch || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Could not open ${resource.displayTitle}. Please try again.',
          style: GoogleFonts.ibmPlexSans(color: Colors.white),
        ),
        backgroundColor: _cardBackground,
        behavior: SnackBarBehavior.floating,
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
      'RESOURCES',
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
  // DIVIDER
  // ============================================================

  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 1,
      decoration: BoxDecoration(
        color: _red,
        boxShadow: [
          BoxShadow(
            color: _red.withValues(alpha: 0.45),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// RESOURCE CARD
// ============================================================

class _ResourceCard extends StatefulWidget {
  const _ResourceCard({
    required this.resource,
    required this.height,
    required this.iconSize,
    required this.titleSize,
    required this.padding,
    required this.onTap,
    this.horizontal = false,
  });

  final _ResourceData resource;

  final double height;
  final double iconSize;
  final double titleSize;
  final double padding;

  final bool horizontal;

  final VoidCallback onTap;

  @override
  State<_ResourceCard> createState() => _ResourceCardState();
}

class _ResourceCardState extends State<_ResourceCard> {
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
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: double.infinity,
          height: widget.height,
          transform: Matrix4.translationValues(0, _hovering ? -5 : 0, 0),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovering
                  ? const Color(0xFFC9A86A)
                  : const Color(0xFF5C1A1B),
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
          child: Padding(
            padding: EdgeInsets.all(widget.padding),
            child: widget.horizontal ? _buildHorizontal() : _buildVertical(),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // VERTICAL CARD
  // ============================================================

  Widget _buildVertical() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Icon(
              widget.resource.icon,
              color: const Color(0xFFC9A86A),
              size: widget.iconSize,
            ),
          ),
        ),

        Text(
          widget.resource.title,
          textAlign: TextAlign.center,
          style: GoogleFonts.prata(
            color: const Color(0xFFC9A86A),
            fontSize: widget.titleSize,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),

        const SizedBox(height: 22),

        _buildOpenLabel(),
      ],
    );
  }

  // ============================================================
  // HORIZONTAL CARD
  // ============================================================

  Widget _buildHorizontal() {
    return Row(
      children: [
        Container(
          width: widget.iconSize * 1.55,
          height: widget.iconSize * 1.55,
          decoration: BoxDecoration(
            color: const Color(0xFF0B132B),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            widget.resource.icon,
            color: const Color(0xFFC9A86A),
            size: widget.iconSize,
          ),
        ),

        SizedBox(width: widget.padding),

        Expanded(
          child: Text(
            widget.resource.title,
            style: GoogleFonts.prata(
              color: const Color(0xFFC9A86A),
              fontSize: widget.titleSize,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
        ),

        const SizedBox(width: 12),

        AnimatedSlide(
          duration: const Duration(milliseconds: 200),
          offset: _hovering ? const Offset(0.15, 0) : Offset.zero,
          child: const Icon(
            Icons.arrow_outward_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ],
    );
  }

  Widget _buildOpenLabel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'OPEN',
          style: GoogleFonts.ibmPlexSans(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
          ),
        ),

        const SizedBox(width: 10),

        AnimatedSlide(
          duration: const Duration(milliseconds: 200),
          offset: _hovering ? const Offset(0.2, -0.2) : Offset.zero,
          child: const Icon(
            Icons.arrow_outward_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// DATA
// ============================================================

class _ResourceData {
  const _ResourceData({
    required this.title,
    required this.icon,
    required this.url,
  });

  final String title;
  final IconData icon;
  final String url;

  String get displayTitle {
    return title.replaceAll('\n', ' ');
  }
}
