import 'package:art_by_hager_ismail/feature/home/model/home_settings_model.dart';


abstract class HomeUserState {}

class HomeUserInitial extends HomeUserState {}

// حالة التحميل الكلي لأول مرة فقط (عشان تظهر الهيكل الخارجي للشاشة)
class HomeUserLoading extends HomeUserState {}

class HomeUserSuccess extends HomeUserState {
  // البيانات (لو null معناها لسه بتحمل)
  final List<StoryModel>? stories;
  final List<GalleryItemModel>? gallery;
  final List<PopupModel>? popups;
  final List<EventModel>? events;
  final List<WorkshopModel>? workshops;

  // رسائل الخطأ لكل قسم منفصل
  final String? storiesError;
  final String? galleryError;
  final String? popupsError;
  final String? eventsError;
  final String? workshopsError;

  HomeUserSuccess({
    this.stories,
    this.gallery,
    this.popups,
    this.events,
    this.workshops,
    this.storiesError,
    this.galleryError,
    this.popupsError,
    this.eventsError,
    this.workshopsError,
  });

  // ميثود الـ copyWith هي المحرك الأساسي لتحديث قسم واحد دون التأثير على الباقي
  HomeUserSuccess copyWith({
    List<StoryModel>? stories,
    List<GalleryItemModel>? gallery,
    List<PopupModel>? popups,
    List<EventModel>? events,
    List<WorkshopModel>? workshops,
    String? storiesError,
    String? galleryError,
    String? popupsError,
    String? eventsError,
    String? workshopsError,
  }) {
    return HomeUserSuccess(
      stories: stories ?? this.stories,
      gallery: gallery ?? this.gallery,
      popups: popups ?? this.popups,
      events: events ?? this.events,
      workshops: workshops ?? this.workshops,
      storiesError: storiesError ?? this.storiesError,
      galleryError: galleryError ?? this.galleryError,
      popupsError: popupsError ?? this.popupsError,
      eventsError: eventsError ?? this.eventsError,
      workshopsError: workshopsError ?? this.workshopsError,
    );
  }
}

// حالة خطأ حرجة (لو فشل الاتصال بالسيرفر أصلاً)
class HomeUserCriticalError extends HomeUserState {
  final String message;
  HomeUserCriticalError(this.message);
}