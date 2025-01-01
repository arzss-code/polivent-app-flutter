import 'package:timeago/timeago.dart' as timeago;

class IdLocaleMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => _shouldShowSuffix ? 'yang lalu' : '';
  @override
  String suffixFromNow() => 'dari sekarang';

  bool get _shouldShowSuffix {
    // Tambahkan logika untuk menentukan apakah suffix harus ditampilkan
    final now = DateTime.now();
    final difference = now.difference(DateTime.now());
    return difference.inMinutes > 0;
  }

  @override
  String lessThanOneMinute(int seconds) => 'baru saja';
  @override
  String aboutAMinute(int minutes) => 'semenit yang lalu';
  @override
  String minutes(int minutes) => '$minutes menit yang lalu';
  @override
  String aboutAnHour(int minutes) => 'sejam yang lalu';
  @override
  String hours(int hours) => '$hours jam yang lalu';
  @override
  String aDay(int hours) => 'sehari yang lalu';
  @override
  String days(int days) => '$days hari yang lalu';
  @override
  String aboutAMonth(int days) => 'sebulan yang lalu';
  @override
  String months(int months) => '$months bulan yang lalu';
  @override
  String aboutAYear(int year) => 'setahun yang lalu';
  @override
  String years(int years) => '$years tahun yang lalu';
  @override
  String wordSeparator() => ' ';
}
