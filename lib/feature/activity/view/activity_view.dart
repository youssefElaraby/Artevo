import 'package:art_by_hager_ismail/feature/booking/view_model/booking/booking_cubit.dart';
import 'package:art_by_hager_ismail/feature/booking/view_model/booking/booking_state.dart';
import 'package:art_by_hager_ismail/feature/booking/model/booking_model.dart'; // تأكد من استيراد الموديل
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../home/presentation/mobile/widget/custom_drawer.dart';
import '../widget/activity_bookings.dart';
import '../widget/activity_feedback.dart';
import '../widget/activity_notifications.dart';

class ActivityView extends StatefulWidget {
  final String? userId;

  const ActivityView({super.key, this.userId});

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool get isMobile => MediaQuery.of(context).size.width < 600;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    Future.microtask(() {
      if (widget.userId != null) {
        context.read<BookingCubit>().fetchBookings(userId: widget.userId!);
      } else {
        context.read<BookingCubit>().emitEmptyBookings();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshBookings() async {
    if (widget.userId != null) {
      await context.read<BookingCubit>().fetchBookings(userId: widget.userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: isMobile ? const CustomDrawer() : null,
      backgroundColor: const Color(0xFFE8DDCF),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 150.h,
                    pinned: true,
                    backgroundColor: const Color(0xFF2F3E34),
                    automaticallyImplyLeading: false,
                    actions: [_buildBackButton()],
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: EdgeInsetsDirectional.only(
                        start: 20.w,
                        bottom: 16.h,
                      ),
                      title: Text(
                        "نشاطاتي",
                        style: TextStyle(
                          fontFamily: 'ElMessiri',
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                          color: const Color(0xFFE8DDCF),
                        ),
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10.h,
                          horizontal: 16.w,
                        ),
                        color: const Color(0xFFE8DDCF),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF2F3E34,
                                ).withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TabBar(
                            controller: _tabController,
                            labelColor: const Color(0xFF2F3E34),
                            unselectedLabelColor: Colors.grey,
                            labelStyle: TextStyle(
                              fontFamily: 'ElMessiri',
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: BoxDecoration(
                              color: const Color(0xFF9C5A1A).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15.r),
                              border: Border(
                                bottom: BorderSide(
                                  color: const Color(0xFF9C5A1A),
                                  width: 2.h,
                                ),
                              ),
                            ),
                            tabs: const [
                              Tab(text: "حجوزاتي"),
                              Tab(text: "الآراء"),
                              Tab(text: "التنبيهات"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: BlocBuilder<BookingCubit, BookingState>(
                builder: (context, state) {
                  if (state is BookingListLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2F3E34),
                      ),
                    );
                  } else if (state is BookingListLoaded) {
                    // 🔥 التعديل الجوهري: ترتيب الحجوزات تنازلياً حسب تاريخ الإنشاء (الأحدث أولاً)
                    final List<BookingModel> sortedBookings = List.from(
                      state.bookings,
                    )..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                    return RefreshIndicator(
                      onRefresh: _refreshBookings,
                      color: const Color(0xFF2F3E34),
                      child: TabBarView(
                        controller: _tabController,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          // نمرر القائمة المرتبة للتابات الفرعية
                          ActivityBookings(bookings: sortedBookings),
                          ActivityFeedback(bookings: sortedBookings),
                          ActivityNotifications(bookings: sortedBookings),
                        ],
                      ),
                    );
                  } else if (state is BookingListError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: EdgeInsets.only(left: 15.w, top: 10.h, bottom: 10.h),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 45.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.2,
            ),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SliverAppBarDelegate({required this.child});

  @override
  double get minExtent => 82.h;
  @override
  double get maxExtent => 82.h;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(
      child: Container(color: const Color(0xFFE8DDCF), child: child),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
