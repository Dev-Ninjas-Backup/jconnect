
class RepostPlatform {
  final String name;
  final String? iconPath;
  final String heroTitle;
  final String heroSubtitle;
  final String visualTag;
  final List<String> highlights;
  final List<String> repostTypes;
  final List<RepostOption> repostOptions;

  const RepostPlatform({
    required this.name,
    required this.iconPath,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.visualTag,
    required this.highlights,
    required this.repostTypes,
    required this.repostOptions,
  });
}

class RepostOption {
  final String title;
  final String price;
  final String badge;

  const RepostOption({
    required this.title,
    required this.price,
    required this.badge,
  });
}
