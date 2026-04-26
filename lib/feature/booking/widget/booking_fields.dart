import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BookingFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;

  const BookingFields({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField(nameController, "الاسم بالكامل", Icons.person_outline),
        SizedBox(height: 16.h),
        _buildTextField(
          emailController,
          "البريد الإلكتروني",
          Icons.email_outlined,
          TextInputType.emailAddress,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          phoneController,
          "رقم الهاتف",
          Icons.phone_outlined,
          TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, [
    TextInputType? type,
  ]) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      style: TextStyle(fontFamily: 'Tajawal', fontSize: 14.sp),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF2F3E34),
          fontFamily: 'ElMessiri',
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF9C5A1A), size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(
            color: const Color(0xFF2F3E34).withOpacity(0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: const BorderSide(color: Color(0xFF9C5A1A)),
        ),
      ),
      validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
    );
  }
}
