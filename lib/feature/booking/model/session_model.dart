import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel {
  final String id; 
  final String name; 
  final String image; 
  final String details; 
  final String locationUrl; 
  final String dayName;
  final String date;
  final String startTime; 
  final String duration; 
  final double price; 
  final int capacity; 
  final int bookedCount; 
  final bool isSuppliesIncluded; 
  final bool isVisible; // (العين اللي بره) يظهر لليوزر ولا لا
  final bool isAcceptingBookings; // (السويتش اللي جوه) يقبل حجز ولا لا
  final DateTime? createdAt; // وقت إنشاء السيشن للترتيب

  SessionModel({
    required this.id,
    required this.name,
    required this.image,
    required this.details,
    required this.locationUrl,
    required this.dayName,
    required this.date,
    required this.startTime,
    required this.duration,
    required this.price,
    required this.capacity,
    this.bookedCount = 0,
    required this.isSuppliesIncluded,
    this.isVisible = true,
    this.isAcceptingBookings = true,
    this.createdAt,
  });


  // حساب المقاعد المتبقية: السعة - عدد المحجوزين
  int get remainingSeats => capacity - bookedCount;

  // هل السيشن ممتلئة تماماً؟
  bool get isFull => bookedCount >= capacity;

  // هل الحجز متاح فعلياً؟ (لازم يكون مفعل + مش مليان + الأدمن فاتح الحجز)
  bool get isActuallyAvailable => isVisible && isAcceptingBookings && !isFull;


  factory SessionModel.fromMap(String id, Map<String, dynamic> map) {
    return SessionModel(
      id: id,
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      details: map['details'] ?? '',
      locationUrl: map['locationUrl'] ?? '',
      dayName: map['dayName'] ?? '',
      date: map['date'] ?? '',
      startTime: map['startTime'] ?? '',
      duration: map['duration'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      capacity: (map['capacity'] ?? 0).toInt(),
      bookedCount: (map['bookedCount'] ?? 0).toInt(),
      isSuppliesIncluded: map['isSuppliesIncluded'] ?? false,
      isVisible: map['isVisible'] ?? true,
      isAcceptingBookings: map['isAcceptingBookings'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'details': details,
      'locationUrl': locationUrl,
      'dayName': dayName,
      'date': date,
      'startTime': startTime,
      'duration': duration,
      'price': price,
      'capacity': capacity,
      'bookedCount': bookedCount,
      'isSuppliesIncluded': isSuppliesIncluded,
      'isVisible': isVisible,
      'isAcceptingBookings': isAcceptingBookings,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}