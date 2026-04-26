import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ ضفت دي عشان نخزن التوكن
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // ✅ ضفت دي عشان نجيب التوكن
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../feature/authentication/sign_up/model/user_model.dart';
import '../../../../core/error/exceptions.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // ✅ ضفت دي
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 🚀 ميثود جديدة لتحديث التوكن (منفصلة تماماً)
  Future<void> updateFCMToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // 1️⃣ جلب التوكن مع محاولة إجبارية
      String? token = await FirebaseMessaging.instance.getToken();

      // 🔥 اطبع دي عندك في الـ Debug Console وقولي شفتها ولا لا
      print("DEBUG: FCM Token Attempt: $token");

      if (token != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmTokens': FieldValue.arrayUnion([token]),
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
        print("🚀 [FCM] Token Updated in Firestore!");
      } else {
        print("⚠️ [FCM] Token is NULL - Check Google Play Services");
      }
    } catch (e) {
      print("❌ [FCM] Error: $e");
    }
  }

  Future<UserModel> signInWithGoogle() async {
    try {
      print("--- 🏁 بدء عملية تسجيل دخول جوجل ---");

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print("⚠️ التحذير: المستخدم قفل قائمة الحسابات (User Cancelled)");
        throw "المستخدم ألغى العملية";
      }

      print("✅ تم اختيار الحساب: ${googleUser.email}");

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print("🔑 Access Token: ${googleAuth.accessToken?.substring(0, 10)}...");
      print("🔑 ID Token: ${googleAuth.idToken?.substring(0, 10)}...");

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print("🎫 تم إنشاء Credential بنجاح");

      print("🚀 محاولة الدخول لـ Firebase...");
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user != null) {
        print("🎯 نجاح نهائي! UID: ${user.uid}");

        // 🚀 تحديث التوكن فور النجاح
        await updateFCMToken();

        return UserModel(
          id: user.uid,
          email: user.email ?? "",
          fullName: user.displayName ?? "مستخدم جوجل",
          phone: user.phoneNumber ?? "",
          profileImageUrl: user.photoURL,
        );
      } else {
        throw "فشل الحصول على بيانات المستخدم من فايربيز";
      }
    } on FirebaseAuthException catch (e) {
      print("🔥 [Firebase Error]: Code: ${e.code}");
      print("🔥 [Firebase Error]: Message: ${e.message}");
      throw "Firebase [${e.code}]: ${e.message}";
    } catch (e, stack) {
      print("🚨 [General Error]: $e");
      print("🚨 [Stack Trace]: $stack");
      throw "Error Raw: ${e.toString()}";
    }
  }

  // ===================== SIGN UP =====================
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    Uint8List? profileImage,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;

      String? profileImageUrl;
      if (profileImage != null) {
        final ref = _storage
            .ref()
            .child('profile_images')
            .child('${user.uid}.jpg');
        await ref.putData(profileImage);
        profileImageUrl = await ref.getDownloadURL();
      }

      await user.updateDisplayName(fullName);
      if (profileImageUrl != null) {
        await user.updatePhotoURL(profileImageUrl);
      }
      await user.reload();

      // 🚀 تحديث التوكن فور النجاح
      await updateFCMToken();

      return UserModel(
        id: user.uid,
        email: email,
        fullName: fullName,
        phone: phone,
        profileImageUrl: profileImageUrl,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw CustomException(message: "كلمة المرور ضعيفة جداً");
      } else if (e.code == 'email-already-in-use') {
        throw CustomException(message: "هذا البريد مسجل بالفعل");
      } else {
        throw CustomException(message: "فشل التسجيل: ${e.message}");
      }
    } catch (e) {
      throw CustomException(message: "خطأ غير متوقع: $e");
    }
  }

  // ===================== SIGN IN EMAIL =====================
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;
      await updateFCMToken();

      return UserModel(
        id: user.uid,
        email: user.email ?? "",
        fullName: user.displayName ?? "",
        phone: "",
        profileImageUrl: user.photoURL,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
        case 'invalid-email':
        case 'user-disabled':
          errorMessage = "البريد الإلكتروني غير صحيح أو الحساب غير موجود";
          break;
        case 'wrong-password':
        case 'invalid-credential':
          errorMessage = "كلمة المرور او البريد الالكتروني غير صحيح";
          break;
        case 'too-many-requests':
          errorMessage = "لقد حاولت كثيراً، تم حظر الدخول مؤقتاً.. حاول لاحقاً";
          break;
        case 'network-request-failed':
          errorMessage = "تأكد من اتصالك بالإنترنت وحاول مجدداً";
          break;
        default:
          errorMessage = "حدث خطأ أثناء تسجيل الدخول، حاول مرة أخرى";
      }
      throw CustomException(message: errorMessage);
    } catch (e) {
      throw CustomException(message: "خطأ غير متوقع: $e");
    }
  }

  Future<void> logout() async {
    try {
      // 🚀 مسح التوكن من القائمة قبل الخروج عشان الإشعارات متتداخلش
      final user = _auth.currentUser;
      String? token = await FirebaseMessaging.instance.getToken();
      if (user != null && token != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmTokens': FieldValue.arrayRemove([token]),
        });
      }
    } catch (e) {
      print("⚠️ Error removing token during logout: $e");
    }

    await _googleSignIn.signOut();
    await _auth.signOut();
  }


// ===================== UPDATE PROFILE IMAGE =====================
  
  /// 🆔 ميثود بسيطة لجلب الـ UID الخاص باليوزر الحالي
  String getCurrentUserId() => _auth.currentUser?.uid ?? "";

  /// 🖼️ ميثود تحديث رابط الصورة في الـ Auth وفي الـ Firestore
  Future<void> updateProfileImage(String imageUrl) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // 1️⃣ تحديث الصورة في Firebase Auth (عشان السيشن والـ Stream يلقطها)
        await user.updatePhotoURL(imageUrl);

        // 2️⃣ تحديث الصورة في Firestore (عشان الداتا الدائمة)
        await _firestore.collection('users').doc(user.uid).update({
          'profilePicture': imageUrl,
        });
        
        print("✅ [AuthService] Profile image updated successfully!");
      }
    } catch (e) {
      print("❌ [AuthService] Error updating profile image: $e");
      throw CustomException(message: "عفواً، فشل تحديث الصورة في السيرفر");
    }
  }

  User? get currentUser => _auth.currentUser;
}
