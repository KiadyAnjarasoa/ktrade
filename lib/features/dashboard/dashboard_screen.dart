import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../data/repositories/trade_repository.dart';
import '../../domain/models/trade_model.dart';
import '../../domain/models/account_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TradeRepository _repository = TradeRepository();
  List<TradeModel> _trades = [];
  AccountModel _account = AccountModel(name: 'Main Account', referenceBalance: 1000.0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final trades = await _repository.getTrades();
    final account = await _repository.getAccount();

    setState(() {
      _trades = trades;
      _account = account;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double netProfitCumule = _trades.fold(0.0, (sum, item) => sum + item.netProfit);
    int totalWin = _trades.where((t) => t.netProfit > 0).length;
    double winRate = _trades.isEmpty ? 0.0 : (totalWin / _trades.length) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('KTrade Dashboard 📊'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- CARTE DE CAPITAL PRINCIPAL ---
                  Card(
                    color: const Color(0xFF19202A),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SOLDE DE RÉFÉRENCE',
                            style: TextStyle(color: KTradeTheme.textMuted, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '\$${(_account.referenceBalance + netProfitCumule).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _statSubTile(
                                'Gain Net Cumulé',
                                '${netProfitCumule >= 0 ? "+" : ""}\$${netProfitCumule.toStringAsFixed(2)}',
                                color: netProfitCumule >= 0 ? KTradeTheme.primaryGreen : KTradeTheme.lossRed,
                              ),
                              _statSubTile('Taux de Réussite', '${winRate.toStringAsFixed(1)}%'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- GRILLE STATISTIQUES ---
                  const Text('Performances Clés 📈', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _infoCard('Total Trades', '${_trades.length}', Icons.swap_horiz),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _infoCard('Gagnants', '$totalWin', Icons.thumb_up, color: KTradeTheme.primaryGreen),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _infoCard('Perdants', '${_trades.length - totalWin}', Icons.thumb_down, color: KTradeTheme.lossRed),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _infoCard('Devise Compte', _account.currency, Icons.attach_money),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _statSubTile(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: KTradeTheme.textMuted, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color ?? Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _infoCard(String title, String value, IconData icon, {Color? color}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color ?? KTradeTheme.textMuted, size: 22),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: KTradeTheme.textMuted, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color ?? Colors.white)),
          ],
        ),
      ),
    );
  }
}