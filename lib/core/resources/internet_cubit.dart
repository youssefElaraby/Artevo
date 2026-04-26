import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum InternetState { initial, connected, disconnected }

class InternetCubit extends Cubit<InternetState> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;

  InternetCubit() : super(InternetState.initial) {
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      // connectivity_plus بترجع لستة في الإصدارات الجديدة
      if (result.contains(ConnectivityResult.none)) {
        emit(InternetState.disconnected);
      } else {
        emit(InternetState.connected);
      }
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}