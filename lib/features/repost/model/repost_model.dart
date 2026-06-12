import 'dart:ui';

class RepostPlatform {
  final String name;
  final String? iconPath;
  final Color accent;
  final List<String> repostTypes;

  const RepostPlatform({
    required this.name,
    required this.iconPath,
    required this.accent,
    required this.repostTypes,
  });
}
