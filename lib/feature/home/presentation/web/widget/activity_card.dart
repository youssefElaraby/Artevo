import 'package:flutter/material.dart';

class ActivityCard extends StatefulWidget {
  final String title;
  final String price;
  final String image;
  final String desc;
  final bool isMostBooked;
  final VoidCallback onBookNow;
  final bool isApprovedDisplay; // إضافة هذا المتغير

  const ActivityCard({
    super.key,
    required this.title,
    required this.price,
    required this.image,
    required this.desc,
    required this.onBookNow,
    this.isMostBooked = false,
    this.isApprovedDisplay =
        false, // القيمة الافتراضية "false" عشان يظهر الزرار عادي
  });

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.translationValues(0, isHovered ? -12 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isHovered
                ? const Color(0xFF9C5A1A).withOpacity(0.5)
                : const Color(0xFFD8C9B6).withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isHovered
                  ? Colors.black.withOpacity(0.12)
                  : Colors.black.withOpacity(0.04),
              blurRadius: isHovered ? 25 : 12,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  child: AnimatedScale(
                    scale: isHovered ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 500),
                    child: Image.network(
                      widget.image,
                      height: 240,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontFamily: 'ElMessiri',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2F3E34),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6F624C),
                          height: 1.6,
                          fontSize: 15,
                        ),
                      ),
                      // هنا التعديل: لو هو "approved display" ما يحطش مسافة ولا زرار
                      if (!widget.isApprovedDisplay) ...[
                        const SizedBox(height: 25),
                        _bookButton(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C5A1A),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  widget.isApprovedDisplay
                      ? "تم التأكيد ✅"
                      : "${widget.price} ج.م",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (widget.isMostBooked) _buildBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF9C5A1A),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: const Text(
            "الأكثر حجزاً 🔥",
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _bookButton() {
    return InkWell(
      onTap: widget.onBookNow,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isHovered ? const Color(0xFF9C5A1A) : const Color(0xFF2F3E34),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: const Text(
          "احجز مكانك الآن",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
