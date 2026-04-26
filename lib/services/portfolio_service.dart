import 'package:art_by_hager_ismail/feature/portfolio/model/portfolio_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/adapters.dart';

class PortfolioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // الوصول لصندوق الكاش (تأكد من فتحه في الـ main)
  final _cache = Hive.box('portfolio_cache');

  // الثوابت الخاصة بالفايربيز
  final String rootCollection = "portfolio_data";
  final String artistId = "hager_ismail_profile";

  DocumentReference get _artistDoc =>
      _firestore.collection(rootCollection).doc(artistId);

  // --- [ 💡 منطق الكاش ] ---

  void _saveToCache(String key, dynamic data) {
    if (data is List) {
      _cache.put(key, data.map((e) => e.toMap()).toList());
    } else {
      _cache.put(key, data.toMap());
    }
  }

  dynamic _getFromCache(String key) => _cache.get(key);

  // --- [ 🚀 دوال جلب البيانات ] ---

  /// 1. جلب البروفايل (مُحدث بالاسم)
  Future<ProfileModel> fetchProfile() async {
    try {
      final doc = await _artistDoc.get();
      if (doc.exists && doc.data() != null) {
        final profile = ProfileModel.fromMap(doc.data() as Map<String, dynamic>);
        _saveToCache('profile', profile);
        return profile;
      }
    } catch (e) {
      final cached = _getFromCache('profile');
      if (cached != null) {
        return ProfileModel.fromMap(Map<String, dynamic>.from(cached));
      }
    }
    // قيم افتراضية لو مفيش إنترنت ولا كاش
    return ProfileModel(imageUrl: '', bio: 'No bio added yet', name: 'Hager Ismail');
  }

  /// 2. جلب الإحصائيات
  Future<List<StatCardModel>> fetchStats() async {
    try {
      final snap = await _artistDoc.collection("stats").orderBy("order").get();
      final stats = snap.docs.map((doc) => StatCardModel.fromMap(doc.id, doc.data())).toList();
      _saveToCache('stats', stats);
      return stats;
    } catch (e) {
      final cached = _getFromCache('stats');
      if (cached != null) {
        return (cached as List).map((e) => StatCardModel.fromMap('', Map<String, dynamic>.from(e))).toList();
      }
      return [];
    }
  }

  /// 3. جلب الخدمات
  Future<List<ServiceModel>> fetchServices() async {
    try {
      final snap = await _artistDoc.collection("services").orderBy("order").get();
      final services = snap.docs.map((doc) => ServiceModel.fromMap(doc.id, doc.data())).toList();
      _saveToCache('services', services);
      return services;
    } catch (e) {
      final cached = _getFromCache('services');
      if (cached != null) {
        return (cached as List).map((e) => ServiceModel.fromMap('', Map<String, dynamic>.from(e))).toList();
      }
      return [];
    }
  }

  /// 4. جلب المهارات
  Future<List<SkillModel>> fetchSkills() async {
    try {
      final snap = await _artistDoc.collection("skills").orderBy("order").get();
      final skills = snap.docs.map((doc) => SkillModel.fromMap(doc.id, doc.data())).toList();
      _saveToCache('skills', skills);
      return skills;
    } catch (e) {
      final cached = _getFromCache('skills');
      if (cached != null) {
        return (cached as List).map((e) => SkillModel.fromMap('', Map<String, dynamic>.from(e))).toList();
      }
      return [];
    }
  }

  /// 5. جلب الأعمال الفنية (الجاليري)
  Future<List<ArtworkModel>> fetchArtworks() async {
    try {
      final snap = await _artistDoc.collection("artworks").orderBy("order").get();
      final artworks = snap.docs.map((doc) => ArtworkModel.fromMap(doc.id, doc.data())).toList();
      _saveToCache('artworks', artworks);
      return artworks;
    } catch (e) {
      final cached = _getFromCache('artworks');
      if (cached != null) {
        return (cached as List).map((e) => ArtworkModel.fromMap('', Map<String, dynamic>.from(e))).toList();
      }
      return [];
    }
  }
}