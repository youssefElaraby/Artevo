import 'dart:async';
import 'package:art_by_hager_ismail/feature/portfolio/view_model/portfolio_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/portfolio_model.dart';

class PortfolioCubit extends Cubit<PortfolioState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String artistId = "hager_ismail_profile";
  final String rootCollection = "portfolio_data";

  // تعريف الـ StreamSubscriptions لمنع الـ Memory Leak
  StreamSubscription? _profileSub;
  StreamSubscription? _statsSub;
  StreamSubscription? _servicesSub;
  StreamSubscription? _skillsSub;
  StreamSubscription? _artworksSub;

  PortfolioCubit() : super(PortfolioInitial());

  DocumentReference get _artistDoc =>
      _firestore.collection(rootCollection).doc(artistId);

  // ==========================================
  // 1️⃣ Stream البروفايل (مُحدث ليشمل الاسم)
  // ==========================================
  Stream<ProfileModel> getProfileStream() {
    return _artistDoc.snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return ProfileModel.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      // قيم افتراضية في حالة عدم وجود الوثيقة
      return ProfileModel(imageUrl: '', bio: 'No bio added yet', name: 'Hager Ismail');
    });
  }

  // ==========================================
  // 2️⃣ Stream الإحصائيات (مترتبة بـ order)
  // ==========================================
  Stream<List<StatCardModel>> getStatsStream() {
    return _artistDoc
        .collection("stats")
        .orderBy("order")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => StatCardModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // ==========================================
  // 3️⃣ Stream الخدمات
  // ==========================================
  Stream<List<ServiceModel>> getServicesStream() {
    return _artistDoc
        .collection("services")
        .orderBy("order")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ServiceModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // ==========================================
  // 4️⃣ Stream المهارات
  // ==========================================
  Stream<List<SkillModel>> getSkillsStream() {
    return _artistDoc
        .collection("skills")
        .orderBy("order")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SkillModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // ==========================================
  // 5️⃣ Stream الجاليري (الأعمال الفنية)
  // ==========================================
  Stream<List<ArtworkModel>> getArtworksStream() {
    return _artistDoc
        .collection("artworks")
        .orderBy("order")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ArtworkModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // ✅ تنظيف الذاكرة عند إغلاق الكيوبت
  @override
  Future<void> close() {
    _profileSub?.cancel();
    _statsSub?.cancel();
    _servicesSub?.cancel();
    _skillsSub?.cancel();
    _artworksSub?.cancel();
    return super.close();
  }
}