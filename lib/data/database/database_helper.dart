import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/models/trade_model.dart';
import '../../domain/models/account_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ktrade.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        currency TEXT NOT NULL,
        reference_balance REAL NOT NULL,
        default_risk_percent REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE trades (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mt5_ticket TEXT,
        symbol TEXT NOT NULL,
        type TEXT NOT NULL,
        open_time TEXT NOT NULL,
        close_time TEXT,
        open_price REAL NOT NULL,
        close_price REAL,
        stop_loss REAL,
        take_profit REAL,
        volume REAL NOT NULL,
        profit REAL NOT NULL,
        commission REAL NOT NULL,
        swap REAL NOT NULL,
        strategy TEXT,
        notes TEXT,
        image_path TEXT
      )
    ''');

    // Compte pa-défaut
    await db.insert('accounts', {
      'name': 'Main Trading Account',
      'currency': 'USD',
      'reference_balance': 1000.0,
      'default_risk_percent': 1.0,
    });
  }

  // --- CRUD TRADES ---
  Future<int> insertTrade(TradeModel trade) async {
    final db = await instance.database;
    return await db.insert('trades', trade.toMap());
  }

  Future<List<TradeModel>> getAllTrades() async {
    final db = await instance.database;
    final result = await db.query('trades', orderBy: 'open_time DESC');
    return result.map((json) => TradeModel.fromMap(json)).toList();
  }

  Future<int> deleteTrade(int id) async {
    final db = await instance.database;
    return await db.delete('trades', where: 'id = ?', whereArgs: [id]);
  }

  // --- ACCOUNT METHODS ---
  Future<AccountModel> getAccount() async {
    final db = await instance.database;
    final result = await db.query('accounts', limit: 1);
    if (result.isNotEmpty) {
      return AccountModel.fromMap(result.first);
    }
    return AccountModel(name: 'Main Account', referenceBalance: 1000.0);
  }

  Future<int> updateAccount(AccountModel account) async {
    final db = await instance.database;
    return await db.update('accounts', account.toMap(), where: 'id = ?', whereArgs: [account.id]);
  }
}