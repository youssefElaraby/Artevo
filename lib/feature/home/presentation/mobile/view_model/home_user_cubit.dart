import 'package:art_by_hager_ismail/feature/home/presentation/mobile/view_model/home_user_state.dart';
import 'package:art_by_hager_ismail/services/home_services.dart';
import 'package:art_by_hager_ismail/feature/home/model/home_settings_model.dart'; // تأكد من استيراد الموديل
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeUserCubit extends Cubit<HomeUserState> {
  final HomeUserService service;

  HomeUserCubit(this.service) : super(HomeUserInitial()) {
    print('🏗️ [CUBIT] HomeUserCubit Created in Memory');
  }

  void initHome() {
    print('🚀 [CUBIT] initHome() TRIGGERED');

    emit(HomeUserSuccess());

    Future.wait([
      loadStories(),
      loadEvents(),
      loadPopups(),
      loadGallery(),
      loadWorkshops(),
    ]);
  }

  Future<void> loadStories() async {
    print('📸 [FETCH] Fetching Stories (Image + Title)...');
    await _loadSection<List<StoryModel>>(
      fetch: service.getStories,
      onSuccess: (state, data) {
        print(
          '✅ [SUCCESS] Stories: ${data.length} items. First Title: ${data.isNotEmpty ? data.first.title : 'N/A'}',
        );
        return state.copyWith(stories: data, storiesError: null);
      },
      onError: (state, error) => state.copyWith(storiesError: error),
    );
  }

  Future<void> loadWorkshops() async {
    print('🛠️ [FETCH] Fetching Workshops (Image + Category)...');
    await _loadSection<List<WorkshopModel>>(
      fetch: service.getActiveWorkshops,
      onSuccess: (state, data) {
        print(
          '✅ [SUCCESS] Workshops: ${data.length} items. First Category: ${data.isNotEmpty ? data.first.category : 'N/A'}',
        );
        return state.copyWith(workshops: data, workshopsError: null);
      },
      onError: (state, error) => state.copyWith(workshopsError: error),
    );
  }

  Future<void> loadEvents() async {
    print('📅 [FETCH] Fetching Events...');
    await _loadSection<List<EventModel>>(
      fetch: service.getActiveEvents,
      onSuccess: (state, data) =>
          state.copyWith(events: data, eventsError: null),
      onError: (state, error) => state.copyWith(eventsError: error),
    );
  }

  Future<void> loadPopups() async {
    print('🖼️ [FETCH] Fetching Popups...');
    await _loadSection<List<PopupModel>>(
      fetch: service.getActivePopups,
      onSuccess: (state, data) =>
          state.copyWith(popups: data, popupsError: null),
      onError: (state, error) => state.copyWith(popupsError: error),
    );
  }

  Future<void> loadGallery() async {
    print('🎨 [FETCH] Fetching Gallery...');
    await _loadSection<List<GalleryItemModel>>(
      fetch: service.getGalleryItems,
      onSuccess: (state, data) =>
          state.copyWith(gallery: data, galleryError: null),
      onError: (state, error) => state.copyWith(galleryError: error),
    );
  }

  // الـ Loader الذكي المعدل ليكون Type-Safe
  Future<void> _loadSection<T>({
    required Future<T> Function() fetch,
    required HomeUserSuccess Function(HomeUserSuccess state, T data) onSuccess,
    required HomeUserSuccess Function(HomeUserSuccess state, String error)
    onError,
  }) async {
    try {
      final data = await fetch();
      if (state is HomeUserSuccess) {
        emit(onSuccess(state as HomeUserSuccess, data));
      }
    } catch (e) {
      print('🔥 [CRITICAL] Exception in _loadSection: $e');
      if (state is HomeUserSuccess) {
        emit(onError(state as HomeUserSuccess, e.toString()));
      }
    }
  }
}
