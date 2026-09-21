class DateConverter {
  static const List<String> hariMasehi = ['Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'];
  static const List<String> pasaran = ['Legi','Pahing','Pon','Wage','Kliwon'];
  static const List<String> bulanMasehi = ['Januari','Februari','Maret','April','Mei','Juni','Juli','Agustus','September','Oktober','November','Desember'];
  static const List<String> bulanHijriah = ['Muharram','Safar','Rabiul Awal','Rabiul Akhir','Jumadil Awal','Jumadil Akhir','Rajab','Syaban','Ramadhan','Syawal','Dzulqaidah','Dzulhijjah'];
  static const List<String> shio = ['Tikus','Kerbau','Macan','Kelinci','Naga','Ular','Kuda','Kambing','Monyet','Ayam','Anjing','Babi'];
  static const List<String> elemen = ['Kayu','Api','Tanah','Logam','Air'];

  static String masehi(DateTime d) => '\${hariMasehi[d.weekday - 1]}, \${d.day} \${bulanMasehi[d.month - 1]} \${d.year}';

  static List<int> _gregorianToHijri(int year, int month, int day) {
    int jd;
    if ((year > 1582) || (year == 1582 && month > 10) || (year == 1582 && month == 10 && day > 14)) {
      jd = ((1461 * (year + 4800 + ((month - 14) ~/ 12))) ~/ 4) +
          ((367 * (month - 2 - 12 * ((month - 14) ~/ 12))) ~/ 12) -
          ((3 * ((year + 4900 + ((month - 14) ~/ 12)) ~/ 100)) ~/ 4) + day - 32075;
    } else {
      jd = 367 * year - ((7 * (year + 5001 + ((month - 9) ~/ 7))) ~/ 4) +
          ((275 * month) ~/ 9) + day + 1729777;
    }
    int l = jd - 1948440 + 10632;
    final n = (l - 1) ~/ 10631;
    l = l - 10631 * n + 354;
    final j = (((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719)) + ((l ~/ 5670) * ((43 * l) ~/ 15238));
    l = l - (((30 - j) ~/ 15) * ((17719 * j) ~/ 50)) - ((j ~/ 16) * ((15238 * j) ~/ 43)) + 29;
    final monthH = (24 * l) ~/ 709;
    final dayH = l - ((709 * monthH) ~/ 24);
    final yearH = 30 * n + j - 30;
    return [yearH, monthH, dayH];
  }

  static String hijriah(DateTime d) {
    final h = _gregorianToHijri(d.year, d.month, d.day);
    return '\${h[2]} \${bulanHijriah[(h[1] - 1).clamp(0, 11)]} \${h[0]} H';
  }

  static int _daysFromEpoch(DateTime d) {
    final base = DateTime.utc(1970, 1, 1);
    final target = DateTime.utc(d.year, d.month, d.day);
    return target.difference(base).inDays;
  }

  static String wetonJawa(DateTime d) {
    final idx = (((_daysFromEpoch(d) + 3) % 5) + 5) % 5;
    return '\${hariMasehi[d.weekday - 1]} \${pasaran[idx]}';
  }

  static String shioCina(DateTime d) {
    final y = d.year;
    final animal = shio[((y - 4) % 12 + 12) % 12];
    final el = elemen[(((y - 4) % 10 + 10) % 10) ~/ 2];
    return '\$animal (\$el)';
  }

  static DateTime _addMonths(DateTime d, int months) {
    final total = d.year * 12 + d.month - 1 + months;
    final targetYear = total ~/ 12;
    final targetMonth = total % 12 + 1;
    final lastDay = DateTime(targetYear, targetMonth + 1, 0).day;
    final day = d.day > lastDay ? lastDay : d.day;
    return DateTime(targetYear, targetMonth, day, d.hour, d.minute, d.second, d.millisecond, d.microsecond);
  }

  static String hitungUmurLengkap(DateTime birthDate) {
    final now = DateTime.now();
    if (birthDate.isAfter(now)) return 'Tanggal lahir belum terjadi';

    var years = now.year - birthDate.year;
    var anchor = DateTime(birthDate.year + years, birthDate.month, birthDate.day, birthDate.hour, birthDate.minute, birthDate.second);
    if (anchor.isAfter(now)) {
      years--;
      anchor = DateTime(birthDate.year + years, birthDate.month, birthDate.day, birthDate.hour, birthDate.minute, birthDate.second);
    }

    var months = 0;
    while (true) {
      final next = _addMonths(anchor, 1);
      if (next.isAfter(now)) break;
      anchor = next;
      months++;
    }

    final remaining = now.difference(anchor);
    final days = remaining.inDays;
    final hours = remaining.inHours.remainder(24);
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);
    return '\$years Tahun \$months Bulan \$days Hari \$hours Jam \$minutes Menit \$seconds Detik';
  }

  static String sakaBali(DateTime d) {
    var tahunSaka = d.year - 78;
    if (d.month < 3 || (d.month == 3 && d.day < 15)) tahunSaka -= 1;
    return '\$tahunSaka Saka';
  }

  static Map<String, String> all(DateTime d) => {
    'Masehi': masehi(d),
    'Hijriah': hijriah(d),
    'Weton Jawa': wetonJawa(d),
    'Shio Cina': shioCina(d),
    'Saka Bali': sakaBali(d),
    'Umur': hitungUmurLengkap(d),
  };
}
