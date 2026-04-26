import 'package:art_by_hager_ismail/feature/booking/model/booking_model.dart';
import 'package:art_by_hager_ismail/feature/booking/view_model/booking/booking_state.dart';
import 'package:art_by_hager_ismail/services/booking_service.dart';
import 'package:art_by_hager_ismail/services/user_session_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingService _service;
  final UserSessionService _sessionService;

  BookingCubit(this._service, this._sessionService) : super(BookingInitial());

  /// ===============================
  /// Create booking
  /// ===============================
  Future<void> createBooking(BookingModel booking) async {
    // 🛡️ حماية إضافية: لو الكيوبت في حالة تحميل حالياً، اخرج فوراً لمنع التكرار
    if (state is BookingLoading) return;

    emit(BookingLoading());
    try {
      // 1️⃣ التأكد من توفر مكان (فقط إذا كان sessionId موجوداً في قائمة الورش)
      if (booking.sessionId != null) {
        try {
          final sessions = await _sessionService.getSessionsOnce();
          // البحث عن السيشن بحذر
          final currentSession = sessions.firstWhere(
            (s) => s.id == booking.sessionId,
          );

          // لو لقاها وطلعت مليانة.. يرفض الحجز
          if (currentSession.bookedCount >= currentSession.capacity) {
            emit(BookingError("للأسف، اكتمل عدد الأماكن في هذه الورشة مؤخراً"));
            return;
          }
        } catch (e) {
          // لو ملقاش الـ ID في الـ Sessions يبقى ده Event عام
          print(
            "Note: Session ID not found in Sessions list, assuming it's a general Event.",
          );
        }
      }

      // 2️⃣ كمل خطوات الحجز والرفع لـ Cloudinary والـ Firestore
      // دي الخطوة اللي بتاخد وقت، والحماية فوق بتمنع دخول طلب تاني أثناء تنفيذها
      await _service.createBooking(booking);

      // 3️⃣ زيادة عدد المحجوزين (فقط لو كان سيشن موجود فعلاً)
      if (booking.sessionId != null) {
        try {
          await _sessionService.incrementBookedCount(booking.sessionId!);
        } catch (_) {
          // تجاهل الخطأ لو فشل التحديث في عداد السيشنز طالما الحجز الأصلي تم
        }
      }

      emit(BookingSuccess("تم الحجز بنجاح"));
    } catch (e) {
      print("Error in createBooking Cubit: $e");
      emit(BookingError("فشل الحجز: $e"));
    }
  }

  /// ===============================
  /// Update booking status (pending, approved, rejected, completed)
  /// ===============================
  Future<void> updateStatus(
    String bookingId,
    String status, {
    String? reason,
  }) async {
    if (state is BookingLoading) return; // حماية من تكرار الضغط

    emit(BookingLoading());
    try {
      await _service.updateBookingStatus(
        bookingId,
        status,
        cancellationReason: reason,
      );
      emit(BookingSuccess("Booking status updated"));
    } catch (e) {
      emit(BookingError("Failed to update status: $e"));
    }
  }

  /// ===============================
  /// Add feedback and rating
  /// ===============================
  Future<void> addFeedback(
    String bookingId,
    String feedback,
    int rating,
  ) async {
    if (state is BookingLoading) return; // حماية

    emit(BookingLoading());
    try {
      await _service.addFeedback(bookingId, feedback, rating);
      emit(BookingSuccess("Feedback added successfully"));
    } catch (e) {
      emit(BookingError("Failed to add feedback: $e"));
    }
  }

  /// ===============================
  /// Fetch bookings for the current user only
  /// ===============================
  Future<void> fetchBookings({required String userId}) async {
    emit(BookingListLoading());
    try {
      final userBookings = await _service.getBookingsByUser(userId);
      emit(BookingListLoaded(userBookings));
    } catch (e) {
      emit(BookingListError("Failed to fetch bookings: $e"));
    }
  }

  void emitEmptyBookings() {
    emit(BookingListLoaded([]));
  }
}
