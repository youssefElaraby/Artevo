

import 'package:art_by_hager_ismail/feature/booking/model/session_model.dart';

abstract class UserSessionsState {}

class UserSessionsInitial extends UserSessionsState {}

class UserSessionsLoading extends UserSessionsState {}

class UserSessionsLoaded extends UserSessionsState {
  final List<SessionModel> sessions;
  UserSessionsLoaded(this.sessions);
}

class UserSessionsError extends UserSessionsState {
  final String message;
  UserSessionsError(this.message);
}