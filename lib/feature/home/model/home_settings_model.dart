import 'package:cloud_firestore/cloud_firestore.dart';

// 1. Gallery Model
class GalleryItemModel {
  final String? id;
  final String url;
  final String type;
  final String? thumbnail;
  final DateTime? createdAt;

  GalleryItemModel({
    this.id,
    required this.url,
    required this.type,
    this.thumbnail,
    this.createdAt,
  });

  GalleryItemModel copyWith({
    String? id,
    String? url,
    String? type,
    String? thumbnail,
    DateTime? createdAt,
  }) => GalleryItemModel(
    id: id ?? this.id,
    url: url ?? this.url,
    type: type ?? this.type,
    thumbnail: thumbnail ?? this.thumbnail,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toMap() => {
    'url': url,
    'type': type,
    'thumbnail': thumbnail,
    'createdAt': createdAt ?? FieldValue.serverTimestamp(),
  };

  factory GalleryItemModel.fromMap(Map<String, dynamic> map, String docId) {
    return GalleryItemModel(
      id: docId,
      url: map['url'] ?? '',
      type: map['type'] ?? 'image',
      thumbnail: map['thumbnail'],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }
}

// 2. Story Model (تم إضافة title ليكون صورة وكلمة)
class StoryModel {
  final String? id;
  final String imageUrl;
  final String? title; // الكلمة اللي هتظهر مع الصورة
  final String? videoUrl;
  final DateTime createdAt;
  final bool isViewed;

  StoryModel({
    this.id,
    required this.imageUrl,
    this.title,
    this.videoUrl,
    required this.createdAt,
    this.isViewed = false,
  });

  StoryModel copyWith({
    String? id,
    String? imageUrl,
    String? title,
    String? videoUrl,
    DateTime? createdAt,
    bool? isViewed,
  }) => StoryModel(
    id: id ?? this.id,
    imageUrl: imageUrl ?? this.imageUrl,
    title: title ?? this.title,
    videoUrl: videoUrl ?? this.videoUrl,
    createdAt: createdAt ?? this.createdAt,
    isViewed: isViewed ?? this.isViewed,
  );

  Map<String, dynamic> toMap() => {
    'imageUrl': imageUrl,
    'title': title,
    'videoUrl': videoUrl,
    'createdAt': Timestamp.fromDate(createdAt),
    'isViewed': isViewed,
  };

  factory StoryModel.fromMap(Map<String, dynamic> map, String docId) {
    return StoryModel(
      id: docId,
      imageUrl: map['imageUrl'] ?? '',
      title: map['title'],
      videoUrl: map['videoUrl'],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isViewed: map['isViewed'] ?? false,
    );
  }
}

// 3. Popup Model
class PopupModel {
  final String? id;
  final bool showPopup;
  final String? popupImageUrl;
  final String? popupTitle;
  final String? popupActionType;

  PopupModel({
    this.id,
    required this.showPopup,
    this.popupImageUrl,
    this.popupTitle,
    this.popupActionType,
  });

  PopupModel copyWith({
    String? id,
    bool? showPopup,
    String? popupImageUrl,
    String? popupTitle,
    String? popupActionType,
  }) => PopupModel(
    id: id ?? this.id,
    showPopup: showPopup ?? this.showPopup,
    popupImageUrl: popupImageUrl ?? this.popupImageUrl,
    popupTitle: popupTitle ?? this.popupTitle,
    popupActionType: popupActionType ?? this.popupActionType,
  );

  Map<String, dynamic> toMap() => {
    'showPopup': showPopup,
    'popupImageUrl': popupImageUrl,
    'popupTitle': popupTitle,
    'popupActionType': popupActionType,
  };

  factory PopupModel.fromMap(Map<String, dynamic> map, String docId) {
    return PopupModel(
      id: docId,
      showPopup: map['showPopup'] ?? false,
      popupImageUrl: map['popupImageUrl'],
      popupTitle: map['popupTitle'],
      popupActionType: map['popupActionType'],
    );
  }
}

// 4. Event Model
class EventModel {
  final String? id;
  final bool isEventActive;
  final String? eventTitle;
  final String? eventDescription;
  final String? eventImageUrl;
  final String? eventDate;
  final String? eventTime;
  final String? eventLocationName;
  final String? eventLocationUrl;
  final double? eventPrice;
  final int? eventTotalSlots;
  final int? eventBookedSlots;
  final dynamic createdAt;

  EventModel({
    this.id,
    required this.isEventActive,
    this.eventTitle,
    this.eventDescription,
    this.eventImageUrl,
    this.eventDate,
    this.eventTime,
    this.eventLocationName,
    this.eventLocationUrl,
    this.eventPrice,
    this.eventTotalSlots,
    this.eventBookedSlots,
    this.createdAt,
  });

  EventModel copyWith({
    String? id,
    bool? isEventActive,
    String? eventTitle,
    String? eventDescription,
    String? eventImageUrl,
    String? eventDate,
    String? eventTime,
    String? eventLocationName,
    String? eventLocationUrl,
    double? eventPrice,
    int? eventTotalSlots,
    int? eventBookedSlots,
    dynamic createdAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      isEventActive: isEventActive ?? this.isEventActive,
      eventTitle: eventTitle ?? this.eventTitle,
      eventDescription: eventDescription ?? this.eventDescription,
      eventImageUrl: eventImageUrl ?? this.eventImageUrl,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      eventLocationName: eventLocationName ?? this.eventLocationName,
      eventLocationUrl: eventLocationUrl ?? this.eventLocationUrl,
      eventPrice: eventPrice ?? this.eventPrice,
      eventTotalSlots: eventTotalSlots ?? this.eventTotalSlots,
      eventBookedSlots: eventBookedSlots ?? this.eventBookedSlots,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'isEventActive': isEventActive,
    'eventTitle': eventTitle,
    'eventDescription': eventDescription,
    'eventImageUrl': eventImageUrl,
    'eventDate': eventDate,
    'eventTime': eventTime,
    'eventLocationName': eventLocationName,
    'eventLocationUrl': eventLocationUrl,
    'eventPrice': eventPrice,
    'eventTotalSlots': eventTotalSlots,
    'eventBookedSlots': eventBookedSlots,
    'createdAt': createdAt ?? FieldValue.serverTimestamp(),
  };

  factory EventModel.fromMap(Map<String, dynamic> map, String docId) {
    return EventModel(
      id: docId,
      isEventActive: map['isEventActive'] ?? false,
      eventTitle: map['eventTitle'],
      eventDescription: map['eventDescription'],
      eventImageUrl: map['eventImageUrl'],
      eventDate: map['eventDate'],
      eventTime: map['eventTime'],
      eventLocationName: map['eventLocationName'],
      eventLocationUrl: map['eventLocationUrl'],
      eventPrice: (map['eventPrice'] as num?)?.toDouble(),
      eventTotalSlots: map['eventTotalSlots'] as int?,
      eventBookedSlots: map['eventBookedSlots'] as int?,
      createdAt: map['createdAt'],
    );
  }
}

// 5. Workshop Model (تم الضبط لدعم الصور والفلترة والوقت)
class WorkshopModel {
  final String? id;
  final String title;
  final bool isShow;
  final String? imageUrl; // صورة الورشة
  final String? category; // القسم للفلترة
  final dynamic createdAt; // الترتيب الزمني

  WorkshopModel({
    this.id,
    required this.title,
    required this.isShow,
    this.imageUrl,
    this.category,
    this.createdAt,
  });

  WorkshopModel copyWith({
    String? id,
    String? title,
    bool? isShow,
    String? imageUrl,
    String? category,
    dynamic createdAt,
  }) => WorkshopModel(
    id: id ?? this.id,
    title: title ?? this.title,
    isShow: isShow ?? this.isShow,
    imageUrl: imageUrl ?? this.imageUrl,
    category: category ?? this.category,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toMap() => {
    'title': title,
    'isShow': isShow,
    'imageUrl': imageUrl,
    'category': category,
    'createdAt': createdAt ?? FieldValue.serverTimestamp(),
  };

  factory WorkshopModel.fromMap(Map<String, dynamic> map, String docId) {
    return WorkshopModel(
      id: docId,
      title: map['title'] ?? '',
      isShow: map['isShow'] ?? false,
      imageUrl: map['imageUrl'],
      category: map['category'],
      createdAt: map['createdAt'],
    );
  }
}
