import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommitteesSection extends StatelessWidget {
  const CommitteesSection({super.key});

  static const Color _background = Color(0xFF0B132B);
  static const Color _gold = Color(0xFFC9A86A);
  static const Color _divider = Color(0xFF5C1A1B);

  static const List<_CommitteeData> _committees = [
    _CommitteeData(
      abbreviation: 'AIPPM',
      name: 'All India Political Parties Meet',
      description:
          'The AIPPM recreates the high-stakes floor of Indian politics, '
          'where representatives of national and regional parties come '
          'together to debate matters of urgent national concern. Delegates '
          'will need to balance party ideology, coalition politics, public '
          'sentiment, and national interest as they work toward — or resist '
          '— consensus.',
      agenda:
          "Deliberation on India's National Security Strategy following "
          'a major cross-border terror attack.',
    ),
    _CommitteeData(
      abbreviation: 'DISEC',
      name: 'Disarmament and International Security Committee',
      description:
          "DISEC brings together the world's nations to address one of the "
          'most enduring challenges in international security — the control '
          'and reduction of weapons capable of mass devastation. Delegates '
          'will navigate competing national interests, existing treaty '
          'frameworks, and the technological shifts reshaping global '
          'deterrence.',
      agenda: 'Nuclear risk reduction and arms control in the 21st century.',
    ),
    _CommitteeData(
      abbreviation: 'CCC',
      name: 'Continuous Crisis Committee',
      description:
          'The CCC is a fast-paced, high-intensity committee where delegates '
          'respond in real time to a rapidly evolving situation, with no '
          'fixed agenda known in advance. Decisions made in one session '
          "ripple directly into the next, testing delegates' ability to "
          'think on their feet and adapt under pressure.',
      agenda: 'Classified',
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
              for (int i = 0; i < _committees.length; i++) ...[
                _CommitteeCard(
                  committee: _committees[i],
                  height: 269,
                  horizontalPadding: 34,
                  abbreviationSize: 54,
                  nameSize: 24,
                  arrowSize: 72,
                  borderRadius: 14,
                  onTap: () {
                    _showCommitteeSheet(context, _committees[i]);
                  },
                ),
                if (i != _committees.length - 1) const SizedBox(height: 30),
              ],
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
          for (int i = 0; i < _committees.length; i++) ...[
            _CommitteeCard(
              committee: _committees[i],
              height: 210,
              horizontalPadding: 30,
              abbreviationSize: 46,
              nameSize: 20,
              arrowSize: 60,
              borderRadius: 14,
              onTap: () {
                _showCommitteeSheet(context, _committees[i]);
              },
            ),
            if (i != _committees.length - 1) const SizedBox(height: 25),
          ],
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
          for (int i = 0; i < _committees.length; i++) ...[
            _CommitteeCard(
              committee: _committees[i],
              height: 150,
              horizontalPadding: 20,
              abbreviationSize: 34,
              nameSize: 15,
              arrowSize: 46,
              borderRadius: 14,
              mobile: true,
              onTap: () {
                _showCommitteeSheet(context, _committees[i]);
              },
            ),
            if (i != _committees.length - 1) const SizedBox(height: 18),
          ],
          const SizedBox(height: 55),
          _buildDivider(),
        ],
      ),
    );
  }

  // ============================================================
  // MODAL BOTTOM SHEET
  // ============================================================

  void _showCommitteeSheet(BuildContext context, _CommitteeData committee) {
    showModalBottomSheet(
      context: context,

      // Allows the sheet to become taller than the default
      // half-screen constraint.
      isScrollControlled: true,

      // We draw the sheet ourselves so the outer area can
      // remain transparent.
      backgroundColor: Colors.transparent,

      barrierColor: Colors.black.withValues(alpha: 0.72),

      builder: (context) {
        return _CommitteeBottomSheet(committee: committee);
      },
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
      'COMMITTEES',
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

// ============================================================
// COMMITTEE CARD
// ============================================================

class _CommitteeCard extends StatefulWidget {
  const _CommitteeCard({
    required this.committee,
    required this.height,
    required this.horizontalPadding,
    required this.abbreviationSize,
    required this.nameSize,
    required this.arrowSize,
    required this.borderRadius,
    required this.onTap,
    this.mobile = false,
  });

  final _CommitteeData committee;

  final double height;
  final double horizontalPadding;
  final double abbreviationSize;
  final double nameSize;
  final double arrowSize;
  final double borderRadius;

  final VoidCallback onTap;

  final bool mobile;

  @override
  State<_CommitteeCard> createState() => _CommitteeCardState();
}

class _CommitteeCardState extends State<_CommitteeCard> {
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
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: double.infinity,
          height: widget.height,
          transform: Matrix4.translationValues(_hovering ? 4 : 0, 0, 0),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(widget.borderRadius),
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
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ]
                : const [],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.committee.abbreviation,
                        style: GoogleFonts.prata(
                          color: const Color(0xFFC9A86A),
                          fontSize: widget.abbreviationSize,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                      SizedBox(height: widget.mobile ? 10 : 16),
                      Text(
                        widget.committee.name,
                        maxLines: widget.mobile ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.ibmPlexSans(
                          color: Colors.white,
                          fontSize: widget.nameSize,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: widget.mobile ? 12 : 30),
                AnimatedSlide(
                  duration: const Duration(milliseconds: 200),
                  offset: _hovering ? const Offset(0.15, 0) : Offset.zero,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: widget.arrowSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// COMMITTEE MODAL
// ============================================================

class _CommitteeBottomSheet extends StatelessWidget {
  const _CommitteeBottomSheet({required this.committee});

  final _CommitteeData committee;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);

    final bool mobile = screen.width < 700;
    final bool tablet = screen.width >= 700 && screen.width < 1200;

    final double horizontalPadding = mobile
        ? 24
        : tablet
        ? 48
        : 70;

    final double abbreviationSize = mobile
        ? 40
        : tablet
        ? 52
        : 62;

    final double nameSize = mobile
        ? 19
        : tablet
        ? 23
        : 27;

    final double bodySize = mobile
        ? 15
        : tablet
        ? 18
        : 20;

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          // Prevent extremely long content from extending
          // beyond the viewport.
          maxHeight: screen.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),

          border: Border(
            top: BorderSide(color: Color(0xFF5C1A1B), width: 3),
            left: BorderSide(color: Color(0xFF5C1A1B), width: 3),
            right: BorderSide(color: Color(0xFF5C1A1B), width: 3),
          ),

          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            14,
            horizontalPadding,
            mobile ? 38 : 52,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1300),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==========================================
                  // DRAG HANDLE
                  // ==========================================
                  Center(
                    child: Container(
                      width: 55,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC9A86A).withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),

                  SizedBox(height: mobile ? 28 : 38),

                  // ==========================================
                  // TOP ROW
                  // ==========================================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              committee.abbreviation,
                              style: GoogleFonts.prata(
                                color: const Color(0xFFC9A86A),
                                fontSize: abbreviationSize,
                                fontWeight: FontWeight.w700,
                                height: 1,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              committee.name,
                              style: GoogleFonts.ibmPlexSans(
                                color: Colors.white,
                                fontSize: nameSize,
                                fontWeight: FontWeight.w400,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 20),

                      _CloseButton(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: mobile ? 30 : 40),

                  // ==========================================
                  // DIVIDER
                  // ==========================================
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: const Color(0xFF5C1A1B),
                  ),

                  SizedBox(height: mobile ? 28 : 36),

                  // ==========================================
                  // DESCRIPTION
                  // ==========================================
                  Text(
                    committee.description,
                    style: GoogleFonts.ibmPlexSans(
                      color: Colors.white,
                      fontSize: bodySize,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                    ),
                  ),

                  SizedBox(height: mobile ? 32 : 42),

                  // ==========================================
                  // AGENDA
                  // ==========================================
                  Text(
                    'AGENDA',
                    style: GoogleFonts.ibmPlexSans(
                      color: const Color(0xFFC9A86A),
                      fontSize: mobile ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: mobile ? 4 : 6,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(mobile ? 20 : 26),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B132B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF5C1A1B),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      committee.agenda,
                      style: GoogleFonts.prata(
                        color: const Color(0xFFC9A86A),
                        fontSize: mobile ? 18 : 22,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CLOSE BUTTON
// ============================================================

class _CloseButton extends StatefulWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
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
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _hovering ? const Color(0xFF5C1A1B) : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF5C1A1B), width: 2),
          ),
          child: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

// ============================================================
// DATA
// ============================================================

class _CommitteeData {
  const _CommitteeData({
    required this.abbreviation,
    required this.name,
    required this.description,
    required this.agenda,
  });

  final String abbreviation;
  final String name;
  final String description;
  final String agenda;
}
