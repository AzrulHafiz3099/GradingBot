import 'package:flutter/material.dart';
import 'SignIn_Page.dart';
import 'utils/colors.dart';
import 'utils/env.dart'; // Use your centralized env config
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Controllers to get user input
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _institutionController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final phone = _phoneController.text.trim();
    final institution = _institutionController.text.trim();

    bool isValidEmail(String email) {
      // Basic email regex pattern
      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      return emailRegex.hasMatch(email);
    }

    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        phone.isEmpty ||
        institution.isEmpty) {
      _showMessage('Please fill all fields');
      return;
    }

    if (password.length < 8) {
      _showMessage('Password must be at least 8 characters long');
      return;
    }

    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      _showMessage('Phone number must be 10 digits and numbers only');
      return;
    }

    if (!isValidEmail(email)) {
      _showMessage('Please enter a valid email address');
      return;
    }

    setState(() => _isLoading = true);

    // Add this print to see the JSON body
    print(
      jsonEncode({
        'Lecturer_Name': fullName,
        'Email': email,
        'Password': password,
        'Phone_Number': phone,
        'Institution_Name': institution,
      }),
    );

    try {
      final url = Uri.parse('${Env.baseUrl}/register');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Lecturer_Name': fullName,
          'Email': email,
          'Password': password,
          'Phone_Number': phone,
          'Institution_Name': institution,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 409) {
        _showMessage(
          data['detail'],
        ); // It will show "Email already registered", etc.
      } else if (response.statusCode == 200) {
        _showMessage("Registration successful");
        Navigator.pop(context);
      } else {
        _showMessage("Error: ${data['detail'] ?? 'Unexpected error'}");
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          _showMessage('Registration successful! Please sign in.');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignInPage()),
          );
        } else {
          _showMessage(data['message'] ?? 'Registration failed');
        }
      } else {
        // _showMessage('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showMessage('Network error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double scaleFactor = screenWidth / 375;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08,
            vertical: screenHeight * 0.05,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Image.asset(
                  'assets/top_circle.jpeg',
                  height: screenHeight * 0.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 28 * scaleFactor,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 30),

              _buildTextField(
                controller: _fullNameController,
                hint: 'Full Name',
                icon: Icons.person,
                scaleFactor: scaleFactor,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _emailController,
                hint: 'Email',
                icon: Icons.email,
                scaleFactor: scaleFactor,
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12 * scaleFactor),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Phone Number (0123456789)',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12 * scaleFactor),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              _buildTextField(
                controller: _institutionController,
                hint: 'Institution Name',
                icon: Icons.apartment,
                scaleFactor: scaleFactor,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48 * scaleFactor,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12 * scaleFactor),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                          : Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16 * scaleFactor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: AppColors.secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required double scaleFactor,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12 * scaleFactor),
        ),
      ),
    );
  }
}
