import 'package:art_by_hager_ismail/feature/booking/model/session_model.dart';
import 'package:art_by_hager_ismail/feature/booking/view_model/session/user_sessions_cubit.dart';
import 'package:art_by_hager_ismail/feature/booking/view_model/session/user_sessions_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'web_booking_form_details.dart';

class WebBookingView extends StatefulWidget {
  const WebBookingView({super.key});

  @override
  State<WebBookingView> createState() => _WebBookingViewState();
}

class _WebBookingViewState extends State<WebBookingView> {
  SessionModel? selectedSession;
  bool isPrivate = false;

  @override
  void initState() {
    super.initState();
    context.read<UserSessionsCubit>().fetchSessions();
  }

  void _resetSelection() {
    setState(() {
      selectedSession = null;
      isPrivate = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocBuilder<UserSessionsCubit, UserSessionsState>(
        builder: (context, state) {
          if (state is UserSessionsLoading) {
            return const SizedBox(
              height: 300,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF2F3E34)),
              ),
            );
          }

          if (state is UserSessionsLoaded) {
            final allItemsFromFirebase = state.sessions;
            final allItems = [
              ...allItemsFromFirebase,
              // _getPrivatePlaceholder(),
            ];

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: (selectedSession == null && !isPrivate)
                  ? _buildLocationsGrid(allItems)
                  : _buildBookingForm(),
            );
          }

          return const Center(child: Text("حدث خطأ في تحميل البيانات"));
        },
      ),
    );
  }

  // 1. واجهة اختيار المكان (الشبكة)
  Widget _buildLocationsGrid(List<SessionModel> items) {
    return Column(
      key: const ValueKey('grid'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _sectionHeader(
          "أين تود أن تبدأ رحلتك؟ 📍",
          "اختر استوديو أو احجز جلسة خاصة",
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 25,
            runSpacing: 25,
            alignment: WrapAlignment.center,
            children: items
                .map(
                  (session) => SizedBox(
                    width: 360,
                    child: _locationCard(session, session.id == 'private'),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 50),
      ],
    );
  }

  // 2. واجهة الفورم
  Widget _buildBookingForm() {
    return Column(
      key: const ValueKey('form'),
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextButton.icon(
            onPressed: _resetSelection,
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 16,
              color: Color(0xFF9C5A1A),
            ),
            label: const Text(
              "العودة لاختيار مكان آخر",
              style: TextStyle(
                color: Color(0xFF9C5A1A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        WebBookingFormDetails(
          isPrivate: isPrivate,
          selectedSession: selectedSession,
          onBookingSuccess: _resetSelection,
        ),
      ],
    );
  }

  Widget _locationCard(SessionModel session, bool isPriv) {
    int available = session.capacity - session.bookedCount;
    bool isFull = !isPriv && (available <= 0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            child: Image.network(
              session.image,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                height: 200,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF2F3E34),
                    fontFamily: 'ElMessiri',
                  ),
                ),
                const SizedBox(height: 12),
                if (!isPriv) ...[
                  _infoRow(Icons.event, "${session.dayName} - ${session.date}"),
                  _infoRow(
                    Icons.access_time,
                    "يبدأ الساعة: ${session.startTime}",
                  ),
                  _infoRow(Icons.payments, "${session.price} ج.م"),
                  _infoRow(
                    Icons.people,
                    isFull ? "مكتمل العدد" : "المتبقي: $available أماكن",
                    color: isFull ? Colors.red : Colors.green,
                  ),
                ] else ...[
                  const Text(
                    "جلسة خاصة في مكانك المفضل..",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: isFull
                            ? null
                            : () {
                                setState(() {
                                  selectedSession = isPriv ? null : session;
                                  isPrivate = isPriv;
                                });
                                Scrollable.ensureVisible(context);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F3E34),
                          disabledBackgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isFull ? "مكتمل العدد" : "احجز الآن",
                          style: const TextStyle(
                            fontFamily: 'ElMessiri',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (!isPriv && session.locationUrl.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF9C5A1A).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () async {
                            final Uri url = Uri.parse(session.locationUrl);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          },
                          icon: const Icon(Icons.location_on_rounded),
                          color: const Color(0xFF9C5A1A),
                          tooltip: "عرض الموقع",
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF9C5A1A)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color ?? const Color(0xFF2F3E34),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String sub) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              fontFamily: 'ElMessiri',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // SessionModel _getPrivatePlaceholder() {
  //   return SessionModel(
  //     id: 'private',
  //     name: "جلسة خاصة",
  //     image:
  //         "https://images.unsplash.com/photo-1460666819451-e16112033c4d?q=80&w=2000",
  //     details: "",
  //     locationUrl: "",
  //     dayName: "",
  //     date: "",
  //     startTime: "",
  //     duration: "",
  //     price: 0,
  //     capacity: 1,
  //     bookedCount: 0,
  //     isSuppliesIncluded: true,
  //     isVisible: true,
  //     isAcceptingBookings: true,
  //   );
  // }
}
