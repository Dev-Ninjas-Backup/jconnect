class OrderTimelineStep {
  final String title;
  final String dateTime;
  final bool isCompleted;
  final String? description;

  OrderTimelineStep({
    required this.title,
    required this.dateTime,
    required this.isCompleted,
    this.description,
  });

  factory OrderTimelineStep.fromJson(Map<String, dynamic> json) {
    // Pick title from several possible keys the backend might use
    String pickTitle(Map<String, dynamic> src) {
      final candidates = ['title', 'name', 'step', 'label', 'text'];
      for (final k in candidates) {
        if (src.containsKey(k) && src[k] != null && src[k].toString().isNotEmpty) {
          return src[k].toString();
        }
      }
      if (src.containsKey('status') && src['status'] != null) {
        final s = src['status'].toString().toUpperCase();
        switch (s) {
          case 'PENDING':
            return 'Order Placed';
          case 'IN_PROGRESS':
            return 'In Progress';
          case 'PROOF_SUBMITTED':
            return 'Proof Submitted';
          case 'RESUBMIT':
            return 'Proof Rejected - Resubmit Required';
          case 'RELEASED':
          case 'COMPLETED':
          case 'COMPLETE':
            return 'Order Completed';
          case 'CANCELLED':
            return 'Order Cancelled';
          default:
            return s;
        }
      }
      return '';
    }

    // Pick date/time from several common keys
    String pickDate(Map<String, dynamic> src) {
      final candidates = ['at', 'createdAt', 'created_at', 'dateTime', 'timestamp', 'date'];
      for (final k in candidates) {
        if (src.containsKey(k) && src[k] != null && src[k].toString().isNotEmpty) {
          return src[k].toString();
        }
      }
      return '';
    }

    String? pickDescription(Map<String, dynamic> src) {
      if (src['description'] != null && src['description'].toString().isNotEmpty) {
        return src['description'].toString();
      }
      if (src['reason'] != null && src['reason'].toString().isNotEmpty) {
        return src['reason'].toString();
      }
      return null;
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
      // If a date timestamp exists for this step, it has arrived/occurred
      final date = pickDate(src);
      if (date.isNotEmpty) {
        return true;
      }
      // fallback: if a status field exists mark completed when it contains 'complete' or is active status
      if (src.containsKey('status') && src['status'] != null) {
        final s = src['status'].toString().toLowerCase();
        return s.contains('complete') || s == 'released' || s == 'proof_submitted' || s == 'resubmit' || s == 'pending' || s == 'in_progress' || s == 'active';
      }
      return false;
    }

    return OrderTimelineStep(
      title: pickTitle(json),
      dateTime: pickDate(json),
      isCompleted: pickCompleted(json),
      description: pickDescription(json),
    );
  }
}
