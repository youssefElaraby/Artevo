import 'package:art_by_hager_ismail/feature/home/presentation/mobile/view/home_mobile_view.dart';
import 'package:art_by_hager_ismail/feature/home/presentation/web/view/home_web_view.dart';
import 'package:art_by_hager_ismail/services/auth_service.dart'; // ✅ اتأكد من المسار صح
import 'package:flutter/material.dart';

class HomeMainView extends StatefulWidget {
  const HomeMainView({super.key});

  @override
  State<HomeMainView> createState() => _HomeMainViewState();
}

class _HomeMainViewState extends State<HomeMainView> {
  @override
  void initState() {
    super.initState();
    // 🚀 تحديث التوكن أول ما اليوزر يدخل الهوم (ويب أو موبايل)
    AuthService().updateFCMToken();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return const HomeWebView();
        } else {
          return const HomeMobileView();
        }
      },
    );
  }
}
