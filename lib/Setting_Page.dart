import 'package:flutter/material.dart';
import '/utils/env.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'SettingPage/EditLecturerProfilePage.dart';
import 'SettingPage/PrivacyPolicy.dart';
import 'SettingPage/HelpSupport.dart';
import 'SettingPage/Password/ForgotPassword.dart';
import 'SignIn_Page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool isNotificationOn = false;
  bool isLightTheme = false;
  final secureStorage = const FlutterSecureStorage();
  String? lecturerId;

  @override
  void initState() {
    super.initState();
    fetchLecturerInfo();
  }

  Map<String, String>? lecturerInfo;

  Future<void> fetchLecturerInfo() async {
    final id = await secureStorage.read(key: 'lecturer_id');
    if (id == null) return;

    try {
      final response = await http.get(
        Uri.parse('${Env.baseUrl}/api_profile/lecturer_info?lecturer_id=$id'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            lecturerId = id;
            lecturerInfo = Map<String, String>.from(data['data']);
          });
        }
      } else {
        print('Failed to fetch lecturer info: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00A5FF),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: 120,
                  color: const Color(0xFF00A5FF),
                ),
                Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/app_icon.png',
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      lecturerInfo?['name'] ?? 'Your Name',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${lecturerInfo?['email'] ?? 'email@example.com'} | ${lecturerInfo?['phone'] ?? '+60 123-456789'}',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    settingsCard([
                      InkWell(
                        onTap: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => EditLecturerProfilePage(
                                    lecturerId: lecturerId ?? '',
                                    currentName: lecturerInfo?['name'] ?? '',
                                    currentEmail: lecturerInfo?['email'] ?? '',
                                    currentPhone: lecturerInfo?['phone'] ?? '',
                                    currentInstitution:
                                        lecturerInfo?['institution'] ?? '',
                                  ),
                            ),
                          );

                          if (updated == true) {
                            await fetchLecturerInfo(); // ✅ Refresh the profile
                          }
                        },

                        child: settingTile(
                          Icons.edit,
                          'Edit profile information',
                        ),
                      ),
                      settingTile(
                        Icons.notifications,
                        'Notification',
                        trailing: Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: isNotificationOn,
                            onChanged: (value) {
                              setState(() {
                                isNotificationOn = value;
                              });
                            },
                            activeColor: Colors.white,
                            inactiveThumbColor: Colors.grey,
                          ),
                        ),
                      ),

                      settingTile(
                        Icons.language,
                        'Language',
                        trailing: const Text(
                          'English',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ], backgroundColor: const Color.fromARGB(255, 45, 136, 185)),
                    const SizedBox(height: 10),
                    settingsCard(
                      [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const ForgotPasswordPage(),
                              ),
                            );
                          },
                          child: settingTile(Icons.lock, 'Reset Password'),
                        ),
                        settingTile(
                          Icons.color_lens,
                          'Dark Mode',
                          trailing: Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: isLightTheme,
                              onChanged: (value) {
                                setState(() {
                                  isLightTheme = value;
                                });
                              },
                              activeColor: Colors.white,
                              inactiveThumbColor: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                      backgroundColor: const Color.fromARGB(255, 45, 136, 185),
                    ),
                    const SizedBox(height: 10),
                    settingsCard(
                      [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const HelpSupportPage(
                                      initialTabIndex: 0,
                                    ),
                              ),
                            );
                          },
                          child: settingTile(Icons.help, 'FAQs'),
                        ),

                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const HelpSupportPage(
                                      initialTabIndex: 1,
                                    ),
                              ),
                            );
                          },
                          child: settingTile(Icons.contact_mail, 'Contact us'),
                        ),

                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PrivacyPolicyPage(),
                              ),
                            );
                          },
                          child: settingTile(
                            Icons.privacy_tip,
                            'Privacy policy',
                          ),
                        ),
                      ],
                      backgroundColor: const Color.fromARGB(255, 45, 136, 185),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.logout,
                                          size: 48,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Sign Out?',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        const Text(
                                          'Are you sure you want to sign out? You will need to sign in again to access your account.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed:
                                                    () => Navigator.of(
                                                      context,
                                                    ).pop(false),
                                                style: OutlinedButton.styleFrom(
                                                  side: const BorderSide(
                                                    color: Colors.grey,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed:
                                                    () => Navigator.of(
                                                      context,
                                                    ).pop(true),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Sign Out',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
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

                          if (confirm == true) {
                            // Print secure storage contents before clearing
                            Map<String, String> allValues =
                                await secureStorage.readAll();

                            if (allValues.isEmpty) {
                              print('🔍 Secure storage is already empty.');
                            } else {
                              print(
                                '🔐 Contents of secure storage before sign out:',
                              );
                              allValues.forEach((key, value) {
                                print(' - $key: $value');
                              });
                            }

                            // Clear secure storage
                            await secureStorage.deleteAll();
                            print('✅ Secure storage cleared.');

                            // Navigate to SignInPage and clear navigation stack
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const SignInPage(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                        child: const Text(
                          'Sign Out',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget settingsCard(
    List<Widget> children, {
    Color backgroundColor = Colors.white,
  }) {
    return Card(
      color: backgroundColor,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: children),
      ),
    );
  }

  Widget settingTile(IconData icon, String title, {Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: trailing,
    );
  }
}
