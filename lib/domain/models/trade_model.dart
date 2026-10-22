enum TradeType { buy, sell }

class TradeModel {
  final int? id;
  final String? mt5Ticket;
  final String symbol;
  final TradeType type;
  final DateTime openTime;
  final DateTime? closeTime;
  final double openPrice;
  final double? closePrice;
  final double? stopLoss;
  final double? takeProfit;
  final double volume;
  final double profit;
  final double commission;
  final double swap;
  final String? strategy;
  final String? notes;
  final String? imagePath;

  TradeModel({
    this.id,
    this.mt5Ticket,
    required this.symbol,
    required this.type,
    required this.openTime,
    this.closeTime,
    required this.openPrice,
    this.closePrice,
    this.stopLoss,
    this.takeProfit,
    required this.volume,
    required this.profit,
    this.commission = 0.0,
    this.swap = 0.0,
    this.strategy,
    this.notes,
    this.imagePath,
  });

  double get netProfit => profit + commission + swap;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mt5_ticket': mt5Ticket,
      'symbol': symbol,
      'type': type == TradeType.buy ? 'BUY' : 'SELL',
      'open_time': openTime.toIso8601String(),
      'close_time': closeTime?.toIso8601String(),
      'open_price': openPrice,
      'close_price': closePrice,
      'stop_loss': stopLoss,
      'take_profit': takeProfit,
      'volume': volume,
      'profit': profit,
      'commission': commission,
      'swap': swap,
      'strategy': strategy,
      'notes': notes,
      'image_path': imagePath,
    };
  }

  factory TradeModel.fromMap(Map<String, dynamic> map) {
    return TradeModel(
      id: map['id'],
      mt5Ticket: map['mt5_ticket'],
      symbol: map['symbol'],
      type: map['type'] == 'BUY' ? TradeType.buy : TradeType.sell,
      openTime: DateTime.parse(map['open_time']),
      closeTime: map['close_time'] != null ? DateTime.parse(map['close_time']) : null,
      openPrice: (map['open_price'] as num).toDouble(),
      closePrice: map['close_price'] != null ? (map['close_price'] as num).toDouble() : null,
      stopLoss: map['stop_loss'] != null ? (map['stop_loss'] as num).toDouble() : null,
      takeProfit: map['take_profit'] != null ? (map['take_profit'] as num).toDouble() : null,
      volume: (map['volume'] as num).toDouble(),
      profit: (map['profit'] as num).toDouble(),
      commission: (map['commission'] as num).toDouble(),
      swap: (map['swap'] as num).toDouble(),
      strategy: map['strategy'],
      notes: map['notes'],
      imagePath: map['image_path'],
    );
  }
}