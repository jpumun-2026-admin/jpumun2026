import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _institutionController = TextEditingController();
  final _munExperienceController = TextEditingController();

  String? _selectedClass;
  String? _committeePreference1;
  String? _committeePreference2;

  // ============================================================
  // DECLARATIONS
  // ============================================================

  bool _declaration1 = false;
  bool _declaration2 = false;
  bool _declaration3 = false;

  bool _showDeclarationError = false;

  // ============================================================
  // DESIGN TOKENS
  // ============================================================

  static const Color background = Color(0xFF0B132B);
  static const Color fieldBackground = Color(0xFF1E1E1E);
  static const Color gold = Color(0xFFC9A86A);
  static const Color red = Color(0xFF5C1A1B);
  static const Color white = Color(0xFFF9F5F4);

  static const List<String> _classes = [
    'PUC I',
    'PUC II',
    'Grade 11',
    'Grade 12',
    'Undergraduate',
    'Other',
  ];

  static const List<_Committee> _committees = [
    _Committee(
      value: 'CCC',
      label: 'Continuous Crisis Committee (CCC)',
    ),
    _Committee(
      value: 'AIPPM',
      label: 'All India Political Parties Meet (AIPPM)',
    ),
    _Committee(
      value: 'DISEC',
      label:
          'Disarmament and International Security Committee (DISEC)',
    ),
  ];

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _institutionController.dispose();
    _munExperienceController.dispose();

    super.dispose();
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }

    final regex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  String? _phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Contact number is required';
    }

    final cleaned = value.replaceAll(
      RegExp(r'[\s\-\(\)]'),
      '',
    );

    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(cleaned)) {
      return 'Enter a valid contact number';
    }

    return null;
  }

  // ============================================================
  // DECLARATION VALIDATION HELPER
  // ============================================================

  void _updateDeclarationError() {
    if (_declaration1 &&
        _declaration2 &&
        _declaration3) {
      _showDeclarationError = false;
    }
  }

  // ============================================================
  // PROCEED
  // ============================================================

  void _proceed() {
    FocusScope.of(context).unfocus();

    final valid =
        _formKey.currentState?.validate() ?? false;

    // ----------------------------------------------------------
    // Committee validation
    // ----------------------------------------------------------

    if (_committeePreference1 == null ||
        _committeePreference2 == null) {
      _showMessage(
        'Please select both committee preferences.',
      );

      return;
    }

    if (_committeePreference1 ==
        _committeePreference2) {
      _showMessage(
        'Committee Preference 1 and 2 must be different.',
      );

      return;
    }

    // ----------------------------------------------------------
    // Declaration validation
    // ----------------------------------------------------------

    if (!_declaration1 ||
        !_declaration2 ||
        !_declaration3) {
      setState(() {
        _showDeclarationError = true;
      });

      _showMessage(
        'Please accept all declarations before proceeding.',
      );

      return;
    }

    if (!valid) {
      return;
    }

    // Clear any previous declaration error.
    if (_showDeclarationError) {
      setState(() {
        _showDeclarationError = false;
      });
    }

    // ----------------------------------------------------------
    // Form data
    // ----------------------------------------------------------

    final data = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'contact': _contactController.text.trim(),
      'institution':
          _institutionController.text.trim(),
      'class': _selectedClass,
      'mun_experience':
          _munExperienceController.text.trim(),
      'committee_preference_1':
          _committeePreference1,
      'committee_preference_2':
          _committeePreference2,

      // Optional:
      // Keeping these in the payload makes it explicit that the
      // declarations were accepted.
      'declaration_information_accurate':
          _declaration1,
      'declaration_code_of_conduct':
          _declaration2,
      'declaration_allocation_policy':
          _declaration3,
    };

    debugPrint(data.toString());

    // TODO:
    // Submit data to Google Sheets here.
    //
    // Once successful, navigate to payment.
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: fieldBackground,
        behavior: SnackBarBehavior.floating,
        content: Text(
          message,
          style: GoogleFonts.ibmPlexSans(
            color: white,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PAGE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final isMobile = width < 650;
            final isTablet =
                width >= 650 && width < 1050;

            final horizontalPadding = isMobile
                ? 24.0
                : isTablet
                    ? 50.0
                    : 80.0;

            return SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1290,
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      isMobile ? 35 : 52,
                      horizontalPadding,
                      isMobile ? 60 : 100,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // ====================================
                          // HEADER
                          // ====================================

                          _buildHeader(
                            isMobile: isMobile,
                            isTablet: isTablet,
                          ),

                          SizedBox(
                            height: isMobile ? 50 : 85,
                          ),

                          // ====================================
                          // INTRODUCTION
                          // ====================================

                          _buildIntroduction(
                            isMobile: isMobile,
                          ),

                          SizedBox(
                            height: isMobile ? 45 : 65,
                          ),

                          _buildDivider(),

                          SizedBox(
                            height: isMobile ? 45 : 65,
                          ),

                          // ====================================
                          // FULL NAME
                          // ====================================

                          _FormFieldBlock(
                            label: 'Delegate Full Name',
                            child: _buildTextField(
                              controller: _nameController,
                              hint: 'John Doe',
                              validator: _required,
                            ),
                          ),

                          const SizedBox(height: 38),

                          // ====================================
                          // EMAIL + CONTACT
                          // ====================================

                          if (isMobile) ...[
                            _FormFieldBlock(
                              label: 'Email Address',
                              child: _buildTextField(
                                controller:
                                    _emailController,
                                hint:
                                    'example@email.com',
                                keyboardType:
                                    TextInputType
                                        .emailAddress,
                                validator:
                                    _emailValidator,
                              ),
                            ),

                            const SizedBox(height: 38),

                            _FormFieldBlock(
                              label: 'Contact Number',
                              child: _buildTextField(
                                controller:
                                    _contactController,
                                hint:
                                    '+91 XXXXX XXXXX',
                                keyboardType:
                                    TextInputType.phone,
                                validator:
                                    _phoneValidator,
                              ),
                            ),
                          ] else
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _FormFieldBlock(
                                    label:
                                        'Email Address',
                                    child:
                                        _buildTextField(
                                      controller:
                                          _emailController,
                                      hint:
                                          'example@email.com',
                                      keyboardType:
                                          TextInputType
                                              .emailAddress,
                                      validator:
                                          _emailValidator,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 28),

                                Expanded(
                                  child: _FormFieldBlock(
                                    label:
                                        'Contact Number',
                                    child:
                                        _buildTextField(
                                      controller:
                                          _contactController,
                                      hint:
                                          '+91 XXXXX XXXXX',
                                      keyboardType:
                                          TextInputType
                                              .phone,
                                      validator:
                                          _phoneValidator,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          const SizedBox(height: 38),

                          // ====================================
                          // INSTITUTION + CLASS
                          // ====================================

                          if (isMobile) ...[
                            _FormFieldBlock(
                              label: 'Institution Name',
                              child: _buildTextField(
                                controller:
                                    _institutionController,
                                hint:
                                    'Enter institution name',
                                validator: _required,
                              ),
                            ),

                            const SizedBox(height: 38),

                            _FormFieldBlock(
                              label: 'Class',
                              child:
                                  _buildClassDropdown(),
                            ),
                          ] else
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _FormFieldBlock(
                                    label:
                                        'Institution Name',
                                    child:
                                        _buildTextField(
                                      controller:
                                          _institutionController,
                                      hint:
                                          'Enter institution name',
                                      validator:
                                          _required,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 28),

                                Expanded(
                                  flex: 2,
                                  child: _FormFieldBlock(
                                    label: 'Class',
                                    child:
                                        _buildClassDropdown(),
                                  ),
                                ),
                              ],
                            ),

                          const SizedBox(height: 38),

                          // ====================================
                          // MUN EXPERIENCE
                          // ====================================

                          _FormFieldBlock(
                            label:
                                'MUN Experience (if any)',
                            child: _buildTextField(
                              controller:
                                  _munExperienceController,
                              hint:
                                  'Tell us about your previous MUN experience',
                              maxLines: 5,
                            ),
                          ),

                          SizedBox(
                            height: isMobile ? 50 : 65,
                          ),

                          // ====================================
                          // COMMITTEE PREFERENCE 1
                          // ====================================

                          _buildCommitteeSection(
                            title:
                                'Committee Preference 01',
                            value:
                                _committeePreference1,
                            onChanged: (value) {
                              setState(() {
                                _committeePreference1 =
                                    value;
                              });
                            },
                            isMobile: isMobile,
                          ),

                          SizedBox(
                            height: isMobile ? 50 : 70,
                          ),

                          // ====================================
                          // COMMITTEE PREFERENCE 2
                          // ====================================

                          _buildCommitteeSection(
                            title:
                                'Committee Preference 02',
                            value:
                                _committeePreference2,
                            onChanged: (value) {
                              setState(() {
                                _committeePreference2 =
                                    value;
                              });
                            },
                            isMobile: isMobile,
                          ),

                          SizedBox(
                            height: isMobile ? 55 : 75,
                          ),

                          // ====================================
                          // DECLARATION
                          // ====================================

                          _buildDeclaration(
                            isMobile: isMobile,
                          ),

                          SizedBox(
                            height: isMobile ? 55 : 80,
                          ),

                          // ====================================
                          // PROCEED
                          // ====================================

                          Center(
                            child: _ProceedButton(
                              onTap: _proceed,
                              isMobile: isMobile,
                            ),
                          ),

                          const SizedBox(height: 14),

                          Center(
                            child: Text(
                              'Up Next: Payment',
                              style:
                                  GoogleFonts.ibmPlexSans(
                                color: gold,
                                fontSize:
                                    isMobile ? 10 : 13,
                                fontWeight:
                                    FontWeight.w700,
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
          },
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader({
    required bool isMobile,
    required bool isTablet,
  }) {
    if (isMobile) {
      return Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Image.asset(
            'lib/assets/logo_text.png',
            width: 330,
            fit: BoxFit.contain,
          ),

          const SizedBox(height: 38),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'INDIVIDUAL DELEGATE\nREGISTRATION',
              textAlign: TextAlign.right,
              style: GoogleFonts.ibmPlexSerif(
                color: white,
                fontSize: 22,
                fontWeight: FontWeight.w400,
                height: 1.25,
                shadows: const [
                  Shadow(
                    color: red,
                    blurRadius: 16.9,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Image.asset(
              'lib/assets/logo_text.png',
              width: isTablet ? 430 : 600,
              fit: BoxFit.contain,
            ),
          ),
        ),

        const SizedBox(width: 40),

        Text(
          'INDIVIDUAL DELEGATE\nREGISTRATION',
          textAlign: TextAlign.right,
          style: GoogleFonts.ibmPlexSerif(
            color: white,
            fontSize: isTablet ? 25 : 34,
            fontWeight: FontWeight.w400,
            height: 1.2,
            shadows: const [
              Shadow(
                color: red,
                blurRadius: 16.9,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INTRODUCTION
  // ============================================================

  Widget _buildIntroduction({
    required bool isMobile,
  }) {
    return Text.rich(
      TextSpan(
        children: const [
          TextSpan(
            text:
                'Jain PU Model United Nations (JPUM) is an intercollegiate Model United Nations conference that brings together students to engage in diplomacy, negotiation, and critical discussion on pressing national and international issues.\n\n',
          ),
          TextSpan(
            text: 'Committees:\n',
          ),
          TextSpan(
            text:
                '-  AIPPM (All India Political Parties Meet)\n',
          ),
          TextSpan(
            text:
                '-  DISEC (Disarmament and International Security Committee)\n',
          ),
          TextSpan(
            text:
                '-  CCC (Continuous Crisis Committee)\n\n',
          ),
          TextSpan(
            text:
                'Registration Fee: ₹900 per delegate. In case of any queries, contact the Secretariat.\n\n',
          ),
          TextSpan(
            text:
                'Please fill in all required details carefully. Committee and portfolio allocations will be communicated via Email/WhatsApp after successful registration and payment verification.',
          ),
        ],
      ),
      style: GoogleFonts.ibmPlexSans(
        color: white,
        fontSize: isMobile ? 14 : 18,
        fontWeight: FontWeight.w400,
        height: 1.55,
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType keyboardType =
        TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      cursorColor: gold,
      style: GoogleFonts.ibmPlexSans(
        color: white,
        fontSize: 17,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.ibmPlexSans(
          color: white.withValues(alpha: 0.56),
          fontSize: 17,
        ),
        filled: true,
        fillColor: fieldBackground,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 18,
          vertical: maxLines > 1 ? 20 : 18,
        ),
        border: _inputBorder(gold),
        enabledBorder: _inputBorder(gold),
        focusedBorder:
            _inputBorder(gold, width: 2),
        errorBorder:
            _inputBorder(Colors.redAccent),
        focusedErrorBorder:
            _inputBorder(
          Colors.redAccent,
          width: 2,
        ),
        errorStyle: GoogleFonts.ibmPlexSans(
          color: Colors.redAccent,
          fontSize: 12,
        ),
      ),
    );
  }

  OutlineInputBorder _inputBorder(
    Color color, {
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }

  // ============================================================
  // CLASS DROPDOWN
  // ============================================================

  Widget _buildClassDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedClass,
      dropdownColor: fieldBackground,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: white,
      ),
      style: GoogleFonts.ibmPlexSans(
        color: white,
        fontSize: 17,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: fieldBackground,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: _inputBorder(gold),
        enabledBorder: _inputBorder(gold),
        focusedBorder:
            _inputBorder(gold, width: 2),
        errorBorder:
            _inputBorder(Colors.redAccent),
      ),
      items: _classes
          .map(
            (value) => DropdownMenuItem(
              value: value,
              child: Text(value),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedClass = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select your class';
        }

        return null;
      },
    );
  }

  // ============================================================
  // COMMITTEE SECTION
  // ============================================================

  Widget _buildCommitteeSection({
    required String title,
    required String? value,
    required ValueChanged<String?> onChanged,
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _UnderlinedLabel(
          text: title,
          fontSize: isMobile ? 20 : 28,
        ),

        const SizedBox(height: 22),

        ..._committees.map(
          (committee) {
            final selected =
                value == committee.value;

            return Padding(
              padding:
                  const EdgeInsets.only(bottom: 14),
              child: InkWell(
                borderRadius:
                    BorderRadius.circular(16),
                onTap: () =>
                    onChanged(committee.value),
                child: AnimatedContainer(
                  duration:
                      const Duration(milliseconds: 150),
                  width: double.infinity,
                  constraints:
                      const BoxConstraints(
                    minHeight: 64,
                  ),
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? fieldBackground
                        : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(16),
                    border: selected
                        ? Border.all(
                            color: gold,
                            width: 1,
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      _RadioCircle(
                        selected: selected,
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Text(
                          committee.label,
                          style:
                              GoogleFonts.ibmPlexSans(
                            color: white,
                            fontSize:
                                isMobile ? 14 : 19,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // DECLARATION
  // ============================================================

  Widget _buildDeclaration({
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _UnderlinedLabel(
          text: 'Declaration',
          fontSize: isMobile ? 20 : 28,
        ),

        const SizedBox(height: 28),

        // ------------------------------------------------------
        // Declaration 1
        // ------------------------------------------------------

        _DeclarationItem(
          value: _declaration1,
          text:
              'I confirm that all the information provided is accurate',
          isMobile: isMobile,
          onChanged: (value) {
            setState(() {
              _declaration1 = value;
              _updateDeclarationError();
            });
          },
        ),

        const SizedBox(height: 18),

        // ------------------------------------------------------
        // Declaration 2
        // ------------------------------------------------------

        _DeclarationItem(
          value: _declaration2,
          text:
              'I agree to abide by the Code of Conduct and decisions of the Executive Board and Secretariat.',
          isMobile: isMobile,
          onChanged: (value) {
            setState(() {
              _declaration2 = value;
              _updateDeclarationError();
            });
          },
        ),

        const SizedBox(height: 18),

        // ------------------------------------------------------
        // Declaration 3
        // ------------------------------------------------------

        _DeclarationItem(
          value: _declaration3,
          text:
              'I understand that committee and portfolio allocations are subject to availability and the discretion of the Secretariat',
          isMobile: isMobile,
          onChanged: (value) {
            setState(() {
              _declaration3 = value;
              _updateDeclarationError();
            });
          },
        ),

        // ------------------------------------------------------
        // Validation message
        // ------------------------------------------------------

        if (_showDeclarationError) ...[
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 18,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  'Please accept all declarations to continue.',
                  style:
                      GoogleFonts.ibmPlexSans(
                    color: Colors.redAccent,
                    fontSize:
                        isMobile ? 12 : 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _buildDivider() {
    return Row(
      children: [
        Transform.rotate(
          angle: 0.785398,
          child: Container(
            width: 7,
            height: 7,
            color: red,
          ),
        ),

        Expanded(
          child: Container(
            height: 1.5,
            color: red,
          ),
        ),

        Transform.rotate(
          angle: 0.785398,
          child: Container(
            width: 7,
            height: 7,
            color: red,
          ),
        ),
      ],
    );
  }
}

// ================================================================
// FORM FIELD BLOCK
// ================================================================

class _FormFieldBlock extends StatelessWidget {
  const _FormFieldBlock({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _UnderlinedLabel(
          text: label,
        ),

        const SizedBox(height: 12),

        child,
      ],
    );
  }
}

// ================================================================
// UNDERLINED LABEL
// ================================================================

class _UnderlinedLabel extends StatelessWidget {
  const _UnderlinedLabel({
    required this.text,
    this.fontSize = 22,
  });

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.ibmPlexSerif(
        color: const Color(0xFFF9F5F4),
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.underline,
        decorationColor:
            const Color(0xFFF9F5F4),
        shadows: const [
          Shadow(
            color: Color(0xFF5C1A1B),
            blurRadius: 16.9,
          ),
        ],
      ),
    );
  }
}

// ================================================================
// RADIO CIRCLE
// ================================================================

class _RadioCircle extends StatelessWidget {
  const _RadioCircle({
    required this.selected,
  });

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25,
      height: 25,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? const Color(0xFFC9A86A)
              : Colors.white,
          width: 2,
        ),
      ),
      child: selected
          ? const DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFC9A86A),
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}

// ================================================================
// DECLARATION ITEM
// ================================================================

class _DeclarationItem extends StatelessWidget {
  const _DeclarationItem({
    required this.value,
    required this.text,
    required this.onChanged,
    required this.isMobile,
  });

  final bool value;
  final String text;
  final ValueChanged<bool> onChanged;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () => onChanged(!value),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 2,
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration:
                  const Duration(milliseconds: 150),
              width: isMobile ? 25 : 32,
              height: isMobile ? 25 : 32,
              margin:
                  const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(4),
                border: Border.all(
                  color: value
                      ? const Color(0xFFC9A86A)
                      : Colors.white,
                  width: 2,
                ),
                color: value
                    ? const Color(0xFFC9A86A)
                    : Colors.transparent,
              ),
              child: value
                  ? const Icon(
                      Icons.check_rounded,
                      color:
                          Color(0xFF0B132B),
                      size: 20,
                    )
                  : null,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                text,
                style:
                    GoogleFonts.ibmPlexSans(
                  color: Colors.white,
                  fontSize:
                      isMobile ? 14 : 18,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// PROCEED BUTTON
// ================================================================

class _ProceedButton extends StatefulWidget {
  const _ProceedButton({
    required this.onTap,
    required this.isMobile,
  });

  final VoidCallback onTap;
  final bool isMobile;

  @override
  State<_ProceedButton> createState() =>
      _ProceedButtonState();
}

class _ProceedButtonState
    extends State<_ProceedButton> {
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
          duration:
              const Duration(milliseconds: 180),
          width: widget.isMobile
              ? double.infinity
              : 560,
          height:
              widget.isMobile ? 65 : 90,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hovering
                ? const Color(0xFFD8B978)
                : const Color(0xFFC9A86A),
            borderRadius:
                BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color:
                    const Color(0xFFC9A86A)
                        .withValues(
                  alpha:
                      _hovering ? 0.45 : 0.33,
                ),
                blurRadius:
                    _hovering ? 80 : 65,
                spreadRadius:
                    _hovering ? 15 : 10,
              ),
            ],
          ),
          child: Text(
            'PROCEED',
            style:
                GoogleFonts.ibmPlexSerif(
              color:
                  const Color(0xFF0B132B),
              fontSize:
                  widget.isMobile ? 23 : 32,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// COMMITTEE DATA
// ================================================================

class _Committee {
  const _Committee({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;
}