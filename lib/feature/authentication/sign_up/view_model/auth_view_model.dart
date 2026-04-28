import 'dart:typed_data';

import 'package:art_by_hager_ismail/services/cloudinary_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../services/auth_service.dart';
import 'auth_states.dart';
import '../../../../core/error/exceptions.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthCubit(this._authService) : super(AuthInitial());

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    String? profileImageUrl,
    Uint8List? profileImage,
  }) async {
    try {
      emit(AuthLoading());

      final user = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );

      print('User ID after Auth signUp: ${user.id}');

      try {
        await _firestore.collection('users').doc(user.id).set({
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'isOnline': true,
          'profilePicture': profileImageUrl ?? '',
          'role': 'user',
          'bookingsCount': 0,
          // 🚀 التعديل هنا: نضمن إن الحقل يتكريه كقائمة فاضية من البداية
          // والـ AuthService هيقوم بالباقي ويحدثه بالتوكن الفعلي
          'fcmTokens': [],
        });
        print('User added to Firestore successfully');

        // بعد ما سجلنا اليوزر في Firestore، نطلب من السيرفيس تحدث التوكن فوراً
        await _authService.updateFCMToken();
      } catch (e) {
        print('Firestore write error: $e');
        throw CustomException(message: 'Failed to add user to Firestore: $e');
      }

      emit(AuthSuccess(userModel: user));
    } on CustomException catch (e) {
      emit(AuthFailure(message: e.message));
    } catch (e) {
      emit(AuthFailure(message: "Something went wrong, please try again."));
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());

      final user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      emit(AuthSuccess(userModel: user));
    } on CustomException catch (e) {
      emit(AuthFailure(message: e.message));
    } catch (e) {
      emit(AuthFailure(message: "Something went wrong, please try again."));
    }
  }

  // 📸 ميثود تحديث صورة البروفايل من الدراور
  Future<void> updateProfileImage(Uint8List imageBytes) async {
    try {
      // 1. نجيب الـ ID بتاع اليوزر الحالي من السيرفيس
      final String userId = _authService.getCurrentUserId();

      if (userId.isEmpty) {
        emit(AuthFailure(message: "لم يتم العثور على بيانات المستخدم"));
        return;
      }

      // 2. 🔥 التعديل هنا: بنضيف وقت الرفع لاسم الملف عشان الرابط يتغير تماماً
      final String uniqueFileName =
          "profile_${userId}_${DateTime.now().millisecondsSinceEpoch}";

      // 3. نرفع الصورة لـ Cloudinary بالاسم الجديد الفريد
      final String? imageUrl = await CloudinaryService().uploadImage(
        imageBytes: imageBytes,
        folder: "profiles",
        fileName: uniqueFileName, // 👈 استخدمنا الاسم الفريد
      );

      if (imageUrl != null) {
        // 4. نحدث الرابط في الفايربيز
        // دلوقتي imageUrl شايل رابط جديد مختلف عن القديم، فالفايربيز هيحدث فوراً
        await _authService.updateProfileImage(imageUrl);

        print("✅ Profile Image Updated Successfully with URL: $imageUrl");
      }
    } catch (e) {
      emit(AuthFailure(message: "فشل تحديث الصورة: ${e.toString()}"));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _authService.logout();
      emit(AuthLoggedOut());
    } catch (e) {
      emit(AuthFailure(message: "Something went wrong, please try again."));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      final user = await _authService.signInWithGoogle();
      emit(AuthSuccess(userModel: user));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }


}
