/// Take a datetime and convert it into an int of the form {year}{month}{day}{hour}{minute} (ex. 202501010030) with leading 0s for months and days less than 10.
int dateTimeToInt(DateTime dateTime) {
  DateTime utc = dateTime.toLocal();

  String month = utc.month < 10 ? '0${utc.month}' : '${utc.month}';
  String day = utc.day < 10 ? '0${utc.day}' : '${utc.day}';
  String hour = utc.hour < 10 ? '0${utc.hour}' : '${utc.hour}';
  String minute = utc.minute < 10 ? '0${utc.minute}' : '${utc.minute}';

  return int.parse('${utc.year}$month$day$hour$minute');
}

/// Return the int formed by taking the current time in local time.
int dateTimeNowToInt() {
  return dateTimeToInt(DateTime.now());
}

/// Return the datetime representation of an int of the form {year}{month}{day}
DateTime intToDateTime(int dateTimeInt) {
  String dateTimeString = dateTimeInt.toString();

  String year = dateTimeString.substring(0, 4);
  String month = dateTimeString.substring(4, 6);
  String day = dateTimeString.substring(6, 8);
  String hour = dateTimeString.substring(8, 10);
  String minute = dateTimeString.substring(10, 12);

  return DateTime(
    int.parse(year),
    int.parse(month),
    int.parse(day),
    int.parse(hour),
    int.parse(minute),
  );
}

String dateTimeToYMDString(DateTime dateTime) {
  DateTime localTime = dateTime.toLocal();
  return '${localTime.year}-${localTime.month}-${localTime.day}';
}

String dateTimeToYMDHMString(DateTime dateTime) {
  DateTime localTime = dateTime.toLocal();
  String min = localTime.minute < 10 ? '0${localTime.minute}' : '${localTime.minute}';

  return '${localTime.year}-${localTime.month}-${localTime.day} ${localTime.hour}:$min';
}

String dateTimetoReadableString(DateTime dateTime) {
  DateTime localTime = dateTime.toLocal();
  String min = localTime.minute < 10 ? '0${localTime.minute}' : '${localTime.minute}';
  String hour = localTime.hour < 12 ? '${localTime.hour}' : '${localTime.hour - 12}';
  String amPm = localTime.hour < 12 ? 'AM' : 'PM';
  if (localTime.hour >= 12) {
    hour = hour == '0' ? '12' : hour; // Convert 0 to 12 for PM
  }

  String month = '';
  
  switch (localTime.month) {
    case 1:
      month = 'January';
      break;
    case 2:
      month = 'February';
      break;
    case 3:
      month = 'March';
      break;
    case 4:
      month = 'April';
      break;
    case 5:
      month = 'May';
      break;
    case 6:
      month = 'June';
      break;
    case 7:
      month = 'July';
      break;
    case 8:
      month = 'August';
      break;
    case 9:
      month = 'September';
      break;
    case 10:
      month = 'October';
      break;
    case 11:
      month = 'November';
      break;
    case 12:
      month = 'December';
      break;
    default:
  }

  return '$month, ${localTime.day} ${localTime.year} $hour:$min $amPm';
}

String dateTimeIntToReadableString(int dateTimeInt) {
  DateTime dateTime = intToDateTime(dateTimeInt);

  return dateTimetoReadableString(dateTime);
}

String dateTimeIntToYMDString(int dateTimeInt) {
  DateTime dateTime = intToDateTime(dateTimeInt);

  return dateTimeToYMDString(dateTime);
}

String dateTimeIntToYMDHMString(int dateTimeInt) {
  DateTime dateTime = intToDateTime(dateTimeInt);

  return dateTimeToYMDHMString(dateTime);
}

bool isInThisMonth(int checkDate) {
  int firstOfYear = DateTime.now().year * 10000;
  int firstOfMonth = firstOfYear + (DateTime.now().month * 100);
  int endOfMonth = firstOfMonth + 31;


  return checkDate >= firstOfMonth && checkDate <= endOfMonth;
}


bool isInPreviousMonth(DateTime currentDate, DateTime nextDate) {
  DateTime previousMonth = currentDate.subtract(Duration(days: currentDate.day + 1));

  int firstOfYear = previousMonth.year * 10000;
  int firstOfMonth = firstOfYear + (previousMonth.month * 100);
  int endOfMonth = firstOfMonth + 31;

  int nextDateInt = dateTimeToInt(nextDate);

  return nextDateInt >= firstOfMonth && nextDateInt <= endOfMonth;
}

bool isInNextMonth(DateTime currentDate, DateTime nextDate) {
  DateTime nextMonth = currentDate.add(Duration(days: 32 - currentDate.day));

  int firstOfYear = nextMonth.year * 10000;
  int firstOfMonth = firstOfYear + (nextMonth.month * 100);
  int endOfMonth = firstOfMonth + 31;

  int nextDateInt = dateTimeToInt(nextDate);

  return nextDateInt > firstOfMonth && nextDateInt <= endOfMonth;
}

bool isInThisWeek(int checkDate) {
  //  Make Sunday the first day of the week
  int currentWeekday = DateTime.now().weekday == 7 ? 1 : DateTime.now().weekday + 1;
  DateTime firstOfWeekDT = DateTime.now().subtract(Duration(days: currentWeekday));

  int firstOfWeek = firstOfWeekDT.year * 10000 + firstOfWeekDT.month * 100 + firstOfWeekDT.day;
  int endOfWeek = firstOfWeek + 7;

  return checkDate >= firstOfWeek && checkDate < endOfWeek;
}

bool isInPreviousWeek(DateTime currentDate, DateTime nextDate) {
  //  Make Sunday the first day of the week
  int currentWeekday = currentDate.weekday == 7 ? 1 : currentDate.weekday + 1;
  DateTime firstOfWeekDT = currentDate.subtract(Duration(days: currentWeekday));

  DateTime firstOfPreviousWeek = firstOfWeekDT.subtract(Duration(days: 7));

  int firstOfWeek = firstOfPreviousWeek.year * 10000 + firstOfPreviousWeek.month * 100 + firstOfPreviousWeek.day;
  int endOfWeek = firstOfWeekDT.year * 10000 + firstOfWeekDT.month * 100 + firstOfWeekDT.day;

  int nextDateInt = dateTimeToInt(nextDate);

  return nextDateInt > firstOfWeek && nextDateInt <= endOfWeek;
}

bool isInNextWeek(DateTime currentDate, DateTime nextDate) {
  //  Make Sunday the first day of the week
  int currentWeekday = currentDate.weekday == 7 ? 1 : currentDate.weekday + 1;
  DateTime firstOfWeekDT = currentDate.subtract(Duration(days: currentWeekday));

  DateTime firstOfNextWeek = firstOfWeekDT.add(Duration(days: 7));
  DateTime endOfNextWeek = firstOfWeekDT.add(Duration(days:  14));

  int firstOfWeek = firstOfNextWeek.year * 10000 + firstOfNextWeek.month * 100 + firstOfNextWeek.day;
  int endOfWeek = endOfNextWeek.year * 10000 + endOfNextWeek.month * 100 + endOfNextWeek.day;

  int nextDateInt = dateTimeToInt(nextDate);

  return nextDateInt >= firstOfWeek && nextDateInt < endOfWeek;
}