import 'dart:typed_data';

class BookingModel {
  final String id;
  final String userId;
  final String? sessionId; // 🔥 حقل لربط الحجز بالسيشن الديناميكية
  final String? placeName;
  final bool isPrivate;
  final DateTime date;
  final String time;
  final String name;
  final String phone;
  final String? notes;
  final double? price; // 🔥 حقل لتسجيل السعر وقت الحجز
  final DateTime createdAt; // 🆕 حقل تاريخ إنشاء الحجز (للتحليلات)
  String? paymentImageUrl;
  final String? cancellationReason;
  final double? rating;
  final String? feedback;
  final String status;

  Uint8List? paymentImageBytes;

  BookingModel({
    required this.id,
    required this.userId,
    this.sessionId,
    this.placeName,
    required this.isPrivate,
    required this.date,
    required this.time,
    required this.name,
    required this.phone,
    required this.createdAt, // أضفناه هنا
    this.notes,
    this.price,
    this.paymentImageUrl,
    this.paymentImageBytes,
    this.cancellationReason,
    this.rating,
    this.feedback,
    required this.status,
  });

  // =======================
  // 🔹 TO MAP
  // =======================
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'sessionId': sessionId,
      'placeName': placeName,
      'isPrivate': isPrivate,
      'date': date.toIso8601String(),
      'time': time,
      'name': name,
      'phone': phone,
      'notes': notes,
      'price': price,
      'createdAt': createdAt.toIso8601String(), // أضفناه هنا
      'paymentImageUrl': paymentImageUrl,
      'cancellationReason': cancellationReason,
      'rating': rating,
      'feedback': feedback,
      'status': status,
    };
  }

  // =======================
  // 🔹 FROM MAP
  // =======================
  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      sessionId: map['sessionId'],
      placeName: map['placeName'],
      isPrivate: map['isPrivate'] ?? false,
      date: DateTime.parse(map['date']),
      // ✅ معالجة createdAt لضمان عدم حدوث Crash مع البيانات القديمة
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      time: map['time'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      notes: map['notes'],
      price: map['price'] != null
          ? double.tryParse(map['price'].toString())
          : null,
      paymentImageUrl: map['paymentImageUrl'],
      cancellationReason: map['cancellationReason'],
      rating: map['rating'] != null
          ? double.tryParse(map['rating'].toString())
          : null,
      feedback: map['feedback'],
      status: map['status'] ?? 'pending',
    );
  }

  // =======================
  // 🔹 COPY WITH
  // =======================
  BookingModel copyWith({
    String? paymentImageUrl,
    Uint8List? paymentImageBytes,
    String? status,
    String? cancellationReason,
    double? rating,
    String? feedback,
    double? price,
    String? sessionId,
    DateTime? createdAt, // أضفناه هنا
  }) {
    return BookingModel(
      id: id,
      userId: userId,
      sessionId: sessionId ?? this.sessionId,
      placeName: placeName,
      isPrivate: isPrivate,
      date: date,
      time: time,
      name: name,
      phone: phone,
      notes: notes,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt, // أضفناه هنا
      paymentImageUrl: paymentImageUrl ?? this.paymentImageUrl,
      paymentImageBytes: paymentImageBytes ?? this.paymentImageBytes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
      status: status ?? this.status,
    );
  }
}
