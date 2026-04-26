import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BookingTimePicker extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final void Function(TimeOfDay) onTimeSelected;

  const BookingTimePicker({
    super.key,
    required this.selectedTime,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (picked != null) onTimeSelected(picked);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFD8C9B6).withOpacity(0.3),
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: const Color(0xFF2F3E34).withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedTime == null
                  ? 'اختر الوقت'
                  : selectedTime!.format(context),
              style: TextStyle(
                fontFamily: 'ElMessiri',
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2F3E34),
              ),
            ),
            const Icon(
              Icons.access_time_outlined,
              color: Color(0xFF9C5A1A),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
