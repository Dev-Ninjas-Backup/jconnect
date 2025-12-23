class OrderTimelineStep {
  final String title;
  final String dateTime;
  final bool isCompleted;

  OrderTimelineStep({
    required this.title,
    required this.dateTime,
    required this.isCompleted,
  });

  factory OrderTimelineStep.fromJson(Map<String, dynamic> json) {
    // Pick title from several possible keys the backend might use
    String pickTitle(Map<String, dynamic> src) {
      final candidates = ['title', 'name', 'step', 'label', 'text'];
      for (final k in candidates) {
        if (src.containsKey(k) && src[k] != null) return src[k].toString();
      }
      return '';
    }

    // Pick date/time from several common keys
    String pickDate(Map<String, dynamic> src) {
      final candidates = ['createdAt'];
      for (final k in candidates) {
        if (src.containsKey(k) && src[k] != null) return src[k].toString();
      }
      return '';
    }

    bool pickCompleted(Map<String, dynamic> src) {
      if (src.containsKey('isCompleted')) {
        return src['isCompleted'] == true ||
            src['isCompleted'] == 1 ||
            src['isCompleted'] == '1' ||
            src['isCompleted'] == 'true';
      }
      if (src.containsKey('completed')) {
        return src['completed'] == true ||
            src['completed'] == 1 ||
            src['completed'] == '1' ||
            src['completed'] == 'true';
      }
      if (src.containsKey('is_completed')) {
        return src['is_completed'] == true ||
            src['is_completed'] == 1 ||
            src['is_completed'] == '1' ||
            src['is_completed'] == 'true';
      }
      // fallback: if a status field exists mark completed when it contains 'complete'
      if (src.containsKey('status') && src['status'] != null) {
        final s = src['status'].toString().toLowerCase();
        return s.contains('complete');
      }
      return false;
    }

    return OrderTimelineStep(
      title: pickTitle(json),
      dateTime: pickDate(json),
      isCompleted: pickCompleted(json),
    );
  }
}
