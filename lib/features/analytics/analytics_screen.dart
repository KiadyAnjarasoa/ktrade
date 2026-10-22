import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../app/theme.dart';
import '../../data/repositories/trade_repository.dart';
import '../../domain/models/trade_model.dart';
import '../../domain/models/account_model.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final TradeRepository _repository = TradeRepository();
  List<TradeModel> _trades = [];
  AccountModel _account = AccountModel(name: 'Main Account', referenceBalance: 1000.0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() => _isLoading = true);
    final trades = await _repository.getTrades();
    final account = await _repository.getAccount();

    setState(() {
      _trades = trades.reversed.toList(); // Chronologique (antitra mankamin'ny vaovao)
      _account = account;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Calcul des statistiques
    double totalGainsBruts = 0.0;
    double totalPertesBrutes = 0.0;
    double bestTrade = 0.0;
    double worstTrade = 0.0;

    for (var trade in _trades) {
      final net = trade.netProfit;
      if (net > 0) {
        totalGainsBruts += net;
        if (net > bestTrade) bestTrade = net;
      } else {
        totalPertesBrutes += net.abs();
        if (net < worstTrade) worstTrade = net;
      }
    }

    final double profitFactor = totalPertesBrutes == 0
        ? (totalGainsBruts > 0 ? 99.9 : 0.0)
        : totalGainsBruts / totalPertesBrutes;

    final double netTotal = totalGainsBruts - totalPertesBrutes;
    final double expectedValue = _trades.isEmpty ? 0.0 : netTotal / _trades.length;

    // 2. Génération des points pour la courbe d'Équité
    List<FlSpot> spots = [FlSpot(0, _account.referenceBalance)];
    double currentCapital = _account.referenceBalance;

    for (int i = 0; i < _trades.length; i++) {
      currentCapital += _trades[i].netProfit;
      spots.add(FlSpot((i + 1).toDouble(), currentCapital));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyse des Performances 📈'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalyticsData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _trades.isEmpty
              ? const Center(
                  child: Text(
                    'Enregistre des trades dans le Journal pour voir l\'analyse.',
                    style: TextStyle(color: KTradeTheme.textMuted),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- COURBE DE CAPITAL (FL CHART) ---
                      const Text(
                        'Évolution du Capital (\$)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 220,
                        padding: const EdgeInsets.only(right: 16, left: 6, top: 16, bottom: 6),
                        decoration: BoxDecoration(
                          color: KTradeTheme.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF222832)),
                        ),
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                color: KTradeTheme.primaryGreen,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: KTradeTheme.primaryGreen.withOpacity(0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- INDICATEURS CLÉS (PROFIT FACTOR / EXPECTED VALUE) ---
                      const Text(
                        'Indicateurs Avancés 🎯',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _analyticsCard(
                              'Profit Factor',
                              profitFactor.toStringAsFixed(2),
                              profitFactor >= 1.5
                                  ? KTradeTheme.primaryGreen
                                  : (profitFactor >= 1.0 ? KTradeTheme.warningOrange : KTradeTheme.lossRed),
                              Icons.auto_graph,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _analyticsCard(
                              'Espérance (Trade)',
                              '${expectedValue >= 0 ? "+" : ""}\$${expectedValue.toStringAsFixed(2)}',
                              expectedValue >= 0 ? KTradeTheme.primaryGreen : KTradeTheme.lossRed,
                              Icons.functions,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // --- MEILLEUR & PIRE TRADE ---
                      Row(
                        children: [
                          Expanded(
                            child: _analyticsCard(
                              'Meilleur Trade',
                              '+\$${bestTrade.toStringAsFixed(2)}',
                              KTradeTheme.primaryGreen,
                              Icons.arrow_upward,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _analyticsCard(
                              'Pire Trade',
                              '-\$${worstTrade.abs().toStringAsFixed(2)}',
                              KTradeTheme.lossRed,
                              Icons.arrow_downward,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _analyticsCard(String label, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(color: KTradeTheme.textMuted, fontSize: 12)),
                Icon(icon, color: color, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}