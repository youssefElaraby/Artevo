import 'dart:typed_data';
import 'package:art_by_hager_ismail/core/route_manager/routes.dart';
import 'package:art_by_hager_ismail/feature/booking/model/booking_model.dart';
import 'package:art_by_hager_ismail/feature/booking/view_model/booking/booking_cubit.dart';
import 'package:art_by_hager_ismail/feature/booking/view_model/booking/booking_state.dart';
import 'package:art_by_hager_ismail/services/push_notificationservice/push_notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:art_by_hager_ismail/feature/home/model/home_settings_model.dart';
import 'package:video_player/video_player.dart';

class WebHero extends StatefulWidget {
  final EventModel? event;
  final List<dynamic>? galleryItems;
  final VoidCallback onLoginRedirect; // ✅ السطر ده عشان يوديك للوجن

  const WebHero({
    super.key,
    this.event,
    this.galleryItems,
    required this.onLoginRedirect, // ✅ لازم تبعت الميثود دي
  });

  @override
  State<WebHero> createState() => _WebHeroState();
}

class _WebHeroState extends State<WebHero> {
  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  Future<void> _launchURL(String? url) async {
    if (url == null || url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch $url");
    }
  }

  Future<void> _pickTransferImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _selectedImageBytes = bytes);
    }
  }

  // ✅ الألرت دلوقتي بيوديك فعلاً للوجن
  void _showLoginAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "تسجيل الدخول مطلوب",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'ElMessiri',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "يرجى تسجيل الدخول أولاً لتتمكن من إتمام عملية الحجز وحفظ مكانك.",
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // اقفل الألرت الأول

              // ✅ التوجيه لصفحة تسجيل الدخول مع تفعيل الـ redirectBack
              Navigator.pushNamed(
                context,
                PageRoutesName
                    .signInRoute, // تأكد إن ده اسم الراوت بتاع الـ SignInView عندك
                arguments: {'redirectBack': true},
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C5A1A),
            ),
            child: const Text(
              "تسجيل الدخول",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showLoginAlert();
      return;
    }

    // 1️⃣ منع الضغط المتكرر أثناء المعالجة
    if (context.read<BookingCubit>().state is BookingLoading) return;

    final String customerName = nameController.text.trim();
    final String customerPhone = phoneController.text.trim();

    if (customerName.isEmpty ||
        customerPhone.isEmpty ||
        _selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("برجاء إكمال البيانات وإرفاق صورة التحويل 🎨"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    DateTime eventDateTime = DateTime.now();
    try {
      if (widget.event?.eventDate != null &&
          widget.event!.eventDate!.contains('/')) {
        List<String> parts = widget.event!.eventDate!.split('/');
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

    final String placeName =
        widget.event?.eventLocationName ?? "فعالية مَـرسَم";
    final String eventTitle = widget.event?.eventTitle ?? "إيفنت ويب";
    final String bookingTime = widget.event?.eventTime ?? "غير محدد";

    final booking = BookingModel(
      id: "EVT_WEB_${DateTime.now().millisecondsSinceEpoch}",
      userId: user.uid,
      sessionId: widget.event?.id ?? '',
      placeName: placeName,
      isPrivate: false,
      date: eventDateTime,
      time: bookingTime,
      name: customerName,
      phone: customerPhone,
      price: widget.event?.eventPrice ?? 0.0,
      paymentImageBytes: _selectedImageBytes,
      status: 'pending',
      createdAt: DateTime.now(), // 🚀 تاريخ الإنشاء للتحليلات
    );

    try {
      // 2️⃣ تنفيذ الحجز والانتظار حتى النجاح في Firestore
      await context.read<BookingCubit>().createBooking(booking);

      // 3️⃣ إرسال الإشعار للأدمن "فقط" بعد نجاح الخطوة السابقة
      await PushNotificationService.sendNotificationToAllAdmins(
        customerName: customerName,
        placeName: "Event| $eventTitle - $placeName",
        bookingTime: bookingTime,
      );

      // تنظيف الحقول بعد النجاح التام
      nameController.clear();
      phoneController.clear();
      setState(() => _selectedImageBytes = null);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم إرسال طلب الحجز بنجاح! 🎉"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // في حالة الفشل، لن يرسل إشعاراً وسيعرف المستخدم بوجود خطأ
      debugPrint("❌ فشل الحجز في WebHero: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("عذراً، حدث خطأ أثناء الحجز: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isCompact = constraints.maxWidth < 1150;
        double screenWidth = constraints.maxWidth;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: isCompact ? 30 : 60),
          child: isCompact
              ? Column(children: _buildContent(context, isCompact, screenWidth))
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildContent(context, isCompact, screenWidth),
                ),
        );
      },
    );
  }

  List<Widget> _buildContent(
    BuildContext context,
    bool isCompact,
    double width,
  ) {
    bool hasEvent = widget.event != null && widget.event!.isEventActive;

    return [
      Expanded(
        flex: isCompact ? 0 : 4,
        child: Column(
          crossAxisAlignment: isCompact
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasEvent)
              _buildEventBadge(isCompact)
            else
              _buildDefaultBadge(isCompact),
            const SizedBox(height: 25),
            if (hasEvent && widget.event!.eventImageUrl != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    widget.event!.eventImageUrl!,
                    height: 140,
                    width: isCompact ? double.infinity : 450,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            _buildMainHeading(isCompact, width, hasEvent),
            const SizedBox(height: 15),
            _buildDescription(isCompact, hasEvent),
            const SizedBox(height: 35),
            hasEvent
                ? _buildBookingForm(isCompact)
                : _buildDefaultButtons(isCompact),
          ],
        ),
      ),
      if (!isCompact) const SizedBox(width: 60),
      Expanded(flex: isCompact ? 0 : 5, child: _buildGallerySlider(isCompact)),
    ];
  }

  Widget _buildBookingForm(bool isCompact) {
    return Column(
      crossAxisAlignment: isCompact
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: isCompact
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            _infoTag(
              Icons.payments_outlined,
              "السعر: ${widget.event!.eventPrice} ج.م",
              Colors.green,
            ),
            const SizedBox(width: 15),
            _infoTag(
              Icons.groups_outlined,
              "المقاعد: ${widget.event!.eventTotalSlots! - widget.event!.eventBookedSlots!}",
              Colors.blue,
            ),
          ],
        ),
        const SizedBox(height: 30),
        const Text(
          "بيانات الحجز وإيصال التحويل:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
            color: Color(0xFF2F3E34),
          ),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: isCompact ? WrapAlignment.center : WrapAlignment.start,
          children: [
            _inputBox("الاسم بالكامل", Icons.person, nameController),
            _inputBox("رقم الهاتف", Icons.phone, phoneController),
            GestureDetector(
              onTap: _pickTransferImage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 180,
                height: 52,
                decoration: BoxDecoration(
                  color: _selectedImageBytes != null
                      ? Colors.green.withOpacity(0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedImageBytes != null
                        ? Colors.green
                        : const Color(0xFFD8C9B6),
                    width: _selectedImageBytes != null ? 2 : 1,
                  ),
                ),
                child: _selectedImageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          _selectedImageBytes!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.upload_file_rounded,
                            size: 18,
                            color: Color(0xFF9C5A1A),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "أرفق الإيصال",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () =>
                  _launchURL("https://ipn.eg/S/hagerismailll/instapay/7YdZos"),
              icon: const Icon(Icons.bolt, color: Colors.white, size: 22),
              label: const Text(
                "دفع InstaPay",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B2E83),
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _confirmBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C5A1A),
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "تأكيد الحجز",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // الميثودات المساعدة (إحصائيات، أزرار، عناوين) نفس الكود السابق
  Widget _buildMainHeading(bool isCompact, double width, bool hasEvent) {
    String text = hasEvent
        ? widget.event!.eventTitle!
        : "اكتشف الفنان\nاللي جواك 🎨";
    return Text(
      text,
      textAlign: isCompact ? TextAlign.center : TextAlign.start,
      style: TextStyle(
        fontFamily: 'ElMessiri',
        fontSize: isCompact ? 38 : (width > 1500 ? 70 : 55),
        fontWeight: FontWeight.w900,
        color: const Color(0xFF2F3E34),
        height: 1.2,
      ),
    );
  }

  Widget _buildDescription(bool isCompact, bool hasEvent) {
    String text = hasEvent
        ? widget.event!.eventDescription!
        : "بيئة هادئة، أدوات احترافية، ومدربون يساعدونك على إظهار أجمل ما في فنك.";
    return Text(
      text,
      textAlign: isCompact ? TextAlign.center : TextAlign.start,
      style: TextStyle(
        fontSize: isCompact ? 16 : 19,
        color: const Color(0xFF6F624C),
        height: 1.6,
        fontFamily: 'Tajawal',
      ),
    );
  }

  Widget _buildEventBadge(bool isCompact) {
    return InkWell(
      onTap: () => _launchURL(widget.event!.eventLocationUrl),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF9C5A1A).withOpacity(0.1),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: const Color(0xFF9C5A1A).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, color: Color(0xFF9C5A1A), size: 18),
            const SizedBox(width: 8),
            Text(
              "${widget.event!.eventLocationName} | ${widget.event!.eventDate}",
              style: const TextStyle(
                color: Color(0xFF9C5A1A),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultBadge(bool isCompact) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2F3E34).withOpacity(0.05),
        borderRadius: BorderRadius.circular(50),
      ),
      child: const Text(
        "استوديو فني متكامل ✨",
        style: TextStyle(color: Color(0xFF2F3E34), fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _inputBox(String hint, IconData icon, TextEditingController ctrl) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8C9B6)),
      ),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, size: 18, color: const Color(0xFF9C5A1A)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _infoTag(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultButtons(bool isCompact) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: isCompact ? WrapAlignment.center : WrapAlignment.start,
      children: [
        _heroBtn("ابدأ رحلتك الفنية", isPrimary: true),
        _heroBtn("شاهد أعمالنا", isPrimary: false),
      ],
    );
  }

  Widget _heroBtn(String label, {required bool isPrimary}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFF9C5A1A) : Colors.transparent,
        borderRadius: BorderRadius.circular(100),
        border: isPrimary
            ? null
            : Border.all(color: const Color(0xFF2F3E34), width: 2),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isPrimary ? Colors.white : const Color(0xFF2F3E34),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGallerySlider(bool isCompact) {
    final list = widget.galleryItems ?? [];
    if (list.isEmpty && (widget.event?.eventImageUrl == null))
      return const SizedBox();
    return Stack(
      children: [
        Container(
          height: isCompact ? 400 : 650,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: PageView.builder(
              controller: _pageController,
              itemCount: list.isEmpty ? 1 : list.length,
              onPageChanged: (v) {
                if (mounted) setState(() => _currentPage = v);
              },
              itemBuilder: (context, index) {
                if (list.isEmpty)
                  return Image.network(
                    widget.event!.eventImageUrl!,
                    fit: BoxFit.cover,
                  );
                final item = list[index];
                if (item.type == 'video')
                  return _WebVideoPlayer(videoUrl: item.url);
                return Image.network(item.url, fit: BoxFit.cover);
              },
            ),
          ),
        ),
        if (list.length > 1) ...[
          Positioned(
            left: 15,
            top: 0,
            bottom: 0,
            child: Center(
              child: CircleAvatar(
                backgroundColor: Colors.white70,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 15,
            top: 0,
            bottom: 0,
            child: Center(
              child: CircleAvatar(
                backgroundColor: Colors.white70,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 18),
                  onPressed: () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ويدجت تشغيل فيديو الويب
class _WebVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const _WebVideoPlayer({required this.videoUrl});
  @override
  State<_WebVideoPlayer> createState() => _WebVideoPlayerState();
}

class _WebVideoPlayerState extends State<_WebVideoPlayer> {
  late VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) setState(() {});
        _controller.setLooping(true);
        _controller.setVolume(0);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? VideoPlayer(_controller)
        : const Center(child: CircularProgressIndicator(color: Colors.white));
  }
}
