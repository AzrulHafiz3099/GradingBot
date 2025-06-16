import 'package:flutter/material.dart';
import 'SignUp_Page.dart';
import 'utils/colors.dart';
import 'main_screen.dart';
// import 'services/mongo_service.dart';  // Removed mongo_service import
import 'services/connection.dart'; // <-- Use your connection test function
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/utils/env.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'SettingPage/Password/ForgotPassword.dart';
import 'package:local_auth/local_auth.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final TextEditingController _emailOrIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  bool? _isConnected; // null = loading, true = connected, false = disconnected
  final String _keyEmail = 'biometric_email';
  final String _keyPassword = 'biometric_password';
  final String _keyLecturerId = 'lecturer_id';

  @override
  void initState() {
    super.initState();
    _clearSecureStorage(); // Clear secure storage on start
    _checkConnection(); // Check backend connection
  }

  Future<void> _clearSecureStorage() async {
    Map<String, String> allValues = await secureStorage.readAll();

    if (allValues.isEmpty) {
      print('🔍 Secure storage is already empty.');
    } else {
      print('🔐 Contents of secure storage before clearing:');
      allValues.forEach((key, value) {
        print(' - $key: $value');
      });
    }

    await secureStorage.delete(key: 'lecturer_id');
    print('🧹 Secure storage cleared on SignInPage load.');
  }

  Future<void> _authenticateWithBiometrics() async {
  final LocalAuthentication auth = LocalAuthentication();

  try {
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    bool isDeviceSupported = await auth.isDeviceSupported();

    print('🔍 canCheckBiometrics: $canCheckBiometrics');
    print('🛠️ isDeviceSupported: $isDeviceSupported');

    if (!canCheckBiometrics || !isDeviceSupported) {
      _showMessage('This device does not support biometric authentication.');
      return;
    }

    final authenticated = await auth.authenticate(
      localizedReason: 'Use your fingerprint to sign in',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );

    if (authenticated) {
      final email = await secureStorage.read(key: _keyEmail);
      final password = await secureStorage.read(key: _keyPassword);

      if (email != null && password != null) {
        _emailOrIdController.text = email;
        _passwordController.text = password;
        print('🔑 Biometric login: trying to sign in with $email');
        await _handleSignIn();
      } else {
        const message = 'No stored credentials found. Please sign in manually first.';
        _showMessage(message);
        print('⚠️ $message');
      }
    }
  } catch (e) {
    final errorMessage = 'Biometric authentication failed: $e';
    _showMessage(errorMessage);
    print('❌ $errorMessage');
  }
}



  Future<void> _showBiometricPrompt(String email, String password) async {
    final existingEmail = await secureStorage.read(key: _keyEmail);

    if (existingEmail != null && existingEmail != email) {
      final shouldReplace = await _showConfirmationDialog(
        'Replace saved account?',
        'A different account is already saved for biometric login. Do you want to replace it?',
      );
      if (!shouldReplace) return;
    }

    final useBiometric = await _showConfirmationDialog(
      'Enable Biometric Login?',
      'Would you like to enable biometric login for this account?',
    );

    if (useBiometric) {
      await secureStorage.write(key: _keyEmail, value: email);
      await secureStorage.write(key: _keyPassword, value: password);
      print('🔒 Biometric credentials stored');
    }
  }

  Future<bool> _showConfirmationDialog(String title, String content) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text(title),
                content: Text(content),
                actions: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  TextButton(
                    child: const Text('Yes'),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Future<void> _checkConnection() async {
    try {
      await testConnection();
      setState(() => _isConnected = true);
      print('✅ Connection to backend succeeded.');
    } catch (e) {
      setState(() => _isConnected = false);
      print('❌ Connection to backend failed: $e');
    }
  }

  @override
  void dispose() {
    _emailOrIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final emailOrId = _emailOrIdController.text.trim();
    final password = _passwordController.text.trim();

    if (emailOrId.isEmpty || password.isEmpty) {
      _showMessage('Please enter your Email/Username and Password');
      return;
    }

    if (_isConnected != true) {
      _showMessage('Not connected to backend. Please try again later.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('${Env.baseUrl}/login');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'emailOrId': emailOrId, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Response from backend: $data');

        if (data['success'] == true) {
          // Save lecturer_id securely
          if (data.containsKey('lecturer_id')) {
            await secureStorage.write(
              key: 'lecturer_id',
              value: data['lecturer_id'],
            );
          }

          _showBiometricPrompt(emailOrId, password);

          setState(() => _isLoading = false);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          setState(() => _isLoading = false);
          _showMessage(data['message'] ?? 'Invalid Email/Username or Password');
        }
      } else {
        setState(() => _isLoading = false);
        _showMessage('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('Network error: $e');
      print('SignIn error: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 375;

    if (_isConnected == null) {
      // still checking connection
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isConnected == false) {
      // not connected
      return Scaffold(
        body: Center(
          child: Text(
            'Not connected to the backend.',
            style: TextStyle(fontSize: 18 * scaleFactor, color: Colors.red),
          ),
        ),
      );
    }

    // connected, show sign in form
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 0),
                Image.asset('assets/logo.png', height: 140 * scaleFactor),
                const SizedBox(height: 10),
                const SizedBox(height: 40),
                Text(
                  'Sign in',
                  style: TextStyle(
                    fontSize: 28 * scaleFactor,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 30),

                // Email or UserName TextField
                TextField(
                  controller: _emailOrIdController,
                  decoration: InputDecoration(
                    hintText: 'Email or Phone Number',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12 * scaleFactor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password TextField
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12 * scaleFactor),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Forget Password ?',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 48 * scaleFactor,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignIn,
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
                              'Sign in',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16 * scaleFactor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 20),
                const Text('Or sign in With'),
                const SizedBox(height: 12),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 45 * scaleFactor,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.fingerprint),
                    onPressed: _authenticateWithBiometrics,
                    label: const Text('Biometrics Sign In'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10 * scaleFactor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have account ? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppColors.secondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
