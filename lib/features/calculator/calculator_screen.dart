import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/calculations/trading_calculator.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _balanceController = TextEditingController(text: '1000');
  final _riskPercentController = TextEditingController(text: '1.0');
  final _entryPriceController = TextEditingController(text: '2650.00');
  final _slController = TextEditingController(text: '2640.00');
  final _tpController = TextEditingController(text: '2680.00');

  bool _isBuy = true;
  String _selectedSymbol = 'XAUUSD (Gold)';
  double _contractSize = 100.0;

  // Résultats calculés
  double _riskAmount = 0.0;
  double _slDistance = 0.0;
  double _rrRatio = 0.0;
  double _calculatedLot = 0.0;
  double _estimatedProfit = 0.0;
  double _estimatedLoss = 0.0;

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  void _recalculate() {
    final balance = double.tryParse(_balanceController.text) ?? 0.0;
    final riskPercent = double.tryParse(_riskPercentController.text) ?? 0.0;
    final entry = double.tryParse(_entryPriceController.text) ?? 0.0;
    final sl = double.tryParse(_slController.text) ?? 0.0;
    final tp = double.tryParse(_tpController.text) ?? 0.0;

    setState(() {
      _riskAmount = TradingCalculator.calculateRiskAmount(
        accountBalance: balance,
        riskPercentage: riskPercent,
      );

      _slDistance = TradingCalculator.calculateSlDistance(
        entryPrice: entry,
        stopLoss: sl,
        isBuy: _isBuy,
      );

      _rrRatio = TradingCalculator.calculateRiskRewardRatio(
        entryPrice: entry,
        stopLoss: sl,
        takeProfit: tp,
        isBuy: _isBuy,
      );

      _calculatedLot = TradingCalculator.calculateLotSize(
        riskAmount: _riskAmount,
        entryPrice: entry,
        stopLoss: sl,
        isBuy: _isBuy,
        contractSize: _contractSize,
      );

      final pnl = TradingCalculator.calculatePotentialProfitLoss(
        entryPrice: entry,
        stopLoss: sl,
        takeProfit: tp,
        lotSize: _calculatedLot,
        isBuy: _isBuy,
        contractSize: _contractSize,
      );

      _estimatedProfit = pnl['estimatedProfit'] ?? 0.0;
      _estimatedLoss = pnl['estimatedLoss'] ?? 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isValidSetup = _slDistance > 0 && _rrRatio >= 1.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant de Position 🧮'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SELECTEUR BUY / SELL ---
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isBuy
                          ? KTradeTheme.primaryGreen
                          : const Color(0xFF222832),
                      foregroundColor:
                          _isBuy ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      setState(() => _isBuy = true);
                      _recalculate();
                    },
                    child: const Text('BUY / ACHAT 📈',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_isBuy
                          ? KTradeTheme.lossRed
                          : const Color(0xFF222832),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      setState(() => _isBuy = false);
                      _recalculate();
                    },
                    child: const Text('SELL / VENTE 📉',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- CARTE D'ENTRÉE DES PARAMÈTRES ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedSymbol,
                      dropdownColor: KTradeTheme.cardBackground,
                      decoration: const InputDecoration(
                        labelText: 'Instrument',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'XAUUSD (Gold)',
                            child: Text('XAUUSD (Gold)')),
                        DropdownMenuItem(
                            value: 'EURUSD', child: Text('EURUSD')),
                        DropdownMenuItem(
                            value: 'GBPUSD', child: Text('GBPUSD')),
                        DropdownMenuItem(
                            value: 'US100 (Nasdaq)',
                            child: Text('US100 (Nasdaq)')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedSymbol = val;
                            if (val.contains('EURUSD') || val.contains('GBPUSD')) {
                              _contractSize = 100000.0;
                              _entryPriceController.text = '1.08500';
                              _slController.text = '1.08200';
                              _tpController.text = '1.09100';
                            } else {
                              _contractSize = 100.0;
                              _entryPriceController.text = '2650.00';
                              _slController.text = '2640.00';
                              _tpController.text = '2680.00';
                            }
                          });
                          _recalculate();
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _balanceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Capital (\$)'),
                            onChanged: (_) => _recalculate(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _riskPercentController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Risque (%)'),
                            onChanged: (_) => _recalculate(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _entryPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Prix d\'Entrée'),
                      onChanged: (_) => _recalculate(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _slController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Stop Loss (SL)'),
                            onChanged: (_) => _recalculate(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _tpController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Take Profit (TP)'),
                            onChanged: (_) => _recalculate(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- CARTE DE RÉSULTAT DU CALCUL (LOT SIZE) ---
            Card(
              color: const Color(0xFF1E242D),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text('LOT SIZE RECOMMANDÉ',
                        style: TextStyle(
                            color: KTradeTheme.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(
                      '$_calculatedLot LOTS',
                      style: const TextStyle(
                        color: KTradeTheme.primaryGreen,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Divider(height: 24, color: Colors.white10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _metricTile('Risque total', '\$${_riskAmount.toStringAsFixed(2)}'),
                        _metricTile('Perte Max', '-\$${_estimatedLoss.toStringAsFixed(2)}',
                            color: KTradeTheme.lossRed),
                        _metricTile('Ratio R:R', '1 : ${_rrRatio.toStringAsFixed(2)}'),
                        _metricTile('Gain Potentiel', '+\$${_estimatedProfit.toStringAsFixed(2)}',
                            color: KTradeTheme.primaryGreen),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- CHECKLIST & STATUS DU SETUP ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isValidSetup
                    ? KTradeTheme.primaryGreen.withOpacity(0.1)
                    : KTradeTheme.lossRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isValidSetup
                      ? KTradeTheme.primaryGreen
                      : KTradeTheme.lossRed,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isValidSetup ? Icons.check_circle : Icons.warning_amber,
                    color: isValidSetup
                        ? KTradeTheme.primaryGreen
                        : KTradeTheme.lossRed,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isValidSetup ? 'SETUP VALIDÉ ✅' : 'SETUP REFUSÉ ⚠️',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isValidSetup
                                ? KTradeTheme.primaryGreen
                                : KTradeTheme.lossRed,
                          ),
                        ),
                        Text(
                          isValidSetup
                              ? 'Le Stop Loss et le ratio R:R respectent tes règles.'
                              : 'Vérifie que le Stop Loss est du bon côté et que le R:R est suffisant.',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricTile(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: KTradeTheme.textMuted, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color ?? Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
      ],
    );
  }
}