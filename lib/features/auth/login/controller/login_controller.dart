// ignore_for_file: avoid_print, unnecessary_nullable_for_final_variable_declarations, await_only_futures

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/fcm_notification/fcm_notification_controller.dart';
import 'package:jconnect/routes/approute.dart';
import 'package:jconnect/features/auth/repository/auth_repository.dart';
import 'package:jconnect/core/endpoint.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authRepository = AuthRepository();
  SharedPreferencesHelperController pref = Get.put(
    SharedPreferencesHelperController(),
  );

  final FcmNotificationController fcmNotificationController = Get.put(
    FcmNotificationController(),
  );

  // Google Sign-In 7.2.0+ is now a singleton - use GoogleSignIn.instance
  // Must call initialize() once before using any methods
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleSignInInitialized = false;

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
        // getFreshToken() always calls FirebaseMessaging.getToken() directly,
        // so it works even if the cached value hasn't populated yet (release mode).
        fcmToken: await fcmNotificationController.getFreshToken(),
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

        // Sync FCM token AFTER auth token is saved — guarantees backend has the
        // correct FCM token for this device, even in release mode.
        try {
          final freshFcmToken = await fcmNotificationController.getFreshToken();
          if (freshFcmToken.isNotEmpty) {
            await fcmNotificationController.syncTokenWithBackend(freshFcmToken);
          }
        } catch (_) {}

        Future.delayed(Duration(seconds: 1), () async {
          await Get.offAllNamed(AppRoute.navBarScreen);
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
    String fcmToken,
  ) async {
    try {
      isLoading.value = true;
      EasyLoading.show(status: 'Logging in...');

      final response = await authRepository.login(
        email: email,
        password: password,
        fcmToken: fcmToken,
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

        // Sync FCM token after auth token is saved
        try {
          final freshFcmToken = await fcmNotificationController.getFreshToken();
          if (freshFcmToken.isNotEmpty) {
            await fcmNotificationController.syncTokenWithBackend(freshFcmToken);
          }
        } catch (_) {}

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

      // 1️⃣ Apple credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Apple name (only first login)
      final fullName =
          '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
              .trim();

      // 2️⃣ Firebase OAuth credential (IMPORTANT)
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // 3️⃣ Firebase sign in
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        oauthCredential,
      );

      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        EasyLoading.showError("Apple login failed");
        return;
      }

      // 4️⃣ Firebase ID token
      final idToken = await firebaseUser.getIdToken(true);

      debugPrint('DEBUG: Firebase User => $firebaseUser');
      // debugPrint('DEBUG: Firebase ID Token => $idToken');
      debugPrint('Firebase ID Token => $idToken', wrapWidth: 2048);

      // print('......... $idToken');

      // 5️⃣ Get username from Firebase user
      final response = await GetConnect().post(
        'https://api.theconnectapp.net/auth/firebase-login',
        {
          "idToken": idToken,
          "provider": "GOOGLE",
          "username": fullName.isNotEmpty
              ? fullName
              : firebaseUser.displayName?.trim() ?? "",
        },
        headers: {"Content-Type": "application/json"},
      );

      debugPrint('DEBUG: API STATUS => ${response.statusCode}');
      debugPrint('DEBUG: API RESPONSE => ${response.body}');
      debugPrint('Firebase ID Token => $idToken');

      // 6️⃣ Success
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.body['success'] == true) {
        final token = response.body['data']['token'] ?? '';
        final user = response.body['data']['user'];

        await pref.saveToken(token);
        await pref.saveRowToken(token);
        await pref.saveUserId(user['id'].toString());
        await pref.saveUserName(
          userName: user['name'] ?? '',
          phoneNumber: user['phone'] ?? '',
        );

        // Sync FCM token now that auth token is saved
        final freshFcmToken = await fcmNotificationController.getFreshToken();
        if (freshFcmToken.isNotEmpty) {
          await fcmNotificationController.syncTokenWithBackend(freshFcmToken);
        }

        EasyLoading.showSuccess('Login successful!');

        Future.delayed(const Duration(milliseconds: 800), () {
          Get.offAllNamed(AppRoute.navBarScreen);
        });
      } else {
        print("=================${response.body['message']}}");
        EasyLoading.showError(response.body['message'] ?? 'Login failed');
      }
    } catch (e) {
      debugPrint('DEBUG: Apple login error => $e');
      EasyLoading.showError('Apple login failed');
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  Future<void> _initializeGoogle() async {
    if (!_googleSignInInitialized) {
      await _googleSignIn.initialize();
      _googleSignInInitialized = true;
    }
  }

  // Google Sign-In method

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      EasyLoading.show(status: 'Signing in with Google...');

      // 1️⃣ Initialize GoogleSignIn (singleton, call once)
      await _initializeGoogle();

      // 2️⃣ Trigger Google Sign-In flow using authenticate() NOT signIn()
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();

      if (googleUser == null) {
        isLoading.value = false;
        EasyLoading.dismiss();
        print('DEBUG: User canceled Google sign-in');
        return;
      }

      print('DEBUG: Google User signed in: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print('DEBUG: Google ID Token: ${googleAuth.idToken}');
      // 4️⃣ Create Firebase credential using idToken
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      print('DEBUG: Firebase credential created');
      // 5️⃣ Sign in to Firebase
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        EasyLoading.showError("Google login failed");
        isLoading.value = false;
        print('DEBUG: Firebase user is null');
        return;
      }
      print('DEBUG: Firebase User: ${firebaseUser.email}');
      print('DEBUG: Firebase User Display Name: ${firebaseUser.displayName}');

      print(firebaseUser.displayName);

      // 6️⃣ Get Firebase ID Token
      final idToken = await firebaseUser.getIdToken(true);

      print('DEBUG: Firebase ID Token: $idToken');

      // 7️⃣ Get username from Firebase user
      final userName = firebaseUser.displayName?.trim() ?? '';

      print('DEBUG: Username: $userName');

      // 8️⃣ Prepare request body
      final requestBody = {
        "idToken": idToken,
        "provider": "google",
        "username": userName,
      };

      print('DEBUG: Request URL: ${Endpoint.firebaseGoogleLogin}');
      print('DEBUG: Request Body: $requestBody');

      // 9️⃣ Call backend API using GetConnect
      final response = await GetConnect().post(
        Endpoint.firebaseGoogleLogin,
        requestBody,
        headers: {"accept": "application/json"},
      );

      print('DEBUG: Response Status Code: ${response.statusCode}');
      print('DEBUG: Response Body: ${response.body}');
      print('DEBUG: Response Status Text: ${response.statusText}');

      isLoading.value = false;
      EasyLoading.dismiss();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.body['data']['token'] ?? '';
        final user = response.body['data']['user'];

        print('DEBUG: Backend Token: $token');
        print('DEBUG: Backend User: $user');

        // 🔟 Save token & user info
        await pref.saveToken(token);
        await pref.saveRowToken(token);
        await pref.saveUserId(user['id'].toString());
        await pref.saveUserName(
          userName: user['name'] ?? '',
          phoneNumber: user['phone'] ?? '',
        );

        print('DEBUG: Token and user info saved successfully');

        // Sync FCM token now that auth token is saved
        final freshFcmToken = await fcmNotificationController.getFreshToken();
        if (freshFcmToken.isNotEmpty) {
          await fcmNotificationController.syncTokenWithBackend(freshFcmToken);
        }

        EasyLoading.showSuccess('Login successful!');
        Future.delayed(Duration(seconds: 1), () async {
          await Get.offAllNamed(AppRoute.navBarScreen);
        });
      } else {
        print('DEBUG: Login failed - Status: ${response.statusCode}');
        print('DEBUG: Error message: ${response.body}');
        EasyLoading.showError(response.body['message'] ?? 'Login failed');
      }
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      EasyLoading.dismiss();
      print('DEBUG: Firebase auth error: ${e.code} - ${e.message}');
      EasyLoading.showError('Google login failed: ${e.message}');
    } catch (e) {
      isLoading.value = false;
      EasyLoading.dismiss();
      print('DEBUG: Google login error: $e');
      print('DEBUG: Error type: ${e.runtimeType}');
      EasyLoading.showError('Google login failed: $e');
    }
  }
}
