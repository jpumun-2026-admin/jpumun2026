import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jpumun_website/services/razorpay_api.dart';
import 'package:jpumun_website/services/razorpay_checkout.dart';
import 'package:jpumun_website/services/razorpay_checkout_types.dart';
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

              const SizedBox(height: 34),

              const _RazorpayPaymentPanel(
                titleSize: 28,
                bodySize: 17,
                buttonHeight: 70,
                buttonTextSize: 22,
                padding: 28,
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

          const SizedBox(height: 28),

          const _RazorpayPaymentPanel(
            titleSize: 24,
            bodySize: 16,
            buttonHeight: 64,
            buttonTextSize: 19,
            padding: 24,
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

          const SizedBox(height: 22),

          const _RazorpayPaymentPanel(
            titleSize: 22,
            bodySize: 15,
            buttonHeight: 58,
            buttonTextSize: 17,
            padding: 22,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  Future<void> _openRegistration(String type) async {
    final String route = type == 'institutional'
        ? '/register-institute'
        : '/register';

    final Uri uri = Uri.base.resolve(route);

    await launchUrl(uri, webOnlyWindowName: '_blank');
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

class _RazorpayPaymentPanel extends StatefulWidget {
  const _RazorpayPaymentPanel({
    required this.titleSize,
    required this.bodySize,
    required this.buttonHeight,
    required this.buttonTextSize,
    required this.padding,
  });

  final double titleSize;
  final double bodySize;
  final double buttonHeight;
  final double buttonTextSize;
  final double padding;

  @override
  State<_RazorpayPaymentPanel> createState() => _RazorpayPaymentPanelState();
}

class _RazorpayPaymentPanelState extends State<_RazorpayPaymentPanel> {
  static const int _checkoutAmountPaise = 100;
  static const String _currency = 'INR';
  static const String _merchantName = 'JPUMUN 2026';
  static const String _description = 'JPUMUN 2026 test registration payment';

  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(widget.padding),
      decoration: BoxDecoration(
        color: RegistrationSection._cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RegistrationSection._red, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Razorpay Standard Checkout',
            style: GoogleFonts.prata(
              color: RegistrationSection._gold,
              fontSize: widget.titleSize,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Run a test payment using Razorpay Standard Checkout. '
            'The amount is currently set to INR $_displayAmount so you can '
            'verify the web flow end-to-end before switching to your live fee.',
            style: GoogleFonts.ibmPlexSans(
              color: RegistrationSection._white,
              fontSize: widget.bodySize,
              fontWeight: FontWeight.w400,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 24),
          _PaymentActionButton(
            height: widget.buttonHeight,
            textSize: widget.buttonTextSize,
            busy: _processing,
            label: _processing ? 'PROCESSING...' : 'PAY INR $_displayAmount',
            onTap: _processing ? null : _startCheckout,
          ),
        ],
      ),
    );
  }

  Future<void> _startCheckout() async {
    if (!isRazorpayCheckoutSupported) {
      _showMessage(
        'Razorpay checkout is only available on the Flutter web build.',
        isError: true,
      );
      return;
    }

    final checkoutReady = await waitForRazorpayCheckout();
    if (!checkoutReady) {
      _showMessage(
        'Razorpay checkout could not be loaded. Please refresh the page and try again.',
        isError: true,
      );
      return;
    }

    setState(() {
      _processing = true;
    });

    try {
      final order = await RazorpayApi.createOrder(
        amount: _checkoutAmountPaise,
        currency: _currency,
        receipt: 'jpumun_${DateTime.now().millisecondsSinceEpoch}',
      );

      final checkoutResult = await openRazorpayCheckout(
        RazorpayCheckoutOptions(
          keyId: order.keyId,
          amount: order.amount,
          currency: order.currency,
          name: _merchantName,
          description: _description,
          orderId: order.orderId,
        ),
      );

      if (!mounted) return;

      switch (checkoutResult.status) {
        case RazorpayCheckoutStatus.success:
          await RazorpayApi.verifyPayment(
            orderId: order.orderId,
            paymentId: checkoutResult.paymentId!,
            signature: checkoutResult.signature!,
          );

          if (!mounted) return;
          _showMessage('Payment verified successfully.');
          break;
        case RazorpayCheckoutStatus.failed:
          _showMessage(
            checkoutResult.errorMessage ?? 'Payment failed.',
            isError: true,
          );
          break;
        case RazorpayCheckoutStatus.dismissed:
          _showMessage('Payment cancelled.');
          break;
      }
    } on RazorpayApiException catch (error) {
      _showMessage(error.message, isError: true);
    } catch (_) {
      _showMessage(
        'Something went wrong while processing the payment.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _processing = false;
        });
      }
    }
  }

  String get _displayAmount {
    return (_checkoutAmountPaise / 100).toStringAsFixed(2);
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.ibmPlexSans(color: Colors.white),
          ),
          backgroundColor: isError
              ? const Color(0xFF8B2E2E)
              : RegistrationSection._cardBackground,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

// ============================================================
// REGISTRATION CARD
// ============================================================

class _PaymentActionButton extends StatelessWidget {
  const _PaymentActionButton({
    required this.height,
    required this.textSize,
    required this.label,
    required this.onTap,
    this.busy = false,
  });

  final double height;
  final double textSize;
  final String label;
  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: onTap == null ? 0.72 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              color: RegistrationSection._gold,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: busy
                  ? SizedBox(
                      width: textSize,
                      height: textSize,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation(Color(0xFF0B132B)),
                      ),
                    )
                  : Text(
                      label,
                      style: GoogleFonts.prata(
                        color: const Color(0xFF0B132B),
                        fontSize: textSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

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
