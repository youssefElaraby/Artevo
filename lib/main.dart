import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // ✅ مهمة للـ PlatformDispatcher
import 'package:firebase_crashlytics/firebase_crashlytics.dart'; // ✅ مكتبة الكراش
import 'package:art_by_hager_ismail/core/resources/internet_magic_handler.dart';
import 'package:art_by_hager_ismail/feature/home/presentation/mobile/view_model/home_user_cubit.dart';
import 'package:art_by_hager_ismail/feature/portfolio/view_model/portfolio_cubit.dart';
import 'package:art_by_hager_ismail/services/auth_service.dart';
import 'package:art_by_hager_ismail/services/booking_service.dart';
import 'package:art_by_hager_ismail/services/home_services.dart';
import 'package:art_by_hager_ismail/services/push_notificationservice/push_notification_service.dart';
import 'package:art_by_hager_ismail/services/user_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'feature/authentication/sign_up/view_model/auth_view_model.dart';
import 'feature/booking/view_model/booking/booking_cubit.dart';
import 'feature/booking/view_model/session/user_sessions_cubit.dart';
import 'firebase_options.dart';
import 'core/resources/application_theme_manager.dart';
import 'core/route_manager/route_generator.dart';
import 'core/route_manager/routes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("📩 إشعار في الخلفية: ${message.messageId}");
}

void main() async {
  // ✅ 1. التأكد من تهيئة الـ Widgets
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ 2. قفل تدوير الشاشة
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ✅ 3. تهيئة فايربيز
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ 4. إعدادات Crashlytics (تسجيل الأخطاء)
  // تسجيل أخطاء Flutter Framework
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // تسجيل الأخطاء اللي بتحصل بره Flutter (Async errors)
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // ✅ 5. تهيئة الإشعارات والـ Localization والـ Hive
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await PushNotificationService.initialize();
  await initializeDateFormatting('ar', null);
  await initializeDateFormatting('en', null);
  await Hive.initFlutter();
  await Hive.openBox('portfolio_cache');

  runApp(const ArtByHagerApp());
}

class ArtByHagerApp extends StatelessWidget {
  const ArtByHagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ScreenUtilInit(
          designSize: constraints.maxWidth > 950
              ? const Size(1920, 1080)
              : const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MultiBlocProvider(
              providers: [
                BlocProvider<AuthCubit>(
                  create: (_) => AuthCubit(AuthService()),
                ),
                BlocProvider<UserSessionsCubit>(
                  create: (_) =>
                      UserSessionsCubit(UserSessionService())..fetchSessions(),
                ),
                BlocProvider<BookingCubit>(
                  create: (_) =>
                      BookingCubit(BookingService(), UserSessionService()),
                ),
                BlocProvider<PortfolioCubit>(create: (_) => PortfolioCubit()),
                BlocProvider<HomeUserCubit>(
                  lazy: false,
                  create: (_) => HomeUserCubit(HomeUserService())..initHome(),
                ),
              ],
              child: MaterialApp(
                navigatorKey: navigatorKey,
                debugShowCheckedModeBanner: false,
                title: 'Artevo',
                theme: ApplicationThemeManager.themeData,
                initialRoute: PageRoutesName.homeMainView,
                onGenerateRoute: RoutesGenerator.onGenerateRoutes,
                builder: (context, child) {
                  // 🚀 السحر هنا: تغليف الأبلكيشن بالـ Wrapper اللي بيعمل الـ Glitch والموجة
                  return InternetMagicWrapper(
                    child: MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(textScaler: TextScaler.noScaling),
                      child: child!,
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
