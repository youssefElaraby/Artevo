import 'dart:typed_data';
import 'package:art_by_hager_ismail/services/push_notificationservice/push_notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:art_by_hager_ismail/feature/booking/model/booking_model.dart';
import 'package:art_by_hager_ismail/feature/booking/view_model/booking/booking_cubit.dart';

class EventDetailsSheet extends StatefulWidget {
  final dynamic event;
  final VoidCallback onUnauthenticated;

  const EventDetailsSheet({
    super.key,
    required this.event,
    required this.onUnauthenticated,
  });

  @override
  State<EventDetailsSheet> createState() => _EventDetailsSheetState();
}

class _EventDetailsSheetState extends State<EventDetailsSheet> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  Uint8List? _imageBytes;
  bool _isPicking = false;
  bool _isSubmitting = false; // 🔥 متغير جديد للتحميل

  Future<void> _pickImage() async {
    setState(() => _isPicking = true);
    final picker = ImagePicker();
    try {
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() => _imageBytes = bytes);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    } finally {
      setState(() => _isPicking = false);
    }
  }

  bool get _isFormValid =>
      _nameController.text.trim().isNotEmpty &&
      _phoneController.text.trim().isNotEmpty &&
      _imageBytes != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBFA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 20.h),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            Text(
              widget.event.eventTitle ?? '',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'ElMessiri',
                color: const Color(0xFF2F3E34),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              "${widget.event.eventPrice} ج.م | ${widget.event.eventLocationName}",
              style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
            ),
            const Divider(height: 30),
            Text(
              "بيانات الحجز:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                fontFamily: 'ElMessiri',
              ),
            ),
            SizedBox(height: 15.h),
            _buildTextField(
              _nameController,
              "الاسم بالكامل",
              Icons.person_outline,
            ),
            SizedBox(height: 12.h),
            _buildTextField(
              _phoneController,
              "رقم التليفون (واتساب)",
              Icons.phone_android,
              isPhone: true,
            ),
            SizedBox(height: 25.h),
            Text(
              "تأكيد الدفع عبر InstaPay:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: Colors.purple[800],
              ),
            ),
            SizedBox(height: 10.h),
            _buildInstaPaySection(),
            SizedBox(height: 25.h),
            Text(
              "صورة إيصال التحويل (إجباري):",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
            SizedBox(height: 10.h),
            _buildImagePickerArea(),
            SizedBox(height: 30.h),
            _buildSubmitButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInstaPaySection() {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            final Uri url = Uri.parse(
              // 'https://ipn.eg/S/hagerismailll/instapay/7YdZos'
              "https://ipn.eg/S/hagerismailll/instapay/7YdZos",
            );
            if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("تأكد من تثبيت تطبيق InstaPay")),
              );
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFF673AB7),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bolt, color: Colors.white),
                Text(
                  " فتح تطبيق InstaPay للتحويل",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.purple.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "hagerismailll",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[800],
                ),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(const ClipboardData(text: "hagerismailll"));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("تم نسخ عنوان الدفع")),
                  );
                },
                icon: const Icon(Icons.copy, size: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePickerArea() {
    return GestureDetector(
      onTap: (_isPicking || _isSubmitting) ? null : _pickImage,
      child: Container(
        height: 120.h,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: _imageBytes != null ? Colors.green : Colors.grey[300]!,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(15.r),
          color: Colors.grey[50],
        ),
        child: _imageBytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(15.r),
                child: Image.memory(_imageBytes!, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _isPicking
                      ? const CircularProgressIndicator(
                          color: Color(0xFF9C5A1A),
                        )
                      : Icon(
                          Icons.add_a_photo_outlined,
                          color: Colors.grey,
                          size: 30.sp,
                        ),
                  SizedBox(height: 8.h),
                  Text(
                    "اضغط لرفع صورة الإيصال",
                    style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return ElevatedButton(
      onPressed: (_isFormValid && !_isSubmitting)
          ? () => _confirmBooking(context)
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2F3E34),
        disabledBackgroundColor: Colors.grey[300],
        minimumSize: Size(double.infinity, 55.h),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
      ),
      child: _isSubmitting
          ? SizedBox(
              height: 20.h,
              width: 20.h,
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              _isFormValid ? "تأكيد حجز مكانك" : "اكمل البيانات وارفق الإيصال",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'ElMessiri',
              ),
            ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPhone = false,
  }) {
    return TextField(
      controller: controller,
      enabled: !_isSubmitting, // 🔥 قفل الحقول أثناء الإرسال
      onChanged: (_) => setState(() {}),
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 20.sp, color: const Color(0xFF2F3E34)),
        labelText: label,
        labelStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
    );
  }

  void _confirmBooking(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      widget.onUnauthenticated();
      return;
    }

    // 🔥 البدء في حالة التحميل
    setState(() => _isSubmitting = true);

    DateTime eventDateTime = DateTime.now();
    try {
      if (widget.event.eventDate != null &&
          widget.event.eventDate.toString().contains('/')) {
        List<String> parts = widget.event.eventDate.split('/');
        if (parts.length == 3) {
          eventDateTime = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      }
    } catch (e) {
      debugPrint("Error parsing date: $e");
    }

    final String customerName = _nameController.text.trim();
    final String placeName = widget.event.eventLocationName ?? "فعالية عامة";
    final String bookingTime = widget.event.eventTime ?? "غير محدد";
    final String eventTitle = widget.event.eventTitle ?? "فعالية";

    final booking = BookingModel(
      id: "EVT_${DateTime.now().millisecondsSinceEpoch}",
      userId: user.uid,
      sessionId: widget.event.id,
      placeName: placeName,
      isPrivate: false,
      date: eventDateTime,
      time: bookingTime,
      name: customerName,
      phone: _phoneController.text.trim(),
      price: double.tryParse(widget.event.eventPrice.toString()) ?? 0.0,
      paymentImageBytes: _imageBytes,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    try {
      // 1️⃣ تنفيذ الحجز الفعلي
      await context.read<BookingCubit>().createBooking(booking);

      // 2️⃣ إرسال الإشعار
      await PushNotificationService.sendNotificationToAllAdmins(
        customerName: customerName,
        placeName: "Event $eventTitle - $placeName",
        bookingTime: bookingTime,
      );

      // 🏁 النجاح: إغلاق البويتن شيت وإظهار رسالة
      if (mounted) {
        Navigator.pop(context); // 🔥 الإغلاق يحدث هنا فقط عند النجاح
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم إرسال طلب حجزك بنجاح! 🎉"),
            backgroundColor: Color(0xFF2F3E34),
          ),
        );
      }
    } catch (e) {
      // ⚠️ الفشل: إعادة الزرار لحالته الطبيعية عشان اليوزر يحاول تاني
      debugPrint("Booking Failed Error: $e");
      if (mounted) {
        setState(
          () => _isSubmitting = false,
        ); // 🔥 وقف التحميل لإتاحة المحاولة مرة تانية
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("عذراً، حدث خطأ: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
