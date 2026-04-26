import 'package:art_by_hager_ismail/feature/home/presentation/mobile/view_model/home_user_cubit.dart';
import 'package:art_by_hager_ismail/feature/home/presentation/mobile/view_model/home_user_state.dart';
import 'package:art_by_hager_ismail/feature/home/presentation/web/widget/web-workshops_grid.dart';
import 'package:art_by_hager_ismail/feature/home/presentation/web/widget/web_booking_view.dart';
import 'package:art_by_hager_ismail/feature/home/presentation/web/widget/web_portfolio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:art_by_hager_ismail/feature/home/presentation/web/widget/web_activities_grid.dart';
import 'package:art_by_hager_ismail/feature/home/presentation/web/widget/web_features_grid.dart';
import 'package:art_by_hager_ismail/feature/home/presentation/web/widget/web_footer.dart';
import 'package:art_by_hager_ismail/feature/home/presentation/web/widget/web_hero.dart';
import 'package:art_by_hager_ismail/feature/home/presentation/web/widget/web_navbar.dart';
import 'package:art_by_hager_ismail/feature/home/presentation/web/widget/web_stories_bar.dart';
// ✅ استيراد الـ Popup الجديد
import 'package:art_by_hager_ismail/feature/home/presentation/web/widget/web_announcement_dialog.dart';

class HomeWebView extends StatefulWidget {
  const HomeWebView({super.key});

  @override
  State<HomeWebView> createState() => _HomeWebViewState();
}

class _HomeWebViewState extends State<HomeWebView> {
  String currentTab = 'home';
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _popupShown = false; // ✅ لمنع تكرار فتح الـ Popup

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (!mounted) return;
      if (_scrollController.offset > 50 && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.offset <= 50 && _isScrolled) {
        setState(() => _isScrolled = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void changeTab(String tabId) {
    if (currentTab == tabId) return;
    setState(() => currentTab = tabId);
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidePadding = screenWidth > 1400 ? screenWidth * 0.06 : 35.0;

    return BlocConsumer<HomeUserCubit, HomeUserState>(
      // ✅ الـ Listener لمراقبة حالة الـ Success وفتح الـ Popup
      listener: (context, state) {
        if (state is HomeUserSuccess &&
            state.popups != null &&
            state.popups!.isNotEmpty &&
            !_popupShown) {
          final activePopup = state.popups!.first;
          if (activePopup.showPopup) {
            _popupShown = true; // علامة إنه ظهر خلاص
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) showWebAnnouncement(context, activePopup, changeTab);
            });
          }
        }
      },
      builder: (context, state) {
        final bool isSuccess = state is HomeUserSuccess;
        final stories = isSuccess ? state.stories : null;
        final events = isSuccess ? state.events : null;
        final galleryItems = isSuccess ? state.gallery : null;
        final workshops = isSuccess ? state.workshops : null;

        return Scaffold(
          backgroundColor: const Color(0xFFE8DDCF),
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      const SizedBox(height: 120),

                      if (currentTab == 'home')
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: sidePadding,
                          ),
                          child: WebStoriesBar(dynamicStories: stories),
                        ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: sidePadding),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: _buildTabContent(
                            events,
                            galleryItems,
                            workshops,
                            state,
                          ),
                        ),
                      ),

                      const SizedBox(height: 80),
                      const WebFooter(),
                    ],
                  ),
                ),

                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: WebNavbar(
                    currentTab: currentTab,
                    onTabChanged: changeTab,
                    isScrolled: _isScrolled,
                  ),
                ),

                if (state is HomeUserLoading)
                  const Positioned(
                    top: 100,
                    left: 20,
                    child: CircularProgressIndicator(color: Color(0xFF9C5A1A)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabContent(
    dynamic events,
    dynamic gallery,
    dynamic workshops,
    HomeUserState state,
  ) {
    switch (currentTab) {
      case 'home':
        return Column(
          key: const ValueKey('home'),
          children: [
            WebHero(
              onLoginRedirect: () => changeTab('booking'),
              event: (events != null && events.isNotEmpty)
                  ? events.first
                  : null,
              galleryItems: gallery,
            ),

            _sectionHeader(
              "ورش العمل والدروس",
              "انضم إلينا وتعلم فنون الرسم باحترافية",
            ),

            WebWorkshopsGrid(
              workshops: workshops,
              onBookingTap: () => changeTab('booking'),
            ),

            _sectionHeader(
              "مميزات المرسم",
              "بيئة إبداعية متكاملة لتطوير مهاراتك",
            ),
            const WebFeaturesGrid(),
          ],
        );
      case 'activities':
        return Column(
          key: const ValueKey('activities'),
          children: [
            _sectionHeader("أنشطة الاستوديو", "متابعة حجوزاتك وذكرياتك الفنية"),
            WebActivitiesGrid(onNavigateToBooking: changeTab),
          ],
        );
      case 'portfolio':
        return const Column(
          key: ValueKey('portfolio'),
          children: [WebPortfolioView()],
        );
      case 'booking':
        return WebBookingView(key: const ValueKey('booking'));
      default:
        return const SizedBox();
    }
  }

  Widget _sectionHeader(String title, String sub) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 3,
            margin: const EdgeInsets.only(bottom: 20),
            color: const Color(0xFF9C5A1A),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'ElMessiri',
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2F3E34),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 19,
              color: Color(0xFF6F624C),
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }
}
