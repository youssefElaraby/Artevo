import 'package:art_by_hager_ismail/feature/booking/model/booking_model.dart';

abstract class BookingState {}

/// =======================
/// Old States (DON'T TOUCH)
/// =======================

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingSuccess extends BookingState {
  final String message;
  BookingSuccess(this.message);
}

class BookingError extends BookingState {
  final String message;
  BookingError(this.message);
}

class BookingLoaded extends BookingState {
  final List<BookingModel> bookings;
  BookingLoaded(this.bookings);
}

/// =======================
/// NEW STATES (Activity)
/// =======================

class BookingListLoading extends BookingState {}

class BookingListLoaded extends BookingState {
  final List<BookingModel> bookings;
  BookingListLoaded(this.bookings);
}

class BookingListError extends BookingState {
  final String message;
  BookingListError(this.message);
}
