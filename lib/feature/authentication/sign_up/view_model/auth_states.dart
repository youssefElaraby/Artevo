import '../model/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserModel userModel;

  AuthSuccess({required this.userModel});
}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure({required this.message});
  
}
class AuthLoggedOut extends AuthState {}
