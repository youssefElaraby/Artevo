import 'dart:typed_data';
import 'package:art_by_hager_ismail/services/cloudinary_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/widget/custom_elevated_button.dart';
import '../../../../core/widget/custom_text_form_field.dart';
import '../../../../core/widget/social_signIn_button.dart';
import '../../../../core/route_manager/routes.dart';
import '../view_model/auth_states.dart';
import '../view_model/auth_view_model.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  Uint8List? _profileImage;
  bool _isUploadingImage = false;
  bool redirectBack = false;

  final Color primaryGreen = const Color(0xFF2F3E34);
  final Color beigeBG = const Color(0xFFF8F4F0);
  final Color accentGold = const Color(0xFF6F624C);
  final Color lightBeige = const Color(0xFFE8DDCF);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && args['redirectBack'] == true) {
      redirectBack = true;
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() => _profileImage = bytes);
    }
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      String? imageUrl;
      if (_profileImage != null) {
        imageUrl = await _uploadProfileImage(_profileImage!);
      }
      context.read<AuthCubit>().signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        fullName: nameController.text.trim(),
        phone: phoneController.text.trim(),
        profileImageUrl: imageUrl,
      );
    }
  }

  Future<String?> _uploadProfileImage(Uint8List imageBytes) async {
    try {
      setState(() => _isUploadingImage = true);
      return await _cloudinaryService.uploadImage(
        imageBytes: imageBytes,
        folder: "profiles",
        fileName: "profile_${DateTime.now().millisecondsSinceEpoch}",
      );
    } catch (_) {
      Fluttertoast.showToast(msg: "فشل رفع الصورة، سيتم التسجيل بدونها");
      return null;
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beigeBG,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Fluttertoast.showToast(msg: "تم إنشاء الحساب بنجاح");
            if (redirectBack) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(
                context,
                PageRoutesName.signInRoute,
              );
            }
          }
          if (state is AuthFailure) {
            Fluttertoast.showToast(msg: state.message);
          }
        },
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) return _buildWebView(state);
              return _buildMobileView(state);
            },
          );
        },
      ),
    );
  }

  // ---------------- ديزاين الـ Web ----------------
  Widget _buildWebView(AuthState state) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            color: primaryGreen,
            child: Stack(
              children: [
                Positioned(
                  top: -100,
                  left: -100,
                  child: _buildCircle(400, Colors.white.withOpacity(0.03)),
                ),
                Positioned(
                  bottom: -50,
                  right: -50,
                  child: _buildCircle(300, accentGold.withOpacity(0.1)),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.brush_rounded, size: 150.r, color: lightBeige),
                      Text(
                        "مَـرسَم",
                        style: TextStyle(
                          fontFamily: 'ElMessiri',
                          fontSize: 80.sp,
                          color: lightBeige,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        "ابدأ رحلتك الفنية معنا اليوم",
                        style: TextStyle(
                          color: lightBeige.withOpacity(0.6),
                          fontSize: 22.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 60.w),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 550),
                child: _buildMainForm(state),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- ديزاين الموبايل ----------------
  Widget _buildMobileView(AuthState state) {
    return Stack(
      children: [
        Positioned(
          top: -40.h,
          right: -40.w,
          child: _buildCircle(180, primaryGreen.withOpacity(0.06)),
        ),
        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 30.h),
                _buildMainForm(state),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
        if (state is AuthLoading || _isUploadingImage) _buildLoadingOverlay(),
      ],
    );
  }

  // ---------------- الفورم الرئيسي ----------------
  Widget _buildMainForm(AuthState state) {
    return Column(
      children: [
        _buildProfileImagePicker(),
        SizedBox(height: 30.h),
        Container(
          padding: EdgeInsets.all(28.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: _buildFormFields(),
        ),
      ],
    );
  }

  Widget _buildProfileImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(3.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [primaryGreen, accentGold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CircleAvatar(
              radius: 65.r,
              backgroundColor: Colors.white,
              backgroundImage: _profileImage != null
                  ? MemoryImage(_profileImage!)
                  : null,
              child: _profileImage == null
                  ? Icon(
                      Icons.add_a_photo_outlined,
                      size: 40.r,
                      color: Colors.grey.shade400,
                    )
                  : null,
            ),
          ),
          Positioned(
            bottom: 5,
            right: 5,
            child: Container(
              padding: EdgeInsets.all(3.r),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 16.r,
                backgroundColor: accentGold,
                child: Icon(Icons.edit, size: 14.r, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "إنشاء حساب",
            style: TextStyle(
              fontFamily: 'ElMessiri',
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
              color: primaryGreen,
            ),
          ),
          SizedBox(height: 25.h),
          CustomTextFormField(
            controller: nameController,
            hintText: "الاسم بالكامل",
            backGround: beigeBG.withOpacity(0.3),
            borderColor: primaryGreen.withOpacity(0.15),
            suffixIcon: Icon(Icons.person_outline_rounded, color: accentGold),
            validator: (v) => v!.isEmpty ? 'الاسم مطلوب' : null,
          ),
          SizedBox(height: 15.h),
          CustomTextFormField(
            controller: emailController,
            hintText: "البريد الإلكتروني",
            backGround: beigeBG.withOpacity(0.3),
            borderColor: primaryGreen.withOpacity(0.15),
            suffixIcon: Icon(Icons.alternate_email_rounded, color: accentGold),
            validator: (v) =>
                !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v!)
                ? 'بريد غير صالح'
                : null,
          ),
          SizedBox(height: 15.h),
          CustomTextFormField(
            controller: phoneController,
            hintText: "رقم الهاتف",
            keyBoardType: TextInputType.phone,
            backGround: beigeBG.withOpacity(0.3),
            borderColor: primaryGreen.withOpacity(0.15),
            suffixIcon: Icon(Icons.phone_android_rounded, color: accentGold),
            validator: (v) => v!.length < 10 ? 'رقم غير صالح' : null,
          ),
          SizedBox(height: 15.h),
          CustomTextFormField(
            controller: passwordController,
            hintText: "كلمة المرور",
            isObscured: true,
            backGround: beigeBG.withOpacity(0.3),
            borderColor: primaryGreen.withOpacity(0.15),
            suffixIcon: Icon(Icons.lock_outline_rounded, color: accentGold),
            validator: (v) => v!.length < 6 ? '6 أحرف على الأقل' : null,
          ),
          SizedBox(height: 30.h),
          SizedBox(
            width: double.infinity,
            height: 55.h,
            child: CustomElevatedButton(
              textStyle: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              label: "انضم الآن",
              backGroundColor: primaryGreen,
              onTap: _handleSignUp,
            ),
          ),
          SizedBox(height: 25.h),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: const Text("أو"),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          SizedBox(height: 20.h),
          SocialSignInButton(
            assetPath: "assets/image/Google.svg",
            text: "التسجيل عبر جوجل",
            onTap: () => context.read<AuthCubit>().signInWithGoogle(),
          ),
          SizedBox(height: 30.h),
          Center(
            child: GestureDetector(
              onTap: () =>
                  Navigator.pushNamed(context, PageRoutesName.signInRoute),
              child: RichText(
                text: TextSpan(
                  text: "لديك حساب بالفعل؟ ",
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                  children: [
                    TextSpan(
                      text: "تسجيل دخول",
                      style: TextStyle(
                        color: accentGold,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black45,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(25.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: primaryGreen),
              if (_isUploadingImage) ...[
                SizedBox(height: 15.h),
                Text(
                  " جاري الانشاء ...",
                  style: TextStyle(
                    color: primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
