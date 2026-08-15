import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jpumun_website/app_config.dart';
import 'package:jpumun_website/payment.dart';
import 'package:jpumun_website/services/registration_api.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  bool _isSubmitting = false;
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _institutionController = TextEditingController();
  final _munExperienceController = TextEditingController();
  final _portfolioPreference1Controller = TextEditingController();
  final _portfolioPreference2Controller = TextEditingController();

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

  static const List<String> _classes = ['11th Class', '12th Class'];

  static const List<_Committee> _committees = [
    _Committee(value: 'CCC', label: 'Continuous Crisis Committee (CCC)'),
    _Committee(
      value: 'AIPPM',
      label: 'All India Political Parties Meet (AIPPM)',
    ),
    _Committee(
      value: 'DISEC',
      label: 'Disarmament and International Security Committee (DISEC)',
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
    _portfolioPreference1Controller.dispose();
    _portfolioPreference2Controller.dispose();

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

    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  String? _phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Contact number is required';
    }

    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(cleaned)) {
      return 'Enter a valid contact number';
    }

    return null;
  }

  // ============================================================
  // DECLARATION VALIDATION HELPER
  // ============================================================

  void _updateDeclarationError() {
    if (_declaration1 && _declaration2 && _declaration3) {
      _showDeclarationError = false;
    }
  }

  // ============================================================
  // PROCEED
  // ============================================================

  Future<void> _proceed() async {
    if (_isSubmitting) return;

    FocusScope.of(context).unfocus();

    final valid = _formKey.currentState?.validate() ?? false;

    if (_committeePreference1 == null || _committeePreference2 == null) {
      _showMessage('Please select both committee preferences.');
      return;
    }

    if (_committeePreference1 == _committeePreference2) {
      _showMessage('Committee Preference 1 and 2 must be different.');
      return;
    }

    if (!_declaration1 || !_declaration2 || !_declaration3) {
      setState(() => _showDeclarationError = true);
      _showMessage('Please accept all declarations before proceeding.');
      return;
    }

    if (!valid) return;

    if (_showDeclarationError) {
      setState(() => _showDeclarationError = false);
    }

    final data = <String, dynamic>{
      'registration_type': 'individual',
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'contact': _contactController.text.trim(),
      'institution': _institutionController.text.trim(),
      'class': _selectedClass,
      'mun_experience': _munExperienceController.text.trim(),
      'committee_preference_1': _committeePreference1,
      'committee_preference_2': _committeePreference2,
      'portfolio_preference_1': _portfolioPreference1Controller.text.trim(),
      'portfolio_preference_2': _portfolioPreference2Controller.text.trim(),
      'declaration_information_accurate': _declaration1,
      'declaration_code_of_conduct': _declaration2,
      'declaration_allocation_policy': _declaration3,
    };

    await _showPaymentSummaryAndProceed(
      title: 'Individual Delegate Registration',
      delegateCount: 1,
      totalAmountPaise: kIndividualRegistrationFeePaise,
      onConfirm: () => _completeRegistration(data),
    );
  }

  Future<void> _completeRegistration(Map<String, dynamic> data) async {
    setState(() => _isSubmitting = true);

    try {
      final decoded = await RegistrationApi.submitRegistration(data);
      final registrationId = decoded['registration_id']?.toString();
      if (registrationId == null || registrationId.isEmpty) {
        throw const RegistrationApiException(
          'Registration was created, but no registration ID was returned.',
        );
      }

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PaymentPage(
            registrationId: registrationId,
            registrationType: 'individual',
            amountPaise: kIndividualRegistrationFeePaise,
          ),
        ),
      );
    } on RegistrationApiException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (error) {
      if (!mounted) return;
      _showMessage(
        'Could not submit your registration right now. Please try again.\n$error',
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _showPaymentSummaryAndProceed({
    required String title,
    required int delegateCount,
    required int totalAmountPaise,
    required Future<void> Function() onConfirm,
  }) async {
    final shouldContinue = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (sheetContext) {
        return _PaymentSummarySheet(
          title: title,
          delegateCount: delegateCount,
          perHeadAmountPaise: kIndividualRegistrationFeePaise,
          subtotalAmountPaise: totalAmountPaise,
          onViewPolicies: () {
            Navigator.of(
              sheetContext,
              rootNavigator: true,
            ).pushNamed('/policies');
          },
          onPayNow: () {
            Navigator.of(sheetContext).pop(true);
          },
        );
      },
    );

    if (shouldContinue == true && mounted) {
      await onConfirm();
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: fieldBackground,
        behavior: SnackBarBehavior.floating,
        content: Text(message, style: GoogleFonts.ibmPlexSans(color: white)),
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
            final isTablet = width >= 650 && width < 1050;

            final horizontalPadding = isMobile
                ? 24.0
                : isTablet
                ? 50.0
                : 80.0;

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1290),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ====================================
                          // HEADER
                          // ====================================
                          _buildHeader(isMobile: isMobile, isTablet: isTablet),

                          SizedBox(height: isMobile ? 50 : 85),

                          // ====================================
                          // INTRODUCTION
                          // ====================================
                          _buildIntroduction(isMobile: isMobile),

                          SizedBox(height: isMobile ? 45 : 65),

                          _buildDivider(),

                          SizedBox(height: isMobile ? 45 : 65),

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
                                controller: _emailController,
                                hint: 'example@email.com',
                                keyboardType: TextInputType.emailAddress,
                                validator: _emailValidator,
                              ),
                            ),

                            const SizedBox(height: 38),

                            _FormFieldBlock(
                              label: 'Contact Number',
                              child: _buildTextField(
                                controller: _contactController,
                                hint: '+91 XXXXX XXXXX',
                                keyboardType: TextInputType.phone,
                                validator: _phoneValidator,
                              ),
                            ),
                          ] else
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _FormFieldBlock(
                                    label: 'Email Address',
                                    child: _buildTextField(
                                      controller: _emailController,
                                      hint: 'example@email.com',
                                      keyboardType: TextInputType.emailAddress,
                                      validator: _emailValidator,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 28),

                                Expanded(
                                  child: _FormFieldBlock(
                                    label: 'Contact Number',
                                    child: _buildTextField(
                                      controller: _contactController,
                                      hint: '+91 XXXXX XXXXX',
                                      keyboardType: TextInputType.phone,
                                      validator: _phoneValidator,
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
                                controller: _institutionController,
                                hint: 'Enter institution name',
                                validator: _required,
                              ),
                            ),

                            const SizedBox(height: 38),

                            _FormFieldBlock(
                              label: 'Class',
                              child: _buildClassDropdown(),
                            ),
                          ] else
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _FormFieldBlock(
                                    label: 'Institution Name',
                                    child: _buildTextField(
                                      controller: _institutionController,
                                      hint: 'Enter institution name',
                                      validator: _required,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 28),

                                Expanded(
                                  flex: 2,
                                  child: _FormFieldBlock(
                                    label: 'Class',
                                    child: _buildClassDropdown(),
                                  ),
                                ),
                              ],
                            ),

                          const SizedBox(height: 38),

                          // ====================================
                          // MUN EXPERIENCE
                          // ====================================
                          _FormFieldBlock(
                            label: 'MUN Experience (if any)',
                            child: _buildTextField(
                              controller: _munExperienceController,
                              hint:
                                  'Tell us about your previous MUN experience',
                              maxLines: 5,
                            ),
                          ),

                          SizedBox(height: isMobile ? 50 : 65),

                          // ====================================
                          // COMMITTEE PREFERENCE 1
                          // ====================================
                          _buildCommitteeSection(
                            title: 'Committee Preference 01',
                            value: _committeePreference1,
                            onChanged: (value) {
                              setState(() {
                                _committeePreference1 = value;
                              });
                            },
                            isMobile: isMobile,
                          ),

                          SizedBox(height: isMobile ? 50 : 70),

                          // ====================================
                          // COMMITTEE PREFERENCE 2
                          // ====================================
                          _buildCommitteeSection(
                            title: 'Committee Preference 02',
                            value: _committeePreference2,
                            onChanged: (value) {
                              setState(() {
                                _committeePreference2 = value;
                              });
                            },
                            isMobile: isMobile,
                          ),

                          SizedBox(height: isMobile ? 38 : 50),

                          _FormFieldBlock(
                            label: 'Portfolio Preference 01',
                            child: _buildTextField(
                              controller: _portfolioPreference1Controller,
                              hint:
                                  'Enter portfolio preference for committee 1',
                              validator: _required,
                            ),
                          ),

                          SizedBox(height: isMobile ? 34 : 42),

                          _FormFieldBlock(
                            label: 'Portfolio Preference 02',
                            child: _buildTextField(
                              controller: _portfolioPreference2Controller,
                              hint:
                                  'Enter portfolio preference for committee 2',
                              validator: _required,
                            ),
                          ),

                          SizedBox(height: isMobile ? 55 : 75),

                          // ====================================
                          // DECLARATION
                          // ====================================
                          _buildDeclaration(isMobile: isMobile),

                          SizedBox(height: isMobile ? 55 : 80),

                          // ====================================
                          // PROCEED
                          // ====================================
                          Center(
                            child: _ProceedButton(
                              onTap: _isSubmitting ? null : () => _proceed(),
                              isMobile: isMobile,
                              isLoading: _isSubmitting,
                            ),
                          ),

                          const SizedBox(height: 14),

                          Center(
                            child: Text(
                              'You will be redirected to the payment proof step for INR 950',
                              style: GoogleFonts.ibmPlexSans(
                                color: gold,
                                fontSize: isMobile ? 10 : 13,
                                fontWeight: FontWeight.w700,
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

  Widget _buildHeader({required bool isMobile, required bool isTablet}) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                shadows: const [Shadow(color: red, blurRadius: 16.9)],
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
            shadows: const [Shadow(color: red, blurRadius: 16.9)],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INTRODUCTION
  // ============================================================

  Widget _buildIntroduction({required bool isMobile}) {
    return Text.rich(
      TextSpan(
        children: const [
          TextSpan(
            text:
                'Jain PU Model United Nations (JPUM) is an intercollegiate Model United Nations conference that brings together students to engage in diplomacy, negotiation, and critical discussion on pressing national and international issues.\n\n',
          ),
          TextSpan(text: 'Committees:\n'),
          TextSpan(text: '-  AIPPM (All India Political Parties Meet)\n'),
          TextSpan(
            text:
                '-  DISEC (Disarmament and International Security Committee)\n',
          ),
          TextSpan(text: '-  CCC (Continuous Crisis Committee)\n\n'),
          TextSpan(
            text:
                'Registration Fee: ₹950 per delegate. In case of any queries, contact the Secretariat.\n\n',
          ),
          TextSpan(
            text:
                'Please fill in all required details carefully. Committee and portfolio allocations will be communicated via Email/WhatsApp after registration and payment verification.',
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
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      cursorColor: gold,
      style: GoogleFonts.ibmPlexSans(color: white, fontSize: 17),
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
        focusedBorder: _inputBorder(gold, width: 2),
        errorBorder: _inputBorder(Colors.redAccent),
        focusedErrorBorder: _inputBorder(Colors.redAccent, width: 2),
        errorStyle: GoogleFonts.ibmPlexSans(
          color: Colors.redAccent,
          fontSize: 12,
        ),
      ),
    );
  }

  OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  // ============================================================
  // CLASS DROPDOWN
  // ============================================================

  Widget _buildClassDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedClass,
      dropdownColor: fieldBackground,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: white),
      style: GoogleFonts.ibmPlexSans(color: white, fontSize: 17),
      decoration: InputDecoration(
        filled: true,
        fillColor: fieldBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: _inputBorder(gold),
        enabledBorder: _inputBorder(gold),
        focusedBorder: _inputBorder(gold, width: 2),
        errorBorder: _inputBorder(Colors.redAccent),
      ),
      items: _classes
          .map((value) => DropdownMenuItem(value: value, child: Text(value)))
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _UnderlinedLabel(text: title, fontSize: isMobile ? 20 : 28),

        const SizedBox(height: 22),

        ..._committees.map((committee) {
          final selected = value == committee.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onChanged(committee.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 64),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? fieldBackground : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: selected ? Border.all(color: gold, width: 1) : null,
                ),
                child: Row(
                  children: [
                    _RadioCircle(selected: selected),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Text(
                        committee.label,
                        style: GoogleFonts.ibmPlexSans(
                          color: white,
                          fontSize: isMobile ? 14 : 19,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ============================================================
  // DECLARATION
  // ============================================================

  Widget _buildDeclaration({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _UnderlinedLabel(text: 'Declaration', fontSize: isMobile ? 20 : 28),

        const SizedBox(height: 28),

        // ------------------------------------------------------
        // Declaration 1
        // ------------------------------------------------------
        _DeclarationItem(
          value: _declaration1,
          text: 'I confirm that all the information provided is accurate',
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  style: GoogleFonts.ibmPlexSans(
                    color: Colors.redAccent,
                    fontSize: isMobile ? 12 : 14,
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
          child: Container(width: 7, height: 7, color: red),
        ),

        Expanded(child: Container(height: 1.5, color: red)),

        Transform.rotate(
          angle: 0.785398,
          child: Container(width: 7, height: 7, color: red),
        ),
      ],
    );
  }
}

// ================================================================
// FORM FIELD BLOCK
// ================================================================

class _FormFieldBlock extends StatelessWidget {
  const _FormFieldBlock({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _UnderlinedLabel(text: label),

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
  const _UnderlinedLabel({required this.text, this.fontSize = 22});

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
        decorationColor: const Color(0xFFF9F5F4),
        shadows: const [Shadow(color: Color(0xFF5C1A1B), blurRadius: 16.9)],
      ),
    );
  }
}

// ================================================================
// RADIO CIRCLE
// ================================================================

class _RadioCircle extends StatelessWidget {
  const _RadioCircle({required this.selected});

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
          color: selected ? const Color(0xFFC9A86A) : Colors.white,
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
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: isMobile ? 25 : 32,
              height: isMobile ? 25 : 32,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: value ? const Color(0xFFC9A86A) : Colors.white,
                  width: 2,
                ),
                color: value ? const Color(0xFFC9A86A) : Colors.transparent,
              ),
              child: value
                  ? const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF0B132B),
                      size: 20,
                    )
                  : null,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                text,
                style: GoogleFonts.ibmPlexSans(
                  color: Colors.white,
                  fontSize: isMobile ? 14 : 18,
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
    required this.isLoading,
  });

  final Future<void> Function()? onTap;
  final bool isMobile;
  final bool isLoading;

  @override
  State<_ProceedButton> createState() => _ProceedButtonState();
}

class _PaymentSummarySheet extends StatelessWidget {
  const _PaymentSummarySheet({
    required this.title,
    required this.delegateCount,
    required this.perHeadAmountPaise,
    required this.subtotalAmountPaise,
    required this.onViewPolicies,
    required this.onPayNow,
  });

  final String title;
  final int delegateCount;
  final int perHeadAmountPaise;
  final int subtotalAmountPaise;
  final VoidCallback onViewPolicies;
  final VoidCallback onPayNow;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111A33),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFF5C1A1B), width: 1.4),
            boxShadow: const [
              BoxShadow(
                color: Color(0x59000000),
                blurRadius: 30,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0x55F9F5F4),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Payment Summary',
                  style: GoogleFonts.prata(
                    color: const Color(0xFFC9A86A),
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: GoogleFonts.ibmPlexSans(
                    color: const Color(0xFFF9F5F4),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                _SummaryRow(
                  label: 'Per delegate',
                  value: _formatAmount(perHeadAmountPaise),
                ),
                const SizedBox(height: 12),
                _SummaryRow(label: 'Delegates', value: '$delegateCount'),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: const Color(0x335C1A1B),
                ),
                const SizedBox(height: 16),
                _SummaryRow(
                  label: 'Subtotal',
                  value: _formatAmount(subtotalAmountPaise),
                  emphasize: true,
                ),
                const SizedBox(height: 18),
                Center(
                  child: TextButton(
                    onPressed: onViewPolicies,
                    child: Text(
                      'Terms and Conditions',
                      style: GoogleFonts.ibmPlexSans(
                        color: const Color(0xFFC9A86A),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFFC9A86A),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onPayNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC9A86A),
                      foregroundColor: const Color(0xFF0B132B),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      'CONTINUE',
                      style: GoogleFonts.prata(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatAmount(int amountPaise) {
    return 'INR ${(amountPaise / 100).toStringAsFixed(0)}';
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final valueColor = emphasize
        ? const Color(0xFFC9A86A)
        : const Color(0xFFF9F5F4);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.ibmPlexSans(
              color: const Color(0xFFF9F5F4),
              fontSize: 15,
              fontWeight: emphasize ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.ibmPlexSans(
            color: valueColor,
            fontSize: emphasize ? 18 : 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ProceedButtonState extends State<_ProceedButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.isLoading
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) {
        if (!widget.isLoading) {
          setState(() => _hovering = true);
        }
      },
      onExit: (_) {
        setState(() {
          _hovering = false;
        });
      },
      child: GestureDetector(
        onTap: widget.isLoading || widget.onTap == null
            ? null
            : () {
                widget.onTap!();
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: widget.isMobile ? double.infinity : 560,
          height: widget.isMobile ? 65 : 90,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hovering
                ? const Color(0xFFD8B978)
                : const Color(0xFFC9A86A),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFFC9A86A,
                ).withValues(alpha: _hovering ? 0.45 : 0.33),
                blurRadius: _hovering ? 80 : 65,
                spreadRadius: _hovering ? 15 : 10,
              ),
            ],
          ),
          child: widget.isLoading
              ? SizedBox(
                  width: widget.isMobile ? 26 : 32,
                  height: widget.isMobile ? 26 : 32,
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Color(0xFF0B132B),
                  ),
                )
              : Text(
                  'PROCEED TO PAYMENT',
                  style: GoogleFonts.ibmPlexSerif(
                    color: const Color(0xFF0B132B),
                    fontSize: widget.isMobile ? 19 : 28,
                    fontWeight: FontWeight.w700,
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
  const _Committee({required this.value, required this.label});

  final String value;
  final String label;
}
