import 'package:art_by_hager_ismail/feature/booking/model/session_model.dart';
import 'package:art_by_hager_ismail/feature/booking/view_model/session/user_sessions_cubit.dart';
import 'package:art_by_hager_ismail/feature/booking/view_model/session/user_sessions_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widget/booking_details_form.dart';
import '../../../../services/user_session_service.dart';

class BookingView extends StatefulWidget {
  const BookingView({super.key});

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> {
  // شلنا الـ isMobile لأننا مش محتاجين نتحكم في الـ Drawer دلوقتي

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          UserSessionsCubit(UserSessionService())..fetchSessions(),
      child: Scaffold(
        backgroundColor: const Color(0xFFE8DDCF),
        // ✅ تم حذف الـ Drawer تماماً من هنا
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 170.h,
                    pinned: true,
                    stretch: true,
                    backgroundColor: const Color(0xFF2F3E34),
                    // ✅ تم إلغاء السهم الأوتوماتيكي عشان ميسحبش الدروار
                    automaticallyImplyLeading: false,
                    actions: [_buildBackButton()],
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      stretchModes: const [
                        StretchMode.zoomBackground,
                        StretchMode.blurBackground,
                      ],
                      centerTitle: false,
                      titlePadding: EdgeInsetsDirectional.only(
                        start: 20.w,
                        bottom: 15.h,
                      ),
                      title: LayoutBuilder(
                        builder: (context, constraints) {
                          bool isCollapsed =
                              constraints.maxHeight <=
                              kToolbarHeight +
                                  MediaQuery.of(context).padding.top +
                                  20;
                          return AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontFamily: 'ElMessiri',
                              fontWeight: FontWeight.bold,
                              fontSize: isCollapsed ? 18.sp : 24.sp,
                              color: const Color(0xFFE8DDCF),
                            ),
                            child: Text(
                              "حجز موعد",
                              style: TextStyle(fontSize: 18.sp),
                            ),
                          );
                        },
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Positioned(
                            left: -15.w,
                            bottom: -5.h,
                            child: Icon(
                              Icons.palette_outlined,
                              size: 150.r,
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 80.h, right: 25.w),
                            child: Opacity(
                              opacity: 0.8,
                              child: Text(
                                "ابدأ رحلتك الفنية الآن..\nاختر المكان والزمان المناسبين.",
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: Colors.white70,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 25.h)),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    sliver: BlocBuilder<UserSessionsCubit, UserSessionsState>(
                      builder: (context, state) {
                        if (state is UserSessionsLoading) {
                          return const SliverToBoxAdapter(
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF2F3E34),
                              ),
                            ),
                          );
                        } else if (state is UserSessionsLoaded) {
                          return SliverList(
                            delegate: SliverChildListDelegate([
                              _sectionTitle("الاستوديوهات المتاحة"),
                              SizedBox(height: 15.h),
                              ...state.sessions.map(
                                (session) => _slotCard(session),
                              ),
                              SizedBox(height: 35.h),
                              _sectionTitle("حجز خاص"),
                              SizedBox(height: 10.h),
                              _privateBookingButton(),
                              SizedBox(height: 120.h),
                            ]),
                          );
                        } else if (state is UserSessionsError) {
                          return SliverToBoxAdapter(
                            child: Center(child: Text(state.message)),
                          );
                        }
                        return const SliverToBoxAdapter(
                          child: SizedBox.shrink(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: EdgeInsets.only(left: 15.w, top: 8.h, bottom: 8.h),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 42.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.12),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFFE8DDCF),
            size: 23,
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: const Color(0xFF9C5A1A),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'ElMessiri',
            fontSize: 19.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF2F3E34),
          ),
        ),
      ],
    );
  }

  Widget _slotCard(SessionModel session) {
    int availableSlots = session.capacity - session.bookedCount;
    bool isFull = availableSlots <= 0;

    return Container(
      margin: EdgeInsets.only(bottom: 20.h, left: 8.w, right: 8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: isFull
                ? Colors.black.withOpacity(0.05)
                : const Color(0xFF2F3E34).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: InkWell(
        onTap: !isFull ? () => _openBookingDetails(session) : null,
        borderRadius: BorderRadius.circular(30.r),
        child: Opacity(
          opacity: isFull ? 0.7 : 1.0,
          child: Padding(
            padding: EdgeInsets.all(15.r),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22.r),
                        border: Border.all(
                          color: const Color(0xFFE8DDCF).withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(21.r),
                        child: Image.network(
                          session.image,
                          width: 100.w,
                          height: 100.w,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.image_not_supported,
                            size: 50.r,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF2F3E34),
                              fontFamily: 'ElMessiri',
                            ),
                          ),
                          SizedBox(height: 10.h),
                          _buildDetailRow(
                            Icons.calendar_today_rounded,
                            session.dayName,
                          ),
                          SizedBox(height: 6.h),
                          _buildDetailRow(
                            Icons.access_time_filled_rounded,
                            "الساعة ${session.startTime}",
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9C5A1A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15.r),
                        border: Border.all(
                          color: const Color(0xFF9C5A1A).withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "${session.price}",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF9C5A1A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "ج.م",
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: const Color(0xFF9C5A1A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _locationButton(session.locationUrl),
                    _statusBadge(isFull, availableSlots),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _locationButton(String locationUrl) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final Uri url = Uri.parse(locationUrl);
          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
            _showToast("تعذر فتح الخريطة");
          }
        },
        borderRadius: BorderRadius.circular(15.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: const Color(0xFF2F3E34),
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Row(
            children: [
              Icon(Icons.map_rounded, color: Colors.white, size: 18.r),
              SizedBox(width: 8.w),
              Text(
                "موقعنا",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(bool isFull, int availableSlots) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: !isFull
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            !isFull ? Icons.check_circle : Icons.error_outline,
            size: 14.r,
            color: !isFull ? Colors.green[800] : Colors.red[800],
          ),
          SizedBox(width: 6.w),
          Text(
            !isFull ? "متاح $availableSlots مقاعد" : "مكتملة تماماً",
            style: TextStyle(
              fontSize: 12.sp,
              color: !isFull ? Colors.green[800] : Colors.red[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xFF2F3E34),
      textColor: Colors.white,
      fontSize: 14.sp,
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.r, color: const Color(0xFF9C5A1A)),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _privateBookingButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF2F3E34), Color(0xFF1B261F)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F3E34).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openBookingDetails(null, isPrivate: true),
          borderRadius: BorderRadius.circular(24.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 18.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_border_rounded, color: Color(0xFFE8DDCF)),
                SizedBox(width: 10.w),
                Text(
                  "طلب جلسة خاصة",
                  style: TextStyle(
                    fontFamily: 'ElMessiri',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE8DDCF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openBookingDetails(SessionModel? session, {bool isPrivate = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.90,
        decoration: const BoxDecoration(
          color: Color(0xFFE8DDCF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 45.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFF2F3E34).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              child: BookingDetailsForm(
                isPrivate: isPrivate,
                selectedSession: session,
                requirePayment: true,
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      if (mounted) {
        context.read<UserSessionsCubit>().fetchSessions();
      }
    });
  }
}
