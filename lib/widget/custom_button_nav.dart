import 'package:flutter/material.dart';
import '/SubmissionPage/Submission.dart';
import '/utils/colors.dart';

class CustomBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  _CustomBottomNavState createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, 0),
              _buildNavItem(Icons.analytics_outlined, 1),
              const SizedBox(width: 60),
              _buildNavItem(Icons.manage_accounts_outlined, 2),
              _buildNavItem(Icons.settings_outlined, 3),
            ],
          ),

          // Center QR Scanner Button
          // Center QR Scanner Button
          Positioned(
            top: -30,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubmissionPage(),
                  ),
                );
              },
              onTapDown: (_) {
                setState(() {
                  _isPressed = true; // Activate shadow when pressed
                });
              },
              onTapUp: (_) {
                setState(() {
                  _isPressed = false; // Remove shadow when release
                });
              },
              onTapCancel: () {
                setState(() {
                  _isPressed = false; // Remove shadow if canceled
                });
              },
              borderRadius: BorderRadius.circular(30),
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 5),
                  boxShadow:
                      _isPressed
                          ? [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ]
                          : const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.qr_code_scanner,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: Icon(
        icon,
        size: 28,
        color: widget.currentIndex == index ? Colors.blue : Colors.grey,
      ),
    );
  }
}
