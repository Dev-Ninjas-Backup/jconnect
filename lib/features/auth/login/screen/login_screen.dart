import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/custom_obsecure_textfield.dart';
import 'package:jconnect/core/common/constants/custom_textfield.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/constants/imagepath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/routes/approute.dart';
import 'package:jconnect/features/auth/login/controller/login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQueryData.fromView(View.of(context)).size;
    final isSmall = size.height < 700;
    final loginController = Get.put(LoginController());

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background overlay
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.4)),
          ),

          // Red glowing circle in background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              Imagepath.redCircleGlow,
              width: size.width * 0.95,
              fit: BoxFit.contain,
            ),
          ),

          // Responsive scrollable content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                   // SizedBox(height: isSmall ? 8 : 8),

                    // Logo
                    Image.asset(
                      "assets/icons/daconnecticon.png",
                      height: isSmall ? 85 : 105,
                      fit: BoxFit.contain,
                    ),

                    // Brand Text
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.montserrat(
                          fontSize: isSmall ? 20 : 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                        children: const [
                          TextSpan(
                            text: "DA'",
                            style: TextStyle(color: Colors.white),
                          ),
                          TextSpan(
                            text: "CONNECT",
                            style: TextStyle(color: Color(0xFFDE1B38)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),

                    // "WELCOME BACK TO"
                    Text(
                      "WELCOME BACK TO",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.bebasNeue(
                        fontSize: sp(isSmall ? 40 : 48),
                        letterSpacing: 1.2,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),

                    // "DA'CONNECT"
                    Text(
                      "DA'CONNECT",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.bebasNeue(
                        fontSize: sp(isSmall ? 40 : 48),
                        letterSpacing: 1.2,
                        color: const Color(0xFFDE1B38),
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Subtitle
                    Text(
                      "Find what you need. Offer what you have.",
                      style: getTextStyle(
                        color: Colors.white,
                        fontsize: isSmall ? 14 : 15,
                        fontweight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: isSmall ? 20 : 28),

                    // Email Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Email or Phone",
                          style: getTextStyle(
                            color: AppColors.primaryTextColor,
                            fontsize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomTextfield(
                          controller: loginController.emailController,
                          hintText: 'Enter your email or phone number',
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Password Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Password",
                          style: getTextStyle(
                            color: AppColors.primaryTextColor,
                            fontsize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomObsecureTextfield(
                          controller: loginController.passwordController,
                        ),
                        const SizedBox(height: 10),

                        // Remember Me + Forgot Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Obx(
                              () => Row(
                                children: [
                                  Checkbox(
                                    value: loginController.rememberMe.value,
                                    onChanged: loginController.toggleRememberMe,
                                    activeColor: AppColors.redColor,
                                  ),
                                  Text(
                                    "Remember me",
                                    style: getTextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.toNamed(AppRoute.forgetPassword);
                              },
                              child: Text(
                                "Forgot Password?",
                                style: getTextStyle(
                                  color: AppColors.redColor,
                                  fontsize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: isSmall ? 16 : 22),

                    // Login Button
                    CustomPrimaryButton(
                      buttonText: "Login",
                      onTap: () {
                        loginController.login();
                      },
                    ),

                    SizedBox(height: isSmall ? 16 : 20),

                    // "or"
                    Text(
                      "or",
                      style: getTextStyle(color: AppColors.primaryTextColor),
                    ),

                    const SizedBox(height: 12),

                    // Social Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => loginController.signInWithGoogle(),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            child: Image.asset(Iconpath.googleIcon, height: 40),
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () async {
                            await Get.find<LoginController>().signInWithApple();
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            child: Image.asset(Imagepath.appleLogo, height: 40),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isSmall ? 18 : 24),

                    // Signup Prompt
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "New to Da Connect? ",
                          style: getTextStyle(color: AppColors.primaryTextColor),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.toNamed(AppRoute.signupScreen);
                          },
                          child: Text(
                            "Create Account",
                            style: getTextStyle(
                              color: const Color(0xFFDE1B38),
                              fontweight: FontWeight.bold,
                              fontsize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
