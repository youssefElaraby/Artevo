// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:lottie/lottie.dart';
// import 'package:url_launcher/url_launcher.dart';

// class SocialFAB extends StatefulWidget {
//   const SocialFAB({super.key});

//   @override
//   State<SocialFAB> createState() => _SocialFABState();
// }

// class _SocialFABState extends State<SocialFAB>
//     with SingleTickerProviderStateMixin {
//   bool isOpen = false;
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 250),
//     );
//     _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   void toggle() {
//     if (isOpen) {
//       _controller.reverse();
//     } else {
//       _controller.forward();
//     }
//     setState(() {
//       isOpen = !isOpen;
//     });
//   }

//   void _launchUrl(String url) async {
//     Uri uri = Uri.parse(url);
//     try {
//       if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
//         debugPrint("Could not launch $url");
//       }
//     } catch (e) {
//       debugPrint("Error launching URL: $e");
//     }
//   }

//   /// 🌟 FAB مع خلفية ودائرة ولوتي أصغر
//   Widget _fabWithLottie(
//     String path,
//     String url,
//     double bottomOffset,
//     Color bgColor,
//   ) {
//     return AnimatedPositioned(
//       duration: const Duration(milliseconds: 300),
//       bottom: isOpen ? bottomOffset.h : 200.h,
//       right: 30.w,
//       child: Opacity(
//         opacity: isOpen ? 1 : 0,
//         child: FloatingActionButton(
//           heroTag: path,
//           onPressed: () => _launchUrl(url),
//           backgroundColor: bgColor,
//           elevation: 4,
//           child: SizedBox(
//             width: 50.w,
//             height: 50.h,
//             child: Padding(
//               padding: const EdgeInsets.all(
//                 7.0,
//               ), // خلى اللوتي أصغر داخل الدائرة
//               child: kIsWeb
//                   ? Lottie.network(path, repeat: true)
//                   : Lottie.asset(path, repeat: true),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       alignment: Alignment.bottomRight,
//       children: [
//         _fabWithLottie(
//           'assets/image/WhatsApp.json',
//           'https://wa.me/201097627239',
//           150,
//           Colors.green,
//         ),
//         _fabWithLottie(
//           'assets/image/instagram icon.json',
//           'https://www.instagram.com/hagerismailll/',
//           220,
//           Colors.purple,
//         ),
//         _fabWithLottie(
//           'assets/image/facebook icon.json',
//           'https://www.facebook.com/share/14Vwi4u7yz2/',
//           290,
//           Colors.blue,
//         ),
//         _fabWithLottie(
//           'assets/image/tiktok icon.json',
//           'https://www.tiktok.com/@hagerismailll',
//           360,
//           Colors.black,
//         ),

//         Positioned(
//           bottom: 100.h,
//           right: 20.w,
//           child: FloatingActionButton(
//             heroTag: 'main',
//             onPressed: toggle,
//             backgroundColor: const Color.fromARGB(
//               255,
//               55,
//               87,
//               65,
//             ).withOpacity(0.7),
//             elevation: 4,
//             child: SizedBox(
//               width: 60.w,
//               height: 60.h,
//               child: Padding(
//                 padding: const EdgeInsets.all(6.0),
//                 child: kIsWeb
//                     ? Lottie.network(
//                         'assets/image/Contact us.json',
//                         repeat: true,
//                       )
//                     : Lottie.asset(
//                         'assets/image/Contact us.json',
//                         repeat: true,
//                       ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
