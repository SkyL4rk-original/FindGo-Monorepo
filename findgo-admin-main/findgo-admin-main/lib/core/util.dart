// ignore_for_file: avoid_classes_with_only_static_members

class Util {
  static String convertDateTimeToUtcISO(DateTime dateTime) {
    final dtUtcIso = dateTime.toUtc().toIso8601String();
    return dtUtcIso.substring(0, dtUtcIso.length - 1);
  }
}
