import 'dart:async';
import 'dart:math';

/// Engine mamokatra data en temps réel (Tick Prices) sy mamakafaka amin'ny AI
class AiChartService {
  final _random = Random();
  double currentPrice = 2650.00; // Price baseline ho an'ny XAUUSD

  /// Stream handraisana ny vidiny mihetsika isaky ny segondra
  Stream<double> get priceStream async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      // Simulation kely amin'ny fiodinan'ny vidiny (-0.85 ka hatramin'ny +0.85)
      double delta = (_random.nextDouble() - 0.48) * 1.5;
      currentPrice += delta;
      yield currentPrice;
    }
  }

  /// Fonction mandefa ny indicators any amin'ny AI mamakafaka
  Future<Map<String, dynamic>> analyzeMarketWithAi({
    required String symbol,
    required List<double> priceHistory,
  }) async {
    // simulation d'appel API IA (ex: OpenAI / DeepSeek / Claude)
    await Future.delayed(const Duration(milliseconds: 1200));

    if (priceHistory.length < 5) {
      return {
        'signal': 'NEUTRAL',
        'confidence': '50%',
        'reason': 'Données insuffisantes pour une analyse précise.',
        'suggestedSL': 0.0,
        'suggestedTP': 0.0,
      };
    }

    // Calcul simple d'analyse de tendance sur la session
    double first = priceHistory.first;
    double last = priceHistory.last;
    double diff = last - first;

    if (diff > 1.2) {
      return {
        'signal': 'BUY 🟢',
        'confidence': '84%',
        'reason': 'Momentum haussier fort détecté. Le prix casse la résistance locale.',
        'suggestedSL': last - 4.5,
        'suggestedTP': last + 9.0,
      };
    } else if (diff < -1.2) {
      return {
        'signal': 'SELL 🔴',
        'confidence': '78%',
        'reason': 'Pression vendeuse dominante. Alignement baissier des moyennes mobiles.',
        'suggestedSL': last + 4.5,
        'suggestedTP': last - 9.0,
      };
    } else {
      return {
        'signal': 'WAIT ⏳',
        'confidence': '65%',
        'reason': 'Marché en consolidation (Range). Attendre une cassure nette.',
        'suggestedSL': last - 2.0,
        'suggestedTP': last + 2.0,
      };
    }
  }
}