import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'models.dart';

class AnchorDb {
  AnchorDb._(this._db);

  final Database _db;

  static Future<AnchorDb> open() async {
    final path = p.join(await getDatabasesPath(), 'anchor.db');
    final db = await openDatabase(
      path,
      version: 1,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE goals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            emoji TEXT NOT NULL,
            target INTEGER,
            created_at INTEGER NOT NULL
          )''');
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            goal_id INTEGER REFERENCES goals(id) ON DELETE SET NULL,
            title TEXT NOT NULL,
            minute_of_day INTEGER NOT NULL,
            days INTEGER NOT NULL,
            intensity INTEGER NOT NULL
          )''');
        await db.execute('''
          CREATE TABLE logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            task_id INTEGER NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
            day TEXT NOT NULL,
            status TEXT NOT NULL,
            at INTEGER NOT NULL
          )''');
        await db.execute('CREATE INDEX logs_day ON logs(day)');
      },
    );
    return AnchorDb._(db);
  }

  Future<List<Goal>> goals() async =>
      (await _db.query('goals', orderBy: 'created_at')).map(Goal.fromMap).toList();

  Future<List<Task>> tasks() async =>
      (await _db.query('tasks', orderBy: 'minute_of_day')).map(Task.fromMap).toList();

  /// Logs whose occurrence day falls in [from]..[to] inclusive, oldest first.
  Future<List<TaskLog>> logsBetween(DateTime from, DateTime to) async => (await _db.query(
        'logs',
        where: 'day >= ? AND day <= ?',
        whereArgs: [dayKey(from), dayKey(to)],
        orderBy: 'at',
      ))
          .map(TaskLog.fromMap)
          .toList();

  /// Completed sessions per goal, across all time.
  Future<Map<int, int>> doneCountByGoal() async {
    final rows = await _db.rawQuery('''
      SELECT t.goal_id AS goal_id, COUNT(*) AS n
      FROM logs l JOIN tasks t ON t.id = l.task_id
      WHERE l.status = 'done' AND t.goal_id IS NOT NULL
      GROUP BY t.goal_id''');
    return {for (final r in rows) r['goal_id'] as int: r['n'] as int};
  }

  Future<int> insertGoal(Goal g) => _db.insert('goals', g.toMap()..remove('id'));

  Future<void> deleteGoal(int id) => _db.delete('goals', where: 'id = ?', whereArgs: [id]);

  Future<int> insertTask(Task t) => _db.insert('tasks', t.toMap()..remove('id'));

  Future<void> updateTask(Task t) => _db.update('tasks', t.toMap(), where: 'id = ?', whereArgs: [t.id]);

  Future<void> deleteTask(int id) => _db.delete('tasks', where: 'id = ?', whereArgs: [id]);

  Future<void> insertLog(TaskLog l) => _db.insert('logs', l.toMap()..remove('id'));

  /// Removes the final (done/skipped) answer for one occurrence, used for undo.
  Future<void> clearResolution(int taskId, String day) => _db.delete(
        'logs',
        where: "task_id = ? AND day = ? AND status != 'snoozed'",
        whereArgs: [taskId, day],
      );
}
