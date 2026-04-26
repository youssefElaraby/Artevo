import 'package:art_by_hager_ismail/feature/booking/model/booking_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cloudinary_service.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  final String collectionName = "bookings";

  /// ===============================
  /// Create booking
  /// ===============================
  Future<void> createBooking(BookingModel booking) async {
    try {
      // Upload payment image if exists
      if (booking.paymentImageBytes != null) {
        final paymentUrl = await _cloudinaryService.uploadImage(
          imageBytes: booking.paymentImageBytes!,
          folder: "bookings",
          fileName: "payment_${DateTime.now().millisecondsSinceEpoch}",
        );
        booking.paymentImageUrl = paymentUrl;
      }

      // Save booking to Firestore
      await _firestore
          .collection(collectionName)
          .doc(booking.id)
          .set(booking.toMap());

      print("✅ Booking Created: ${booking.toMap()}");
    } catch (e) {
      print("❌ Error creating booking: $e");
      rethrow;
    }
  }

  /// ===============================
  /// Update booking status (pending, completed, cancelled)
  /// ===============================
  Future<void> updateBookingStatus(
    String bookingId,
    String status, {
    String? cancellationReason,
  }) async {
    try {
      final Map<String, dynamic> updateData = {"status": status};
      if (cancellationReason != null) {
        updateData["cancellationReason"] = cancellationReason;
      }

      await _firestore.collection(collectionName).doc(bookingId).update(updateData);

      print("✅ Booking $bookingId status updated to $status");
    } catch (e) {
      print("❌ Error updating booking status: $e");
      rethrow;
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
    try {
      await _firestore.collection(collectionName).doc(bookingId).update({
        "feedback": feedback,
        "rating": rating,
      });

      print("✅ Feedback added to $bookingId: $feedback, rating: $rating");
    } catch (e) {
      print("❌ Error adding feedback: $e");
      rethrow;
    }
  }

 
  Future<BookingModel?> getBooking(String bookingId) async {
    try {
      final doc = await _firestore.collection(collectionName).doc(bookingId).get();
      if (!doc.exists) return null;
      return BookingModel.fromMap(doc.data()!);
    } catch (e) {
      print("❌ Error getting booking $bookingId: $e");
      return null;
    }
  }

  /// ===============================
  /// Get bookings filtered by user (or all if userId is null)
  /// ===============================
  Future<List<BookingModel>> getBookingsByUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .where("userId", isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("❌ Error getting bookings for user $userId: $e");
      return [];
    }
  }

  /// ===============================
  /// Get all bookings (no filter)
  /// ===============================
  Future<List<BookingModel>> getAllBookings() async {
    try {
      final snapshot = await _firestore.collection(collectionName).get();

      return snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("❌ Error getting all bookings: $e");
      return [];
    }
  }
}
