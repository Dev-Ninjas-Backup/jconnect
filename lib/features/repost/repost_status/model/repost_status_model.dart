class RepostOrderSeller {
  final String id;
  final String username;
  final String? profilePhoto;

  const RepostOrderSeller({
    required this.id,
    required this.username,
    this.profilePhoto,
  });

  factory RepostOrderSeller.fromJson(Map<String, dynamic> json) {
    return RepostOrderSeller(
      id: json['id'] as String,
      username: json['username'] as String,
      profilePhoto: json['profilePhoto'] as String?,
    );
  }
}

class RepostOrderBuyer {
  final String id;
  final String username;
  final String? profilePhoto;

  const RepostOrderBuyer({
    required this.id,
    required this.username,
    this.profilePhoto,
  });

  factory RepostOrderBuyer.fromJson(Map<String, dynamic> json) {
    return RepostOrderBuyer(
      id: json['id'] as String,
      username: json['username'] as String,
      profilePhoto: json['profilePhoto'] as String?,
    );
  }
}

class RepostOrderListing {
  final String id;
  final String platform;
  final double price;
  final int followerCount;
  final String description;
  final bool isActive;
  final bool isPaused;
  final String defaultTurnaround;

  const RepostOrderListing({
    required this.id,
    required this.platform,
    required this.price,
    required this.followerCount,
    required this.description,
    required this.isActive,
    required this.isPaused,
    required this.defaultTurnaround,
  });

  factory RepostOrderListing.fromJson(Map<String, dynamic> json) {
    return RepostOrderListing(
      id: json['id'] as String,
      platform: json['platform'] as String,
      price: (json['price'] as num).toDouble(),
      followerCount: json['followerCount'] as int,
      description: json['description'] as String,
      isActive: json['isActive'] as bool,
      isPaused: json['isPaused'] as bool,
      defaultTurnaround: json['defaultTurnaround'] as String,
    );
  }
}

class RepostStatusItem {
  final String id;
  final String orderCode;
  final String buyerId;
  final String sellerId;
  final String listingId;
  final String platform;
  final String timeframe;
  final double amount;
  final double platformFee;
  final double sellerAmount;
  final String status;
  final String contentUrl;
  final List<String> contentFiles;
  final DateTime? countdownEndsAt;
  final String? proofType;
  final String? proofUrl;
  final List<String> proofFiles;
  final DateTime? proofSubmittedAt;
  final DateTime? reviewWindowEndsAt;
  final DateTime? redoWindowEndsAt;
  final int redoCount;
  final String? redoInstructions;
  final bool isReleased;
  final DateTime? releasedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final RepostOrderListing? listing;
  final RepostOrderSeller? seller;
  final RepostOrderBuyer? buyer;

  const RepostStatusItem({
    required this.id,
    required this.orderCode,
    required this.buyerId,
    required this.sellerId,
    required this.listingId,
    required this.platform,
    required this.timeframe,
    required this.amount,
    required this.platformFee,
    required this.sellerAmount,
    required this.status,
    required this.contentUrl,
    required this.contentFiles,
    this.countdownEndsAt,
    this.proofType,
    this.proofUrl,
    required this.proofFiles,
    this.proofSubmittedAt,
    this.reviewWindowEndsAt,
    this.redoWindowEndsAt,
    required this.redoCount,
    this.redoInstructions,
    required this.isReleased,
    this.releasedAt,
    required this.createdAt,
    required this.updatedAt,
    this.listing,
    this.seller,
    this.buyer,
  });

  factory RepostStatusItem.fromJson(Map<String, dynamic> json) {
    return RepostStatusItem(
      id: json['id'] as String,
      orderCode: json['orderCode'] as String,
      buyerId: json['buyerId'] as String,
      sellerId: json['sellerId'] as String,
      listingId: json['listingId'] as String,
      platform: json['platform'] as String,
      timeframe: json['timeframe'] as String,
      amount: (json['amount'] as num) / 100.toDouble(),
      platformFee: (json['platformFee'] as num) / 100.toDouble(),
      sellerAmount: (json['sellerAmount'] as num) / 100.toDouble(),
      status: json['status'] as String,
      contentUrl: json['contentUrl'] as String? ?? '',
      contentFiles: List<String>.from(json['contentFiles'] as List? ?? []),
      countdownEndsAt: json['countdownEndsAt'] != null
          ? DateTime.tryParse(json['countdownEndsAt'] as String)
          : null,
      proofType: json['proofType'] as String?,
      proofUrl: json['proofUrl'] as String?,
      proofFiles: List<String>.from(json['proofFiles'] as List? ?? []),
      proofSubmittedAt: json['proofSubmittedAt'] != null
          ? DateTime.tryParse(json['proofSubmittedAt'] as String)
          : null,
      reviewWindowEndsAt: json['reviewWindowEndsAt'] != null
          ? DateTime.tryParse(json['reviewWindowEndsAt'] as String)
          : null,
      redoWindowEndsAt: json['redoWindowEndsAt'] != null
          ? DateTime.tryParse(json['redoWindowEndsAt'] as String)
          : null,
      redoCount: json['redoCount'] as int? ?? 0,
      redoInstructions: json['redoInstructions'] as String?,
      isReleased: json['isReleased'] as bool? ?? false,
      releasedAt: json['releasedAt'] != null
          ? DateTime.tryParse(json['releasedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      listing: json['listing'] != null
          ? RepostOrderListing.fromJson(json['listing'] as Map<String, dynamic>)
          : null,
      seller: json['seller'] != null
          ? RepostOrderSeller.fromJson(json['seller'] as Map<String, dynamic>)
          : null,
      buyer: json['buyer'] != null
          ? RepostOrderBuyer.fromJson(json['buyer'] as Map<String, dynamic>)
          : null,
    );
  }

  RepostStatusItem copyWith({
    String? id,
    String? orderCode,
    String? buyerId,
    String? sellerId,
    String? listingId,
    String? platform,
    String? timeframe,
    double? amount,
    double? platformFee,
    double? sellerAmount,
    String? status,
    String? contentUrl,
    List<String>? contentFiles,
    DateTime? countdownEndsAt,
    String? proofType,
    String? proofUrl,
    List<String>? proofFiles,
    DateTime? proofSubmittedAt,
    DateTime? reviewWindowEndsAt,
    DateTime? redoWindowEndsAt,
    int? redoCount,
    String? redoInstructions,
    bool? isReleased,
    DateTime? releasedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    RepostOrderListing? listing,
    RepostOrderSeller? seller,
    RepostOrderBuyer? buyer,
  }) {
    return RepostStatusItem(
      id: id ?? this.id,
      orderCode: orderCode ?? this.orderCode,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      listingId: listingId ?? this.listingId,
      platform: platform ?? this.platform,
      timeframe: timeframe ?? this.timeframe,
      amount: amount ?? this.amount,
      platformFee: platformFee ?? this.platformFee,
      sellerAmount: sellerAmount ?? this.sellerAmount,
      status: status ?? this.status,
      contentUrl: contentUrl ?? this.contentUrl,
      contentFiles: contentFiles ?? this.contentFiles,
      countdownEndsAt: countdownEndsAt ?? this.countdownEndsAt,
      proofType: proofType ?? this.proofType,
      proofUrl: proofUrl ?? this.proofUrl,
      proofFiles: proofFiles ?? this.proofFiles,
      proofSubmittedAt: proofSubmittedAt ?? this.proofSubmittedAt,
      reviewWindowEndsAt: reviewWindowEndsAt ?? this.reviewWindowEndsAt,
      redoWindowEndsAt: redoWindowEndsAt ?? this.redoWindowEndsAt,
      redoCount: redoCount ?? this.redoCount,
      redoInstructions: redoInstructions ?? this.redoInstructions,
      isReleased: isReleased ?? this.isReleased,
      releasedAt: releasedAt ?? this.releasedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      listing: listing ?? this.listing,
      seller: seller ?? this.seller,
      buyer: buyer ?? this.buyer,
    );
  }
}
