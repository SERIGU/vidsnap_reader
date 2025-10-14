import 'package:flutter_test/flutter_test.dart';
import 'package:vidsnap_reader/src/services/ad_service.dart';

void main() {
  test('gating ops counter', () async {
    final ads = AdService.instance;
    ads.isPremium = false;
    expect(await ads.maybeShowInterstitial(), true);
    expect(await ads.requireRewarded(), true);
  });
}
