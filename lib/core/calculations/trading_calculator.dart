import 'dart:math';

/// Moteur Mathématique Déterministe pur pour KTrade (sans IA)
class TradingCalculator {
  /// 1. Calcul du montant risqué en devise (ex: USD)
  /// R = Balance * (RiskPercentage / 100)
  static double calculateRiskAmount({
    required double accountBalance,
    required double riskPercentage,
  }) {
    if (accountBalance <= 0 || riskPercentage <= 0) return 0.0;
    return accountBalance * (riskPercentage / 100.0);
  }

  /// 2. Calcul de la distance du Stop Loss (toujours positive)
  static double calculateSlDistance({
    required double entryPrice,
    required double stopLoss,
    required bool isBuy,
  }) {
    if (isBuy) {
      return entryPrice - stopLoss;
    } else {
      return stopLoss - entryPrice;
    }
  }

  /// 3. Calcul du Risk:Reward Ratio (R:R)
  /// R:R = Distance TP / Distance SL
  static double calculateRiskRewardRatio({
    required double entryPrice,
    required double stopLoss,
    required double takeProfit,
    required bool isBuy,
  }) {
    final slDistance = calculateSlDistance(
      entryPrice: entryPrice,
      stopLoss: stopLoss,
      isBuy: isBuy,
    );

    if (slDistance <= 0) return 0.0;

    final tpDistance = isBuy ? (takeProfit - entryPrice) : (entryPrice - takeProfit);
    if (tpDistance <= 0) return 0.0;

    return tpDistance / slDistance;
  }

  /// 4. Calcul de la taille de position (Lot Size)
  /// Volume = RiskAmount / (SL_Distance * ContractSize)
  static double calculateLotSize({
    required double riskAmount,
    required double entryPrice,
    required double stopLoss,
    required bool isBuy,
    required double contractSize, // ex: 100,000 (Forex), 100 (Gold)
    double minLot = 0.01,         // Volume minimal autorisé
    double maxLot = 100.0,        // Volume maximal
    double lotStep = 0.01,        // Incrément autorisé
  }) {
    final slDistance = calculateSlDistance(
      entryPrice: entryPrice,
      stopLoss: stopLoss,
      isBuy: isBuy,
    );

    if (slDistance <= 0 || riskAmount <= 0 || contractSize <= 0) return 0.0;

    final lossPerLot = slDistance * contractSize;
    if (lossPerLot <= 0) return 0.0;

    double rawLot = riskAmount / lossPerLot;

    // Ajustement aux contraintes du broker (Lot step)
    double adjustedLot = (rawLot / lotStep).floor() * lotStep;

    if (adjustedLot < minLot) return minLot;
    if (adjustedLot > maxLot) return maxLot;

    return double.parse(adjustedLot.toStringAsFixed(2));
  }

  /// 5. Estimation du Gain et de la Perte monétaire
  static Map<String, double> calculatePotentialProfitLoss({
    required double entryPrice,
    required double stopLoss,
    required double takeProfit,
    required double lotSize,
    required bool isBuy,
    required double contractSize,
  }) {
    final slDistance = calculateSlDistance(
      entryPrice: entryPrice,
      stopLoss: stopLoss,
      isBuy: isBuy,
    );

    final tpDistance = isBuy ? (takeProfit - entryPrice) : (entryPrice - takeProfit);

    final estimatedLoss = slDistance * contractSize * lotSize;
    final estimatedProfit = max(0.0, tpDistance) * contractSize * lotSize;

    return {
      'estimatedLoss': double.parse(estimatedLoss.toStringAsFixed(2)),
      'estimatedProfit': double.parse(estimatedProfit.toStringAsFixed(2)),
    };
  }
}