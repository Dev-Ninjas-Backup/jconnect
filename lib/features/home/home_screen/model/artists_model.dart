class ArtistsModel {
  final String id;
  final String fullName;
  final String email;
  final String? profilePhoto;
  final String phone;

  final bool isVerified;
  final bool isTermsAgreed;
  final bool isLogin;
  final bool isDeleted;
  final bool isActive;

  final int loginAttempts;
  final double withdrawnAmount;

  final bool phoneVerified;

  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String role;
  final String validationType;

  final String? customerIdStripe;

  final List<ServiceModel> services;
  final ProfileModel? profile;
  final List<ReviewModel> reviewsReceived;

  final double averageRating;
  final int totalReviews;

  const ArtistsModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.profilePhoto,
    required this.phone,
    required this.isVerified,
    required this.isTermsAgreed,
    required this.isLogin,
    required this.isDeleted,
    required this.isActive,
    required this.loginAttempts,
    required this.withdrawnAmount,
    required this.phoneVerified,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
    required this.role,
    required this.validationType,
    this.customerIdStripe,
    required this.services,
    this.profile,
    required this.reviewsReceived,
    required this.averageRating,
    required this.totalReviews,
  });

  factory ArtistsModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? v) => v == null ? null : DateTime.tryParse(v);

    return ArtistsModel(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      profilePhoto: json['profilePhoto'],
      phone: json['phone'] ?? '',
      isVerified: json['isVerified'] ?? false,
      isTermsAgreed: json['is_terms_agreed'] ?? false,
      isLogin: json['isLogin'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      isActive: json['isActive'] ?? true,
      loginAttempts: json['login_attempts'] ?? 0,
      withdrawnAmount: (json['withdrawn_amount'] ?? 0).toDouble(),
      phoneVerified: json['phoneVerified'] ?? false,
      lastLoginAt: parseDate(json['last_login_at']),
      createdAt: parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: parseDate(json['updated_at']) ?? DateTime.now(),

      role: json['role'] ?? '',
      validationType: json['validation_type'] ?? '',
      customerIdStripe: json['customerIdStripe'],
      services: (json['services'] as List? ?? [])
          .map((e) => ServiceModel.fromJson(e))
          .toList(),
      profile: json['profile'] != null
          ? ProfileModel.fromJson(json['profile'])
          : null,
      reviewsReceived: (json['ReviewsReceived'] as List? ?? [])
          .map((e) => ReviewModel.fromJson(e))
          .toList(),
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
    );
  }
}

class ServiceModel {
  final String id;
  final String serviceName;
  final String serviceType;
  final String description;
  final double price;
  final String currency;
  final bool isPost;
  final bool isCustom;

  ServiceModel({
    required this.id,
    required this.serviceName,
    required this.serviceType,
    required this.description,
    required this.price,
    required this.currency,
    required this.isPost,
    required this.isCustom,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      serviceName: json['serviceName'] ?? '',
      serviceType: json['serviceType'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      isPost: json['isPost'] ?? false,
      isCustom: json['isCustom'] ?? false,
    );
  }
}

class ProfileModel {
  final String userId;
  final String? profileImageUrl;
  final String? shortBio;
  final List<SocialProfileModel> socialProfiles;

  ProfileModel({
    required this.userId,
    this.profileImageUrl,
    this.shortBio,
    required this.socialProfiles,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['user_id'],
      profileImageUrl: json['profile_image_url'],
      shortBio: json['short_bio'],
      socialProfiles: (json['socialProfiles'] as List? ?? [])
          .map((e) => SocialProfileModel.fromJson(e))
          .toList(),
    );
  }
}

class SocialProfileModel {
  final String id;
  final String platformName;
  final String platformLink;
  final int orderId;

  SocialProfileModel({
    required this.id,
    required this.platformName,
    required this.platformLink,
    required this.orderId,
  });

  factory SocialProfileModel.fromJson(Map<String, dynamic> json) {
    return SocialProfileModel(
      id: json['id'],
      platformName: json['platformName'],
      platformLink: json['platformLink'],
      orderId: json['orderId'],
    );
  }
}

class ReviewModel {
  final String? id;
  final int? rating;
  final String? reviewText;
  final ReviewerModel? reviewer;

  ReviewModel({this.id, this.rating, this.reviewText, this.reviewer});

  factory ReviewModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ReviewModel();

    return ReviewModel(
      id: json['id'],
      rating: json['rating'],
      reviewText: json['reviewText'],
      reviewer: json['reviewer'] != null
          ? ReviewerModel.fromJson(json['reviewer'])
          : null,
    );
  }
}

class ReviewerModel {
  final String? id;
  final String? fullName;
  final String? profilePhoto;

  ReviewerModel({this.id, this.fullName, this.profilePhoto});

  factory ReviewerModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ReviewerModel();

    return ReviewerModel(
      id: json['id'],
      fullName: json['full_name'],
      profilePhoto: json['profilePhoto'],
    );
  }
}
