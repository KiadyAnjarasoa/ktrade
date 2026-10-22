import 'package:csv/csv.dart';
import '../../domain/models/trade_model.dart';

class Mt5CsvParser {
  /// Mamaky ilay string CSV avy amin'ny fichier MT5 ary mamadika azy ho liste de TradeModel
  static List<TradeModel> parseCsvString(String csvContent) {
    List<TradeModel> parsedTrades = [];

    // Parsing an'ny CSV ligne par ligne
    final List<List<dynamic>> rows = const CsvToListConverter(
      fieldDelimiter: ',',
      eol: '\n',
    ).convert(csvContent);

    if (rows.isEmpty) return parsedTrades;

    // Hitady ny index-n'ny colonnes lehibe (Ticket, Time, Symbol, Type, Volume, Price, Profit, Commission, Swap)
    int ticketIndex = -1;
    int timeIndex = -1;
    int symbolIndex = -1;
    int typeIndex = -1;
    int volumeIndex = -1;
    int priceIndex = -1;
    int profitIndex = -1;
    int commissionIndex = -1;
    int swapIndex = -1;

    // Analysena ny en-tête (Header)
    for (int i = 0; i < rows.length; i++) {
      final row = rows[i].map((e) => e.toString().trim().toLowerCase()).toList();

      if (row.contains('ticket') || row.contains('order') || row.contains('position')) {
        ticketIndex = row.indexWhere((e) => e.contains('ticket') || e.contains('order') || e.contains('position'));
        timeIndex = row.indexWhere((e) => e.contains('time') || e.contains('date'));
        symbolIndex = row.indexWhere((e) => e.contains('symbol') || e.contains('item'));
        typeIndex = row.indexWhere((e) => e.contains('type'));
        volumeIndex = row.indexWhere((e) => e.contains('volume') || e.contains('lots') || e.contains('size'));
        priceIndex = row.indexWhere((e) => e.contains('price'));
        profitIndex = row.indexWhere((e) => e.contains('profit'));
        commissionIndex = row.indexWhere((e) => e.contains('commission'));
        swapIndex = row.indexWhere((e) => e.contains('swap'));

        // Traitement an'ireo lignes data aorian'ny header
        for (int j = i + 1; j < rows.length; j++) {
          final dataRow = rows[j];
          if (dataRow.length <= 3) continue;

          try {
            final typeStr = dataRow[typeIndex].toString().toUpperCase();
            if (!typeStr.contains('BUY') && !typeStr.contains('SELL')) continue;

            final ticket = ticketIndex != -1 ? dataRow[ticketIndex].toString() : null;
            final symbol = symbolIndex != -1 ? dataRow[symbolIndex].toString() : 'UNKNOWN';
            final isBuy = typeStr.contains('BUY');
            
            final openTimeStr = timeIndex != -1 ? dataRow[timeIndex].toString() : DateTime.now().toIso8601String();
            DateTime openTime = DateTime.tryParse(openTimeStr) ?? DateTime.now();

            final volume = volumeIndex != -1 ? double.tryParse(dataRow[volumeIndex].toString().replaceAll(',', '.')) ?? 0.01 : 0.01;
            final openPrice = priceIndex != -1 ? double.tryParse(dataRow[priceIndex].toString().replaceAll(',', '.')) ?? 0.0 : 0.0;
            final profit = profitIndex != -1 ? double.tryParse(dataRow[profitIndex].toString().replaceAll(',', '.')) ?? 0.0 : 0.0;
            final commission = commissionIndex != -1 ? double.tryParse(dataRow[commissionIndex].toString().replaceAll(',', '.')) ?? 0.0 : 0.0;
            final swap = swapIndex != -1 ? double.tryParse(dataRow[swapIndex].toString().replaceAll(',', '.')) ?? 0.0 : 0.0;

            parsedTrades.add(
              TradeModel(
                mt5Ticket: ticket,
                symbol: symbol,
                type: isBuy ? TradeType.buy : TradeType.sell,
                openTime: openTime,
                closeTime: openTime,
                openPrice: openPrice,
                volume: volume,
                profit: profit,
                commission: commission,
                swap: swap,
                strategy: 'MT5 Import',
              ),
            );
          } catch (_) {
            // Ignorer les lignes mal formées
          }
        }
        break;
      }
    }

    return parsedTrades;
  }
}