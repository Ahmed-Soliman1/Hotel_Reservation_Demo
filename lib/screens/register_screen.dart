import 'package:flutter/material.dart';
import '../models/database_service.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/custom_components.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final db = DatabaseService();
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  bool _isLoading = false;
  String _error = '';
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() => _error = '');

    // Validation
    if (firstNameCtrl.text.isEmpty ||
        lastNameCtrl.text.isEmpty ||
        emailCtrl.text.isEmpty ||
        passwordCtrl.text.isEmpty) {
      setState(() => _error = 'All fields are required');
      return;
    }

    if (passwordCtrl.text != confirmPasswordCtrl.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    if (passwordCtrl.text.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters');
      return;
    }

    // Check if email already exists
    final allUsers = await db.getAllUsers();
    if (allUsers.any((u) => u.email == emailCtrl.text.trim())) {
      setState(() => _error = 'Email already registered');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        firstName: firstNameCtrl.text.trim(),
        lastName: lastNameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text,
        role: UserRole.guest,
      );

      await db.createUser(newUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Please login.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    } catch (e) {
      setState(() => _error = 'Registration failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.luxuryGradient,
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeController,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400, minWidth: 280),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Column(
                      children: [
                        // Logo
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.accentCyan.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.person_add_outlined,
                            size: 48,
                            color: AppTheme.accentCyan,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Title
                        Text(
                          'Create Account',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w900,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Subtitle
                        Text(
                          'Join Sphinx Hotel and discover luxury',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        // First Name
                        GlowTextField(
                          label: 'First Name',
                          controller: firstNameCtrl,
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Last Name
                        GlowTextField(
                          label: 'Last Name',
                          controller: lastNameCtrl,
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Email
                        GlowTextField(
                          label: 'Email Address',
                          hint: 'your@email.com',
                          controller: emailCtrl,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Password
                        GlowTextField(
                          label: 'Password',
                          hint: 'Min 8 characters',
                          controller: passwordCtrl,
                          prefixIcon: Icons.lock_outlined,
                          suffixIcon: Icons.visibility_off_outlined,
                          obscureText: true,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Confirm Password
                        GlowTextField(
                          label: 'Confirm Password',
                          controller: confirmPasswordCtrl,
                          prefixIcon: Icons.lock_outlined,
                          suffixIcon: Icons.visibility_off_outlined,
                          obscureText: true,
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Error Message
                        if (_error.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppTheme.errorRed.withOpacity(0.15),
                              border: Border.all(
                                color: AppTheme.errorRed.withOpacity(0.5),
                                width: 1.5,
                              ),
                              borderRadius: AppRadius.lgRadius,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: AppTheme.errorRed,
                                  size: 18,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    _error,
                                    style: TextStyle(
                                      color: AppTheme.errorRed,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: AppSpacing.xl),

                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          child: GlowButton(
                            label: 'Create Account',
                            icon: Icons.check_circle_outline,
                            isLoading: _isLoading,
                            onPressed: _register,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Sign In',
                                style: const TextStyle(
                                  color: AppTheme.accentCyan,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
