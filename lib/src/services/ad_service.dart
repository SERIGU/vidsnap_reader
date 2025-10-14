/// Stub de monetización para MODO PRUEBA.
/// - No muestra anuncios.
/// - Siempre permite continuar.
/// Cuando integremos AdMob, sustituiremos este archivo por la versión real.

class AdService {
  AdService._();
  static final instance = AdService._();

  bool isPremium = false;
  int _ops = 0;

  Future<void> init() async {
    // No-op en modo prueba
  }

  /// Úsalo antes de operaciones NO-Pro.
  Future<bool> maybeShowInterstitial() async {
    _ops += 1;
    return true;
  }

  /// Úsalo para operaciones Pro cuando no es Premium.
  Future<bool> requireRewarded() async {
    return true;
  }
}
