import 'package:flutter/material.dart';
import '/utils/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatefulWidget {
  final int initialTabIndex; // 0 = FAQ, 1 = Contact Us

  const HelpSupportPage({super.key, this.initialTabIndex = 0});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, String>> faqList = [
    {
      "question": "How do I change my profile information?",
      "answer":
          "To change profile information, go to Settings > Edit Profile Information",
    },
    {
      "question": "How do I start scanning papers?",
      "answer":
          "Tap the 'scan' icon at the bottom navigation bar to scan exam papers",
    },
    {
      "question": "How do I manage my question scheme?",
      "answer":
          "Go to Management Page > Exam Management >  Select Class > Click Exam > Click Question > Manage the Schemes",
    },
    {
      "question": "Is my data safe and private?",
      "answer":
          "Yes. All data is encrypted and only used within the scope of your account settings.",
    },
  ];

  final List<Map<String, dynamic>> contactList = [
    {"icon": Icons.headset_mic, "label": "Customer Services"},
    {"icon": FontAwesomeIcons.whatsapp, "label": "WhatsApp"},
    {"icon": Icons.language, "label": "Website"},
    {"icon": Icons.facebook, "label": "Facebook"},
    {"icon": FontAwesomeIcons.xTwitter, "label": "X"},
    {"icon": Icons.camera_alt, "label": "Instagram"},
  ];

  List<bool> _expanded = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _expanded = List.filled(faqList.length, false);
  }

  Future<void> _openWhatsAppLink() async {
    final url = Uri.parse("https://wa.link/c81d69");

    // Don't check with canLaunchUrl for HTTPS, just launch
    try {
      await launchUrl(
        url,
        mode:
            LaunchMode.platformDefault, // fallback to browser or system handler
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error opening WhatsApp: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00A5FF), // Blue background
      appBar: AppBar(
        backgroundColor: Colors.white, // white top bar
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF00A5FF),
          ), // blue back icon
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help Center',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00A5FF), // blue title text
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xFF00A5FF), // selected tab text color
          unselectedLabelColor: Colors.black45, // unselected tab text
          indicatorColor: Color(0xFF00A5FF), // indicator color
          tabs: const [Tab(text: "FAQ"), Tab(text: "Contact Us")],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [_buildFAQTab(), _buildContactTab()],
      ),
    );
  }

  Widget _buildFAQTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
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
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: ExpansionPanelList(
            elevation: 1,
            expansionCallback: (index, isOpen) {
              setState(() {
                _expanded[index] = !_expanded[index];
              });
            },
            children:
                faqList.asMap().entries.map((entry) {
                  int idx = entry.key;
                  final faq = entry.value;

                  return ExpansionPanel(
                    canTapOnHeader: true,
                    isExpanded: _expanded[idx],
                    headerBuilder:
                        (_, isExpanded) => Container(
                          color: const Color(
                            0xFFF0F8FF,
                          ), // Light blue for question
                          child: ListTile(
                            title: Text(
                              faq["question"]!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                    body: Container(
                      color: const Color(0xFFF8F8F8), // Light grey for answer
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Text(
                        faq["answer"]! + "\n",
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildContactTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
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
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: contactList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = contactList[index];
            return InkWell(
              onTap: () {
                final label = item["label"];
                if (label == "WhatsApp") {
                  _openWhatsAppLink();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(item["icon"], color: Colors.black54),
                    const SizedBox(width: 16),
                    Text(
                      item["label"],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
