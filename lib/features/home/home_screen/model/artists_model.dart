// artists_model.dart

class ArtistsModel {
  final String id;
  final String fullName;
  final String email;
  final String? profilePhoto;
  final String phone;
  final String? pinCode;
  final String? otp;
  final String? googleId;
  final String? emailOtp;
  final String? otpExpiresAt;
  final bool isVerified;
  final bool isTermsAgreed;
  final bool isLogin;
  final bool isDeleted;
  final bool isActive;
  final int loginAttempts;
  final int withdrawnAmount;

  final int? phoneOtp; 
  final String? phoneOtpExpiresAt;
  final bool phoneVerified;

  final String? lastLoginAt; 
  final String createdAt;
  final String updatedAt;
  final String? tokenExpiresAt;

  final String role;
  final String validationType;
  final String? authProvider;
  final int? stripeAccountId;
  final String? sellerIDStripe;
  final String? customerIdStripe;

  final List<ServiceModel> services;
  final List<ReviewModel> reviewsGiven;
  final List<ReviewModel> reviewsReceived;

  ArtistsModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.profilePhoto,
    required this.phone,
    this.pinCode,
    this.otp,
    this.googleId,
    this.emailOtp,
    this.otpExpiresAt,
    required this.isVerified,
    required this.isTermsAgreed,
    required this.isLogin,
    required this.isDeleted,
    required this.isActive,
    required this.loginAttempts,
    required this.withdrawnAmount,
    this.phoneOtp,
    this.phoneOtpExpiresAt,
    required this.phoneVerified,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
    this.tokenExpiresAt,
    required this.role,
    required this.validationType,
    this.authProvider,
    this.stripeAccountId,
    this.sellerIDStripe,
    this.customerIdStripe,
    required this.services,
    required this.reviewsGiven,
    required this.reviewsReceived,
  });

  factory ArtistsModel.fromJson(Map<String, dynamic> json) {
    return ArtistsModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      profilePhoto: json['profilePhoto'] as String?,
      phone: json['phone'].toString(),
      pinCode: json['pinCode'].toString(),
      otp: json['otp'].toString(),
      googleId: json['googleId'] as String?,
      emailOtp: json['emailOtp'].toString(),
      otpExpiresAt: json['otpExpiresAt'].toString(),
      isVerified: json['isVerified'] as bool,
      isTermsAgreed: json['is_terms_agreed'] as bool,
      isLogin: json['isLogin'] as bool,
      isDeleted: json['isDeleted'] as bool,
      isActive: json['isActive'] as bool,
      loginAttempts: json['login_attempts'] as int,
      withdrawnAmount: json['withdrawn_amount'] as int,
      phoneOtp: json['phoneOtp'] as int?,
      phoneOtpExpiresAt: json['phoneOtpExpiresAt'].toString(),
      phoneVerified: json['phoneVerified'] as bool,
      lastLoginAt: json['last_login_at'].toString(),
      createdAt: json['created_at'].toString(),
      updatedAt: json['updated_at'].toString(),
      tokenExpiresAt: json['token_expires_at'].toString(),
      role: json['role'] as String,
      validationType: json['validation_type'] as String,
      authProvider: json['auth_provider'] as String?,
      stripeAccountId: json['stripeAccountId'] as int?,
      sellerIDStripe: json['sellerIDStripe'].toString(),
      customerIdStripe: json['customerIdStripe'].toString(),
      services: (json['services'] as List<dynamic>? ?? [])
          .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      reviewsGiven: (json['ReviewsGiven'] as List<dynamic>? ?? [])
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      reviewsReceived: (json['ReviewsReceived'] as List<dynamic>? ?? [])
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'email': email,
    'profilePhoto': profilePhoto,
    'phone': phone,
    'pinCode': pinCode,
    'otp': otp,
    'googleId': googleId,
    'emailOtp': emailOtp,
    'otpExpiresAt': otpExpiresAt,
    'isVerified': isVerified,
    'is_terms_agreed': isTermsAgreed,
    'isLogin': isLogin,
    'isDeleted': isDeleted,
    'isActive': isActive,
    'login_attempts': loginAttempts,
    'withdrawn_amount': withdrawnAmount,
    'phoneOtp': phoneOtp,
    'phoneOtpExpiresAt': phoneOtpExpiresAt,
    'phoneVerified': phoneVerified,
    'last_login_at': lastLoginAt,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'token_expires_at': tokenExpiresAt,
    'role': role,
    'validation_type': validationType,
    'auth_provider': authProvider,
    'stripeAccountId': stripeAccountId,
    'sellerIDStripe': sellerIDStripe,
    'customerIdStripe': customerIdStripe,
    'services': services.map((s) => s.toJson()).toList(),
    'ReviewsGiven': reviewsGiven.map((r) => r.toJson()).toList(),
    'ReviewsReceived': reviewsReceived.map((r) => r.toJson()).toList(),
  };
}

// ==================================================================
// Service Model
// ==================================================================

class ServiceModel {
  final String id;
  final String serviceName;
  final String description;
  final int price;
  final String currency;
  final String creatorId;
  final String createdAt;
  final String updatedAt;
  final bool isPost;
  final bool isCustom;

  ServiceModel({
    required this.id,
    required this.serviceName,
    required this.description,
    required this.price,
    required this.currency,
    required this.creatorId,
    required this.createdAt,
    required this.updatedAt,
    required this.isPost,
    required this.isCustom,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      serviceName: json['serviceName'] as String,
      description: json['description'] as String,
      price: json['price'] as int,
      currency: json['currency'].toString(),
      creatorId: json['creatorId'] as String,
      createdAt: json['createdAt'].toString(),
      updatedAt: json['updatedAt'] as String,
      isPost: json['isPost'] as bool? ?? false,
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'serviceName': serviceName,
    'description': description,
    'price': price,
    'currency': currency,
    'creatorId': creatorId,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'isPost': isPost,
    'isCustom': isCustom,
  };
}

// ==================================================================
// Review Model
// ==================================================================

class ReviewModel {
  final String id;
  final String reviewerId;
  final String artistId;
  final int rating;
  final String reviewText;
  final String createdAt;
  final String updatedAt;

  ReviewModel({
    required this.id,
    required this.reviewerId,
    required this.artistId,
    required this.rating,
    required this.reviewText,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      reviewerId: json['reviewerId'] as String,
      artistId: json['artistId'] as String,
      rating: json['rating'] as int,
      reviewText: json['reviewText'] as String? ?? '',
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'reviewerId': reviewerId,
    'artistId': artistId,
    'rating': rating,
    'reviewText': reviewText,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}
