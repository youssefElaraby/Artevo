import 'package:art_by_hager_ismail/feature/home/presentation/mobile/view_model/home_user_cubit.dart';
import 'package:art_by_hager_ismail/feature/home/presentation/mobile/view_model/home_user_state.dart';
import 'package:art_by_hager_ismail/feature/home/presentation/mobile/widget/event_home_card.dart';
import 'package:art_by_hager_ismail/feature/home/presentation/web/widget/web_footer.dart';
import 'package:art_by_hager_ismail/feature/home/presentation/web/widget/web_stories_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/route_manager/routes.dart';
import '../../../model/home_settings_model.dart';
import '../widget/Social_fab.dart';
import '../widget/cta_booking_button.dart';
import '../widget/custom_drawer.dart';
import '../widget/portfolio_preview.dart';
import '../widget/home_promo_dialog.dart';

class HomeMobileView extends StatelessWidget {
  const HomeMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeUserCubit, HomeUserState>(
      listenWhen: (previous, current) {
        if (current is HomeUserSuccess && previous is HomeUserSuccess) {
          return (previous.popups == null || previous.popups!.isEmpty) &&
              (current.popups != null && current.popups!.isNotEmpty);
        }
        return current is HomeUserSuccess && previous is! HomeUserSuccess;
      },
      listener: (context, state) {
        if (state is HomeUserSuccess &&
            state.popups != null &&
            state.popups!.isNotEmpty) {
          final promo = state.popups!.first;
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => HomePromoDialog(
              imageUrl: promo.popupImageUrl ?? '',
              title: promo.popupTitle ?? '',
            ),
          );
        }
      },
      child: Scaffold(
        drawer: const CustomDrawer(),
        backgroundColor: const Color(0xFFF4ECE1),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFF5EEE7), Color(0xFFE8DDCF)],
                  ),
                ),
              ),
              BlocBuilder<HomeUserCubit, HomeUserState>(
                builder: (context, state) {
                  if (state is HomeUserLoading || state is HomeUserInitial) {
                    return _buildFullPageShimmer();
                  }

                  final bool hasEvents =
                      state is HomeUserSuccess &&
                      state.events != null &&
                      state.events!.isNotEmpty;
                  final bool hasGallery =
                      state is HomeUserSuccess &&
                      state.gallery != null &&
                      state.gallery!.isNotEmpty;

                  return CustomScrollView(
                    slivers: [
                      _buildSliverAppBar(context),
                      if (hasEvents) ...[
                        SliverToBoxAdapter(child: _buildStoriesSection(state)),

                        SliverToBoxAdapter(child: _buildEventsSection(state)),
                        SliverToBoxAdapter(
                          child: _buildHeroBanner(context, state),
                        ),
                        if (hasGallery)
                          SliverToBoxAdapter(
                            child: _buildGallerySection(state),
                          ),
                      ] else ...[
                        SliverToBoxAdapter(child: _buildStoriesSection(state)),
                        if (hasGallery)
                          SliverToBoxAdapter(
                            child: _buildGallerySection(state),
                          ),
                        SliverToBoxAdapter(child: _buildFeaturedSection(state)),
                      ],
                      SliverToBoxAdapter(child: _buildWorkshopsSection(state)),
                      SliverToBoxAdapter(child: SizedBox(height: 15.h)),
                      SliverToBoxAdapter(child: const WebFooter()),
                    ],
                  );
                },
              ),
              //هنعطلها مؤقت بس من هنشيلها
              // const SocialFAB(),
              Positioned(
                left: 16.w,
                bottom: 2.h,
                right: 16.w,
                child: CtaBookingButton(
                  onTap: () =>
                      Navigator.pushNamed(context, PageRoutesName.bookingRoute),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context, HomeUserState state) {
    state is HomeUserSuccess &&
        state.popups != null &&
        state.popups!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.r),
          gradient: const LinearGradient(
            colors: [Color(0xFF2F3E34), Color(0xFF475745)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28.r),
          child: Stack(
            children: [
              Positioned(
                top: -20.h,
                left: -20.w,
                child: Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -30.h,
                right: -20.w,
                child: Container(
                  width: 140.w,
                  height: 140.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرسمك الإبداعي',
                      style: TextStyle(
                        fontFamily: 'ElMessiri',
                        fontSize: 24.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'تصفّح القصص، شاهد الأعمال، واحجز ورشتك القادمة.',
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Row(
                      children: [
                        _buildHeroChip('قصص حية', Icons.auto_stories_rounded),
                        SizedBox(width: 10.w),
                        _buildHeroChip(
                          'معرض رقمي',
                          Icons.photo_library_rounded,
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              PageRoutesName.bookingRoute,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE8DDCF),
                              foregroundColor: const Color(0xFF2F3E34),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                            ),
                            child: Text(
                              'احجز ورشة الآن',
                              style: TextStyle(
                                fontFamily: 'ElMessiri',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroChip(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16.sp),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullPageShimmer() {
    return Shimmer(
      duration: const Duration(seconds: 2),
      color: Colors.white,
      colorOpacity: 0.25,
      enabled: true,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
              height: 210.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28.r),
                color: const Color(0xFFD8C9B6),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerHeader(),
                  SizedBox(height: 10.h),
                  Container(
                    height: 120.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.r),
                      color: const Color(0xFFD8C9B6),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildShimmerHeader(),
                  SizedBox(height: 10.h),
                  Container(
                    height: 220.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.r),
                      color: const Color(0xFFD8C9B6),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildShimmerHeader(),
                  SizedBox(height: 10.h),
                  Container(
                    height: 180.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.r),
                      color: const Color(0xFFD8C9B6),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Row(
                    children: [
                      _buildShimmerWorkshopCard(),
                      SizedBox(width: 12.w),
                      _buildShimmerWorkshopCard(),
                    ],
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 160.w,
          height: 18.h,
          decoration: BoxDecoration(
            color: const Color(0xFFD8C9B6),
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 120.w,
          height: 10.h,
          decoration: BoxDecoration(
            color: const Color(0xFFD8C9B6),
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerWorkshopCard() {
    return Expanded(
      child: Container(
        height: 180.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFD8C9B6),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.r),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 90.w,
                    height: 10.h,
                    color: const Color(0xFFD8C9B6),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    width: 60.w,
                    height: 8.h,
                    color: const Color(0xFFD8C9B6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoriesSection(HomeUserState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                WebStoriesBar(
                  dynamicStories: state is HomeUserSuccess
                      ? state.stories
                      : null,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: _sectionHeader(
                    'قصصنا الحية',
                    'استكشف آخر تحديثات الورش والأعمال',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsSection(HomeUserState state) {
    if (state is HomeUserSuccess &&
        state.events != null &&
        state.events!.isNotEmpty) {
      final featuredEvent = state.events!.first;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 9.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: _sectionHeader(
                'فعاليات مميزة',
                'حدث واحد فقط وجدناه يناسبك',
              ),
            ),
            SizedBox(height: 5.h),
            EventHomeCard(event: featuredEvent),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildGallerySection(HomeUserState state) {
    if (state is HomeUserSuccess &&
        state.gallery != null &&
        state.gallery!.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('أعمالنا المختارة', 'أفضل لمحات من معرضنا الرقمي'),
            SizedBox(height: 12.h),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 18.h),
                child: PortfolioPreview(galleryItems: state.gallery),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildWorkshopsSection(HomeUserState state) {
    if (state is HomeUserSuccess && state.workshops != null) {
      final activeWorkshops = state.workshops!.where((w) => w.isShow).toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: _sectionHeader(
              'ورش مرسم',
              'اختر ورشتك التالية من بين عدة خيارات',
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: _buildCategoryChips(),
          ),
          SizedBox(height: 5.h),
          SizedBox(
            height: 240.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              itemCount: activeWorkshops.length,
              separatorBuilder: (context, index) => SizedBox(width: 16.w),
              itemBuilder: (context, index) => SizedBox(
                width: 185.w,
                child: WorkshopGridCard(workshop: activeWorkshops[index]),
              ),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180.h,
      pinned: true,
      backgroundColor: const Color(0xFF2F3E34),
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(
          Icons.notifications_none_rounded,
          color: Color(0xFFE8DDCF),
          size: 28,
        ),
        onPressed: () {
          //تيست كراش بجججج
          // FirebaseCrashlytics.instance.crash();
          final user = FirebaseAuth.instance.currentUser;
          Navigator.pushNamed(
            context,
            PageRoutesName.ActivityRoute,
            arguments: user?.uid,
            
          );
        },
      ),
      actions: [
        Builder(
          builder: (context) => Padding(
            padding: EdgeInsets.only(left: 10.w),
            child: IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: Color(0xFFE8DDCF),
                size: 32,
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          "مَـرسَم",
          style: TextStyle(
            fontFamily: 'ElMessiri',
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE8DDCF),
            fontSize: 25.sp,
          ),
        ),
        background: Stack(
          children: [
            Positioned(
              left: -20.w,
              bottom: 2.h,
              child: Icon(
                Icons.palette_outlined,
                size: 140.r,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final cats = ["ديكور", "رصاص", "زيت", "فخار", "أطفال", "تصميم"];
    return Container(
      height: 44.h,
      margin: EdgeInsets.symmetric(vertical: 6.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        itemCount: cats.length,
        itemBuilder: (context, index) => Container(
          margin: EdgeInsets.only(left: 10.w),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: index == 0 ? const Color(0xFF2F3E34) : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFFE8DDCF)),
          ),
          child: Text(
            cats[index],
            style: TextStyle(
              color: index == 0 ? Colors.white : const Color(0xFF2F3E34),
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(
    String title,
    String sub, {
    bool isShortMargin = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: isShortMargin ? 8.h : 10.h, bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF2F3E34),
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              SizedBox(width: 7.w),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'ElMessiri',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2F3E34),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            sub,
            style: TextStyle(fontSize: 11.sp, color: const Color(0xFF6F624C)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection(HomeUserState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('✨ مختارات المرسم', 'أفضل الأعمال التي نوصيك بها'),
          SizedBox(height: 12.h),
          Builder(
            builder: (context) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF8F0), Color(0xFFFAF5EF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: const Color(0xFFE8DDCF), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: const Color(0xFF2F3E34),
                          size: 24.r,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'استكشف قصتنا الفنية',
                            style: TextStyle(
                              fontFamily: 'ElMessiri',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2F3E34),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'نحن نؤمن بقوة الفن وتأثيره على الحياة اليومية. من خلال ورشنا، ننقل المعرفة والخبرة لكل محب للفن.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF6F624C),
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        PageRoutesName.bookingRoute,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F3E34),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(
                        'اكتشف الآن',
                        style: TextStyle(
                          fontFamily: 'ElMessiri',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WorkshopGridCard extends StatelessWidget {
  final WorkshopModel workshop;
  const WorkshopGridCard({super.key, required this.workshop});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, PageRoutesName.bookingRoute);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
                child: CachedNetworkImage(
                  imageUrl: workshop.imageUrl ?? '',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer(
                    duration: const Duration(seconds: 2),
                    color: Colors.grey[300]!,
                    child: Container(color: Colors.grey[200]),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xFFF3EFE9),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            color: const Color(0xFF2F3E34).withOpacity(0.4),
                            size: 30.sp,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "لا يوجد اتصال",
                            style: TextStyle(
                              fontSize: 8.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workshop.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2F3E34),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ابدأ الآن',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: const Color(0xFF6F624C),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4ECE1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12.sp,
                          color: const Color(0xFF2F3E34),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
