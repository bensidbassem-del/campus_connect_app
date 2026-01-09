import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/auth_service_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final nameController = TextEditingController();
  final bacYearController = TextEditingController();
  final specialtyController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  String errorMessage = '';

  Future<void> register() async {
    // Input validation
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        bacYearController.text.isEmpty ||
        specialtyController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please fill in all required fields';
      });
      return;
    }

    setState(() {
      loading = true;
      errorMessage = '';
    });

    try {
      // Use the newly created register method from AuthServiceController
      // Note: Splitting name into first/last is a bit hacky here,
      // ideally UI should have separate fields or backend handles full name.
      // For now, using name as firstName and empty lastName, or splitting by space.
      final names = nameController.text.split(' ');
      final firstName = names.isNotEmpty ? names.first : nameController.text;
      final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

      final success = await ref
          .read(authServiceProvider)
          .register(
            username: emailController.text.split('@')[0], // username from email
            email: emailController.text,
            password: passwordController.text,
            firstName: firstName,
            lastName: lastName,
            studentId:
                'STU-${DateTime.now().millisecondsSinceEpoch}', // generating ID for now
          );

      if (!mounted) return;

      if (success) {
        // Navigate to login screen or direct login (if backend returns token)
        // Since register flow usually requires login afterwards or returns to login:
        Navigator.pop(context); // Go back to login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please login.'),
          ),
        );
      } else {
        setState(() {
          errorMessage =
              'Registration failed. Username or email might be taken.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Campus Connect',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Error message display
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),

              // Name field
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // BAC Year field
              TextField(
                controller: bacYearController,
                decoration: const InputDecoration(
                  labelText: 'High School Graduation Year',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              // Specialty field
              TextField(
                controller: specialtyController,
                decoration: const InputDecoration(
                  labelText: 'Specialty',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Email field
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              // Password field
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Register button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : register,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Register', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up controllers
    nameController.dispose();
    bacYearController.dispose();
    specialtyController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
