import 'package:flutter/material.dart';

import '../models/database_service.dart';

import '../models/models.dart';

import '../theme/app_theme.dart';

import '../theme/custom_components.dart';

import 'register_screen.dart';

import 'guest_home.dart';

import 'staff_home.dart';

import 'manager_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State createState() => _LoginScreenState();
}

class _LoginScreenState extends State with TickerProviderStateMixin {
  final db = DatabaseService();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
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
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future _login() async {
    setState(() => _error = '');
    if (emailCtrl.text.isEmpty || passwordCtrl.text.isEmpty) {
      setState(() => _error = 'Email and password are required');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Get all users from database
      final allUsers = await db.getAllUsers();

      // Find user with matching email and password
      final user = allUsers.firstWhere(
        (u) => u.email == emailCtrl.text.trim() && u.password == passwordCtrl.text,
        orElse: () => throw Exception('Invalid email or password'),
      );

      if (mounted) {
        // Navigate based on user role
        Widget nextScreen;
        switch (user.role) {
          case UserRole.guest:
            nextScreen = GuestHome(currentUser: user);
            break;
          case UserRole.staff:
            nextScreen = StaffHome(currentUser: user);
            break;
          case UserRole.manager:
            nextScreen = ManagerHome();
            break;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => nextScreen),
        );
      }
    } catch (e) {
      setState(() => _error = 'Invalid email or password');
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
              position: Tween(
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
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            Icons.lock_outline,
                            size: 48,
                            color: AppTheme.accentCyan,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Title
                        Text(
                          'Sphinx Hotel',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w900,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Subtitle
                        Text(
                          'Luxury Hotel Booking',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        // Email Field
                        GlowTextField(
                          label: 'Email Address',
                          hint: 'your@email.com',
                          controller: emailCtrl,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Password Field
                        GlowTextField(
                          label: 'Password',
                          controller: passwordCtrl,
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

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          child: GlowButton(
                            label: 'Sign In',
                            icon: Icons.login_outlined,
                            isLoading: _isLoading,
                            onPressed: _login,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Demo Credentials
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppTheme.accentCyan.withOpacity(0.1),
                            borderRadius: AppRadius.lgRadius,
                            border: Border.all(
                              color: AppTheme.accentCyan.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Demo Credentials',
                                style: TextStyle(
                                  color: AppTheme.accentCyan,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              
                              // Guest Demo
                              _DemoCredential(
                                label: 'Guest',
                                email: 'guest@example.com',
                                password: 'password123',
                                onTap: () {
                                  emailCtrl.text = 'guest@example.com';
                                  passwordCtrl.text = 'password123';
                                },
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              
                              // Staff Demo (NEW)
                              _DemoCredential(
                                label: 'Staff',
                                email: 'staff@sphinxhotel.com',
                                password: 'password123',
                                onTap: () {
                                  emailCtrl.text = 'staff@sphinxhotel.com';
                                  passwordCtrl.text = 'password123';
                                },
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              
                              // Manager Demo
                              _DemoCredential(
                                label: 'Manager',
                                email: 'manager@sphinxhotel.com',
                                password: 'password123',
                                onTap: () {
                                  emailCtrl.text = 'manager@sphinxhotel.com';
                                  passwordCtrl.text = 'password123';
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Don\'t have an account? ',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => RegisterScreen()),
                              ),
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
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

class _DemoCredential extends StatelessWidget {
  final String label;
  final String email;
  final String password;
  final VoidCallback onTap;

  const _DemoCredential({
    required this.label,
    required this.email,
    required this.password,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard.withOpacity(0.3),
          borderRadius: AppRadius.mdRadius,
          border: Border.all(
            color: AppTheme.accentCyan.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_outlined,
              color: AppTheme.accentCyan,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
