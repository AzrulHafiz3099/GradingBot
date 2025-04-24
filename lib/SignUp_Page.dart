import 'package:flutter/material.dart';
import 'SignIn_Page.dart';
import 'utils/colors.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    // Get screen size
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Define a scaling factor based on the screen width
    double scaleFactor = screenWidth / 375; // 375 is a common width for mobile screens

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08, // 8% padding on each side
            vertical: screenHeight * 0.05, // 5% padding vertically
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Optional: Top-right circle graphic
              Align(
                alignment: Alignment.topRight,
                child: Image.asset(
                  'assets/top_circle.jpeg', // Replace if needed
                  height: screenHeight * 0.2, // 20% of screen height
                ),
              ),
              const SizedBox(height: 10),

              // Title
              Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 28 * scaleFactor, // Adjust font size based on screen width
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),

              const SizedBox(height: 30),

              // Full Name
              _buildTextField(
                hint: 'Full Name',
                icon: Icons.person,
                screenWidth: screenWidth,
              ),

              const SizedBox(height: 12),

              // Email
              _buildTextField(
                hint: 'Email',
                icon: Icons.email,
                screenWidth: screenWidth,
              ),

              const SizedBox(height: 12),

              // Password
              TextField(
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
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

              // Phone Number
              _buildTextField(
                hint: 'Phone Number',
                icon: Icons.phone,
                screenWidth: screenWidth,
              ),

              const SizedBox(height: 12),

              // Institution Name
              _buildTextField(
                hint: 'Institution Name',
                icon: Icons.apartment,
                screenWidth: screenWidth,
              ),

              const SizedBox(height: 24),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 48 * scaleFactor, // Button height based on screen height
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12 * scaleFactor),
                    ),
                  ),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16 * scaleFactor, // Button text size based on screen width
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Bottom Text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignInPage()),
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
    required String hint,
    required IconData icon,
    required double screenWidth,
  }) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
