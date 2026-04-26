import 'dart:io';
import 'package:art_by_hager_ismail/core/route_manager/routes.dart';
import 'package:art_by_hager_ismail/feature/authentication/sign_up/view_model/auth_states.dart';
import 'package:art_by_hager_ismail/feature/authentication/sign_up/view_model/auth_view_model.dart';
import 'package:art_by_hager_ismail/feature/booking/model/session_model.dart';
import 'package:art_by_hager_ismail/services/push_notificationservice/push_notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'booking_notes_field.dart';
import '../../booking/model/booking_model.dart';
import '../view_model/booking/booking_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookingDetailsForm extends StatefulWidget {
  final bool isPrivate;
  final SessionModel? selectedSession;
  final bool requirePayment;

  const BookingDetailsForm({
    super.key,
    required this.isPrivate,
    this.selectedSession,
    this.requirePayment = true,
  });

  @override
  State<BookingDetailsForm> createState() => _BookingDetailsFormState();
}

class _BookingDetailsFormState extends State<BookingDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false; // لمنع تكرار الطلب

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  File? paymentImageMobile;
  Uint8List? paymentImageWeb;
  final ImagePicker _picker = ImagePicker();

  bool get canSubmit {
    if (!widget.isPrivate && widget.selectedSession != null) {
      final available =
          widget.selectedSession!.capacity -
          widget.selectedSession!.bookedCount;
      if (available <= 0) return false;
    }
    if (!widget.requirePayment) return true;
    return (kIsWeb ? paymentImageWeb != null : paymentImageMobile != null);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Column(
                  children: [
                    if (!widget.isPrivate && widget.selectedSession != null)
                      _buildEnhancedSessionTicket(),
                    SizedBox(height: 25.h),
                    _sectionHeader(
                      "بيانات الحجز",
                      Icons.assignment_ind_outlined,
                    ),
                    _buildCardWrapper(
                      child: Column(
                        children: [
                          _customTextField(
                            nameController,
                            "الاسم الثلاثي",
                            Icons.person_outline,
                          ),
                          SizedBox(height: 15.h),
                          _customTextField(
                            phoneController,
                            "رقم الواتساب",
                            Icons.phone_android_outlined,
                            type: TextInputType.phone,
                          ),
                        ],
                      ),
                    ),
                    if (widget.requirePayment) _buildInstaPayPaymentCard(),
                    _buildCardWrapper(
                      child: BookingNotesField(controller: notesController),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
              child: _buildSubmitButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedSessionTicket() {
    final s = widget.selectedSession!;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2F3E34),
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
                child: Image.network(
                  s.image,
                  height: 160.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // 🔥 لو اللينك باظ يعرض اللي هنا
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 160.h,
                      width: double.infinity,
                      color: const Color(0xFF2F3E34), // لون زيتي من ستايلك
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: const Color(0xFFE8DDCF),
                        size: 40.r,
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C5A1A),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    "${s.price} ج.م",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                Text(
                  s.name,
                  style: TextStyle(
                    color: const Color(0xFFE8DDCF),
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ElMessiri',
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ticketInfoTile(Icons.calendar_today, s.dayName, s.date),
                    _ticketInfoTile(
                      Icons.access_time_filled,
                      "الوقت",
                      s.startTime,
                    ),
                    _ticketInfoTile(
                      Icons.group,
                      "المقاعد",
                      "${s.capacity - s.bookedCount} متاح",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ticketInfoTile(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFFE8DDCF).withOpacity(0.7),
          size: 18.sp,
        ),
        SizedBox(height: 4.h),
        Text(
          title,
          style: TextStyle(color: Colors.white54, fontSize: 10.sp),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> _sendNotificationToAdmin() async {
    try {
      final authState = context.read<AuthCubit>().state;

      // صورة افتراضية (Backup)
      String userImg = "https://cdn-icons-png.flaticon.com/512/149/149071.png";

      if (authState is AuthSuccess) {
        // ✅ بنستخدم الاسم اللى انت عرفته فى الموديل بتاعك بالظبط
        final img = authState.userModel.profileImageUrl;

        if (img != null && img.isNotEmpty) {
          userImg = img;
        } else {
          // لو الموديل مش قاريها، ممكن نسحبها "يدوى" من الـ Auth نفسه كحل أخير
          userImg = FirebaseAuth.instance.currentUser?.photoURL ?? userImg;
        }
      }

      // 📍 تجهيز بيانات المكان والوقت
      String place = widget.isPrivate
          ? "طلب خاص (Private)"
          : (widget.selectedSession?.name ?? "جلسة رسم");

      String time = widget.isPrivate
          ? "يتم التنسيق لاحقاً"
          : (widget.selectedSession?.startTime ?? "");

      // 🚀 إرسال الإشعار المطور للأدمن
      await PushNotificationService.sendNotificationToAllAdmins(
        customerName: nameController.text.trim(),
        placeName: place,
        bookingTime: time,
      );

      debugPrint("✅ إشعار الحجز أُرسل بنجاح بصورة: $userImg");
    } catch (e) {
      debugPrint("⚠️ فشل إرسال الإشعار: $e");
    }
  }

  void _submit() async {
    if (_isSubmitting) return; // حماية من تكرار الضغط

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      await _showLoginRequiredDialog();
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    // ابدأ عملية الإرسال
    setState(() => _isSubmitting = true);

    try {
      DateTime eventDate;
      try {
        eventDate = widget.selectedSession != null
            ? DateTime.parse(widget.selectedSession!.date)
            : DateTime.now();
      } catch (_) {
        eventDate = DateTime.now();
      }

      // تجهيز البيانات الأساسية
      final String customerName = nameController.text.trim();
      final String placeName = widget.isPrivate
          ? "طلب خاص"
          : (widget.selectedSession?.name ?? "جلسة رسم");
      final String bookingTime = widget.isPrivate
          ? "Private"
          : (widget.selectedSession?.startTime ?? "");

      // إنشاء موديل الحجز مع إضافة createdAt
      final booking = BookingModel(
        id: "BK_${DateTime.now().millisecondsSinceEpoch}",
        userId: user.uid,
        sessionId: widget.isPrivate ? null : widget.selectedSession?.id,
        placeName: placeName,
        isPrivate: widget.isPrivate,
        date: widget.isPrivate ? DateTime.now() : eventDate,
        time: bookingTime,
        name: customerName,
        phone: phoneController.text.trim(),
        notes: notesController.text.trim(),
        price: widget.isPrivate
            ? 0
            : (double.tryParse(widget.selectedSession!.price.toString()) ?? 0),
        paymentImageBytes: kIsWeb
            ? paymentImageWeb
            : paymentImageMobile?.readAsBytesSync(),
        status: "pending",
        createdAt:
            DateTime.now(), // 🚀 تاريخ إنشاء الطلب الفعلي (للوقت الحقيقي في التحليلات)
      );

      // 1️⃣ التسجيل في قاعدة البيانات (الفايرستور) والانتظار حتى النجاح
      // 💡 لازم الـ createBooking في الكيوبيت ترجع Future<void>
      await context.read<BookingCubit>().createBooking(booking);

      // 🚀 2️⃣ إطلاق الإشعار الفعلي للأدمن (لن يتم الوصول هنا إلا إذا نجح السطر السابق)
      await _sendNotificationToAdmin();

      _showToast("تم إرسال طلب الحجز بنجاح! 🎨");

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // 3️⃣ في حال حدوث خطأ تقني في الخطوة رقم 1، لن يتم إرسال الإشعار
      debugPrint("❌ فشل عملية الحجز والإشعار: $e");
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showToast("حدث خطأ أثناء الحجز، يرجى المحاولة لاحقاً");
      }
    }
  }

  Future<void> _showLoginRequiredDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            "تسجيل الدخول مطلوب",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'ElMessiri',
              color: const Color(0xFF2F3E34),
            ),
          ),
          content: Text(
            "يرجى تسجيل الدخول لتتمكن من إتمام عملية الحجز.",
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text("إلغاء", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await Navigator.pushNamed(
                  context,
                  PageRoutesName.signInRoute,
                  arguments: {'redirectBack': true},
                );
                if (mounted) {
                  setState(() {});
                  if (FirebaseAuth.instance.currentUser != null) {
                    _showToast("تم تسجيل الدخول بنجاح، يمكنك إكمال الحجز الآن");
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C5A1A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                "تسجيل الدخول",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    bool isFull =
        !widget.isPrivate &&
        widget.selectedSession != null &&
        (widget.selectedSession!.capacity -
                widget.selectedSession!.bookedCount <=
            0);

    return InkWell(
      onTap: (canSubmit && !_isSubmitting)
          ? _submit
          : (FirebaseAuth.instance.currentUser == null ? _submit : null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          gradient:
              (canSubmit && !_isSubmitting ||
                  FirebaseAuth.instance.currentUser == null)
              ? const LinearGradient(
                  colors: [Color(0xFF2F3E34), Color(0xFF3D5245)],
                )
              : LinearGradient(
                  colors: [Colors.grey.shade400, Colors.grey.shade500],
                ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Center(
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
                  isFull
                      ? "نعتذر.. الحجز مكتمل"
                      : (FirebaseAuth.instance.currentUser == null
                            ? "سجل دخول لإتمام الحجز"
                            : (canSubmit
                                  ? "تأكيد وإرسال الطلب"
                                  : "أرفق صورة الدفع")),
                  style: TextStyle(
                    fontFamily: 'ElMessiri',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color:
                        (canSubmit || FirebaseAuth.instance.currentUser == null)
                        ? const Color(0xFFE8DDCF)
                        : Colors.white70,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildCardWrapper({required Widget child, Color? color}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(top: 15.h),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: child,
    );
  }

  Widget _customTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? type,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      onChanged: (v) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF2F3E34).withOpacity(0.5),
          size: 20,
        ),
        filled: true,
        fillColor: const Color(0xFFFBFBFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (v) => v!.trim().isEmpty ? "هذا الحقل مطلوب" : null,
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF9C5A1A), size: 20),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'ElMessiri',
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            color: const Color(0xFF2F3E34),
          ),
        ),
      ],
    );
  }

  Widget _buildInstaPayPaymentCard() {
    return _buildCardWrapper(
      color: const Color(0xFF673AB7).withOpacity(0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            "تأكيد الدفع عبر InstaPay",
            Icons.account_balance_wallet_outlined,
          ),
          SizedBox(height: 12.h),
          InkWell(
            onTap: _launchInstaPay,
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
                    " فتح التطبيق للتحويل",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          _buildCopyableAddress(),
          SizedBox(height: 12.h),
          _buildImagePickerArea(),
        ],
      ),
    );
  }

  Widget _buildCopyableAddress() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.purple.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "hagerismaill",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
              color: Colors.purple,
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: "hagerismaill"));
              _showToast("تم نسخ العنوان");
            },
            icon: const Icon(Icons.copy, size: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePickerArea() {
    return GestureDetector(
      onTap: _showPickOptions,
      child: Container(
        height: 100.h,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.purple.withOpacity(0.2),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(15.r),
          color: Colors.white,
        ),
        child: (kIsWeb ? paymentImageWeb != null : paymentImageMobile != null)
            ? ClipRRect(
                borderRadius: BorderRadius.circular(15.r),
                child: kIsWeb
                    ? Image.memory(paymentImageWeb!, fit: BoxFit.cover)
                    : Image.file(paymentImageMobile!, fit: BoxFit.cover),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    color: Colors.purple,
                  ),
                  Text(
                    "ارفق صورة التحويل",
                    style: TextStyle(fontSize: 10, color: Colors.purple),
                  ),
                ],
              ),
      ),
    );
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: const Color(0xFF2F3E34),
      textColor: Colors.white,
    );
  }

  Future<void> _launchInstaPay() async {
    final Uri url = Uri.parse(
      'https://ipn.eg/S/hagerismailll/instapay/7YdZos',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication))
      _showToast("تأكد من تثبيت تطبيق InstaPay");
  }

  void _showPickOptions() {
    if (kIsWeb) {
      _pickPaymentImageWeb();
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('المعرض'),
              onTap: () {
                Navigator.pop(context);
                _pickPaymentImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('الكاميرا'),
              onTap: () {
                Navigator.pop(context);
                _pickPaymentImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPaymentImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() => paymentImageMobile = File(pickedFile.path));
    }
  }

  Future<void> _pickPaymentImageWeb() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      Uint8List bytes = await pickedFile.readAsBytes();
      setState(() => paymentImageWeb = bytes);
    }
  }
}
