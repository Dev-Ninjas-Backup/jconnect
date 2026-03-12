# Stripe push provisioning rules - suppress warnings for optional features
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider
# --- Stripe core (REQUIRED) ---
-keep class com.flutter.stripe.** { *; }
-keep class com.stripe.android.** { *; }
-keep class com.reactnativestripesdk.** { *; }

-dontwarn com.stripe.android.**
-dontwarn com.reactnativestripesdk.**

# --- Google Pay (Stripe dependency) ---
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# --- Flutter platform views (important) ---
-keep class io.flutter.plugin.platform.** { *; }

# --- Firebase Messaging (FCM) ---
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.internal.** { *; }
-dontwarn com.google.firebase.**
# Keep FCM background handler entry point
-keep class io.flutter.plugins.firebase.messaging.** { *; }
-keep class com.google.firebase.messaging.FirebaseMessagingService { *; }
-keep class com.google.firebase.iid.** { *; }

# !! CRITICAL for release FCM !!
# firebase_installations — used internally by getToken() in FCM v2+.
# Without this, R8 strips the classes and getToken() silently returns null.
-keep class com.google.firebase.installations.** { *; }
-keep class com.google.firebase.installations.local.** { *; }
-keep class com.google.firebase.installations.remote.** { *; }
-dontwarn com.google.firebase.installations.**

# Firebase components registry (needed for plugin initialization)
-keep class com.google.firebase.components.** { *; }
-keep class com.google.firebase.provider.** { *; }
-keep class com.google.firebase.platforminfo.** { *; }

# Google DataTransport (Firebase telemetry layer)
-keep class com.google.android.datatransport.** { *; }
-dontwarn com.google.android.datatransport.**

# GMS tasks (async operations used by Firebase)
-keep class com.google.android.gms.tasks.** { *; }

# Keep all Firebase Messaging class names (prevent obfuscation)
-keepnames class com.google.firebase.messaging.** { *; }
# --- flutter_local_notifications (REQUIRED for release) ---
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class androidx.core.app.NotificationCompat { *; }
-keep class androidx.core.app.NotificationManagerCompat { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# --- Keep Flutter plugin registrations ---
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
-keep class io.flutter.plugin.common.** { *; }

# --- Keep all Flutter embedding entry points ---
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# --- Prevent R8 from renaming anything in firebase_messaging plugin ---
-keepnames class com.google.firebase.messaging.** { *; }
