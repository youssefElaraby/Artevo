import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // تأكد من وجود مكتبة intl في الـ pubspec.yaml

class WebActivitiesGrid extends StatelessWidget {
  final Function(String) onNavigateToBooking;

  const WebActivitiesGrid({super.key, required this.onNavigateToBooking});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1️⃣ سيكشن الذكريات (الجلسات المكتملة فقط)
        _buildSectionTitle("ذكرياتك وجلساتك المكتملة ✨"),
        const SizedBox(height: 30),
        _buildApprovedActivitiesGrid(),

        const SizedBox(height: 80),

        // 2️⃣ سيكشن سجل الحجوزات (متابعة الحالة)
        if (user != null) ...[
          _buildSectionTitle("سجل حجوزاتك ومتابعة الحالة 🔍"),
          const SizedBox(height: 30),
          _buildUserBookingsList(user.uid),
        ] else ...[
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text(
                "سجل دخولك لمتابعة حالة حجوزاتك السابقة.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // --- بناء شبكة الذكريات المكتملة ---
  Widget _buildApprovedActivitiesGrid() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("يرجى تسجيل الدخول لمشاهدة ذكرياتك."));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'completed')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2F3E34)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("لا توجد جلسات مكتملة بعد. ابدأ رحلتك الآن! 🎨"),
          );
        }

        // 🔥 الترتيب بـ createdAt للأحدث
        final docs = snapshot.data!.docs;
        docs.sort((a, b) {
          var aTime = a['createdAt'] ?? '';
          var bTime = b['createdAt'] ?? '';
          return bTime.toString().compareTo(aTime.toString());
        });

        return LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 1200
                ? 3
                : (constraints.maxWidth > 800 ? 2 : 1);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 25,
                mainAxisSpacing: 25,
                mainAxisExtent: 580, // زودنا الارتفاع شوية عشان الداتا الجديدة
              ),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                return _buildCreativeActivityCard(data);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCreativeActivityCard(Map<String, dynamic> data) {
    String dateStr = data['date'].toString().split('T')[0];
    String timeStr = data['time'] ?? "--:--";
    String feedback = data['feedback'] ?? "تجربة فنية ملهمة! ✨";
    int ratingNum = int.tryParse(data['rating']?.toString() ?? '5') ?? 5;

    ValueNotifier<bool> isHovered = ValueNotifier(false);

    return MouseRegion(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      cursor: SystemMouseCursors.click,
      child: ValueListenableBuilder<bool>(
        valueListenable: isHovered,
        builder: (context, hovered, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            transform: hovered
                ? (Matrix4.identity()..translate(0, -12, 0))
                : Matrix4.identity(),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: hovered
                      ? Colors.black.withOpacity(0.12)
                      : Colors.black.withOpacity(0.06),
                  blurRadius: hovered ? 30 : 15,
                  offset: hovered ? const Offset(0, 15) : const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                  child: Image.network(
                    data['paymentImageUrl'] ??
                        'https://via.placeholder.com/300',
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              data['placeName'] ?? 'جلسة فنية',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2F3E34),
                                fontFamily: 'ElMessiri',
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 22,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            Icons.star,
                            color: i < ratingNum
                                ? Colors.amber
                                : Colors.grey[300],
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _infoRow(
                        Icons.calendar_today_rounded,
                        "التاريخ: $dateStr",
                      ),
                      const SizedBox(height: 10),
                      _infoRow(Icons.watch_later_rounded, "الوقت: $timeStr"),
                      const Divider(height: 35, color: Color(0xFFE8DDCF)),
                      const Text(
                        "رأيك المكتوب:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9C5A1A),
                          fontSize: 14,
                          fontFamily: 'ElMessiri',
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 70,
                        child: SingleChildScrollView(
                          child: Text(
                            feedback,
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 14,
                              height: 1.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6F624C)),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF6F624C),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // --- بناء سجل الحجوزات ---
  Widget _buildUserBookingsList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const SizedBox();
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return const Center(child: Text("لم تقم بأي حجوزات بعد."));

        // 🔥 الترتيب بـ createdAt للأحدث في سجل الحجوزات
        final docs = snapshot.data!.docs;
        docs.sort((a, b) {
          var aTime = a['createdAt'] ?? '';
          var bTime = b['createdAt'] ?? '';
          return bTime.toString().compareTo(aTime.toString());
        });

        return Column(
          children: docs
              .map(
                (doc) => WebBookingCard(
                  booking: doc.data() as Map<String, dynamic>,
                  docId: doc.id,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF9C5A1A),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 15),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'ElMessiri',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2F3E34),
          ),
        ),
      ],
    );
  }
}

class WebBookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final String docId;
  const WebBookingCard({super.key, required this.booking, required this.docId});

  @override
  Widget build(BuildContext context) {
    String status = booking['status'] ?? 'pending';
    String? feedback = booking['feedback'];
    String? cancellationReason = booking['cancellationReason'];

    // ✅ معالجة الـ CreatedAt لعرض وقت الطلب بالضبط
    String requestTimeFormatted = "غير محدد";
    if (booking['createdAt'] != null) {
      try {
        DateTime dt = DateTime.parse(booking['createdAt']);
        requestTimeFormatted = DateFormat('yyyy-MM-dd | hh:mm a').format(dt);
      } catch (e) {
        requestTimeFormatted = booking['createdAt'].toString().split('.')[0];
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: booking['paymentImageUrl'] != null
                ? Image.network(
                    booking['paymentImageUrl'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 100,
                    height: 100,
                    color: const Color(0xFFE8DDCF),
                    child: const Icon(
                      Icons.art_track,
                      color: Color(0xFF9C5A1A),
                      size: 35,
                    ),
                  ),
          ),
          const SizedBox(width: 25),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      booking['placeName'] ?? "حجز مَـرسَم",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        fontFamily: 'ElMessiri',
                        color: Color(0xFF2F3E34),
                      ),
                    ),
                    _statusBadge(status),
                  ],
                ),
                const SizedBox(height: 12),

                // 👤 معلومات الشخص الحجز
                Wrap(
                  spacing: 20,
                  runSpacing: 10,
                  children: [
                    _infoBadge(
                      Icons.person,
                      "الاسم: ${booking['name'] ?? 'غير معروف'}",
                    ),
                    _infoBadge(
                      Icons.phone,
                      "الهاتف: ${booking['phone'] ?? '---'}",
                    ),
                    _infoBadge(
                      Icons.attach_money,
                      "السعر: ${booking['price'] ?? 0} ج.م",
                    ),
                  ],
                ),

                const SizedBox(height: 15),
                const Divider(color: Color(0xFFF5F0E1)),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "📅 موعد الجلسة: ${booking['date'].toString().split('T')[0]} | 🕒 ${booking['time']}",
                      style: const TextStyle(
                        color: Color(0xFF6F624C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "📩 تم الطلب في: $requestTimeFormatted",
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),

                if (booking['notes'] != null &&
                    booking['notes'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      "📝 ملاحظاتك: ${booking['notes']}",
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),

                if (status == 'rejected' &&
                    cancellationReason != null &&
                    cancellationReason.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "⚠️ سبب الرفض: $cancellationReason",
                        style: TextStyle(
                          color: Colors.red[900],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                if (feedback != null && feedback.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      "💬 رأيك: $feedback",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F6F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF9C5A1A)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF2F3E34)),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color = status == 'approved'
        ? Colors.green
        : status == 'completed'
        ? const Color(0xFF2F3E34)
        : status == 'rejected'
        ? Colors.red
        : Colors.orange;
    String label = status == 'approved'
        ? 'مقبول'
        : status == 'completed'
        ? 'مكتمل'
        : status == 'rejected'
        ? 'مرفوض'
        : 'قيد الانتظار';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
