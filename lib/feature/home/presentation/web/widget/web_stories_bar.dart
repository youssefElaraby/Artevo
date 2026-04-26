import 'package:art_by_hager_ismail/feature/home/model/home_settings_model.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb; // ✅ ضروري للتميز بين المنصات
import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

class WebStoriesBar extends StatelessWidget {
  final List<StoryModel>? dynamicStories;
  final String? error;

  const WebStoriesBar({super.key, this.dynamicStories, this.error});

  final List<Map<String, String>> staticStories = const [
    {
      'title': 'ورشة الزيت',
      'img': 'https://images.unsplash.com/photo-1579783902614-a3fb39279623',
    },
    {
      'title': 'كورس الفحم',
      'img': 'https://images.unsplash.com/photo-1513364776144-60967b0f800f',
    },
  ];

  @override
  Widget build(BuildContext context) {
    if (dynamicStories == null && error == null) {
      return _buildShimmerEffect();
    }

    final bool hasDynamicData =
        dynamicStories != null && dynamicStories!.isNotEmpty;
    final displayList = hasDynamicData ? dynamicStories! : [];

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: displayList.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = displayList[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoryDisplayScreen(
                    stories: displayList,
                    initialIndex: index,
                  ),
                ),
              );
            },
            child: _buildStoryItem(item.imageUrl, item.title ?? "جديد"),
          );
        },
      ),
    );
  }

  Widget _buildStoryItem(String img, String name) {
    return SizedBox(
      width: 75,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFF9C5A1A),
                  Color(0xFFD8C9B6),
                  Color(0xFF2F3E34),
                ],
              ),
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFFE8DDCF),
              backgroundImage: NetworkImage(img),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'ElMessiri',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2F3E34),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 13),
        itemCount: 5,
        separatorBuilder: (context, index) => const SizedBox(width: 1),
        itemBuilder: (context, index) => Column(
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: const BoxDecoration(
                color: Color(0xFFD8C9B6),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 45,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFD8C9B6),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StoryDisplayScreen extends StatefulWidget {
  final List<dynamic> stories;
  final int initialIndex;

  const StoryDisplayScreen({
    super.key,
    required this.stories,
    required this.initialIndex,
  });

  @override
  State<StoryDisplayScreen> createState() => _StoryDisplayScreenState();
}

class _StoryDisplayScreenState extends State<StoryDisplayScreen> {
  final StoryController controller = StoryController();
  List<StoryItem> storyItems = [];

  @override
  void initState() {
    super.initState();
    _initStoryItems();
  }

  void _initStoryItems() {
    for (int i = widget.initialIndex; i < widget.stories.length; i++) {
      final story = widget.stories[i];
      String url = story.imageUrl;
      String title = story.title ?? "جديد";

      bool isVideo =
          url.toLowerCase().contains('.mp4') ||
          url.toLowerCase().contains('.mov') ||
          url.toLowerCase().contains('.webm');

      if (isVideo) {
        storyItems.add(
          StoryItem.pageVideo(
            url,
            controller: controller,
            duration: const Duration(seconds: 15),
            caption: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'ElMessiri',
                backgroundColor: Colors.black45,
              ),
            ),
          ),
        );
      } else {
        storyItems.add(
          StoryItem.pageImage(
            url: url,
            controller: controller,
            imageFit: kIsWeb ? BoxFit.contain : BoxFit.cover,
            caption: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'ElMessiri',
                backgroundColor: Colors.black45,
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // حساب العرض المناسب للويب ليكون ريسبونسيف
    double screenWidth = MediaQuery.of(context).size.width;
    double storyWidth = kIsWeb
        ? (screenWidth > 600 ? 450 : screenWidth)
        : screenWidth;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: SizedBox(
              width: storyWidth,
              // حماية: إذا كانت القائمة فارغة لا تظهر StoryView لمنع الخطأ
              child: storyItems.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : StoryView(
                      storyItems: storyItems,
                      controller: controller,
                      onComplete: () => Navigator.pop(context),
                      onVerticalSwipeComplete: (direction) {
                        if (direction == Direction.down) Navigator.pop(context);
                      },
                    ),
            ),
          ),
          Positioned(
            top: 40,
            right: kIsWeb
                ? (screenWidth > 600 ? (screenWidth - 450) / 2 + 20 : 20)
                : 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 35),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
