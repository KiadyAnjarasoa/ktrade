import '../../domain/models/trade_model.dart';
import '../../domain/models/account_model.dart';
import '../database/database_helper.dart';

class TradeRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> addTrade(TradeModel trade) async {
    return await _dbHelper.insertTrade(trade);
  }

  Future<List<TradeModel>> getTrades() async {
    return await _dbHelper.getAllTrades();
  }

  Future<int> deleteTrade(int id) async {
    return await _dbHelper.deleteTrade(id);
  }

  Future<AccountModel> getAccount() async {
    return await _dbHelper.getAccount();
  }

  Future<int> updateAccount(AccountModel account) async {
    return await _dbHelper.updateAccount(account);
  }
}