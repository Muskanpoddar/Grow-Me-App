enum TimeFilter { week, month, year, all }

DateTime getStartDate(TimeFilter filter) {
  final now = DateTime.now();

  switch (filter) {
    case TimeFilter.week:
      return now.subtract(const Duration(days: 7));
    case TimeFilter.month:
      return DateTime(now.year, now.month, 1);
    case TimeFilter.year:
      return DateTime(now.year, 1, 1);
    case TimeFilter.all:
      return DateTime(2000, 1, 1);
  }
}
