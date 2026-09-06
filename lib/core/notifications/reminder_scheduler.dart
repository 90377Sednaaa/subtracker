class ScheduleRequest {
  const ScheduleRequest({
    required this.id,
    required this.title,
    required this.body,
    required this.fireAt,
  });

  final int id;
  final String title;
  final String body;
  final DateTime fireAt;
}

abstract class ReminderScheduler {
  Future<void> schedule(ScheduleRequest request);
  Future<void> cancel(int id);
}

/// Stable, positive 31-bit notification id derived from the Firestore doc id.
int notificationIdFor(String subscriptionId) =>
    subscriptionId.hashCode & 0x7fffffff;
