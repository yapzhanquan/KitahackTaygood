import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// A modal sign-in page matching the ProjekWatch design system.
/// Shown when an unauthenticated user tries to perform a gated action.
class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  /// Show as a modal bottom sheet. Returns true if sign-in succeeded.
  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SignInPage(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.people_alt_rounded,
                      size: 32,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    'Sign in to continue',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to add check-ins, bookmark projects,\nand contribute to community tracking.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Google Sign-In button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: auth.isLoading
                          ? null
                          : () async {
                              final success = await auth.signInWithGoogle();
                              if (success && context.mounted) {
                                Navigator.pop(context, true);
                              }
                            },
                      icon: auth.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Image.network(
                              'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                              width: 20,
                              height: 20,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.g_mobiledata_rounded,
                                  size: 24),
                            ),
                      label: Text(
                        auth.isLoading ? 'Signing in...' : 'Continue with Google',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Disclaimer
                  const Text(
                    'Your check-ins are attributed to your account.\nPlease provide factual observations only.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
