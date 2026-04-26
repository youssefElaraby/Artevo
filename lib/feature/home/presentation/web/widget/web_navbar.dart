import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:art_by_hager_ismail/core/route_manager/routes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WebNavbar extends StatelessWidget {
  final String currentTab;
  final Function(String) onTabChanged;
  final bool isScrolled;

  const WebNavbar({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
    required this.isScrolled,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      height: isScrolled ? 80 : 135,
      padding: EdgeInsets.symmetric(horizontal: isScrolled ? 40 : 80),
      decoration: BoxDecoration(
        color: isScrolled
            ? const Color(0xFFE8DDCF).withOpacity(0.98)
            : Colors.transparent,
        boxShadow: isScrolled
            ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
            : [],
      ),
      child: Stack(
        children: [
          // 1. اللوجو المتحرك (مَـرسَم.)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            right: isScrolled ? 0 : (screenWidth / 2) - 130,
            top: isScrolled ? 15 : 10,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 400),
              style: TextStyle(
                fontFamily: 'ElMessiri',
                fontSize: isScrolled ? 30 : 55,
                fontWeight: FontWeight.bold,
                color: const Color(
                  0xFF2F3E34,
                ).withOpacity(isScrolled ? 1.0 : 0.0),
              ),
              child: const Text("مَـرسَم."),
            ),
          ),

          // 2. القائمة (المنيو) في المنتصف
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            left: isScrolled ? screenWidth * 0.15 : (screenWidth / 2) - 340,
            bottom: isScrolled ? 15 : 15,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _navItem("الرئيسية", 'home'),
                _navItem("أعمالنا", 'portfolio'),
                _navItem("الأنشطة", 'activities'),
                const SizedBox(width: 20),
                _bookingButton(),
              ],
            ),
          ),

          // 3. منطقة البروفايل / تسجيل الدخول (أقصى اليسار)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            left: 0,
            top: isScrolled ? 15 : 35,
            child: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, authSnapshot) {
                if (authSnapshot.hasData && authSnapshot.data != null) {
                  // جلب بيانات المستخدم الحقيقية من Firestore
                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(authSnapshot.data!.uid)
                        .snapshots(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.hasData && userSnapshot.data!.exists) {
                        final userData =
                            userSnapshot.data!.data() as Map<String, dynamic>;
                        return _userProfileInfo(
                          context,
                          fullName: userData['fullName'] ?? 'فنان مَـرسَم',
                          imageUrl: userData['profilePicture'], // الحقل الصحيح
                        );
                      }
                      return const SizedBox(width: 40, height: 40);
                    },
                  );
                }
                // في حالة عدم تسجيل الدخول
                return _loginButton(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ويدجت بيانات المستخدم + قائمة تسجيل الخروج
  Widget _userProfileInfo(
    BuildContext context, {
    required String fullName,
    String? imageUrl,
  }) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 55),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (value) async {
        if (value == 'logout') {
          await FirebaseAuth.instance.signOut();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              const Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                "تسجيل الخروج",
                style: TextStyle(fontFamily: 'Tajawal', fontSize: 14.sp),
              ),
            ],
          ),
        ),
      ],
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F3E34),
                    fontFamily: 'Tajawal',
                  ),
                ),
                const Text(
                  "حسابي",
                  style: TextStyle(fontSize: 10, color: Color(0xFF9C5A1A)),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF9C5A1A), width: 1.5),
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFE8DDCF),
                backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                    ? NetworkImage(imageUrl)
                    : null,
                child: (imageUrl == null || imageUrl.isEmpty)
                    ? const Icon(
                        Icons.person,
                        color: Color(0xFF2F3E34),
                        size: 20,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loginButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => Navigator.pushNamed(context, PageRoutesName.signInRoute),
      icon: const Icon(Icons.login_rounded, size: 18, color: Color(0xFF2F3E34)),
      label: const Text(
        "تسجيل الدخول",
        style: TextStyle(
          color: Color(0xFF2F3E34),
          fontWeight: FontWeight.bold,
          fontFamily: 'Tajawal',
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF2F3E34), width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
    );
  }

  Widget _navItem(String title, String tabId) {
    bool isActive = currentTab == tabId;
    return InkWell(
      onTap: () => onTabChanged(tabId),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isActive
                    ? const Color(0xFF9C5A1A)
                    : const Color(0xFF6F624C),
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 2,
              width: isActive ? 20 : 0,
              color: const Color(0xFF9C5A1A),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bookingButton() {
    return ElevatedButton(
      onPressed: () => onTabChanged('booking'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2F3E34),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
      child: const Text(
        "احجز سيشن 🎨",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Tajawal',
        ),
      ),
    );
  }
  
}
