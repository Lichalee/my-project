class OccasionReminder {
  final String id;
  final String title; // e.g. "Mom's Birthday"
  final String recipient; // e.g. "Mom"
  final DateTime date;
  final String occasionType; // 'Birthday', 'Anniversary', 'Valentine', 'Graduation'
  final String suggestedFlower;

  OccasionReminder({
    required this.id,
    required this.title,
    required this.recipient,
    required this.date,
    required this.occasionType,
    required this.suggestedFlower,
  });

  int get daysRemaining {
    final now = DateTime.now();
    final thisYearDate = DateTime(now.year, date.month, date.day);
    if (thisYearDate.isBefore(DateTime(now.year, now.month, now.day))) {
      return DateTime(now.year + 1, date.month, date.day).difference(now).inDays;
    }
    return thisYearDate.difference(DateTime(now.year, now.month, now.day)).inDays;
  }
}
