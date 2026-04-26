import 'package:art_by_hager_ismail/feature/home/model/home_settings_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeUserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String mainColl = "home_management";
  final String contentDoc = "content";

  // دالة المسار الموحدة
  CollectionReference _getColl(String section) {
    return _db.collection(mainColl).doc(contentDoc).collection(section);
  }

  // 1. القصص (Stories) - بتسحب الـ title الجديد (صورة وكلمة)
  Future<List<StoryModel>> getStories() async {
    print('📡 [SERVICE] Fetching Stories (Image + Title)...');
    try {
      final snap = await _getColl(
        'stories',
      ).orderBy('createdAt', descending: true).get();

      print('✅ [SERVICE] Stories found: ${snap.docs.length}');
      return snap.docs
          .map(
            (d) => StoryModel.fromMap(d.data() as Map<String, dynamic>, d.id),
          )
          .toList();
    } catch (e) {
      print('❌ [SERVICE] Error in getStories: $e');
      return [];
    }
  }

  // 2. الجاليري (Gallery)
  Future<List<GalleryItemModel>> getGalleryItems() async {
    print('📡 [SERVICE] Fetching Gallery...');
    try {
      final snap = await _getColl(
        'gallery',
      ).orderBy('createdAt', descending: true).get();

      print('✅ [SERVICE] Gallery items found: ${snap.docs.length}');
      return snap.docs
          .map(
            (d) => GalleryItemModel.fromMap(
              d.data() as Map<String, dynamic>,
              d.id,
            ),
          )
          .toList();
    } catch (e) {
      print('❌ [SERVICE] Error in getGalleryItems: $e');
      return [];
    }
  }

  // 3. البانرات (Popups)
  Future<List<PopupModel>> getActivePopups() async {
    print('📡 [SERVICE] Fetching Active Popups...');
    try {
      final snap = await _getColl(
        'popups',
      ).where('showPopup', isEqualTo: true).get();

      print('✅ [SERVICE] Popups found: ${snap.docs.length}');
      return snap.docs
          .map(
            (d) => PopupModel.fromMap(d.data() as Map<String, dynamic>, d.id),
          )
          .toList();
    } catch (e) {
      print('❌ [SERVICE] Error in getActivePopups: $e');
      return [];
    }
  }

  // 4. الفعاليات (Events)
  Future<List<EventModel>> getActiveEvents() async {
    print('📡 [SERVICE] Fetching Active Events...');
    try {
      final snap = await _getColl('events')
          .where('isEventActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      print('✅ [SERVICE] Events found: ${snap.docs.length}');
      return snap.docs
          .map(
            (d) => EventModel.fromMap(d.data() as Map<String, dynamic>, d.id),
          )
          .toList();
    } catch (e) {
      print('❌ [SERVICE] Error in getActiveEvents: $e');
      return [];
    }
  }

  // 5. الورش (Workshops) - تم التعديل لجلب الـ Image والـ Category (نوع الورشة)
  Future<List<WorkshopModel>> getActiveWorkshops() async {
    print(
      '📡 [SERVICE] Fetching Active Workshops (with Images & Categories)...',
    );
    try {
      final snap = await _getColl('workshops')
          .where('isShow', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      print('✅ [SERVICE] Workshops found: ${snap.docs.length}');
      return snap.docs
          .map(
            (d) =>
                WorkshopModel.fromMap(d.data() as Map<String, dynamic>, d.id),
          )
          .toList();
    } catch (e) {
      print('❌ [SERVICE] Error in getActiveWorkshops: $e');
      return [];
    }
  }
}
