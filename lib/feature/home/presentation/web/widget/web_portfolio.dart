import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:art_by_hager_ismail/feature/portfolio/view_model/portfolio_cubit.dart';
import 'package:art_by_hager_ismail/feature/portfolio/model/portfolio_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart'; // ✅ للرص الاحترافي
import 'package:flutter_tilt/flutter_tilt.dart'; // ✅ لتأثير اللوحة الطائرة

class WebPortfolioView extends StatelessWidget {
  const WebPortfolioView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PortfolioCubit>();

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 700;
        bool isTablet =
            constraints.maxWidth >= 700 && constraints.maxWidth < 1100;

        return Column(
          children: [
            // --- 1. Hero Profile Section ---
            StreamBuilder<ProfileModel>(
              stream: cubit.getProfileStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return _buildHeroSection(context, snapshot.data!, isMobile);
              },
            ),

            // --- 2. Stats Section ---
            StreamBuilder<List<StatCardModel>>(
              stream: cubit.getStatsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                return _buildStatsStrip(snapshot.data!, isMobile);
              },
            ),

            // --- 3. Skills Section ---
            StreamBuilder<List<SkillModel>>(
              stream: cubit.getSkillsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                return _buildSkillsSection(snapshot.data!, isMobile);
              },
            ),

            // --- 4. Gallery Section (The 3D Floating Gallery) ---
            StreamBuilder<List<ArtworkModel>>(
              stream: cubit.getArtworksStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                return _buildGallerySection(
                  context,
                  snapshot.data!,
                  isMobile,
                  isTablet,
                );
              },
            ),

            _buildFooter(),
          ],
        );
      },
    );
  }

  // --- الهيرو بدون خلفيات صريحة ---
  Widget _buildHeroSection(
    BuildContext context,
    ProfileModel profile,
    bool isMobile,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 80.h,
        horizontal: isMobile ? 20.w : 100.w,
      ),
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Tilt(
            tiltConfig: const TiltConfig(angle: 10, enableRevert: true),
            child: Hero(
              tag: 'profile_pic',
              child: Container(
                width: isMobile ? 180.r : 300.r,
                height: isMobile ? 180.r : 300.r,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isMobile ? 100 : 40),
                  image: DecorationImage(
                    image: NetworkImage(profile.imageUrl),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9C5A1A).withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 60.w, height: 40.h),
          Expanded(
            flex: isMobile ? 0 : 1,
            child: Column(
              crossAxisAlignment: isMobile
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  "الفنانة التشكيلية",
                  style: TextStyle(
                    color: const Color(0xFF9C5A1A),
                    letterSpacing: 3,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  profile.name,
                  style: TextStyle(
                    fontFamily: 'ElMessiri',
                    fontSize: isMobile ? 35.sp : 55.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2F3E34),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  profile.bio,
                  textAlign: isMobile ? TextAlign.center : TextAlign.start,
                  style: TextStyle(
                    fontSize: 18.sp,
                    height: 1.6,
                    color: const Color(0xFF6F624C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsStrip(List<StatCardModel> stats, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h),
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(
            color: const Color(0xFF2F3E34).withOpacity(0.1),
          ),
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: isMobile ? 30.w : 100.w,
        runSpacing: 20.h,
        children: stats
            .map(
              (s) => Column(
                children: [
                  Text(
                    s.value,
                    style: TextStyle(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2F3E34),
                    ),
                  ),
                  Text(
                    s.title,
                    style: const TextStyle(
                      color: Color(0xFF9C5A1A),
                      fontWeight: FontWeight.w600,),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildSkillsSection(List<SkillModel> skills, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 80.h,
        horizontal: isMobile ? 20.w : 100.w,
      ),
      color: const Color(0xFF2F3E34),
      child: Column(
        children: [
          Text(
            "الخبرات الفنية",
            style: TextStyle(
              fontFamily: 'ElMessiri',
              fontSize: 35.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 50.h),
          Wrap(
            spacing: 20.w,
            runSpacing: 20.h,
            alignment: WrapAlignment.center,
            children: skills
                .map(
                  (s) => Container(
                    width: isMobile ? double.infinity : 300.w,
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              s.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${s.percentage}%",
                              style: const TextStyle(color: Color(0xFF9C5A1A)),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        LinearProgressIndicator(
                          value: s.percentage / 100,
                          backgroundColor: Colors.white10,
                          color: const Color(0xFF9C5A1A),
                          minHeight: 6,
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // --- سيكشن الجاليري المجرم ---
  Widget _buildGallerySection(
    BuildContext context,
    List<ArtworkModel> artworks,
    bool isMobile,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 100.h,
        horizontal: isMobile ? 15.w : 60.w,
      ),
      child: Column(
        children: [
          Text(
            "C U R A T E D  W O R K S",
            style: TextStyle(
              letterSpacing: 8,
              fontSize: 14.sp,
              color: const Color(0xFF9C5A1A),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 60.h),
          MasonryGridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
            mainAxisSpacing: 30,
            crossAxisSpacing: 30,
            itemCount: artworks.length,
            itemBuilder: (context, index) {
              return _artworkFloatingCard(context, artworks[index]);
            },
          ),
        ],
      ),
    );
  }

  // --- ويدجت اللوحة الطائرة (الاحترافية) ---
  Widget _artworkFloatingCard(BuildContext context, ArtworkModel art) {
    return Tilt(
      tiltConfig: const TiltConfig(
        angle: 15,
        enableRevert: true,
        moveDuration: Duration(milliseconds: 500),
      ),
      lightConfig: const LightConfig(
        color: Colors.white,
        minIntensity: 0.1,
        maxIntensity: 0.4,
      ),
      shadowConfig: ShadowConfig(
        color: Colors.black.withOpacity(0.2),
        minBlurRadius: 25,
        maxBlurRadius: 40,),
      child: GestureDetector(
        onTap: () => _showLightbox(context, art.images.first),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFF2F3E34).withOpacity(0.1),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(art.images.first, fit: BoxFit.cover),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    art.title,
                    style: TextStyle(
                      fontFamily: 'ElMessiri',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2F3E34),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    art.description,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF6F624C),
                      fontFamily: 'Tajawal',
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLightbox(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.black87),
            ),
          ),
          Center(child: InteractiveViewer(child: Image.network(url))),
          Positioned(
            top: 40,
            right: 40,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 40),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: const Center(
        child: Text(
          "© 2026 مَـرسَم - هاجر إسماعيل | سحر الفن في كل تفصيلة",
          style: TextStyle(
            color: Colors.grey,
            fontFamily: 'Tajawal',
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
