import 'package:art_by_hager_ismail/core/route_manager/routes.dart';
import 'package:art_by_hager_ismail/feature/booking/model/booking_model.dart';
import 'package:art_by_hager_ismail/feature/booking/model/session_model.dart';
import 'package:art_by_hager_ismail/feature/booking/view_model/booking/booking_cubit.dart';
import 'package:art_by_hager_ismail/feature/booking/view_model/booking/booking_state.dart';
import 'package:art_by_hager_ismail/services/push_notificationservice/push_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class WebBookingFormDetails extends StatefulWidget {
  final bool isPrivate;
  final SessionModel? selectedSession;
  final String? defaultLocation;
  final String? locationImage;
  final VoidCallback? onBookingSuccess;

  const WebBookingFormDetails({
    super.key,
    required this.isPrivate,
    this.selectedSession,
    this.defaultLocation,
    this.locationImage,
    this.onBookingSuccess,
  });

  @override
  State<WebBookingFormDetails> createState() => _WebBookingFormDetailsState();
}

class _WebBookingFormDetailsState extends State<WebBookingFormDetails> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController customPlaceController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  Uint8List? paymentImageWeb;

  bool get canSubmit => paymentImageWeb != null;

  @override
  void initState() {
    super.initState();
    // 🚀 تعبئة البيانات التلقائية
    if (!widget.isPrivate && widget.selectedSession != null) {
      dateController.text =
          "${widget.selectedSession!.dayName} - ${widget.selectedSession!.date}";
      timeController.text = widget.selectedSession!.startTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state is BookingSuccess) {
          _showStatusSnackBar("تم استلام طلب حجزك بنجاح! 🎉", isError: false);
          if (widget.onBookingSuccess != null) widget.onBookingSuccess!();
        } else if (state is BookingError) {
          _showStatusSnackBar("حدث خطأ: ${state.message}", isError: true);
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isCompact = constraints.maxWidth < 900;
          return Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
              constraints: const BoxConstraints(
                maxWidth: 1100,
              ), // شلنا الـ maxHeight
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Flex(
                direction: isCompact ? Axis.vertical : Axis.horizontal,
                textDirection: TextDirection.rtl,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // مهم جداً للويب
                children: [
                  // قسم الفورم
                  Expanded(
                    flex: isCompact ? 0 : 6,
                    child: _buildFormSection(isCompact),
                  ),
                  if (!isCompact)
                    Container(
                      width: 1,
                      height: 600,
                      color: const Color(0xFFE8DDCF),
                    ),
                  // قسم الملخص (الفاتورة)
                  Expanded(
                    flex: isCompact ? 0 : 4,
                    child: _buildSummarySection(isCompact),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormSection(bool isCompact) {
    return Padding(
      padding: EdgeInsets.all(isCompact ? 20.w : 35.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان الرئيسي
            Text(
              widget.isPrivate ? "حجز جلسة خاصة 🏠" : "تأكيد الحجز 🎨",
              style: TextStyle(
                fontFamily: 'ElMessiri',
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2F3E34),
              ),
            ),
            SizedBox(height: 10.h),

            // --- عرض التفاصيل كنص (فوق) في حالة الجلسة العامة ---
            if (!widget.isPrivate && widget.selectedSession != null) ...[
              Container(
                padding: EdgeInsets.all(15.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C5A1A).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: const Color(0xFF9C5A1A).withOpacity(0.1),
                  ),
                ),
                child: Column(
                  children: [
                    _infoDetailRow(
                      Icons.storefront,
                      "المكان:",
                      widget.selectedSession!.name,
                    ),
                    Divider(
                      color: const Color(0xFF9C5A1A).withOpacity(0.1),
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _infoDetailRow(
                            Icons.calendar_today,
                            "التاريخ:",
                            widget.selectedSession!.date,
                          ),
                        ),
                        Expanded(
                          child: _infoDetailRow(
                            Icons.access_time,
                            "الوقت:",
                            widget.selectedSession!.startTime,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25.h),
            ],

            // --- الحقول المطلوبة من المستخدم ---
            if (widget.isPrivate) ...[
              _webTextField(
                customPlaceController,
                "عنوان الجلسة بالتفصيل",
                Icons.location_on_outlined,
              ),
              SizedBox(height: 15.h),
            ],

            Row(
              children: [
                Expanded(
                  child: _webTextField(
                    nameController,
                    "الاسم بالكامل",
                    Icons.person_outline,
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: _webTextField(
                    phoneController,
                    "رقم التواصل",
                    Icons.phone_android_outlined,
                    type: TextInputType.phone,
                  ),
                ),
              ],
            ),

            if (widget.isPrivate) ...[
              SizedBox(height: 15.h),
              Row(
                children: [
                  Expanded(
                    child: _webTextField(
                      dateController,
                      "التاريخ",
                      Icons.calendar_today,
                      onTap: _pickDateWeb,
                      readOnly: true,
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: _webTextField(
                      timeController,
                      "الوقت",
                      Icons.access_time,
                      onTap: _pickTimeWeb,
                      readOnly: true,
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: 15.h),
            _webTextField(
              notesController,
              "ملاحظات إضافية لـ مَـرسَم",
              Icons.edit_note,
            ),
            SizedBox(height: 30.h),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  // هيلبر ميثود لعرض الصفوف النصية بشكل منسق
  Widget _infoDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: const Color(0xFF9C5A1A)),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
            fontFamily: 'ElMessiri',
          ),
        ),
        SizedBox(width: 5.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2F3E34),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(bool isCompact) {
    final session = widget.selectedSession;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F6F2),
        borderRadius: isCompact
            ? BorderRadius.vertical(bottom: Radius.circular(25.r))
            : BorderRadius.only(
                topLeft: Radius.circular(25.r),
                bottomLeft: Radius.circular(25.r),
              ),
      ),
      padding: EdgeInsets.all(30.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (session?.image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(15.r),
              child: Image.network(
                session!.image,
                height: 180.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          SizedBox(height: 20.h),
          _summaryRow(
            "المكان",
            widget.isPrivate ? "جلسة خاصة" : session?.name ?? "-",
          ),
          _summaryRow(
            "التكلفة",
            widget.isPrivate ? "حسب الاتفاق" : "${session?.price} ج.م",
          ),
          const Divider(height: 40),
          _buildInstaPaySection(),
          const SizedBox(height: 25),
          _buildWebPaymentZone(),
        ],
      ),
    );
  }

  // --- دوال الأكشن ---
  // --- دالة الأكشن المعدلة ---
  void _submitBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showLoginRequiredDialog();
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    // 1️⃣ منع المستخدم من الضغط المتكرر إذا كان الحجز جارياً
    if (context.read<BookingCubit>().state is BookingLoading) return;

    DateTime finalDate;
    String displayDate = "";
    if (!widget.isPrivate && widget.selectedSession != null) {
      finalDate =
          DateTime.tryParse(widget.selectedSession!.date) ?? DateTime.now();
      displayDate = widget.selectedSession!.date;
    } else {
      finalDate = DateTime.tryParse(dateController.text) ?? DateTime.now();
      displayDate = dateController.text;
    }

    // تجهيز البيانات للنوتفيكيشن
    final String customerName = nameController.text.trim();
    final String placeName = widget.isPrivate
        ? " ${customPlaceController.text}"
        : " ${widget.selectedSession?.name}";
    final String bookingTime = timeController.text;

    // إنشاء موديل الحجز
    final booking = BookingModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user.uid,
      sessionId: widget.isPrivate ? null : widget.selectedSession?.id,
      placeName: widget.isPrivate
          ? customPlaceController.text
          : widget.selectedSession?.name,
      isPrivate: widget.isPrivate,
      date: finalDate,
      time: bookingTime,
      name: customerName,
      phone: phoneController.text,
      notes: notesController.text,
      price: widget.isPrivate
          ? 0
          : (widget.selectedSession?.price ?? 0).toDouble(),
      paymentImageBytes: paymentImageWeb,
      status: "pending",
      createdAt: DateTime.now(), // 🚀 تاريخ إنشاء الطلب الفعلي
    );

    try {
      // 2️⃣ تنفيذ الحجز في السيرفر والانتظار حتى النجاح
      await context.read<BookingCubit>().createBooking(booking);

      // 3️⃣ إرسال النوتفيكيشن للأدمن "فقط" بعد تأكد الحجز في قاعدة البيانات
      await PushNotificationService.sendNotificationToAllAdmins(
        customerName: customerName,
        placeName: placeName,
        bookingTime: "$displayDate | $bookingTime",
      );

      // ملاحظة: الـ BlocListener الموجود في الكود سيتولى إظهار رسالة النجاح (تم استلام طلبك بنجاح)
    } catch (e) {
      // في حالة حدوث خطأ تقني في الخطوة 2، لن يصل الكود لإرسال الإشعار
      debugPrint("❌ فشل الحجز في الويب: $e");
      _showStatusSnackBar(
        "عذراً، حدث خطأ أثناء إتمام الحجز. حاول مرة أخرى.",
        isError: true,
      );
    }
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) {
        bool isLoading = state is BookingLoading;
        return SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: (isLoading || !canSubmit) ? null : _submitBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F3E34),
              disabledBackgroundColor: Colors.grey.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    "إتمام الحجز",
                    style: TextStyle(
                      fontFamily: 'ElMessiri',
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _webTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? type,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      readOnly: readOnly,
      onTap: onTap,
      style: TextStyle(fontSize: 14.sp),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF9C5A1A)),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade50 : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      validator: (v) => v!.isEmpty ? "مطلوب" : null,
    );
  }

  // --- الميثودز المساعدة (نفس اللي كانت عندك مع تحسينات طفيفة) ---
  Future<void> _pickDateWeb() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null)
      setState(
        () => dateController.text = "${date.year}-${date.month}-${date.day}",
      );
  }

  Future<void> _pickTimeWeb() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null)
      setState(() => timeController.text = time.format(context));
  }

  Future<void> _pickImageWeb() async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => paymentImageWeb = bytes);
    }
  }

  Future<void> _launchInstaPay() async {
    final Uri url = Uri.parse('https://ipn.eg/S/hagerismailll/instapay/7YdZos');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _showStatusSnackBar("عذراً، تعذر فتح InstaPay.", isError: true);
    }
  }

  Widget _buildInstaPaySection() {
    return Column(
      children: [
        Text(
          "InstaPay: hagerismailll",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
            color: Colors.purple,
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _launchInstaPay,
          icon: const Icon(Icons.payment, color: Colors.white),
          label: const Text(
            "دفع سريع عبر انستا باي",
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebPaymentZone() {
    return GestureDetector(
      onTap: _pickImageWeb,
      child: Container(
        width: double.infinity,
        height: 150.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: paymentImageWeb != null
                ? Colors.green
                : Colors.purple.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: paymentImageWeb != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(15.r),
                child: Image.memory(paymentImageWeb!, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    color: Colors.purple.withOpacity(0.5),
                    size: 40,
                  ),
                  Text(
                    "ارفق سكرين شوت التحويل",
                    style: TextStyle(
                      color: Colors.purple.withOpacity(0.6),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: const Color(0xFF6F624C), fontSize: 14.sp),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF2F3E34),
        behavior: SnackBarBehavior.floating,
        width: 400,
      ),
    );
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تسجيل الدخول مطلوب"),
        content: const Text("يرجى تسجيل الدخول لإتمام عملية الحجز"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                PageRoutesName.signInRoute,
                arguments: {"redirectBack": true},
              );
            },
            child: const Text("دخول"),
          ),
        ],
      ),
    );
  }
}
