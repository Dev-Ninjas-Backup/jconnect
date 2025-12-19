class ProfileModel {
  final String name;
  final String imageUrl;
  final String shortbio;
  final int totaldeals;
  final double earnings;
  final double rating;

  ProfileModel({
    required this.name,
    required this.imageUrl,
    required this.shortbio,
    required this.totaldeals,
    required this.earnings,
    required this.rating,
  });
}

class SocialLinkModel {
  final String platform;
  final String url;

  SocialLinkModel({required this.platform, required this.url});
}

class RateModel {
  final String title;
  final String description;
  final double price;

  RateModel({
    required this.title,
    required this.description,
    required this.price,
  });

  copyWith({required String title}) {}
}
