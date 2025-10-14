class PageRange {
  final List<int> pages;
  PageRange(this.pages);
}

class RangeParser {
  /// "1-3,7,10-12" (1-based). Lanza FormatException si hay error.
  static PageRange parse(String input, {required int maxPages}) {
    if (input.trim().isEmpty) throw const FormatException('Empty');
    final set = <int>{};
    final parts = input.split(',').map((e) => e.trim()).toList();
    for (final p in parts) {
      if (p.isEmpty) continue;
      if (p.contains('-')) {
        final b = p.split('-').map((e) => e.trim()).toList();
        if (b.length != 2) throw const FormatException('Bad token');
        final s = int.tryParse(b[0]) ?? -1;
        final e = int.tryParse(b[1]) ?? -1;
        if (s <= 0 || e <= 0 || e < s) throw const FormatException('Bad range');
        for (int i = s; i <= e; i++) {
          if (i > maxPages) throw const FormatException('Out of bounds');
          set.add(i);
        }
      } else {
        final v = int.tryParse(p) ?? -1;
        if (v <= 0 || v > maxPages) throw const FormatException('Bad page');
        set.add(v);
      }
    }
    final list = set.toList()..sort();
    return PageRange(list);
  }
}
