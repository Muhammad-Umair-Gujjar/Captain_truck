import 'package:flutter/material.dart';
import '../../widgets/custom_text_field.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../widgets/custom_button.dart';
import '../../constants/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/custom_animation.dart';
import '../../widgets/custom_popup.dart';
import '../../widgets/email_verification_popup.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  int step = 0;
  bool _isLoading = false;
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final cnicController = TextEditingController();
  final addressController = TextEditingController();

  // FocusNodes for each field
  final nameFocus = FocusNode();
  final mobileFocus = FocusNode();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();
  final cnicFocus = FocusNode();
  final addressFocus = FocusNode();

  bool passwordObscure = true;
  bool confirmPasswordObscure = true;

  Future<void> _handleSignup() async {
    if (!_validateAllFields()) return;

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.signup(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        phone: mobileController.text.trim(),
        address: addressController.text.trim(),
        cnic: cnicController.text.trim(),
      );

      if (!mounted) return;

      if (result['success'] == true) {
        _showEmailVerificationDialog(
          result['message'] ?? 'Please verify your email',
          'Account created successfully!',
        );
      } else {
        final errorCode = result['error'];
        final message =
            result['message'] ?? 'Failed to create account. Please try again.';
        result['message'] ?? 'Failed to create account. Please try again.';

        if (errorCode == 'email-already-in-use') {
          _showEmailExistsDialog(message);
        } else {
          CustomPopup.showError(context, 'Signup Failed', message);
        }
      }
    } catch (e) {
      if (mounted) {
        CustomPopup.showError(
          context,
          'Error',
          'An unexpected error occurred. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _validateAllFields() {
    // Name validation - only letters and spaces, no numbers
    if (nameController.text.trim().isEmpty) {
      CustomPopup.showError(context, 'Validation Error', 'Name is required');
      return false;
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(nameController.text.trim())) {
      CustomPopup.showError(
        context,
        'Validation Error',
        'Name should only contain letters and spaces',
      );
      return false;
    }

    if (nameController.text.trim().length < 2) {
      CustomPopup.showError(
        context,
        'Validation Error',
        'Name must be at least 2 characters long',
      );
      return false;
    }

    // Phone validation - Pakistani format
    if (mobileController.text.trim().isEmpty) {
      CustomPopup.showError(
        context,
        'Validation Error',
        'Phone number is required',
      );
      return false;
    }

    String phone = mobileController.text
        .trim()
        .replaceAll(' ', '')
        .replaceAll('-', '');
    if (!RegExp(r'^(\+92|92|0)?3[0-9]{9}$').hasMatch(phone)) {
      CustomPopup.showError(
        context,
        'Validation Error',
        'Please enter a valid Pakistani mobile number (e.g., 03001234567)',
      );
      return false;
    }

    // Email validation
    if (emailController.text.trim().isEmpty) {
      CustomPopup.showError(context, 'Validation Error', 'Email is required');
      return false;
    }

    if (!RegExp(
      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    ).hasMatch(emailController.text.trim())) {
      CustomPopup.showError(
        context,
        'Validation Error',
        'Please enter a valid email address',
      );
      return false;
    }

    // Password validation - strong password requirements
    if (passwordController.text.isEmpty) {
      CustomPopup.showError(
        context,
        'Validation Error',
        'Password is required',
      );
      return false;
    }

    if (passwordController.text.length < 8) {
      CustomPopup.showError(
        context,
        'Validation Error',
        'Password must be at least 8 characters long',
      );
      return false;
    }

    if (!RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]',
    ).hasMatch(passwordController.text)) {
      CustomPopup.showError(
        context,
        'Validation Error',
        'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character',
      );
      return false;
    }

    // Confirm password validation
    if (confirmPasswordController.text.isEmpty) {
      CustomPopup.showError(
        context,
        'Validation Error',
        'Please confirm your password',
      );
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      CustomPopup.showError(
        context,
        'Validation Error',
        'Passwords do not match',
      );
      return false;
    }

    // CNIC validation - Pakistani format
    if (cnicController.text.trim().isEmpty) {
      CustomPopup.showError(context, 'Validation Error', 'CNIC is required');
      return false;
    }

    String cnic = cnicController.text.trim().replaceAll('-', '');
    if (!RegExp(r'^\d{13}$').hasMatch(cnic)) {
      CustomPopup.showError(
        context,
        'Validation Error',
        'Please enter a valid 13-digit CNIC number (e.g., 12345-6789012-3)',
      );
      return false;
    }

    // Address validation
    if (addressController.text.trim().isEmpty) {
      CustomPopup.showError(context, 'Validation Error', 'Address is required');
      return false;
    }

    if (addressController.text.trim().length < 10) {
      CustomPopup.showError(
        context,
        'Validation Error',
        'Please enter a complete address (at least 10 characters)',
      );
      return false;
    }

    return true;
  }

  void _showEmailVerificationDialog(String message, String title) {
    EmailVerificationPopup.show(context);
  }

  void _showEmailExistsDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.person_outline, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Account Already Exists'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            SizedBox(height: 16),
            Text(
              'This email is already registered. Would you like to login instead?',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Login'),
          ),
        ],
      ),
    );
  }

  List<Widget> getFields() {
    return [
      CustomTextField(
        label: 'Name',
        hint: 'Enter Name',
        controller: nameController,
        keyboardType: TextInputType.name,
        prefixIcon: FaIcon(FontAwesomeIcons.user,
          color: AppColors.textTertiary,
          size: 20,
        ),
        helpText: 'Only letters and spaces allowed (minimum 2 characters)',
        key: const ValueKey('nameField'),
      ),
      CustomTextField(
        label: 'Mobile Number',
        hint: 'Enter Mobile Number',
        controller: mobileController,
        keyboardType: TextInputType.phone,
        prefixIcon: FaIcon(FontAwesomeIcons.phone,
          color: AppColors.textTertiary,
          size: 20,
        ),
        helpText: 'Pakistani format: 03xxxxxxxxx (e.g., 03001234567)',
        key: const ValueKey('mobileField'),
      ),
      CustomTextField(
        label: 'Email',
        hint: 'thisand@that.com',
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        prefixIcon: FaIcon(FontAwesomeIcons.envelope,
          color: AppColors.textTertiary,
          size: 20,
        ),
        helpText: 'Valid email address required for verification',
        key: const ValueKey('emailField'),
      ),
      CustomTextField(
        label: 'Password',
        hint: 'Enter Password',
        controller: passwordController,
        obscureText: passwordObscure,
        keyboardType: TextInputType.visiblePassword,
        prefixIcon: FaIcon(FontAwesomeIcons.lock,
          color: AppColors.textTertiary,
          size: 20,
        ),
        suffixIcon: IconButton(
          icon: FaIcon(
            passwordObscure ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
            color: AppColors.textTertiary,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              passwordObscure = !passwordObscure;
            });
          },
        ),
        helpText:
            'At least 8 characters with uppercase, lowercase, number, and special character',
        key: const ValueKey('passwordField'),
      ),
      CustomTextField(
        label: 'Confirm Password',
        hint: 'Re-enter Password',
        controller: confirmPasswordController,
        obscureText: confirmPasswordObscure,
        keyboardType: TextInputType.visiblePassword,
        prefixIcon: FaIcon(FontAwesomeIcons.lock,
          color: AppColors.textTertiary,
          size: 20,
        ),
        suffixIcon: IconButton(
          icon: FaIcon(
            confirmPasswordObscure
                ? FontAwesomeIcons.eyeSlash
                : FontAwesomeIcons.eye,
            color: AppColors.textTertiary,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              confirmPasswordObscure = !confirmPasswordObscure;
            });
          },
        ),
        helpText: 'Must match the password entered above',
        key: const ValueKey('confirmPasswordField'),
      ),
      CustomTextField(
        label: 'CNIC',
        hint: '12345-6789XXX-0',
        controller: cnicController,
        keyboardType: TextInputType.number,
        prefixIcon: FaIcon(FontAwesomeIcons.idCard,
          color: AppColors.textTertiary,
          size: 20,
        ),
        helpText: '13-digit Pakistani CNIC (e.g., 12345-6789012-3)',
        key: const ValueKey('cnicField'),
      ),
      CustomTextField(
        label: 'Address',
        hint: 'Enter Address',
        controller: addressController,
        keyboardType: TextInputType.streetAddress,
        prefixIcon: FaIcon(FontAwesomeIcons.locationDot,
          color: AppColors.textTertiary,
          size: 20,
        ),
        helpText: 'Complete address with at least 10 characters',
        key: const ValueKey('addressField'),
      ),
    ];
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    cnicController.dispose();
    addressController.dispose();
    nameFocus.dispose();
    mobileFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    cnicFocus.dispose();
    addressFocus.dispose();
    super.dispose();
  }

  List<String> getFieldLabels() {
    return [
      'Name',
      'Mobile Number',
      'Email',
      'Password',
      'Confirm Password',
      'CNIC',
      'Address',
    ];
  }

  List<String> getFieldValues() {
    return [
      nameController.text,
      mobileController.text,
      emailController.text,
      passwordController.text,
      confirmPasswordController.text,
      cnicController.text,
      addressController.text,
    ];
  }

  bool validateCurrentField() {
    switch (step) {
      case 1:
        // Name validation
        if (nameController.text.trim().isEmpty) return false;
        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(nameController.text.trim())) {
          return false;
        }
        if (nameController.text.trim().length < 2) return false;
        return true;
      case 2:
        // Phone validation
        if (mobileController.text.trim().isEmpty) return false;
        String phone = mobileController.text
            .trim()
            .replaceAll(' ', '')
            .replaceAll('-', '');
        return RegExp(r'^(\+92|92|0)?3[0-9]{9}$').hasMatch(phone);
      case 3:
        // Email validation
        if (emailController.text.trim().isEmpty) return false;
        return RegExp(
          r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
        ).hasMatch(emailController.text.trim());
      case 4:
        // Password validation
        if (passwordController.text.length < 8) return false;
        return RegExp(
          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]',
        ).hasMatch(passwordController.text);
      case 5:
        // Confirm password validation
        return confirmPasswordController.text == passwordController.text &&
            confirmPasswordController.text.isNotEmpty;
      case 6:
        // CNIC validation
        if (cnicController.text.trim().isEmpty) return false;
        String cnic = cnicController.text.trim().replaceAll('-', '');
        return RegExp(r'^\d{13}$').hasMatch(cnic);
      case 7:
        // Address validation
        return addressController.text.trim().length >= 10;
      default:
        return true;
    }
  }

  void nextStep() {
    if (validateCurrentField()) {
      setState(() {
        if (step < getFields().length) {
          step++;
          _requestFocusForStep(step);
        }
      });
    }
  }

  void _requestFocusForStep(int step) {
    FocusScope.of(context).unfocus();
    switch (step) {
      case 1:
        FocusScope.of(context).requestFocus(nameFocus);
        break;
      case 2:
        FocusScope.of(context).requestFocus(mobileFocus);
        break;
      case 3:
        FocusScope.of(context).requestFocus(emailFocus);
        break;
      case 4:
        FocusScope.of(context).requestFocus(passwordFocus);
        break;
      case 5:
        FocusScope.of(context).requestFocus(confirmPasswordFocus);
        break;
      case 6:
        FocusScope.of(context).requestFocus(cnicFocus);
        break;
      case 7:
        FocusScope.of(context).requestFocus(addressFocus);
        break;
      default:
        break;
    }
  }

  void resetForm() {
    setState(() {
      step = 0;
      nameController.clear();
      mobileController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      cnicController.clear();
      addressController.clear();
      passwordObscure = true;
      confirmPasswordObscure = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/login');
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth > 500
                          ? constraints.maxWidth * 0.2
                          : 24.0,
                      vertical: 20,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/images/logo.svg',
                          width: size.width * 0.60,
                          height: size.width * 0.60,
                        ),
                        Transform(
                          transform: Matrix4.translationValues(0, -50, 0),
                          child: Text(
                            'Book & Relax',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (step == 0) ...[
                          FadeSlideAnimation(
                            beginOffset: const Offset(0, 0.2),
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: FaIcon(FontAwesomeIcons.userLarge,
                                      size: 40,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                CustomButton(
                                  text: 'Sign Up',
                                  onPressed: () {
                                    nextStep();
                                    _requestFocusForStep(1);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ] else if (step > 0 && step <= getFields().length) ...[
                          FadeSlideAnimation(
                            beginOffset: const Offset(0, 0.2),
                            child: Focus(
                              focusNode: [
                                nameFocus,
                                mobileFocus,
                                emailFocus,
                                passwordFocus,
                                confirmPasswordFocus,
                                cnicFocus,
                                addressFocus,
                              ][step - 1],
                              child: getFields()[step - 1],
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                            text: step == getFields().length
                                ? 'Review'
                                : 'Next',
                            onPressed: () {
                              if (step < getFields().length) {
                                nextStep();
                              } else {
                                setState(() {
                                  step++;
                                });
                              }
                            },
                            enabled: validateCurrentField(),
                          ),
                        ] else if (step > getFields().length) ...[
                          FadeSlideAnimation(
                            beginOffset: const Offset(0, 0.2),
                            child: Center(
                              child: Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          FaIcon(FontAwesomeIcons.clipboardList,
                                            color: AppColors.primary,
                                            size: 22,
                                          ),
                                          const SizedBox(width: 10),
                                          const Text(
                                            'Review your details:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      ...List.generate(getFields().length, (i) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 10,
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                '${getFieldLabels()[i]}: ',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textTertiary,
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  getFieldLabels()[i] ==
                                                              'Password' ||
                                                          getFieldLabels()[i] ==
                                                              'Confirm Password'
                                                      ? '*' *
                                                            getFieldValues()[i]
                                                                .length
                                                      : getFieldValues()[i],
                                                  style: const TextStyle(
                                                    color:
                                                        AppColors.textPrimary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                      const SizedBox(height: 24),
                                      CustomButton(
                                        text: _isLoading
                                            ? 'Creating Account...'
                                            : 'Create Account',
                                        onPressed: _isLoading
                                            ? () {}
                                            : () => _handleSignup(),
                                      ),
                                      const SizedBox(height: 12),
                                      Center(
                                        child: ElevatedButton.icon(
                                          onPressed: resetForm,
                                          icon: FaIcon(FontAwesomeIcons.penToSquare,
                                            color: AppColors.primary,
                                            size: 18,
                                          ),
                                          label: const Text(
                                            'Edit',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.background,
                                            foregroundColor: AppColors.primary,
                                            elevation: 0,
                                            side: const BorderSide(
                                              color: AppColors.primary,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 10,
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
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
