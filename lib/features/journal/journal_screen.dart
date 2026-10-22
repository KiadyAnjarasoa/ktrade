import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart'; // Commenté temporairement
import '../../app/theme.dart';
import '../../data/repositories/trade_repository.dart';
import '../../data/importers/mt5_csv_parser.dart';
import '../../domain/models/trade_model.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TradeRepository _repository = TradeRepository();
  List<TradeModel> _trades = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrades();
  }

  Future<void> _loadTrades() async {
    setState(() => _isLoading = true);
    final trades = await _repository.getTrades();
    setState(() {
      _trades = trades;
      _isLoading = false;
    });
  }

  /// Importation d'un fichier CSV MetaTrader 5 (Désactivé temporairement pour le test emulator)
  Future<void> _importMt5Csv() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('L\'importation CSV sera bientot disponible ! 🔄'),
        backgroundColor: KTradeTheme.warningOrange,
      ),
    );
  }

  /// Formulaire d'enregistrement manuel de trade
  void _showAddTradeModal() {
    final symbolController = TextEditingController(text: 'XAUUSD');
    final volumeController = TextEditingController(text: '0.10');
    final openPriceController = TextEditingController(text: '2650.00');
    final closePriceController = TextEditingController(text: '2665.00');
    final profitController = TextEditingController(text: '150.00');
    bool isBuy = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: KTradeTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enregistrer un Trade 📝',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('BUY')),
                          selected: isBuy,
                          selectedColor: KTradeTheme.primaryGreen,
                          onSelected: (val) => setModalState(() => isBuy = true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('SELL')),
                          selected: !isBuy,
                          selectedColor: KTradeTheme.lossRed,
                          onSelected: (val) => setModalState(() => isBuy = false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: symbolController,
                    decoration: const InputDecoration(
                      labelText: 'Instrument (ex: XAUUSD)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: volumeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Volume (Lot)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: profitController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Profit/Perte (\$)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: openPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Prix Entrée',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: closePriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Prix Sortie',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KTradeTheme.primaryGreen,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final newTrade = TradeModel(
                          symbol: symbolController.text,
                          type: isBuy ? TradeType.buy : TradeType.sell,
                          openTime: DateTime.now(),
                          closeTime: DateTime.now(),
                          openPrice: double.tryParse(openPriceController.text) ?? 0.0,
                          closePrice: double.tryParse(closePriceController.text) ?? 0.0,
                          volume: double.tryParse(volumeController.text) ?? 0.01,
                          profit: double.tryParse(profitController.text) ?? 0.0,
                        );

                        await _repository.addTrade(newTrade);
                        if (mounted) Navigator.pop(ctx);
                        _loadTrades();
                      },
                      child: const Text(
                        'Enregistrer le Trade',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal de Trading 📘'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrades,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _trades.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book, size: 64, color: KTradeTheme.textMuted),
            const SizedBox(height: 16),
            const Text(
              'Aucun trade enregistré pour le moment.',
              style: TextStyle(color: KTradeTheme.textMuted),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: KTradeTheme.primaryGreen,
                foregroundColor: Colors.black,
              ),
              onPressed: _showAddTradeModal,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un Trade'),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _trades.length,
        itemBuilder: (context, index) {
          final trade = _trades[index];
          final isWin = trade.netProfit >= 0;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isWin
                    ? KTradeTheme.primaryGreen.withOpacity(0.2)
                    : KTradeTheme.lossRed.withOpacity(0.2),
                child: Icon(
                  trade.type == TradeType.buy
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  color: isWin ? KTradeTheme.primaryGreen : KTradeTheme.lossRed,
                ),
              ),
              title: Text(
                '${trade.symbol} (${trade.type == TradeType.buy ? 'BUY' : 'SELL'})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Lot: ${trade.volume}\n${trade.openTime.day}/${trade.openTime.month}/${trade.openTime.year}',
                style: const TextStyle(color: KTradeTheme.textMuted, fontSize: 12),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isWin ? "+" : ""}\$${trade.netProfit.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isWin ? KTradeTheme.primaryGreen : KTradeTheme.lossRed,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: KTradeTheme.primaryGreen,
        foregroundColor: Colors.black,
        onPressed: _showAddTradeModal,
        child: const Icon(Icons.add),
      ),
    );
  }
}