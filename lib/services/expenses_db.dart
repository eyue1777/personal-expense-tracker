import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/expense.dart';

class ExpensesDb {
  ExpensesDb._();
  static final ExpensesDb instance = ExpensesDb._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'expenses.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE expenses(id INTEGER PRIMARY KEY AUTOINCREMENT, amount REAL, category TEXT, note TEXT, date TEXT)',
        );
      },
    );
  }

  Future<int> insert(Expense expense) async =>
      (await database).insert('expenses', expense.toMap());
  Future<int> update(Expense expense) async => (await database).update(
    'expenses',
    expense.toMap(),
    where: 'id = ?',
    whereArgs: [expense.id],
  );
  Future<int> delete(int id) async =>
      (await database).delete('expenses', where: 'id = ?', whereArgs: [id]);

  Future<List<Expense>> getAllExpenses() async {
    final maps = await (await database).query('expenses', orderBy: 'date DESC');
    return maps.map((e) => Expense.fromMap(e)).toList();
  }

  Future<double> getMonthlyTotal() async {
    final res = await (await database).rawQuery(
      'SELECT SUM(amount) as total FROM expenses',
    );
    return (res.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<void> wipeDatabase() async => (await database).delete('expenses');
}
