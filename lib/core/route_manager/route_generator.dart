import 'package:art_by_hager_ismail/core/route_manager/routes.dart';
import 'package:art_by_hager_ismail/feature/authentication/sign_in/view/sign_in_view.dart';
import 'package:art_by_hager_ismail/feature/authentication/sign_up/view/sign_up_view.dart';
import 'package:art_by_hager_ismail/feature/home/presentation/main/home_main_view.dart';
import 'package:art_by_hager_ismail/feature/home/presentation/web/view/home_web_view.dart';
import 'package:flutter/material.dart';

// تأكد من صحة هذا المسار أو استبدله بـ package import
import 'package:art_by_hager_ismail/feature/home/presentation/mobile/view/home_mobile_view.dart';

import '../../feature/activity/view/activity_view.dart';
import '../../feature/booking/view/booking_view.dart';
import '../../feature/portfolio/view/portfolio_view.dart';

class RoutesGenerator {
  static Route<dynamic> onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case PageRoutesName.initialHome:
      case PageRoutesName.homeMainView:
        return MaterialPageRoute(
          builder: (context) => const HomeMainView(),
          settings: settings,
        );

      case PageRoutesName.portfolioRoute:
        return MaterialPageRoute(
          builder: (context) => const PortfolioView(),
          settings: settings,
        );

      case PageRoutesName.bookingRoute:
        return MaterialPageRoute(
          builder: (context) => const BookingView(),
          settings: settings,
        );

      case PageRoutesName.ActivityRoute:
        final String? userId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (context) => ActivityView(userId: userId),
          settings: settings,
        );

      case PageRoutesName.signInRoute:
        return MaterialPageRoute(
          builder: (context) => const SignInView(),
          settings: settings,
        );

      case PageRoutesName.signUpRoute:
        return MaterialPageRoute(
          builder: (context) => const SignUpView(),
          settings: settings,
        );

      case PageRoutesName.homeWebView:
        return MaterialPageRoute(
          builder: (context) => HomeWebView(),
          settings: settings,
        );

      case PageRoutesName.homeMobileView:
        return MaterialPageRoute(
          builder: (context) => HomeMobileView(), // شيلنا الـ const هنا
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (context) => const HomeMainView(),
          settings: settings,
        );
    }
  }
}
