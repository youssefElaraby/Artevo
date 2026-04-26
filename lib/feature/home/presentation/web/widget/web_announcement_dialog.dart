import 'package:flutter/material.dart';
import 'package:art_by_hager_ismail/feature/home/model/home_settings_model.dart';

// ✅ لازم الميثود دي تكون موجودة هنا (برا الكلاس) عشان الـ HomeWebView يشوفها
void showWebAnnouncement(BuildContext context, PopupModel popup, Function(String) onAction) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => WebAnnouncementDialog(popup: popup, onAction: onAction),
  );
}

class WebAnnouncementDialog extends StatelessWidget {
  final PopupModel popup;
  final Function(String) onAction;

  const WebAnnouncementDialog({
    super.key,
    required this.popup,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // المحتوى الرئيسي بناءً على بيانات الفايربيز
          Container(
            constraints: const BoxConstraints(maxWidth: 550),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 30,
                  offset: Offset(0, 15),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. عرض الصورة القادمة من Cloudinary
                  if (popup.popupImageUrl != null && popup.popupImageUrl!.isNotEmpty)
                    AspectRatio(
                      aspectRatio: 16 / 10,
                      child: Image.network(
                        popup.popupImageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: const Color(0xFFF3EDE7),
                            child: const Center(
                              child: CircularProgressIndicator(color: Color(0xFF9C5A1A)),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          color: const Color(0xFFE8DDCF),
                          child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        ),
                      ),
                    ),
                  
                  // 2. عرض النص (popupTitle) اللي هو عندك "test popups"
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        Text(
                          popup.popupTitle ?? "مرحباً بك في مَـرسَم",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'ElMessiri',
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2F3E34),
                          ),
                        ),
                        
                        // 3. الزرار (مش هيظهر عندك حالياً لأن popupActionType عندك null)
                        if (popup.popupActionType != null && popup.popupActionType!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 25),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  onAction(popup.popupActionType!);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF9C5A1A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  elevation: 5,
                                ),
                                child: const Text(
                                  "استكشف الآن 🎨",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          const SizedBox(height: 10), 
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 4. زرار الإغلاق العلوي
          Positioned(
            top: 15,
            right: 15,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}