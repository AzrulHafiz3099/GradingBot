import 'package:flutter/material.dart';
import '/utils/colors.dart';
import 'ResetPassword.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/utils/env.dart';
import 'dart:async';

class VerificationPage extends StatefulWidget {
  final String? email;
  final String? phone;

  const VerificationPage({super.key, this.email, this.phone});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  bool isVerifying = false;

  int _secondsRemaining = 60;
  Timer? _timer;

  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  int _resendCount = 0;
  final int _maxResends = 2;

  // ✅ Declare before calling it in initState
  Future<void> _sendOTP({String? phone, String? email}) async {
    final endpoint =
        phone != null
            ? '/api_password/send_otp?phone=$phone'
            : '/api_password/send_otp_email';
    final uri = Uri.parse('${Env.baseUrl}$endpoint');

    try {
      final response =
          phone != null
              ? await http.post(uri)
              : await http.post(
                uri,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({'email': email}),
              );

      if (response.statusCode == 200) {
        debugPrint("OTP sent successfully.");
      } else {
        final data = jsonDecode(response.body);
        _showSnackBar(data['detail'] ?? 'Failed to send OTP.');
      }
    } catch (e) {
      _showSnackBar('Error sending OTP: $e');
    }
  }

  void _startCountdown() {
    _timer?.cancel(); // clear previous timer
    setState(() => _secondsRemaining = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  @override
void initState() {
  super.initState();
  if (widget.phone != null) {
    _sendOTP(phone: widget.phone);
    _startCountdown(); // ✅ already here
  } else if (widget.email != null) {
    _sendOTP(email: widget.email);
    _startCountdown(); // ✅ this was missing!
  }
}


  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((c) => c.text.trim()).join();
    if (otp.length != 4) {
      _showSnackBar("Please enter a 4-digit code.");
      return;
    }

    final uri = Uri.parse('${Env.baseUrl}/api_password/verify_otp');
final body = jsonEncode({
  if (widget.phone != null) "phone": widget.phone,
  if (widget.email != null) "email": widget.email,
  "otp": otp,
});
    setState(() => isVerifying = true);

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ResetPasswordPage(phone: widget.phone ?? '', email: widget.email ?? ''),

  ),
);

      } else {
        final data = jsonDecode(response.body);
        _showSnackBar(data['detail'] ?? 'OTP verification failed.');

        for (var controller in _otpControllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus(); // put focus back to the first field
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    } finally {
      setState(() => isVerifying = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final String target = widget.phone ?? widget.email ?? '';

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false, // ⛔️ Remove back button
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Verification',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Text('Verification code sent to: ${widget.phone != null ? '+6$target' : target}'),
              const SizedBox(height: 4),
              Text(
                _secondsRemaining > 0
                    ? 'Code expires in $_secondsRemaining seconds'
                    : 'Code has expired. Please resend.',
                style: TextStyle(
                  color:
                      _secondsRemaining > 0 ? Colors.black54 : Colors.redAccent,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 60,
                    height: 60,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          if (index < 3) {
                            FocusScope.of(
                              context,
                            ).requestFocus(_focusNodes[index + 1]);
                          } else {
                            FocusScope.of(context).unfocus();
                          }
                        } else if (index > 0) {
                          FocusScope.of(
                            context,
                          ).requestFocus(_focusNodes[index - 1]);
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text("If you didn’t receive a code? "),
                  TextButton(
                    onPressed:
                        (_resendCount >= _maxResends ||
                                (widget.phone == null && widget.email == null))
                            ? null
                            : () {
                              for (var controller in _otpControllers) {
                                controller.clear();
                              }

                              setState(() {
                                _resendCount++;
                              });

                              if (widget.phone != null) {
                                _sendOTP(phone: widget.phone);
                              } else if (widget.email != null) {
                                _sendOTP(email: widget.email);
                              }

                              _startCountdown();
                            },

                    child: Text(
                      _resendCount >= _maxResends ? 'Resend' : 'Resend',
                      style: TextStyle(
                        color:
                            _resendCount >= _maxResends
                                ? Colors.grey
                                : AppColors.secondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isVerifying ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      isVerifying
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Verify',
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
}
