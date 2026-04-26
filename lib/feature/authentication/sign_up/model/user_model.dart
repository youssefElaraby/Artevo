class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String? profileImageUrl;
  // 🚀 الحقل الجديد: قائمة بالعناوين الفريدة لكل أجهزة اليوزر
  final List<String>? fcmTokens;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    this.profileImageUrl,
    this.fcmTokens, // ضفناه هنا كاختياري
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      // 📥 حفظ القائمة في الفاير ستور
      'fcmTokens': fcmTokens ?? [],
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      phone: map['phone'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      // 📤 سحب القائمة من الفاير ستور والتأكد إنها List<String>
      fcmTokens: map['fcmTokens'] != null
          ? List<String>.from(map['fcmTokens'])
          : [],
    );
  }
}
