import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/exceptions.dart';
import '../utils/ui_helpers.dart';
import '../utils/validators.dart';
import '../widgets/loading_button.dart';
import '../widgets/password_field.dart';

class SignUpScreen extends StatefulWidget {
  final AuthService authService;

  const SignUpScreen({super.key, required this.authService});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await widget.authService.signUp(
        _emailController.text,
        _passwordController.text,
      );
      // The root listener now shows the calculator. This screen was pushed on
      // top of the login screen, so we just remove it from the stack.
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } on AppAuthException catch (e) {
      if (mounted) {
        showNotice(context, e.message);
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
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
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    PasswordField(
                      controller: _confirmController,
                      label: 'Confirm password',
                      validator: (value) => Validators.confirmPassword(
                          value, _passwordController.text),
                      onSubmitted: (_) => _signUp(),
                    ),
                    const SizedBox(height: 24),
                    LoadingButton(
                      label: 'Create account',
                      isLoading: _loading,
                      onPressed: _signUp,
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
