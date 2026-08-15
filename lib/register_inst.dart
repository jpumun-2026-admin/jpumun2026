import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jpumun_website/app_config.dart';
import 'package:jpumun_website/payment.dart';
import 'package:jpumun_website/services/registration_api.dart';

class RegisterInstitute extends StatefulWidget {
  const RegisterInstitute({super.key});

  @override
  State<RegisterInstitute> createState() => _RegisterInstituteState();
}

class _RegisterInstituteState extends State<RegisterInstitute> {
  final _formKey = GlobalKey<FormState>();

  bool _isSubmitting = false;
  // ============================================================
  // FORM A — INSTITUTIONAL REGISTRATION
  // ============================================================

  final _institutionController = TextEditingController();

  final _facultyAdvisorNameController = TextEditingController();
  final _facultyAdvisorContactController = TextEditingController();

  final _headDelegateNameController = TextEditingController();
  final _headDelegateContactController = TextEditingController();

  final _delegationSizeController = TextEditingController();

  // ============================================================
  // FORM B — DELEGATE DETAILS
  // ============================================================

  final List<_DelegateFormData> _delegates = [_DelegateFormData()];

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
  static const List<String> _classes = ['11th Class', '12th Class'];

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _institutionController.dispose();

    _facultyAdvisorNameController.dispose();
    _facultyAdvisorContactController.dispose();

    _headDelegateNameController.dispose();
    _headDelegateContactController.dispose();

    _delegationSizeController.dispose();

    for (final delegate in _delegates) {
      delegate.dispose();
    }

    super.dispose();
  }

  // ============================================================
  // VALIDATORS
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

  String? _delegationSizeValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Delegation size is required';
    }

    final size = int.tryParse(value.trim());

    if (size == null || size <= 0) {
      return 'Enter a valid delegation size';
    }

    return null;
  }

  // ============================================================
  // DELEGATE MANAGEMENT
  // ============================================================

  void _addDelegate() {
    setState(() {
      _delegates.add(_DelegateFormData());
    });
  }

  void _removeDelegate(int index) {
    if (_delegates.length == 1) {
      _showMessage('At least one delegate must be added.');
      return;
    }

    final removed = _delegates.removeAt(index);
    removed.dispose();

    setState(() {});
  }

  // ============================================================
  // DECLARATION HELPER
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

    for (int i = 0; i < _delegates.length; i++) {
      final delegate = _delegates[i];

      if (delegate.selectedClass == null) {
        _showMessage('Please select the class for Delegate ${i + 1}.');
        return;
      }

      if (delegate.committeePreference1 == null ||
          delegate.committeePreference2 == null) {
        _showMessage(
          'Please select both committee preferences for Delegate ${i + 1}.',
        );
        return;
      }

      if (delegate.committeePreference1 == delegate.committeePreference2) {
        _showMessage(
          'Delegate ${i + 1} must select two different committee preferences.',
        );
        return;
      }
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
      'registration_type': 'institutional',
      'institution_name': _institutionController.text.trim(),
      'faculty_advisor': {
        'name': _facultyAdvisorNameController.text.trim(),
        'contact': _facultyAdvisorContactController.text.trim(),
      },
      'head_delegate': {
        'name': _headDelegateNameController.text.trim(),
        'contact': _headDelegateContactController.text.trim(),
      },
      'approximate_delegation_size': int.tryParse(
        _delegationSizeController.text.trim(),
      ),
      'delegates': _delegates
          .map(
            (delegate) => {
              'full_name': delegate.nameController.text.trim(),
              'email': delegate.emailController.text.trim(),
              'contact': delegate.contactController.text.trim(),
              'class': delegate.selectedClass,
              'mun_experience': delegate.munExperienceController.text.trim(),
              'committee_preference_1': delegate.committeePreference1,
              'committee_preference_2': delegate.committeePreference2,
              'portfolio_country_preference_1': delegate
                  .portfolioPreference1Controller
                  .text
                  .trim(),
              'portfolio_country_preference_2': delegate
                  .portfolioPreference2Controller
                  .text
                  .trim(),
            },
          )
          .toList(),
      'declaration_information_accurate': _declaration1,
      'declaration_code_of_conduct': _declaration2,
      'declaration_allocation_policy': _declaration3,
    };

    final delegateCount = _delegates.length;
    final subtotalAmountPaise =
        delegateCount * kInstitutionalRegistrationFeePerDelegatePaise;

    await _showPaymentSummaryAndProceed(
      title: 'Institutional Delegation Registration',
      delegateCount: delegateCount,
      subtotalAmountPaise: subtotalAmountPaise,
      onConfirm: () =>
          _completeRegistration(data, totalAmountPaise: subtotalAmountPaise),
    );
  }

  Future<void> _completeRegistration(
    Map<String, dynamic> data, {
    required int totalAmountPaise,
  }) async {
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
            registrationType: 'institutional',
            amountPaise: totalAmountPaise,
          ),
        ),
      );
    } on RegistrationApiException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (error) {
      if (!mounted) return;
      _showMessage(
        'Could not submit your institutional registration right now. Please try again.\n$error',
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
    required int subtotalAmountPaise,
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
          perHeadAmountPaise: kInstitutionalRegistrationFeePerDelegatePaise,
          subtotalAmountPaise: subtotalAmountPaise,
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
                          // FORM A
                          // ====================================
                          _buildSectionHeading(
                            number: '01',
                            title: 'Institutional Registration',
                            isMobile: isMobile,
                          ),

                          SizedBox(height: isMobile ? 38 : 52),

                          _buildFormA(isMobile: isMobile),

                          SizedBox(height: isMobile ? 55 : 80),

                          _buildDivider(),

                          SizedBox(height: isMobile ? 55 : 80),

                          // ====================================
                          // FORM B
                          // ====================================
                          _buildSectionHeading(
                            number: '02',
                            title: 'Delegation Details',
                            isMobile: isMobile,
                          ),

                          const SizedBox(height: 18),

                          Text(
                            'Please provide the details of each delegate who will be representing your institution.',
                            style: GoogleFonts.ibmPlexSans(
                              color: white.withValues(alpha: 0.75),
                              fontSize: isMobile ? 13 : 17,
                              height: 1.5,
                            ),
                          ),

                          SizedBox(height: isMobile ? 35 : 50),

                          ...List.generate(_delegates.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 34),
                              child: _buildDelegateCard(
                                index: index,
                                isMobile: isMobile,
                              ),
                            );
                          }),

                          const SizedBox(height: 6),

                          _AddDelegateButton(
                            onTap: _addDelegate,
                            isMobile: isMobile,
                            isLoading: false,
                          ),

                          SizedBox(height: isMobile ? 60 : 85),

                          _buildDivider(),

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
                              onTap: _isSubmitting ? null : _proceed,
                              isMobile: isMobile,
                              isLoading: _isSubmitting,
                            ),
                          ),

                          const SizedBox(height: 14),

                          Center(
                            child: Text(
                              'You will be redirected to the payment proof step after registration',
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
              'INSTITUTIONAL DELEGATION\nREGISTRATION',
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
          'INSTITUTIONAL DELEGATION\nREGISTRATION',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        Text(
          'This registration form must be completed by the Head Delegate on behalf of the institution.',
          style: GoogleFonts.ibmPlexSans(
            color: gold,
            fontSize: isMobile ? 14 : 18,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 14),

        Text(
          'The Head Delegate is responsible for providing the institutional details and the details of all participating delegates. Please ensure that all information entered is accurate before proceeding to payment.',
          style: GoogleFonts.ibmPlexSans(
            color: white,
            fontSize: isMobile ? 14 : 18,
            fontWeight: FontWeight.w400,
            height: 1.55,
          ),
        ),

        const SizedBox(height: 14),

        Text(
          'Following confirmation of the institutional registration, registration details will be communicated to the Head Delegate and Faculty Advisor.',
          style: GoogleFonts.ibmPlexSans(
            color: white.withValues(alpha: 0.75),
            fontSize: isMobile ? 13 : 17,
            fontWeight: FontWeight.w400,
            height: 1.55,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION HEADING
  // ============================================================

  Widget _buildSectionHeading({
    required String number,
    required String title,
    required bool isMobile,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          number,
          style: GoogleFonts.ibmPlexSans(
            color: gold,
            fontSize: isMobile ? 16 : 20,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(width: 18),

        Expanded(
          child: Text(
            title,
            style: GoogleFonts.ibmPlexSerif(
              color: white,
              fontSize: isMobile ? 26 : 36,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FORM A
  // ============================================================

  Widget _buildFormA({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Institution
        _FormFieldBlock(
          label: 'Institution Name',
          child: _buildTextField(
            controller: _institutionController,
            hint: 'Enter institution name',
            validator: _required,
          ),
        ),

        const SizedBox(height: 38),

        // Faculty Advisor
        _UnderlinedLabel(text: 'Faculty Advisor', fontSize: isMobile ? 20 : 26),

        const SizedBox(height: 22),

        if (isMobile) ...[
          _FormFieldBlock(
            label: 'Faculty Advisor Name',
            child: _buildTextField(
              controller: _facultyAdvisorNameController,
              hint: 'Enter faculty advisor name',
              validator: _required,
            ),
          ),

          const SizedBox(height: 38),

          _FormFieldBlock(
            label: 'Contact Number',
            child: _buildTextField(
              controller: _facultyAdvisorContactController,
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
                  label: 'Faculty Advisor Name',
                  child: _buildTextField(
                    controller: _facultyAdvisorNameController,
                    hint: 'Enter faculty advisor name',
                    validator: _required,
                  ),
                ),
              ),

              const SizedBox(width: 28),

              Expanded(
                child: _FormFieldBlock(
                  label: 'Contact Number',
                  child: _buildTextField(
                    controller: _facultyAdvisorContactController,
                    hint: '+91 XXXXX XXXXX',
                    keyboardType: TextInputType.phone,
                    validator: _phoneValidator,
                  ),
                ),
              ),
            ],
          ),

        const SizedBox(height: 48),

        // Head Delegate
        _UnderlinedLabel(text: 'Head Delegate', fontSize: isMobile ? 20 : 26),

        const SizedBox(height: 22),

        if (isMobile) ...[
          _FormFieldBlock(
            label: 'Head Delegate Name',
            child: _buildTextField(
              controller: _headDelegateNameController,
              hint: 'Enter head delegate name',
              validator: _required,
            ),
          ),

          const SizedBox(height: 38),

          _FormFieldBlock(
            label: 'Contact Number',
            child: _buildTextField(
              controller: _headDelegateContactController,
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
                  label: 'Head Delegate Name',
                  child: _buildTextField(
                    controller: _headDelegateNameController,
                    hint: 'Enter head delegate name',
                    validator: _required,
                  ),
                ),
              ),

              const SizedBox(width: 28),

              Expanded(
                child: _FormFieldBlock(
                  label: 'Contact Number',
                  child: _buildTextField(
                    controller: _headDelegateContactController,
                    hint: '+91 XXXXX XXXXX',
                    keyboardType: TextInputType.phone,
                    validator: _phoneValidator,
                  ),
                ),
              ),
            ],
          ),

        const SizedBox(height: 38),

        // Delegation size
        _FormFieldBlock(
          label: 'Approximate Delegation Size',
          child: _buildTextField(
            controller: _delegationSizeController,
            hint: 'Enter approximate number of delegates',
            keyboardType: TextInputType.number,
            validator: _delegationSizeValidator,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DELEGATE CARD
  // ============================================================

  Widget _buildDelegateCard({required int index, required bool isMobile}) {
    final delegate = _delegates[index];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: fieldBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: red, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Delegate ${index + 1}',
                  style: GoogleFonts.ibmPlexSerif(
                    color: gold,
                    fontSize: isMobile ? 22 : 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              if (_delegates.length > 1)
                IconButton(
                  tooltip: 'Remove delegate',
                  onPressed: () => _removeDelegate(index),
                  icon: const Icon(Icons.close_rounded, color: white),
                ),
            ],
          ),

          const SizedBox(height: 30),

          // Full name
          _FormFieldBlock(
            label: 'Delegate Full Name',
            child: _buildTextField(
              controller: delegate.nameController,
              hint: 'John Doe',
              validator: _required,
            ),
          ),

          const SizedBox(height: 32),

          // Email + contact
          if (isMobile) ...[
            _FormFieldBlock(
              label: 'Email Address',
              child: _buildTextField(
                controller: delegate.emailController,
                hint: 'example@email.com',
                keyboardType: TextInputType.emailAddress,
                validator: _emailValidator,
              ),
            ),

            const SizedBox(height: 32),

            _FormFieldBlock(
              label: 'Contact Number',
              child: _buildTextField(
                controller: delegate.contactController,
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
                      controller: delegate.emailController,
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
                      controller: delegate.contactController,
                      hint: '+91 XXXXX XXXXX',
                      keyboardType: TextInputType.phone,
                      validator: _phoneValidator,
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 32),

          if (isMobile) ...[
            _FormFieldBlock(
              label: 'Class',
              child: _buildClassDropdown(delegate),
            ),

            const SizedBox(height: 32),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _FormFieldBlock(
                    label: 'Class',
                    child: _buildClassDropdown(delegate),
                  ),
                ),
                const Expanded(child: SizedBox()),
              ],
            ),

          if (!isMobile) const SizedBox(height: 32),

          // MUN Experience
          _FormFieldBlock(
            label: 'MUN Experience (if any)',
            child: _buildTextField(
              controller: delegate.munExperienceController,
              hint: 'Tell us about previous MUN experience',
              maxLines: 4,
            ),
          ),

          const SizedBox(height: 42),

          // Committee Preference 1
          _buildCommitteeSection(
            title: 'Committee Preference 01',
            value: delegate.committeePreference1,
            onChanged: (value) {
              setState(() {
                delegate.committeePreference1 = value;
              });
            },
            isMobile: isMobile,
          ),

          const SizedBox(height: 42),

          // Committee Preference 2
          _buildCommitteeSection(
            title: 'Committee Preference 02',
            value: delegate.committeePreference2,
            onChanged: (value) {
              setState(() {
                delegate.committeePreference2 = value;
              });
            },
            isMobile: isMobile,
          ),

          const SizedBox(height: 38),

          _FormFieldBlock(
            label: 'Portfolio Preference 01',
            child: _buildTextField(
              controller: delegate.portfolioPreference1Controller,
              hint: 'Enter portfolio preference for committee 1',
              validator: _required,
            ),
          ),

          const SizedBox(height: 32),

          _FormFieldBlock(
            label: 'Portfolio Preference 02',
            child: _buildTextField(
              controller: delegate.portfolioPreference2Controller,
              hint: 'Enter portfolio preference for committee 2',
              validator: _required,
            ),
          ),
        ],
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
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
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

  Widget _buildClassDropdown(_DelegateFormData delegate) {
    return DropdownButtonFormField<String>(
      initialValue: delegate.selectedClass,
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
          .map(
            (value) =>
                DropdownMenuItem<String>(value: value, child: Text(value)),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          delegate.selectedClass = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a class';
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
                  color: selected ? background : Colors.transparent,
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

        _DeclarationItem(
          value: _declaration1,
          text:
              'I confirm that all institutional and delegate information provided is accurate',
          isMobile: isMobile,
          onChanged: (value) {
            setState(() {
              _declaration1 = value;
              _updateDeclarationError();
            });
          },
        ),

        const SizedBox(height: 18),

        _DeclarationItem(
          value: _declaration2,
          text:
              'I confirm that I am the Head Delegate and am authorised to submit this registration on behalf of the institution and its delegation.',
          isMobile: isMobile,
          onChanged: (value) {
            setState(() {
              _declaration2 = value;
              _updateDeclarationError();
            });
          },
        ),

        const SizedBox(height: 18),

        _DeclarationItem(
          value: _declaration3,
          text:
              'I understand that committee and portfolio allocations are subject to availability and the discretion of the Secretariat.',
          isMobile: isMobile,
          onChanged: (value) {
            setState(() {
              _declaration3 = value;
              _updateDeclarationError();
            });
          },
        ),

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
// DELEGATE DATA
// ================================================================

class _DelegateFormData {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final contactController = TextEditingController();
  final munExperienceController = TextEditingController();
  final portfolioPreference1Controller = TextEditingController();
  final portfolioPreference2Controller = TextEditingController();

  String? selectedClass;
  String? committeePreference1;
  String? committeePreference2;

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    contactController.dispose();
    munExperienceController.dispose();
    portfolioPreference1Controller.dispose();
    portfolioPreference2Controller.dispose();
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
// ADD DELEGATE BUTTON
// ================================================================

class _AddDelegateButton extends StatefulWidget {
  const _AddDelegateButton({
    required this.onTap,
    required this.isMobile,
    required this.isLoading,
  });

  final VoidCallback? onTap;
  final bool isMobile;
  final bool isLoading;

  @override
  State<_AddDelegateButton> createState() => _AddDelegateButtonState();
}

class _AddDelegateButtonState extends State<_AddDelegateButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFC9A86A);

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
        onTap: widget.isLoading ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: widget.isMobile ? double.infinity : 260,
          height: 58,
          decoration: BoxDecoration(
            color: _hovering
                ? gold.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: gold, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, color: gold, size: 24),

              const SizedBox(width: 9),

              Text(
                'ADD DELEGATE',
                style: GoogleFonts.ibmPlexSans(
                  color: gold,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
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

class _ProceedButtonState extends State<_ProceedButton> {
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
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF111A33),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
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

// ================================================================
// COMMITTEE DATA
// ================================================================

class _Committee {
  const _Committee({required this.value, required this.label});

  final String value;
  final String label;
}
