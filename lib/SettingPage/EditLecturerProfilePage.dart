import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/utils/colors.dart';
import '/utils/env.dart';

class EditLecturerProfilePage extends StatefulWidget {
  final String lecturerId;
  final String currentName;
  final String currentEmail;
  final String currentPhone;
  final String currentInstitution;

  const EditLecturerProfilePage({
    super.key,
    required this.lecturerId,
    required this.currentName,
    required this.currentEmail,
    required this.currentPhone,
    required this.currentInstitution,
  });

  @override
  State<EditLecturerProfilePage> createState() => _EditLecturerProfilePageState();
}

class _EditLecturerProfilePageState extends State<EditLecturerProfilePage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController institutionController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentName);
    emailController = TextEditingController(text: widget.currentEmail);
    phoneController = TextEditingController(text: widget.currentPhone);
    institutionController = TextEditingController(text: widget.currentInstitution);
  }

  Future<void> _updateLecturer() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final institution = institutionController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || institution.isEmpty) {
      _showSnackBar('Please fill in all fields.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final body = {
        'name': name,
        'email': email,
        'phone': phone,
        'institution': institution,
      };
      print('${Env.baseUrl}/api_profile/update_lecturers/${widget.lecturerId}');

      final response = await http.put(
        Uri.parse('${Env.baseUrl}/api_profile/update_lecturers/${widget.lecturerId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // _showSnackBar('Profile updated successfully!');
        Navigator.pop(context, true);
      } else {
        _showSnackBar(data['message'] ?? 'Failed to update profile.');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    institutionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.secondaryColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            _buildField('Name', nameController, 'Enter name'),
            _buildField('Email', emailController, 'Enter email', readOnly: true),
            _buildField('Phone Number', phoneController, 'Enter phone number', keyboardType: TextInputType.phone),
            _buildField('Institution', institutionController, 'Enter institution'),
            const SizedBox(height: 24),
            if (isLoading) const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: isLoading ? null : _updateLecturer,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
  String label,
  TextEditingController controller,
  String hint, {
  TextInputType? keyboardType,
  bool readOnly = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      const SizedBox(height: 4),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly, // 👈 Apply the readOnly flag here
        decoration: InputDecoration(
          hintText: hint,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          filled: readOnly,
          fillColor: readOnly ? Colors.grey[200] : null, // Optional: grey background
        ),
        style: TextStyle(
          color: readOnly ? Colors.black54 : null, // Optional: dimmed text
        ),
      ),
      const SizedBox(height: 16),
    ],
  );
}

}
