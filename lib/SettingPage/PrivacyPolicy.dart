import 'package:flutter/material.dart';
import '/utils/colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.secondaryColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Privacy Policy",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "This mobile application, Grading Bot, is developed as part of a Final Year Project at Universiti Teknikal Malaysia Melaka (UTeM). It aims to assist lecturers in the grading process of handwritten student examination answers using Optical Character Recognition (OCR) and AI-powered keyword detection.",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 12),
                Text(
                  "Data Collection & Usage",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "• The application captures images of written answers.\n"
                  "• Extracted text is analyzed locally using predefined keywords entered by the lecturer.\n"
                  "• No personal student data is permanently stored without consent.\n"
                  "• Email, phone number, and institution data of lecturers are stored only for account and communication purposes.",
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 12),
                Text(
                  "Security",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "We ensure that all data processed is secured through encryption and proper handling practices. Data collected is only accessible to authorized users and used strictly for grading functionalities.",
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 12),
                Text(
                  "Purpose of AI Integration",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "The AI integration serves the purpose of automating the marking process based on keyword detection. It does not make decisions beyond grading and is designed to be transparent, auditable, and editable by human lecturers.",
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 12),
                Text(
                  "User Responsibility",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Lecturers are responsible for reviewing the AI-generated marks before submission. The system offers recommendations and is not a substitute for final academic judgment.",
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 12),
                Text(
                  "Changes & Updates",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "This policy may be updated as features evolve. Users will be notified of any major changes within the application.",
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 12),
                Text(
                  "Contact",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "For questions or concerns regarding this privacy policy, please contact azrulhafiz0177@gmail.com.",
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
