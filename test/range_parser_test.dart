import 'package:flutter_test/flutter_test.dart';
import 'package:vidsnap_reader/src/services/range_parser.dart';

void main() {
  test('parse simple ranges', () {
    final p = RangeParser.parse('1-3,7,10-12', maxPages: 50).pages;
    expect(p, [1,2,3,7,10,11,12]);
  });

  test('invalid tokens', () {
    expect(()=> RangeParser.parse('0,2', maxPages: 10), throwsFormatException);
    expect(()=> RangeParser.parse('2-1', maxPages: 10), throwsFormatException);
    expect(()=> RangeParser.parse('999', maxPages: 10), throwsFormatException);
  });
}
