import 'package:art_by_hager_ismail/core/widget/social_signIn_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../core/widget/custom_elevated_button.dart';
import '../../../../core/widget/custom_text_form_field.dart';
import '../../../../core/route_manager/routes.dart';
import '../../sign_up/view_model/auth_states.dart';
import '../../sign_up/view_model/auth_view_model.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool redirectBack = false;

  final Color primaryGreen = const Color(0xFF2F3E34);
  final Color beigeBG = const Color(0xFFF8F4F0);
  final Color accentGold = const Color(0xFF6F624C);
  final Color lightBeige = const Color(0xFFE8DDCF);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // استلام الأرجيومنت عشان نعرف هنرجع لورا ولا هنروح للهوم
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && args['redirectBack'] == true) {
      redirectBack = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beigeBG,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Fluttertoast.showToast(msg: "أهلاً بك في مَـرسَم");

            // اللوجيك بتاعك: لو جاي من حجز ارجع بـ pop، لو داخل عادي روح للهوم
            if (redirectBack) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(
                context,
                PageRoutesName.initialHome,
              );
            }
          }
          if (state is AuthFailure) {
            Fluttertoast.showToast(
              msg: state.message,
              backgroundColor: Colors.redAccent,
            );
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
                      Hero(
                        tag: 'logo',
                        child: Icon(
                          Icons.palette_rounded,
                          size: 180.r,
                          color: lightBeige,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "مَـرسَم",
                        style: TextStyle(
                          fontFamily: 'ElMessiri',
                          fontSize: 90.sp,
                          color: lightBeige,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          shadows: const [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: accentGold.withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          "حيث يلتقي الإبداع بالهواية",
                          style: TextStyle(
                            color: lightBeige.withOpacity(0.8),
                            fontSize: 20.sp,
                          ),
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
          flex: 4,
          child: Container(
            color: beigeBG,
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 60.w),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [_buildFormCard(state)],
                  ),
                ),
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
          top: -50.h,
          left: -50.w,
          child: _buildCircle(200, primaryGreen.withOpacity(0.08)),
        ),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  Hero(
                    tag: 'logo',
                    child: Icon(
                      Icons.palette_rounded,
                      size: 80.r,
                      color: primaryGreen,
                    ),
                  ),
                  Text(
                    "مَـرسَم",
                    style: TextStyle(
                      fontFamily: 'ElMessiri',
                      fontSize: 40.sp,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  _buildFormCard(state),
                ],
              ),
            ),
          ),
        ),
        if (state is AuthLoading) _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildFormCard(AuthState state) {
    return Container(
      padding: EdgeInsets.all(32.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: _buildFormContent(state),
    );
  }

  Widget _buildFormContent(AuthState state) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "تسجيل الدخول",
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
              color: primaryGreen,
              fontFamily: 'ElMessiri',
            ),
          ),
          SizedBox(height: 30.h),
          CustomTextFormField(
            controller: emailController,
            hintText: "البريد الإلكتروني",
            backGround: beigeBG.withOpacity(0.3),
            borderColor: primaryGreen.withOpacity(0.15),
            suffixIcon: Icon(
              Icons.alternate_email_rounded,
              color: accentGold,
              size: 22.r,
            ),
            validator: (v) => v!.isEmpty ? 'البريد مطلوب' : null,
          ),
          SizedBox(height: 18.h),
          CustomTextFormField(
            controller: passwordController,
            hintText: "كلمة المرور",
            isObscured: true,
            backGround: beigeBG.withOpacity(0.3),
            borderColor: primaryGreen.withOpacity(0.15),
            suffixIcon: Icon(
              Icons.lock_person_outlined,
              color: accentGold,
              size: 22.r,
            ),
            validator: (v) => v!.isEmpty ? 'كلمة المرور مطلوبة' : null,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {},
              child: Text(
                "نسيت كلمة المرور؟",
                style: TextStyle(
                  color: accentGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            height: 55.h,
            child: CustomElevatedButton(
              label: "دخول للمرسم",
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
              backGroundColor: primaryGreen,
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  context.read<AuthCubit>().signInWithEmail(
                    password: passwordController.text.trim(),
                    email: emailController.text.trim(),
                  );
                }
              },
            ),
          ),
          SizedBox(height: 30.h),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: const Text("أو"),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          SizedBox(height: 20.h),
          SocialSignInButton(
            assetPath: "assets/image/Google.svg",
            text: "استخدام حساب جوجل",
            onTap: () => context.read<AuthCubit>().signInWithGoogle(),
          ),
          SizedBox(height: 30.h),
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                PageRoutesName.signUpRoute,
                arguments: {'redirectBack': redirectBack},
              ),
              child: RichText(
                text: TextSpan(
                  text: "ليس لديك حساب؟ ",
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                  children: [
                    TextSpan(
                      text: "سجل الآن",
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
          child: CircularProgressIndicator(color: primaryGreen, strokeWidth: 5),
        ),
      ),
    );
  }
}
