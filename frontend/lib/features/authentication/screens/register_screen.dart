import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../widgets/auth_gate.dart';

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
      // API endpoint - update with your actual backend URL
      const String apiUrl = 'http://your-backend-url.com/api/register';

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        'name': nameController.text,
        'bac_year': bacYearController.text,
        'specialty': specialtyController.text,
        'email': emailController.text,
        'password': passwordController.text,
      };

      // Make HTTP POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Check response status
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse response data
        final responseData = jsonDecode(response.body);

        // Assuming backend returns token and user data
        final String token = responseData['token'];
        final String role = responseData['user']['role'] ?? 'student';

        // Save authentication data
        await ref.read(authServiceProvider).saveAuth(token: token, role: role);

        if (!mounted) return;

        // Navigate to auth gate
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthGate()),
        );
      } else {
        // Handle error responses
        final errorData = jsonDecode(response.body);
        setState(() {
          errorMessage =
              errorData['message'] ?? 'Registration failed. Please try again.';
        });
      }
    } catch (e) {
      // Handle network or other errors
      setState(() {
        errorMessage = 'Network error: ${e.toString()}';
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
