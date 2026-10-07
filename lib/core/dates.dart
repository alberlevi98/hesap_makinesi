/// Calendar difference between two dates as years, months and days.
class DateDiff {
  const DateDiff(this.years, this.months, this.days, this.totalDays);
  final int years;
  final int months;
  final int days;
  final int totalDays;
}

DateTime _utcDate(DateTime d) => DateTime.utc(d.year, d.month, d.day);

int _daysInMonth(int year, int month) => DateTime.utc(year, month + 1, 0).day;

/// Order-independent: the result is always non-negative.
DateDiff dateDifference(DateTime a, DateTime b) {
  var start = _utcDate(a);
  var end = _utcDate(b);
  if (end.isBefore(start)) {
    final t = start;
    start = end;
    end = t;
  }
  // Whole months between the dates, then the remaining days counted from
  // the anchor date (day clamped to month length, e.g. Jan 31 + 1 month = Feb 29).
  var totalMonths = (end.year - start.year) * 12 + end.month - start.month;
  if (end.day < start.day) totalMonths--;
  final anchorYear = start.year + (start.month - 1 + totalMonths) ~/ 12;
  final anchorMonth = (start.month - 1 + totalMonths) % 12 + 1;
  final anchorDay = start.day.clamp(1, _daysInMonth(anchorYear, anchorMonth));
  final anchor = DateTime.utc(anchorYear, anchorMonth, anchorDay);
  final years = totalMonths ~/ 12;
  final months = totalMonths % 12;
  final days = end.difference(anchor).inDays;
  return DateDiff(years, months, days, end.difference(start).inDays);
}

DateTime addDays(DateTime date, int days) {
  final d = _utcDate(date).add(Duration(days: days));
  return DateTime(d.year, d.month, d.day);
}
