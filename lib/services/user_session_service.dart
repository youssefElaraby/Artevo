import 'package:art_by_hager_ismail/feature/booking/model/session_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserSessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = "sessions_places";

  /// 1️⃣ جلب البيانات مرة واحدة فقط (Future)
  Future<List<SessionModel>> getSessionsOnce() async {
    try {
      final snap = await _firestore
          .collection(collectionName)
          .where('isVisible', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get(const GetOptions(source: Source.serverAndCache));

      return snap.docs
          .map((doc) => SessionModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// 2️⃣ تحديث عداد الأماكن المحجوزة 🔥
  /// الميثود دي بتنقص مكان من المتاح عن طريق زيادة الـ bookedCount
  Future<void> incrementBookedCount(String sessionId) async {
    try {
      await _firestore.collection(collectionName).doc(sessionId).update({
        'bookedCount': FieldValue.increment(
          1,
        ), // زيادة العداد بمقدار 1 في السيرفر
      });
    } catch (e) {
      print("Error updating bookedCount: $e");
      rethrow;
    }
  }
}
