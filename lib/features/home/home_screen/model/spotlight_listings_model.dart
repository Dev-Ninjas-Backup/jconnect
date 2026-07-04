class SpotlightListingModel {
  final String id;
  final String sellerId;
  final String platform;
  final double price;
  final int followerCount;
  final String description;
  final bool isActive;
  final bool isPaused;
  final bool isSpotlight;
  final String defaultTurnaround;
  final int totalPurchases;
  final int totalAccepts;
  final int totalProofs;
  final int totalRedos;
  final int totalAutoReleases;
  final int totalCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SpotlightSeller? seller;

  SpotlightListingModel({
    required this.id,
    required this.sellerId,
    required this.platform,
    required this.price,
    required this.followerCount,
    required this.description,
    required this.isActive,
    required this.isPaused,
    required this.isSpotlight,
    required this.defaultTurnaround,
    required this.totalPurchases,
    required this.totalAccepts,
    required this.totalProofs,
    required this.totalRedos,
    required this.totalAutoReleases,
    required this.totalCompleted,
    required this.createdAt,
    required this.updatedAt,
    this.seller,
  });

  factory SpotlightListingModel.fromJson(Map<String, dynamic> json) {
    return SpotlightListingModel(
      id: json['id'] ?? '',
      sellerId: json['sellerId'] ?? '',
      platform: json['platform'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      followerCount: json['followerCount'] ?? 0,
      description: json['description'] ?? '',
      isActive: json['isActive'] ?? false,
      isPaused: json['isPaused'] ?? false,
      isSpotlight: json['isSpotlight'] ?? false,
      defaultTurnaround: json['defaultTurnaround'] ?? '',
      totalPurchases: json['totalPurchases'] ?? 0,
      totalAccepts: json['totalAccepts'] ?? 0,
      totalProofs: json['totalProofs'] ?? 0,
      totalRedos: json['totalRedos'] ?? 0,
      totalAutoReleases: json['totalAutoReleases'] ?? 0,
      totalCompleted: json['totalCompleted'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      seller: json['seller'] != null ? SpotlightSeller.fromJson(json['seller']) : null,
    );
  }
}

class SpotlightSeller {
  final String id;
  final String fullName;
  final String username;
  final String? profilePhoto;
  final bool isProfileVerified;

  SpotlightSeller({
    required this.id,
    required this.fullName,
    required this.username,
    this.profilePhoto,
    required this.isProfileVerified,
  });

  factory SpotlightSeller.fromJson(Map<String, dynamic> json) {
    return SpotlightSeller(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      username: json['username'] ?? '',
      profilePhoto: json['profilePhoto'],
      isProfileVerified: json['isProfileVerified'] ?? false,
    );
  }
}
