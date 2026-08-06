import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterIndividualForm extends StatefulWidget {
  const RegisterIndividualForm({super.key});

  @override
  State<RegisterIndividualForm> createState() => _RegisterIndividualFormState();
}

class _RegisterIndividualFormState extends State<RegisterIndividualForm> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _munExperienceController = TextEditingController();
  final _committeePref1Controller = TextEditingController();
  final _committeePref2Controller = TextEditingController();
  final _portfolioPref1Controller = TextEditingController();
  final _portfolioPref2Controller = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _munExperienceController.dispose();
    _committeePref1Controller.dispose();
    _committeePref2Controller.dispose();
    _portfolioPref1Controller.dispose();
    _portfolioPref2Controller.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.ibmPlexSans(
        color: const Color(0xFFB7B7B7),
        fontSize: 14,
      ),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF5C1A1B), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF5C1A1B), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFC9A86A), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  Widget _buildSectionTitle(String text, {double size = 20}) {
    return Text(
      text,
      style: GoogleFonts.ibmPlexSerif(
        color: const Color(0xFFC9A86A),
        fontSize: size,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.ibmPlexSans(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.ibmPlexSans(
            color: Colors.white,
            fontSize: 15,
          ),
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // Hook up backend / form submit here
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        return Container(
          width: double.infinity,
          color: const Color(0xFF0B132B),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 48,
            vertical: isMobile ? 24 : 40,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF5C1A1B),
                    width: 2,
                  ),
                ),
                padding: EdgeInsets.all(isMobile ? 20 : 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Individual Registration',
                        style: GoogleFonts.ibmPlexSerif(
                          color: const Color(0xFFC9A86A),
                          fontSize: isMobile ? 26 : 36,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fill in your details to register as an individual delegate.',
                        style: GoogleFonts.ibmPlexSans(
                          color: Colors.white,
                          fontSize: isMobile ? 14 : 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (isMobile) ...[
                        _buildField(
                          label: 'Delegate Full Name',
                          controller: _fullNameController,
                          hint: 'Enter your full name',
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Email Address',
                          controller: _emailController,
                          hint: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Contact Number',
                          controller: _contactController,
                          hint: 'Enter your phone number',
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'MUN Experience (if any)',
                          controller: _munExperienceController,
                          hint: 'Tell us about your MUN experience',
                          maxLines: 4,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Committee Preference (1)',
                          controller: _committeePref1Controller,
                          hint: 'CCC / DISEC / AIPPM',
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Committee Preference (2)',
                          controller: _committeePref2Controller,
                          hint: 'CCC / DISEC / AIPPM',
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Portfolio/Country Preference (1)',
                          controller: _portfolioPref1Controller,
                          hint: 'Fill in the blanks',
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Portfolio/Country Preference (2)',
                          controller: _portfolioPref2Controller,
                          hint: 'Fill in the blanks',
                        ),
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  _buildField(
                                    label: 'Delegate Full Name',
                                    controller: _fullNameController,
                                    hint: 'Enter your full name',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildField(
                                    label: 'Email Address',
                                    controller: _emailController,
                                    hint: 'Enter your email',
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildField(
                                    label: 'Contact Number',
                                    controller: _contactController,
                                    hint: 'Enter your phone number',
                                    keyboardType: TextInputType.phone,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildField(
                                    label: 'MUN Experience (if any)',
                                    controller: _munExperienceController,
                                    hint: 'Tell us about your MUN experience',
                                    maxLines: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                children: [
                                  _buildField(
                                    label: 'Committee Preference (1)',
                                    controller: _committeePref1Controller,
                                    hint: 'CCC / DISEC / AIPPM',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildField(
                                    label: 'Committee Preference (2)',
                                    controller: _committeePref2Controller,
                                    hint: 'CCC / DISEC / AIPPM',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildField(
                                    label: 'Portfolio/Country Preference (1)',
                                    controller: _portfolioPref1Controller,
                                    hint: 'Fill in the blanks',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildField(
                                    label: 'Portfolio/Country Preference (2)',
                                    controller: _portfolioPref2Controller,
                                    hint: 'Fill in the blanks',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC9A86A),
                            foregroundColor: const Color(0xFF0B132B),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'SUBMIT REGISTRATION',
                            style: GoogleFonts.ibmPlexSerif(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
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
      },
    );
  }
}