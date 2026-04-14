import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:clip_frame/features/schedule/data/model.dart';

class DatabaseService {
  static Database? _database;
  static const String tableName = 'scheduled_posts';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'clip_frame.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id TEXT PRIMARY KEY,
            imageUrl TEXT,
            thumbnailUrl TEXT,
            title TEXT,
            tags TEXT,
            scheduleTime TEXT,
            rawScheduleTime TEXT,
            status TEXT,
            contentType TEXT,
            createdAt TEXT
          )
        ''');
      },
    );
  }

  static Future<void> savePosts(List<SchedulePost> posts) async {
    final db = await database;
    Batch batch = db.batch();
    
    // Clear old data for the given status if needed, or just insert/replace
    for (var post in posts) {
      batch.insert(
        tableName,
        {
          'id': post.id,
          'imageUrl': post.imageUrl,
          'thumbnailUrl': post.thumbnailUrl,
          'title': post.title,
          'tags': jsonEncode(post.tags),
          'scheduleTime': post.scheduleTime,
          'rawScheduleTime': post.rawScheduleTime,
          'status': post.status,
          'contentType': post.contentType,
          'createdAt': post.createdAt?.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  static Future<List<SchedulePost>> getPostsByStatus(String status) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'status = ?',
      whereArgs: [status],
    );

    return List.generate(maps.length, (i) {
      return SchedulePost(
        id: maps[i]['id'],
        imageUrl: maps[i]['imageUrl'],
        thumbnailUrl: maps[i]['thumbnailUrl'],
        title: maps[i]['title'],
        tags: List<String>.from(jsonDecode(maps[i]['tags'])),
        scheduleTime: maps[i]['scheduleTime'],
        rawScheduleTime: maps[i]['rawScheduleTime'],
        status: maps[i]['status'],
        contentType: maps[i]['contentType'],
        createdAt: maps[i]['createdAt'] != null
            ? DateTime.tryParse(maps[i]['createdAt'])
            : null,
      );
    });
  }

  static Future<void> deletePost(String id) async {
    final db = await database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> clearAll() async {
    final db = await database;
    await db.delete(tableName);
  }
}
