import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../app/theme.dart';
import 'package:ktrade/core/Services/ai_chart_service.dart';

class RealtimeAiScreen extends StatefulWidget {
  const RealtimeAiScreen({super.key});

  @override
  State<RealtimeAiScreen> createState() => _RealtimeAiScreenState();
}

class _RealtimeAiScreenState extends State<RealtimeAiScreen> {
  final AiChartService _aiService = AiChartService();
  StreamSubscription<double>? _streamSubscription;

  final List<FlSpot> _spots = [];
  final List<double> _priceHistory = [];
  double _xValue = 0;

  String _selectedSymbol = 'EURUSD';
  String _selectedTimeframe = '15mn';

  bool _isAnalyzing = false;
  Map<String, dynamic>? _aiAnalysis;

  @override
  void initState() {
    super.initState();
    _startMarketStream();
  }

  void _startMarketStream() {
    _streamSubscription?.cancel();
    _spots.clear();
    _priceHistory.clear();
    _xValue = 0;

    _streamSubscription = _aiService
        .getPriceStream(_selectedSymbol)
        .listen((price) {
      if (!mounted) return;
      setState(() {
        _xValue += 1;
        _spots.add(FlSpot(_xValue, price));
        _priceHistory.add(price);

        if (_spots.length > 30) {
          _spots.removeAt(0);
        }
      });
    });
  }

  Future<void> _runAiAnalysis() async {
    setState(() => _isAnalyzing = true);
    final result = await _aiService.analyzeMarketWithAi(
      symbol: _selectedSymbol,
      timeframe: _selectedTimeframe,
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
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double currentPrice = _priceHistory.isNotEmpty
        ? _priceHistory.last
        : (_selectedSymbol == 'XAUUSD' ? 2650.0 : 1.0850);

    int decimals = _selectedSymbol == 'XAUUSD' ? 2 : 5;

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
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: KTradeTheme.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF222832)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSymbol,
                        dropdownColor: KTradeTheme.cardBackground,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                              value: 'EURUSD', child: Text('EUR/USD')),
                          DropdownMenuItem(
                              value: 'GBPUSD', child: Text('GBP/USD')),
                          DropdownMenuItem(
                              value: 'XAUUSD', child: Text('XAU/USD (Gold)')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedSymbol = val;
                              _aiAnalysis = null;
                            });
                            _startMarketStream();
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('15mn'),
                  selected: _selectedTimeframe == '15mn',
                  selectedColor: KTradeTheme.primaryGreen,
                  labelStyle: TextStyle(
                    color: _selectedTimeframe == '15mn'
                        ? Colors.black
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedTimeframe = '15mn');
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('1h'),
                  selected: _selectedTimeframe == '1h',
                  selectedColor: KTradeTheme.primaryGreen,
                  labelStyle: TextStyle(
                    color: _selectedTimeframe == '1h'
                        ? Colors.black
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedTimeframe = '1h');
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              color: KTradeTheme.cardBackground,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$_selectedSymbol ($_selectedTimeframe Live)',
                            style: const TextStyle(
                                color: KTradeTheme.textMuted, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(
                          '\$${currentPrice.toStringAsFixed(decimals)}',
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: KTradeTheme.primaryGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: KTradeTheme.primaryGreen),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.fiber_manual_record,
                              color: KTradeTheme.primaryGreen, size: 12),
                          SizedBox(width: 6),
                          Text('LIVE',
                              style: TextStyle(
                                  color: KTradeTheme.primaryGreen,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Graphique en temps réel ($_selectedTimeframe)',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                              color:
                                  KTradeTheme.primaryGreen.withOpacity(0.12),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: KTradeTheme.primaryGreen,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isAnalyzing ? null : _runAiAnalysis,
                icon: const Icon(Icons.auto_awesome),
                label: Text(
                  _isAnalyzing
                      ? 'Analyse en cours ($_selectedTimeframe)...'
                      : 'Demander l\'Avis de l\'IA 🧠',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_aiAnalysis != null) ...[
              Card(
                color: KTradeTheme.cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(
                      color: KTradeTheme.primaryGreen, width: 1),
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
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Confiance: ${_aiAnalysis!['confidence']}',
                            style: const TextStyle(
                                color: KTradeTheme.primaryGreen,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: Colors.white24),
                      Text(
                        _aiAnalysis!['reason'],
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'SL Suggeré: \$${_aiAnalysis!['suggestedSL'].toStringAsFixed(decimals)}',
                            style: const TextStyle(
                                color: KTradeTheme.lossRed,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'TP Suggeré: \$${_aiAnalysis!['suggestedTP'].toStringAsFixed(decimals)}',
                            style: const TextStyle(
                                color: KTradeTheme.primaryGreen,
                                fontWeight: FontWeight.bold),
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