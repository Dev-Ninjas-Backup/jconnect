// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/routes/approute.dart';
import 'package:jconnect/features/auth/repository/auth_repository.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authRepository = AuthRepository();
  SharedPreferencesHelperController pref = Get.put(
    SharedPreferencesHelperController(),
  );

  var rememberMe = false.obs;
  RxBool isLoading = false.obs;

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      EasyLoading.showError("Please enter your email or phone");
      return;
    }

    if (password.isEmpty) {
      EasyLoading.showError("Please enter your password");
      return;
    }

    if (password.length < 6) {
      EasyLoading.showError("Password must be at least 6 characters");
      return;
    }

    await _performLogin(email, password);
  }

  Future<void> _performLogin(String email, String password) async {
    try {
      isLoading.value = true;
      EasyLoading();

      final response = await authRepository.login(
        email: email,
        password: password,
      );

      isLoading.value = false;
      EasyLoading.dismiss();

      // Extract token and user data from response
      final token = response['data']['token'] ?? '';
      final user = response['data']['user'];
      pref.saveToken(token);
      pref.saveRowToken(token);
      pref.saveUserId(user['id'].toString());

      print('DEBUG: Login Response: $response');
      print('DEBUG: Token: $token');
      print('DEBUG: User: $user');

      if (token.isNotEmpty) {
        EasyLoading.showSuccess('Login successful!');

        Future.delayed(Duration(seconds: 1), () {
          Get.offAllNamed(AppRoute.navBarScreen);
        });
      } else {
        EasyLoading.showError('Login failed: No token received');
      }
    } catch (e) {
      isLoading.value = false;
      EasyLoading.showError('Login failed: $e');
      print('DEBUG: Login error: $e');
    }
  }

  Future<void> performLoginAfterVerification(
    String email,
    String password,
  ) async {
    try {
      isLoading.value = true;
      EasyLoading.show(status: 'Logging in...');

      final response = await authRepository.login(
        email: email,
        password: password,
      );

      isLoading.value = false;
      EasyLoading.dismiss();

      // Extract token and user data from response
      final token = response['data']['token'] ?? '';
      final user = response['data']['user'];
      pref.saveToken(token);
      pref.saveRowToken(token);
      pref.saveUserId(user['id'].toString());

      print('DEBUG: Login Response: $response');
      print('DEBUG: Token: $token');
      print('DEBUG: User: $user');

      if (token.isNotEmpty) {
        //   EasyLoading.showSuccess('Login successful!');

        Future.delayed(Duration(seconds: 1), () {
          Get.toNamed(AppRoute.profileSetupScreen);
        });
      } else {
        //   EasyLoading.showError('Login failed: No token received');
      }
    } catch (e) {
      isLoading.value = false;
      // EasyLoading.showError('Login failed: $e');
      print('DEBUG: Login error: $e');
    }
  }

  // Apple Sign-In method

  Future<void> signInWithApple() async {
    try {
      isLoading.value = true;
      EasyLoading.show(status: 'Signing in with Apple...');

      // 1️⃣ Apple credentials
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // 2️⃣ Firebase credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // 3️⃣ Sign in to Firebase
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        oauthCredential,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        EasyLoading.showError("Apple login failed");
        isLoading.value = false;
        return;
      }

      // 4️⃣ Get Firebase ID Token
      final idToken = await firebaseUser.getIdToken(true);

      // 5️⃣ Call backend API using GetConnect
      final response = await GetConnect().post(
        'https://api.theconnectapp.net/auth/firebase-login',
        {"idToken": idToken, "provider": "apple", "username": ""},
      );

      isLoading.value = false;
      EasyLoading.dismiss();

      if (response.statusCode == 200 && response.body['success'] == true) {
        final token = response.body['data']['token'] ?? '';
        final user = response.body['data']['user'];

        // 6️⃣ Save token & user info
        await pref.saveToken(token);
        await pref.saveRowToken(token);
        await pref.saveUserId(user['id'].toString());
        await pref.saveUserName(
          userName: user['name'] ?? '',
          phoneNumber: user['phone'] ?? '',
        );

        EasyLoading.showSuccess('Login successful!');
        Future.delayed(Duration(seconds: 1), () {
          Get.offAllNamed(AppRoute.navBarScreen);
        });
      } else {
        EasyLoading.showError(response.body['message'] ?? 'Login failed');
      }
    } catch (e) {
      isLoading.value = false;
      EasyLoading.dismiss();
      print('DEBUG: Apple login error: $e');
      EasyLoading.showError('Apple login failed: $e');
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
