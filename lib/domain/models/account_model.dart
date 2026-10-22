class AccountModel {
  final int? id;
  final String name;
  final String currency;
  final double referenceBalance;
  final double defaultRiskPercent;

  AccountModel({
    this.id,
    required this.name,
    this.currency = 'USD',
    required this.referenceBalance,
    this.defaultRiskPercent = 1.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'currency': currency,
      'reference_balance': referenceBalance,
      'default_risk_percent': defaultRiskPercent,
    };
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'],
      name: map['name'],
      currency: map['currency'],
      referenceBalance: (map['reference_balance'] as num).toDouble(),
      defaultRiskPercent: (map['default_risk_percent'] as num).toDouble(),
    );
  }
}