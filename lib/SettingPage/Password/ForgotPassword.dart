import 'package:flutter/material.dart';
import '/utils/colors.dart';
import 'VerificationCode.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/utils/env.dart';

enum ResetOption { none, email, phone }

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  ResetOption _selectedOption = ResetOption.none;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;

  Future<void> _checkAndSend() async {
    final String? email =
        _selectedOption == ResetOption.email
            ? emailController.text.trim()
            : null;
    final String? phone =
        _selectedOption == ResetOption.phone
            ? phoneController.text.trim()
            : null;

    final uri = Uri.parse('${Env.baseUrl}/api_auth/check_user').replace(
      queryParameters: {
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      },
    );

    setState(() => isLoading = true);

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerificationPage(email: email, phone: phone),
          ),
        );
      } else {
        final data = jsonDecode(response.body);
        _showSnackBar(data['detail'] ?? 'User not found');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: AppColors.secondaryColor),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06,
          vertical: screenHeight * 0.04,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenHeight * 0.9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Forgot Password',
                style: TextStyle(
                  fontSize: screenWidth * 0.055,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              const Text('Choose a method to reset your password:'),
              const SizedBox(height: 10),
              _buildOptionTile('Email Address', ResetOption.email),
              _buildOptionTile('Phone Number', ResetOption.phone),
              const SizedBox(height: 24),

              if (_selectedOption == ResetOption.email)
                _buildInputField(
                  controller: emailController,
                  label: 'Enter Email Address',
                  hint: 'example@gmail.com',
                  icon: Icons.email,
                ),
              if (_selectedOption == ResetOption.phone)
                _buildInputField(
                  controller: phoneController,
                  label: 'Enter Phone Number',
                  hint: '0123456789',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),

              SizedBox(height: screenHeight * 0.1),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      (_selectedOption == ResetOption.none)
                          ? null
                          : () async {
                            final String? email =
                                _selectedOption == ResetOption.email
                                    ? emailController.text.trim()
                                    : null;
                            final String? phone =
                                _selectedOption == ResetOption.phone
                                    ? phoneController.text.trim()
                                    : null;

                            final uri = Uri.parse(
                              '${Env.baseUrl}/api_password/check_user',
                            ).replace(
                              queryParameters: {
                                if (email != null) 'email': email,
                                if (phone != null) 'phone': phone,
                              },
                            );

                            try {
                              final response = await http.get(uri);

                              if (response.statusCode == 200) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => VerificationPage(
                                          email: email,
                                          phone: phone,
                                        ),
                                  ),
                                );
                              } else {
                                final data = jsonDecode(response.body);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      data['detail'] ?? 'User not found',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryColor,
                    disabledBackgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      isLoading
                          ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                          : const Text(
                            'Send',
                            style: TextStyle(color: Colors.white),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile(String title, ResetOption option) {
    return RadioListTile<ResetOption>(
      value: option,
      groupValue: _selectedOption,
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _selectedOption = value;

          // Clear the opposite controller
          if (value == ResetOption.email) {
            phoneController.clear(); // Clear phone when email is selected
          } else if (value == ResetOption.phone) {
            emailController.clear(); // Clear email when phone is selected
          }
        });
      },
      activeColor: AppColors.secondaryColor,
      contentPadding: EdgeInsets.zero,
      title: Text(title),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        TextField(
          key: ValueKey(
            keyboardType,
          ), // 🔑 Force rebuild on keyboardType change
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
