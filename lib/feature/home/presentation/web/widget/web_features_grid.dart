import 'package:flutter/material.dart';

class WebFeaturesGrid extends StatelessWidget {
  const WebFeaturesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // لو الشاشة أصغر من 900 بكسل، الكروت هتيجي تحت بعض
        bool isCompact = constraints.maxWidth < 900;

        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: 40,
            // البادنج الجانبي بيبقى صفر هنا لأننا واخدينه في الـ HomeWebView الأب
            horizontal: 0,
          ),
          child: isCompact
              ? Column(
                  children: [
                    _FeatureCard(
                      title: "كل المستويات",
                      desc: "سواء مبتدئ أو محترف، ليك مكان عندنا.",
                      icon: Icons.brush_rounded,
                    ),
                    const SizedBox(height: 20),
                    _FeatureCard(
                      title: "أجواء ملهمة",
                      desc: "إضاءة طبيعية، موسيقى هادية ومشروبات مجانية.",
                      icon: Icons.coffee_rounded,
                    ),
                    const SizedBox(height: 20),
                    _FeatureCard(
                      title: "أدوات احترافية",
                      desc: "كل الخامات والأدوات متاحة ليك مجاناً.",
                      icon: Icons.palette_rounded,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _FeatureCard(
                        title: "كل المستويات",
                        desc: "سواء مبتدئ أو محترف، ليك مكان عندنا.",
                        icon: Icons.brush_rounded,
                      ),
                    ),
                    const SizedBox(width: 25),
                    Expanded(
                      child: _FeatureCard(
                        title: "أجواء ملهمة",
                        desc: "إضاءة طبيعية، موسيقى هادية ومشروبات مجانية.",
                        icon: Icons.coffee_rounded,
                      ),
                    ),
                    const SizedBox(width: 25),
                    Expanded(
                      child: _FeatureCard(
                        title: "أدوات احترافية",
                        desc: "كل الخامات والأدوات متاحة ليك مجاناً.",
                        icon: Icons.palette_rounded,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

// كلاس منفصل للكارت عشان نتحكم في الـ Hover State
class _FeatureCard extends StatefulWidget {
  final String title;
  final String desc;
  final IconData icon;

  const _FeatureCard({
    required this.title,
    required this.desc,
    required this.icon,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          // حركة الظل لما الماوس ييجي على الكارت
          boxShadow: [
            BoxShadow(
              color: isHovered
                  ? const Color(0xFF2F3E34).withOpacity(0.1)
                  : const Color(0xFF2F3E34).withOpacity(0.03),
              blurRadius: isHovered ? 30 : 15,
              offset: isHovered ? const Offset(0, 15) : const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: isHovered
                ? const Color(0xFF9C5A1A).withOpacity(0.5)
                : const Color(0xFFD8C9B6).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            // أيقونة بتتحرك لفوق شوية في الـ Hover
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              transform: Matrix4.translationValues(0, isHovered ? -10 : 0, 0),
              child: Icon(
                widget.icon,
                size: 55,
                color: const Color(0xFF9C5A1A),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'ElMessiri',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2F3E34),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              widget.desc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6F624C),
                height: 1.6,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
