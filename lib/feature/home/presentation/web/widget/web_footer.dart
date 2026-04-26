import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WebFooter extends StatelessWidget {
  const WebFooter({super.key});

  Future<void> _launchURL(String? urlString) async {
    if (urlString == null || urlString.isEmpty || urlString == "#") return;

    Uri url;

    if (!urlString.startsWith('http')) {
      String cleanNumber = urlString.replaceAll(RegExp(r'[^0-9]'), '');

      if (cleanNumber.startsWith('0')) {
        cleanNumber = '20${cleanNumber.substring(1)}';
      }

      url = Uri.parse("https://wa.me/$cleanNumber");
    } else {
      url = Uri.parse(urlString);
    }

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Error launching $url: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 60),
      color: const Color(0xFF2F3E34),
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('settings')
            .doc('social_links')
            .get(),
        builder: (context, snapshot) {
          Map<String, dynamic> links = {
            'facebook': 'https://facebook.com',
            'instagram': 'https://instagram.com',
            'whatsapp': 'https://wa.me/20123456789',
          };

          if (snapshot.hasData && snapshot.data!.exists) {
            links = snapshot.data!.data() as Map<String, dynamic>;
          }

          return Column(
            children: [
              const Text(
                "مَـرسَم",
                style: TextStyle(
                  fontFamily: 'ElMessiri',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE8DDCF),
                ),
              ),
              SizedBox(height: 5.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialIcon(
                    FontAwesomeIcons.facebook, // شلنا الـ casting
                    () => _launchURL(links['facebook']),
                  ),
                  _socialIcon(
                    FontAwesomeIcons.instagram,
                    () => _launchURL(links['instagram']),
                  ),
                  _socialIcon(
                    FontAwesomeIcons.whatsapp,
                    () => _launchURL(links['whatsapp']),
                  ),
                                    _socialIcon(
                    FontAwesomeIcons.tiktok,
                    () => _launchURL(links['tiktok']),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                "© 2026 جميع الحقوق محفوظة لـ Hager's.",
                style: TextStyle(color: Colors.white24, fontSize: 14),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _socialIcon(dynamic icon, VoidCallback onTap) {
    // خلي النوع dynamic عشان يقبل أي أيقونة
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            // ✅ استخدم FaIcon بدل Icon عشان تعرض FontAwesome صح
            child: FaIcon(icon, color: const Color(0xFFE8DDCF), size: 28),
          ),
        ),
      ),
    );
  }
}
