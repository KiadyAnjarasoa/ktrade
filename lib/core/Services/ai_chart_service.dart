import 'dart:async';
import 'dart:math';

class AiChartService {
  final _random = Random();

  final Map<String, double> _basePrices = {
    'EURUSD': 1.0850,
    'GBPUSD': 1.2950,
    'XAUUSD': 2650.00,
  };

  Stream<double> getPriceStream(String symbol) async* {
    double currentPrice = _basePrices[symbol] ?? 1.0850;
    double volatility = symbol == 'XAUUSD' ? 1.5 : 0.0003;

    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      double delta = (_random.nextDouble() - 0.48) * volatility;
      currentPrice += delta;
      yield currentPrice;
    }
  }

  Future<Map<String, dynamic>> analyzeMarketWithAi({
    required String symbol,
    required String timeframe,
    required List<double> priceHistory,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    if (priceHistory.length < 5) {
      return {
        'signal': 'NEUTRAL',
        'confidence': '50%',
        'reason': 'Données insuffisantes pour une analyse en $timeframe.',
        'suggestedSL': 0.0,
        'suggestedTP': 0.0,
      };
    }

    double first = priceHistory.first;
    double last = priceHistory.last;
    double diff = last - first;
    double threshold = symbol == 'XAUUSD' ? 1.2 : 0.0008;

    if (diff > threshold) {
      return {
        'signal': 'BUY 🟢',
        'confidence': timeframe == '1h' ? '89%' : '82%',
        'reason': 'Tendance haussière confirmée en $timeframe sur $symbol. Cassure de résistance.',
        'suggestedSL': symbol == 'XAUUSD' ? last - 5.0 : last - 0.0015,
        'suggestedTP': symbol == 'XAUUSD' ? last + 10.0 : last + 0.0030,
      };
    } else if (diff < -threshold) {
      return {
        'signal': 'SELL 🔴',
        'confidence': timeframe == '1h' ? '85%' : '78%',
        'reason': 'Pression vendeuse forte en $timeframe sur $symbol. Rejet sous le niveau clé.',
        'suggestedSL': symbol == 'XAUUSD' ? last + 5.0 : last + 0.0015,
        'suggestedTP': symbol == 'XAUUSD' ? last - 10.0 : last - 0.0030,
      };
    } else {
      return {
        'signal': 'WAIT ⏳',
        'confidence': '65%',
        'reason': 'Marché en consolidation en $timeframe. Attendre une impulsion nette.',
        'suggestedSL': symbol == 'XAUUSD' ? last - 2.0 : last - 0.0008,
        'suggestedTP': symbol == 'XAUUSD' ? last + 2.0 : last + 0.0008,
      };
    }
  }
}