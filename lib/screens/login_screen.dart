import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/exceptions.dart';
import '../utils/ui_helpers.dart';
import '../utils/validators.dart';
import '../widgets/loading_button.dart';
import '../widgets/password_field.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final AuthService authService;

  const LoginScreen({super.key, required this.authService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _signingIn = false;
  bool _googleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _signingIn = true);
    try {
      await widget.authService.signIn(
        _emailController.text,
        _passwordController.text,
      );
      // nothing else to do: the listener at the app root switches screens
    } on AppAuthException catch (e) {
      if (mounted) showNotice(context, e.message);
    }
    if (mounted) setState(() => _signingIn = false);
  }

  Future<void> _googleSignIn() async {
    setState(() => _googleLoading = true);
    try {
      await widget.authService.signInWithGoogle();
    } on GoogleSignInCancelledException {
      // user closed the popup, no message needed
    } on AppAuthException catch (e) {
      if (mounted) showNotice(context, e.message);
    }
    if (mounted) setState(() => _googleLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final busy = _signingIn || _googleLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.calculate_rounded,
                        size: 72, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 12),
                    Text(
                      'Welcome back',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.email,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    PasswordField(
                      controller: _passwordController,
                      validator: Validators.password,
                      onSubmitted: (_) => _signIn(),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: busy
                            ? null
                            : () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ForgotPasswordScreen(
                                        authService: widget.authService),
                                  ),
                                ),
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    LoadingButton(
                      label: 'Sign In',
                      isLoading: _signingIn,
                      onPressed: busy ? null : _signIn,
                    ),
                    const SizedBox(height: 12),
                    LoadingButton(
                      label: 'Continue with Google',
                      icon: Icons.g_mobiledata,
                      outlined: true,
                      isLoading: _googleLoading,
                      onPressed: busy ? null : _googleSignIn,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: busy
                              ? null
                              : () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => SignUpScreen(
                                          authService: widget.authService),
                                    ),
                                  ),
                          child: const Text('Sign up'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
