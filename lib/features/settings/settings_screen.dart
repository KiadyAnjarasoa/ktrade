import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../data/repositories/trade_repository.dart';
import '../../domain/models/account_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TradeRepository _repository = TradeRepository();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _riskController = TextEditingController();

  AccountModel? _account;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    setState(() => _isLoading = true);
    final account = await _repository.getAccount();
    setState(() {
      _account = account;
      _nameController.text = account.name;
      _balanceController.text = account.referenceBalance.toStringAsFixed(2);
      _riskController.text = account.defaultRiskPercent.toStringAsFixed(1);
      _isLoading = false;
    });
  }

  Future<void> _saveAccount() async {
    if (_account == null) return;

    final updatedAccount = AccountModel(
      id: _account!.id,
      name: _nameController.text,
      currency: _account!.currency,
      referenceBalance: double.tryParse(_balanceController.text) ?? 1000.0,
      defaultRiskPercent: double.tryParse(_riskController.text) ?? 1.0,
    );

    await _repository.updateAccount(updatedAccount);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paramètres mis à jour avec succès ! ✅'),
          backgroundColor: KTradeTheme.primaryGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réglages KTrade ⚙️'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Compte de Trading',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nom du compte',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _balanceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Capital de Référence (\$)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _riskController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Risque par défaut (%)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: KTradeTheme.primaryGreen,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _saveAccount,
                              child: const Text(
                                'Enregistrer les modifications',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Informations & Sécurité',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  const Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.security, color: KTradeTheme.primaryGreen),
                          title: Text('Stockage 100% Local'),
                          subtitle: Text(
                            'Tes données financières ne quittent jamais ton téléphone.',
                            style: TextStyle(fontSize: 12, color: KTradeTheme.textMuted),
                          ),
                        ),
                        Divider(height: 1, color: Color(0xFF222832)),
                        ListTile(
                          leading: Icon(Icons.info_outline, color: KTradeTheme.textMuted),
                          title: Text('Version de l\'application'),
                          subtitle: Text(
                            'KTrade v1.0.0 (Offline Engine)',
                            style: TextStyle(fontSize: 12, color: KTradeTheme.textMuted),
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
}