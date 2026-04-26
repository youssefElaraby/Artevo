import 'package:art_by_hager_ismail/feature/home/model/home_settings_model.dart';
import 'package:flutter/material.dart';

class WebWorkshopsGrid extends StatelessWidget {
  final List<WorkshopModel>? workshops;
  final VoidCallback onBookingTap;

  const WebWorkshopsGrid({
    super.key,
    this.workshops,
    required this.onBookingTap,
  });

  @override
  Widget build(BuildContext context) {
    if (workshops == null || workshops!.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            "لا توجد ورش عمل متاحة حالياً.. انتظرونا قريباً ✨",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // تحديد عدد الكروت في الصف بناءً على عرض الشاشة
        int crossAxisCount = constraints.maxWidth > 1200
            ? 4
            : (constraints.maxWidth > 800 ? 2 : 1);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 20),
          itemCount: workshops!.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 25,
            mainAxisSpacing: 25,
            mainAxisExtent: 380, // ارتفاع الكارت
          ),
          itemBuilder: (context, index) {
            final workshop = workshops![index];
            return _buildWorkshopCard(context, workshop);
          },
        );
      },
    );
  }

  Widget _buildWorkshopCard(BuildContext context, WorkshopModel workshop) {
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
          // 1️⃣ صورة الورشة مع بادج القسم
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                  child: Image.network(
                    workshop.imageUrl ?? 'https://via.placeholder.com/400x300',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(color: const Color(0xFFE8DDCF)),
                  ),
                ),
                if (workshop.category != null)
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9C5A1A),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        workshop.category!,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 2️⃣ تفاصيل الورشة
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workshop.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ElMessiri',
                    color: Color(0xFF2F3E34),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "تعلم التقنيات الفنية بأسلوب أكاديمي مبسط مع نخبة من المدربين.",
                  maxLines: 2,
                  style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 20),
                
                // زرار الحجز
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onBookingTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F3E34),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    child: const Text(
                      "احجز مكانك الآن",
                      style: TextStyle(fontWeight: FontWeight.bold),
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
}