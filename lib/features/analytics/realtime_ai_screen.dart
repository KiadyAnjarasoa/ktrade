import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../app/theme.dart';
import '../../core/services/ai_chart_service.dart';

class RealtimeAiScreen extends StatefulWidget {
  const RealtimeAiScreen({super.key});

  @override
  State<RealtimeAiScreen> createState() => _RealtimeAiScreenState();
}

class _RealtimeAiScreenState extends State<RealtimeAiScreen> {
  final AiChartService _aiService = AiChartService();
  final List<FlSpot> _spots = [];
  final List<double> _priceHistory = [];
  double _xValue = 0;
  
  bool _isAnalyzing = false;
  Map<String, dynamic>? _aiAnalysis;

  @override
  void initState() {
    super.initState();
    _listenToMarket();
  }

  void _listenToMarket() {
    _aiService.priceStream.listen((price) {
      if (!mounted) return;
      setState(() {
        _xValue += 1;
        _spots.add(FlSpot(_xValue, price));
        _priceHistory.add(price);

        // Mitazona teboka 30 farany ihany mba tsy hahacharge be ny memoria
        if (_spots.length > 30) {
          _spots.removeAt(0);
        }
      });
    });
  }

  Future<void> _runAiAnalysis() async {
    setState(() => _isAnalyzing = true);
    final result = await _aiService.analyzeMarketWithAi(
      symbol: 'XAUUSD',
      priceHistory: _priceHistory,
    );
    if (mounted) {
      setState(() {
        _aiAnalysis = result;
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double currentPrice = _priceHistory.isNotEmpty ? _priceHistory.last : 2650.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Market & AI Assistant 🤖'),
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology, color: KTradeTheme.primaryGreen),
            onPressed: _runAiAnalysis,
            tooltip: 'Lancer l\'Analyse IA',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Price Card
            Card(
              color: KTradeTheme.cardBackground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('XAU/USD (Live)', style: TextStyle(color: KTradeTheme.textMuted, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(
                          '\$${currentPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: KTradeTheme.primaryGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: KTradeTheme.primaryGreen),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.fiber_manual_record, color: KTradeTheme.primaryGreen, size: 12),
                          SizedBox(width: 6),
                          Text('LIVE', style: TextStyle(color: KTradeTheme.primaryGreen, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Realtime FlChart
            const Text('Graphique en temps réel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              height: 220,
              padding: const EdgeInsets.only(right: 16, top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: KTradeTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: _spots.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _spots,
                            isCurved: true,
                            color: KTradeTheme.primaryGreen,
                            barWidth: 2.5,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: KTradeTheme.primaryGreen.withOpacity(0.12),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 24),

            // AI Decision Section
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: KTradeTheme.primaryGreen,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isAnalyzing ? null : _runAiAnalysis,
                icon: const Icon(Icons.auto_awesome),
                label: Text(
                  _isAnalyzing ? 'Analyse en cours par l\'IA...' : 'Demander l\'Avis de l\'IA 🧠',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (_aiAnalysis != null) ...[
              Card(
                color: KTradeTheme.cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: KTradeTheme.primaryGreen, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Signal IA: ${_aiAnalysis!['signal']}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Confiance: ${_aiAnalysis!['confidence']}',
                            style: const TextStyle(color: KTradeTheme.primaryGreen, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: Colors.white24),
                      Text(
                        _aiAnalysis!['reason'],
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'SL Suggeré: \$${_aiAnalysis!['suggestedSL'].toStringAsFixed(2)}',
                            style: const TextStyle(color: KTradeTheme.lossRed, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'TP Suggeré: \$${_aiAnalysis!['suggestedTP'].toStringAsFixed(2)}',
                            style: const TextStyle(color: KTradeTheme.primaryGreen, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}