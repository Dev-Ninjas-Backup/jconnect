
class RepostPlatform {
  final String name;
  final String? iconPath;
  final String heroTitle;
  final String heroSubtitle;
  final String visualTag;
 // final List<String> highlights;
  final List<String> repostTypes;
  final List<RepostOption> repostOptions;

  const RepostPlatform({
    required this.name,
    required this.iconPath,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.visualTag,
   // required this.highlights,
    required this.repostTypes,
    required this.repostOptions,
  });
}

class RepostOption {
  final String title;
  final String price;
  final String badge;
  final String listingId;
  final int followerCount;
  final String description;
  final String defaultTurnaround;
  final String rawPlatform;

  const RepostOption({
    required this.title,
    required this.price,
    required this.badge,
    required this.listingId,
    required this.followerCount,
    required this.description,
    required this.defaultTurnaround,
    required this.rawPlatform,
  });
}
