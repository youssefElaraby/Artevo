// ==========================================
// 1. Enums - أنواع الأعمال الفنية
// ==========================================
enum ArtworkType { painting, drawing, digital, sculpture, other }

// ==========================================
// 2. Profile Model - مُحدث لإضافة حقل الاسم
// ==========================================
class ProfileModel {
  final String imageUrl;
  final String bio;
  final String name; // ✅ تم إضافة الاسم

  ProfileModel({required this.imageUrl, required this.bio, required this.name});

  factory ProfileModel.fromMap(Map<String, dynamic> map) => ProfileModel(
    imageUrl: map['imageUrl'] ?? '',
    bio: map['bio'] ?? '',
    name: map['name'] ?? 'Hager Ismail', // قيمة افتراضية
  );

  Map<String, dynamic> toMap() => {
    'imageUrl': imageUrl,
    'bio': bio,
    'name': name,
  };
}

// ==========================================
// 3. StatCard Model - الإحصائيات
// ==========================================
class StatCardModel {
  final String id;
  final String title;
  final String value;
  final int order;

  StatCardModel({
    required this.id,
    required this.title,
    required this.value,
    required this.order,
  });

  factory StatCardModel.fromMap(String id, Map<String, dynamic> map) =>
      StatCardModel(
        id: id,
        title: map['title'] ?? '',
        value: map['value'] ?? '',
        order: map['order'] ?? 0,
      );

  Map<String, dynamic> toMap() => {
    'title': title,
    'value': value,
    'order': order,
  };
}

// ==========================================
// 4. Service Model - الخدمات
// ==========================================
class ServiceModel {
  final String id;
  final String title;
  final int order;

  ServiceModel({required this.id, required this.title, required this.order});

  factory ServiceModel.fromMap(String id, Map<String, dynamic> map) =>
      ServiceModel(id: id, title: map['title'] ?? '', order: map['order'] ?? 0);

  Map<String, dynamic> toMap() => {'title': title, 'order': order};
}

// ==========================================
// 5. Skill Model - المهارات
// ==========================================
class SkillModel {
  final String id;
  final String name;
  final int percentage;
  final int order;

  SkillModel({
    required this.id,
    required this.name,
    required this.percentage,
    required this.order,
  });

  factory SkillModel.fromMap(String id, Map<String, dynamic> map) => SkillModel(
    id: id,
    name: map['name'] ?? '',
    percentage: map['percentage'] ?? 0,
    order: map['order'] ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'percentage': percentage,
    'order': order,
  };
}

// ==========================================
// 6. Artwork Model - الجاليري
// ==========================================
class ArtworkModel {
  final String id;
  final String title;
  final String description;
  final List<String> images;
  final ArtworkType type;
  final int order;
  final DateTime createdAt;

  ArtworkModel({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.type,
    required this.order,
    required this.createdAt,
  });

  factory ArtworkModel.fromMap(String id, Map<String, dynamic> map) =>
      ArtworkModel(
        id: id,
        title: map['title'] ?? '',
        description: map['description'] ?? '',
        images: List<String>.from(map['images'] ?? []),
        type: ArtworkType.values.firstWhere(
          (e) => e.toString() == map['type'],
          orElse: () => ArtworkType.other,
        ),
        order: map['order'] ?? 0,
        createdAt: (map['createdAt'] != null)
            ? (map['createdAt'] as dynamic).toDate()
            : DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'images': images,
    'type': type.toString(),
    'order': order,
    'createdAt': createdAt,
  };
}

// ==========================================
// 7. Achievement Model - الإنجازات
// ==========================================
class AchievementModel {
  final String id;
  final String title;
  final String date;
  final int order;

  AchievementModel({
    required this.id,
    required this.title,
    required this.date,
    required this.order,
  });

  factory AchievementModel.fromMap(String id, Map<String, dynamic> map) =>
      AchievementModel(
        id: id,
        title: map['title'] ?? '',
        date: map['date'] ?? '',
        order: map['order'] ?? 0,
      );

  Map<String, dynamic> toMap() => {
    'title': title,
    'date': date,
    'order': order,
  };
}
