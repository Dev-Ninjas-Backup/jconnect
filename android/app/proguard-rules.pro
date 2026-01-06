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
