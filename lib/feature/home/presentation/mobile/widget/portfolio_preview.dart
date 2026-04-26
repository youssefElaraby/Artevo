import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:video_player/video_player.dart';

class PortfolioPreview extends StatelessWidget {
  final List<dynamic>? galleryItems;

  const PortfolioPreview({super.key, this.galleryItems});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double carouselHeight = screenWidth < 600 ? 160.h : 300.h;

    if (galleryItems == null || galleryItems!.isEmpty) {
      return const SizedBox.shrink();
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: carouselHeight,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        enlargeCenterPage: true,
        viewportFraction: screenWidth < 600 ? 0.9 : 0.7,
      ),
      items: galleryItems!.map((item) {
        // تأكد أن الكي هو 'url' كما في الـ Document الخاص بك
        final String? itemUrl = item.url;

        if (itemUrl == null || itemUrl.isEmpty) {
          return _buildPlaceholder(carouselHeight, Icons.image_not_supported);
        }

        final bool isVideo =
            itemUrl.toLowerCase().contains('.mp4') ||
            itemUrl.toLowerCase().contains('/video/upload/');

        return ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: isVideo
              ? VideoPreviewWidget(url: itemUrl)
              : Image.network(
                  itemUrl,
                  width: double.infinity,
                  height: carouselHeight,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) =>
                      _buildPlaceholder(carouselHeight, Icons.broken_image),
                ),
        );
      }).toList(),
    );
  }

  Widget _buildPlaceholder(double height, IconData icon) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(icon, color: Colors.grey[500], size: 40),
    );
  }
}

// --- ويدجت الفيديو في نفس الملف عشان الإيرور يختفي ---
class VideoPreviewWidget extends StatefulWidget {
  final String url;
  const VideoPreviewWidget({super.key, required this.url});

  @override
  State<VideoPreviewWidget> createState() => _VideoPreviewWidgetState();
}

class _VideoPreviewWidgetState extends State<VideoPreviewWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.setVolume(0); // صامت
          _controller.setLooping(true);
          _controller.play();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        color: const Color(0xFFD8C9B6),
        child: const Center(
          child: Icon(
            Icons.play_circle_outline,
            color: Colors.white24,
            size: 48,
          ),
        ),
      );
    }
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}
