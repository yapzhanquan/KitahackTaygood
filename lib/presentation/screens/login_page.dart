import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/constants/app_strings.dart';

/// Login / Registration Page
/// Premium Airbnb-inspired auth screen with:
/// - Tab switching between Login & Register
/// - Email + Password fields with validation
/// - Animated transitions
/// - Consistent design system usage
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // Login fields
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Register fields
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmController = TextEditingController();

  bool _loginObscure = true;
  bool _registerObscure = true;
  bool _confirmObscure = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // Simulate login delay
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Welcome back! (Auth backend not connected yet)',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textInverse),
          ),
          backgroundColor: AppColors.slate800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          margin: const EdgeInsets.all(AppSpacing.md),
        ),
      );
      Navigator.pop(context);
    });
  }

  void _handleRegister() {
    if (!_registerFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Account created! (Auth backend not connected yet)',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textInverse),
          ),
          backgroundColor: AppColors.green700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          margin: const EdgeInsets.all(AppSpacing.md),
        ),
      );
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabSelector(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLoginForm(),
                  _buildRegisterForm(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Spacer(),
          Text(
            AppStrings.appName,
            style: AppTypography.titleLarge,
          ),
          const Spacer(),
          const SizedBox(width: 36), // Balance the close button
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.md,
      ),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(color: AppColors.border),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: AppColors.slate900,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: AppColors.textInverse,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTypography.labelLarge,
          unselectedLabelStyle: AppTypography.labelMedium,
          tabs: const [
            Tab(text: 'Log In'),
            Tab(text: 'Register'),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.md,
      ),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),

            // Welcome text
            Text(
              'Welcome back',
              style: AppTypography.displaySmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Log in to track projects and contribute check-ins',
              style: AppTypography.bodySmall,
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Email field
            _buildTextField(
              controller: _loginEmailController,
              label: 'Email',
              hint: 'you@example.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),

            const SizedBox(height: AppSpacing.md),

            // Password field
            _buildTextField(
              controller: _loginPasswordController,
              label: 'Password',
              hint: 'Enter your password',
              icon: Icons.lock_outline_rounded,
              obscure: _loginObscure,
              onToggleObscure: () => setState(() => _loginObscure = !_loginObscure),
              validator: _validatePassword,
            ),

            const SizedBox(height: AppSpacing.xs),

            // Forgot password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.slate600,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 36),
                ),
                child: Text(
                  'Forgot password?',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.slate600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Login button
            _buildPrimaryButton(
              label: 'Log In',
              onTap: _handleLogin,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Divider
            _buildDivider(),

            const SizedBox(height: AppSpacing.xl),

            // Social buttons
            _buildSocialButton(
              icon: Icons.g_mobiledata_rounded,
              label: 'Continue with Google',
              onTap: _launchGoogleSignIn,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.md,
      ),
      child: Form(
        key: _registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),

            // Welcome text
            Text(
              'Join the community',
              style: AppTypography.displaySmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Create an account to start tracking and reporting',
              style: AppTypography.bodySmall,
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Name field
            _buildTextField(
              controller: _registerNameController,
              label: 'Full Name',
              hint: 'Your name',
              icon: Icons.person_outline_rounded,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),

            const SizedBox(height: AppSpacing.md),

            // Email field
            _buildTextField(
              controller: _registerEmailController,
              label: 'Email',
              hint: 'you@example.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),

            const SizedBox(height: AppSpacing.md),

            // Password field
            _buildTextField(
              controller: _registerPasswordController,
              label: 'Password',
              hint: 'At least 6 characters',
              icon: Icons.lock_outline_rounded,
              obscure: _registerObscure,
              onToggleObscure: () => setState(() => _registerObscure = !_registerObscure),
              validator: _validatePassword,
            ),

            const SizedBox(height: AppSpacing.md),

            // Confirm password field
            _buildTextField(
              controller: _registerConfirmController,
              label: 'Confirm Password',
              hint: 'Re-enter your password',
              icon: Icons.lock_outline_rounded,
              obscure: _confirmObscure,
              onToggleObscure: () => setState(() => _confirmObscure = !_confirmObscure),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please confirm your password';
                if (v != _registerPasswordController.text) return 'Passwords do not match';
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // Register button
            _buildPrimaryButton(
              label: 'Create Account',
              onTap: _handleRegister,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Divider
            _buildDivider(),

            const SizedBox(height: AppSpacing.xl),

            // Social buttons
            _buildSocialButton(
              icon: Icons.g_mobiledata_rounded,
              label: 'Continue with Google',
              onTap: _launchGoogleSignIn,
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SHARED WIDGETS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelLarge),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          validator: validator,
          style: AppTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
            prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
            suffixIcon: onToggleObscure != null
                ? GestureDetector(
                    onTap: onToggleObscure,
                    child: Icon(
                      obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                  )
                : null,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.slate900, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.red500),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.red500, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: _isLoading ? AppColors.slate600 : AppColors.slate900,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppColors.slate900.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.textInverse,
                  ),
                )
              : Text(
                  label,
                  style: AppTypography.button.copyWith(
                    color: AppColors.textInverse,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'or',
            style: AppTypography.caption,
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: AppColors.textPrimary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.button.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GOOGLE SIGN-IN
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _launchGoogleSignIn() async {
    final url = Uri.parse('https://accounts.google.com/signin');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // VALIDATORS
  // ─────────────────────────────────────────────────────────────────────────

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }
}
