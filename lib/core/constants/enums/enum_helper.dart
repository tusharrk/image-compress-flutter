class EnumHelper {
  static T? fromString<T extends Enum>(String? value, List<T> values) {
    if (value == null) return null;
    try {
      return values.firstWhere(
        (e) => e.toString().split('.').last == value,
      );
    } catch (e) {
      return null;
    }
  }

  static String? enumToString<T extends Enum>(T? enumValue) {
    return enumValue?.toString().split('.').last;
  }
}
