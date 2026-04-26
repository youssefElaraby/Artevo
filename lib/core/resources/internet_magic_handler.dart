import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InternetMagicHandler {
  static final StreamController<bool> _statusController =
      StreamController<bool>.broadcast();
  static StreamSubscription<List<ConnectivityResult>>? _subscription;
  static bool _isInitialized = false;

  static void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final hasNet = !results.contains(ConnectivityResult.none);
      _statusController.add(hasNet);
    });
  }

  static void dispose() {
    _subscription?.cancel();
    _statusController.close();
  }
}

class InternetMagicWrapper extends StatefulWidget {
  final Widget child;
  const InternetMagicWrapper({super.key, required this.child});

  @override
  State<InternetMagicWrapper> createState() => _InternetMagicWrapperState();
}

class _InternetMagicWrapperState extends State<InternetMagicWrapper>
    with TickerProviderStateMixin {
  late AnimationController _glitchController;
  late AnimationController _waveController;
  bool _isOnline = true;
  StreamSubscription? _statusSub;

  @override
  void initState() {
    super.initState();
    InternetMagicHandler.initialize();

    // أنيميشن الموجة عند الفصل (باهتة)
    _glitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // أنيميشن الموجة عند الرجوع (ذهبية)
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _statusSub = InternetMagicHandler._statusController.stream.listen((hasNet) {
      if (_isOnline != hasNet) {
        setState(() => _isOnline = hasNet);
        if (!hasNet) {
          HapticFeedback.heavyImpact();
          _waveController.reset();
          _glitchController.forward(from: 0.0);
        } else {
          HapticFeedback.lightImpact();
          _glitchController.reset();
          _waveController.forward(from: 0.0);
        }
      }
    });
  }

  @override
  void dispose() {
    _glitchController.dispose();
    _waveController.dispose();
    _statusSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_glitchController, _waveController]),
      builder: (context, child) {
        return Stack(
          children: [
            // الشاشة الأصلية (بتقلب أبيض وأسود لو النت فصل)
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                !_isOnline ? Colors.grey : Colors.transparent,
                BlendMode.saturation,
              ),
              child: widget.child,
            ),

            // 🔴 موجة فصل النت (بدون ألوان - ستايل مطفي)
            if (_glitchController.value > 0.01 &&
                _glitchController.value < 0.99)
              Positioned.fill(
                child: CustomPaint(
                  painter: _IphoneWavePainter(
                    progress: _glitchController.value,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),

            // 🟢 موجة رجوع النت (الذهبية الفخمة)
            if (_waveController.value > 0.01 && _waveController.value < 0.99)
              Positioned.fill(
                child: CustomPaint(
                  painter: _IphoneWavePainter(
                    progress: _waveController.value,
                    color: const Color(0xFFFFE8A1),
                  ),
                ),
              ),

            // 📢 التوست الكريتيف
            _buildSmartToast(),
          ],
        );
      },
    );
  }

  Widget _buildSmartToast() {
    // التوست يظهر لو النت فصل (يفضل ثابت) أو لو الموجة شغالة عند الرجوع
    bool shouldShow =
        !_isOnline ||
        (_waveController.value > 0.1 && _waveController.value < 0.8);

    if (!shouldShow) return const SizedBox.shrink();

    return Positioned(
      bottom: 50.h,
      left: 30.w,
      right: 30.w,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: _isOnline
                ? const Color(0xFF2F3E34).withOpacity(0.9)
                : Colors.redAccent.shade700.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Text(
            _isOnline
                ? "عادت الألوان! تم الاتصال ✅"
                : "أنت تتصفح في وضع السكون (أوفلاين) 🎨",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
              fontFamily: 'ElMessiri',
            ),
          ),
        ),
      ),
    );
  }
}

class _IphoneWavePainter extends CustomPainter {
  final double progress;
  final Color color;
  _IphoneWavePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    final Paint wavePaint = Paint()
      ..color = color.withOpacity((1 - progress) * 0.8)
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = Colors.white.withOpacity((1 - progress) * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 3; i++) {
      double iProgress = (progress - (i * 0.2)).clamp(0.0, 1.0);
      if (iProgress == 0.0) continue;

      double baseRadius = size.height * 0.7 * iProgress;

      Path path = Path();
      const int steps = 100;
      for (int step = 0; step < steps; step++) {
        double angle = (step / steps) * 2 * math.pi;
        double radius =
            baseRadius + (15 * math.sin(angle * (3 + i) + progress * 10));

        double x = centerX + radius * math.cos(angle);
        double y = centerY + radius * math.sin(angle);

        if (step == 0)
          path.moveTo(x, y);
        else
          path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, wavePaint);
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _IphoneWavePainter oldDelegate) => true;
}
