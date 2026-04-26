import 'package:art_by_hager_ismail/feature/portfolio/model/portfolio_model.dart';
import 'package:art_by_hager_ismail/feature/portfolio/view_model/portfolio_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widget/portfolio_header.dart';
import '../widget/user_profile_header.dart';
import '../widget/user_stats_section.dart';
import '../widget/user_services_section.dart';
import '../widget/user_skills_section.dart';
import '../widget/user_gallery_section.dart';

class PortfolioView extends StatelessWidget {
  const PortfolioView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final cubit = context.read<PortfolioCubit>();

    return Scaffold(
      backgroundColor: const Color(0xFFE8DDCF),
      body: Directionality(
        textDirection: TextDirection.rtl, // لسه عربي زي ما إحنا
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 250.h,
              pinned: true,
              backgroundColor: const Color(0xFF2F3E34),
              automaticallyImplyLeading: false, // لغينا أي زرار أوتوماتيك
              // 1. زرار الرجوع في الـ actions عشان يظهر "شمال" في العربي
              actions: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    // حساب حالة السكرول (هنا بنستخدم ارتفاع السليفر)
                    return Padding(
                      padding: EdgeInsets.only(
                        left: 15.w,
                        top: 10.h,
                        bottom: 10.h,
                      ),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 70.w, // كبرناه سنة
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // فتحنا اللون الأبيض جداً عشان ينور
                            color: Colors.white.withOpacity(0.25),
                            border: Border.all(
                              color: Colors.white.withOpacity(
                                0.5,
                              ), // برواز أبيض فاتح
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_circle_left_sharp,
                            color: Colors.white, // السهم أبيض صريح عشان يبان
                            size: 22,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],

              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                ),
              ),

              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Stack(
                  children: [
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: PortfolioHeader(),
                    ),
                    Positioned(
                      bottom: 25.h,
                      right: 20.w,
                      left: 20.w,
                      child: StreamBuilder<ProfileModel>(
                        stream: cubit.getProfileStream(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox();
                          return UserProfileHeader(
                            profile: snapshot.data!,
                            isMobile: isMobile,
                            isCollapsed: false,
                          );
                        },
                      ),
                    ),
                  ],
                ),

                centerTitle: false,
                titlePadding: EdgeInsets.zero,
                title: LayoutBuilder(
                  builder: (context, constraints) {
                    bool isCollapsed =
                        constraints.maxHeight <=
                        kToolbarHeight +
                            MediaQuery.of(context).padding.top +
                            10;
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isCollapsed ? 1.0 : 0.0,
                      child: isCollapsed
                          ? Padding(
                              // البادينج اليمين عشان يبعد عن الـ actions اللي بقت على الشمال
                              padding: EdgeInsets.only(
                                right: 20.w,
                                bottom: 12.h,
                              ),
                              child: StreamBuilder<ProfileModel>(
                                stream: cubit.getProfileStream(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData)
                                    return const SizedBox();
                                  return UserProfileHeader(
                                    profile: snapshot.data!,
                                    isMobile: isMobile,
                                    isCollapsed: true,
                                  );
                                },
                              ),
                            )
                          : const SizedBox(),
                    );
                  },
                ),
              ),
            ),

            // ... (باقي الـ SliverPadding والمحتوى زي ما هو)
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 25.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  StreamBuilder<List<StatCardModel>>(
                    stream: cubit.getStatsStream(),
                    builder: (context, snapshot) =>
                        UserStatsSection(stats: snapshot.data ?? []),
                  ),
                  SizedBox(height: 30.h),
                  StreamBuilder<List<ServiceModel>>(
                    stream: cubit.getServicesStream(),
                    builder: (context, snapshot) =>
                        UserServicesSection(services: snapshot.data ?? []),
                  ),
                  SizedBox(height: 30.h),
                  StreamBuilder<List<SkillModel>>(
                    stream: cubit.getSkillsStream(),
                    builder: (context, snapshot) =>
                        UserSkillsSection(skills: snapshot.data ?? []),
                  ),
                  SizedBox(height: 35.h),
                  StreamBuilder<List<ArtworkModel>>(
                    stream: cubit.getArtworksStream(),
                    builder: (context, snapshot) => UserGallerySection(
                      artworks: snapshot.data ?? [],
                      isMobile: isMobile,
                      isWeb: width > 1000,
                    ),
                  ),
                  SizedBox(height: 100.h),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
