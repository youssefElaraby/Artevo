import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';
import 'package:art_by_hager_ismail/feature/home/model/home_settings_model.dart';

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
    // تثبيت المدة لكل شيء (صور وفيديو)
    const fixedDuration = Duration(seconds: 5);

    for (int i = widget.initialIndex; i < widget.stories.length; i++) {
      final story = widget.stories[i];
      String url = (story is StoryModel) ? story.imageUrl : story['img']!;
      String title = (story is StoryModel) ? "جديد" : story['name']!;

      bool isVideo = url.toLowerCase().contains('.mp4') ||
          url.toLowerCase().contains('.mov') ||
          url.toLowerCase().contains('/video/upload/') ||
          url.toLowerCase().contains('.webm');

      if (isVideo) {
        storyItems.add(
          StoryItem.pageVideo(
            url,
            controller: controller,
            // الإضافة المهمة هنا عشان يلتزم بالـ 5 ثواني
            duration: fixedDuration, 
            caption: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'ElMessiri',
              ),
            ),
          ),
        );
      } else {
        storyItems.add(
          StoryItem.pageImage(
            url: url,
            controller: controller,
            duration: fixedDuration,
            caption: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'ElMessiri',
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
    if (storyItems.isEmpty) return const SizedBox();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          StoryView(
            storyItems: storyItems,
            controller: controller,
            repeat: false,
            onComplete: () => Navigator.pop(context),
            onVerticalSwipeComplete: (direction) {
              if (direction == Direction.down) Navigator.pop(context);
            },
          ),
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}