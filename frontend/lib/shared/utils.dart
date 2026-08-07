class Utils {
  static String formatTimestamp(DateTime time) {
    return '${time.hour}:${time.minute} ${time.day}/${time.month}/${time.year}';
  }
}
