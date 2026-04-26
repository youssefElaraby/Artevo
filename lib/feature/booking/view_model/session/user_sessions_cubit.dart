import 'package:art_by_hager_ismail/feature/booking/view_model/session/user_sessions_state.dart';
import 'package:art_by_hager_ismail/services/user_session_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



class UserSessionsCubit extends Cubit<UserSessionsState> {
  final UserSessionService _service;

  UserSessionsCubit(this._service) : super(UserSessionsInitial());

  Future<void> fetchSessions() async {
    emit(UserSessionsLoading());
    try {
      final sessions = await _service.getSessionsOnce();
      if (!isClosed) {
        emit(UserSessionsLoaded(sessions));
      }
    } catch (e) {
      if (!isClosed) {
        emit(UserSessionsError("حدث خطأ: ${e.toString()}"));
      }
    }
  }
}