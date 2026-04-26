import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BookingDatePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final void Function(DateTime) onDateSelected;

  const BookingDatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: now,
          firstDate: now,
          lastDate: DateTime(now.year + 1),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: Color(0xFF2F3E34)),
            ),
            child: child!,
          ),
        );
        if (picked != null) onDateSelected(picked);
      },
      child: _pickerContainer(
        selectedDate == null
            ? 'اختر التاريخ'
            : selectedDate!.toLocal().toString().split(' ')[0],
        Icons.calendar_today_outlined,
      ),
    );
  }

  Widget _pickerContainer(String text, IconData icon) {
    return Container(
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
            text,
            style: TextStyle(
              fontFamily: 'ElMessiri',
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2F3E34),
            ),
          ),
          Icon(icon, color: const Color(0xFF9C5A1A), size: 20),
        ],
      ),
    );
  }
}
