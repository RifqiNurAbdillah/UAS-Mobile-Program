import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/item.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  // Fungsi untuk menginisialisasi database
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    // Buka database dan upgrade versi jika perlu
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // Fungsi untuk membuat tabel pada versi pertama
  Future _createDB(Database db, int version) async {
    // Membuat tabel untuk users
    await db.execute(''' 
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        nama TEXT,
        alamat TEXT,
        npm TEXT,
        email TEXT,
        telepon TEXT,
        prodi TEXT,
        kelas TEXT,
        jk TEXT,
        role TEXT
      )
    ''');

    // Insert user admin secara otomatis
    await db.insert('users', {
      'username': 'admin123',
      'password': 'password123',
      'nama': 'Administrator',
      'alamat': '',
      'npm': '',
      'email': '',
      'telepon': '',
      'prodi': '',
      'kelas': '',
      'jk': '',
      'role': 'admin',
    });

    // Membuat tabel untuk items
    await db.execute(''' 
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT,
        year INTEGER,
        description TEXT NOT NULL,
        pdfPath TEXT,
        coverPath TEXT
      )
    ''');
  }

  // Fungsi untuk menangani upgrade database
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Jika versi database lebih rendah dari versi 2, hapus tabel lama dan buat yang baru
      await db.execute('DROP TABLE IF EXISTS items');
      await db.execute(''' 
        CREATE TABLE items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          author TEXT,
          year INTEGER,
          description TEXT NOT NULL,
          pdfPath TEXT,
          coverPath TEXT
        )
      ''');
    }
  }

  // ================= USER =================

  // Register user
  Future<int> registerUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  // Login user
  Future<User?> loginUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username=? AND password=?',
      whereArgs: [username, password],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // ================= CRUD ITEM =================

  // Insert item
  Future<int> insertItem(Item item) async {
    final db = await database;
    return await db.insert('items', item.toMap());
  }

  // Get all items
  Future<List<Item>> getItems() async {
    final db = await database;
    final result = await db.query('items');
    return result.map((e) => Item.fromMap(e)).toList();
  }

  // Update item
  Future<int> updateItem(Item item) async {
    final db = await database;
    return await db.update(
      'items',
      item.toMap(),
      where: 'id=?',
      whereArgs: [item.id],
    );
  }

  // Delete item
  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete('items', where: 'id=?', whereArgs: [id]);
  }

  // ================= DEBUG =================

  // Print semua user di console
  Future<void> printAllUsers() async {
    final db = await database;
    final result = await db.query('users');
    print('--- USERS IN DB ---');
    for (var row in result) {
      print(row); // row ini Map<String, dynamic> semua kolom
    }
    print('------------------');
  }

  // Cek apakah user dengan username & password ada
  Future<bool> isUserExist(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username=? AND password=?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
  }

  // Hapus database (untuk recreate / reset database)
  Future<void> deleteDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');
    await deleteDatabase(path);
    print('Database deleted!');
  }
}
