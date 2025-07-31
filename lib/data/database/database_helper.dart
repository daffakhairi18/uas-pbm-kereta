import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';
import '../models/passenger_model.dart';
import '../models/schedule_model.dart';
import '../models/ticket_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), AppConstants.databaseName);
    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create passengers table
    await db.execute('''
      CREATE TABLE passengers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        id_number TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        user_type TEXT NOT NULL,
        username TEXT,
        password TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Create schedules table
    await db.execute('''
      CREATE TABLE schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        train_number TEXT NOT NULL,
        origin TEXT NOT NULL,
        destination TEXT NOT NULL,
        departure_time TEXT NOT NULL,
        arrival_time TEXT NOT NULL,
        train_class TEXT NOT NULL,
        price REAL NOT NULL,
        available_seats INTEGER NOT NULL,
        is_active INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create tickets table
    await db.execute('''
      CREATE TABLE tickets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        passenger_id INTEGER NOT NULL,
        schedule_id INTEGER NOT NULL,
        ticket_number TEXT NOT NULL,
        passenger_name TEXT NOT NULL,
        passenger_id_number TEXT NOT NULL,
        train_number TEXT NOT NULL,
        origin TEXT NOT NULL,
        destination TEXT NOT NULL,
        departure_time TEXT NOT NULL,
        arrival_time TEXT NOT NULL,
        train_class TEXT NOT NULL,
        price REAL NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (passenger_id) REFERENCES passengers (id),
        FOREIGN KEY (schedule_id) REFERENCES schedules (id)
      )
    ''');

    // Insert default admin user
    await db.insert('passengers', {
      'name': 'Administrator',
      'id_number': 'ADMIN001',
      'phone': '08123456789',
      'email': 'admin@trainbooking.com',
      'user_type': AppConstants.userTypeAdmin,
      'username': AppConstants.defaultAdminUsername,
      'password': AppConstants.defaultAdminPassword,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Insert sample schedules
    await _insertSampleSchedules(db);
  }

  Future<void> _insertSampleSchedules(Database db) async {
    final now = DateTime.now();
    final schedules = [
      {
        'train_number': 'KA-001',
        'origin': 'Gambir (GMR)',
        'destination': 'Bandung (BD)',
        'departure_time': DateTime(now.year, now.month, now.day + 1, 8, 0).toIso8601String(),
        'arrival_time': DateTime(now.year, now.month, now.day + 1, 10, 30).toIso8601String(),
        'train_class': 'Eksekutif',
        'price': 150000.0,
        'available_seats': 50,
        'is_active': 1,
        'created_at': now.toIso8601String(),
      },
      {
        'train_number': 'KA-002',
        'origin': 'Bandung (BD)',
        'destination': 'Yogyakarta (YK)',
        'departure_time': DateTime(now.year, now.month, now.day + 1, 14, 0).toIso8601String(),
        'arrival_time': DateTime(now.year, now.month, now.day + 1, 18, 30).toIso8601String(),
        'train_class': 'Bisnis',
        'price': 120000.0,
        'available_seats': 75,
        'is_active': 1,
        'created_at': now.toIso8601String(),
      },
      {
        'train_number': 'KA-003',
        'origin': 'Yogyakarta (YK)',
        'destination': 'Surabaya Gubeng (SGU)',
        'departure_time': DateTime(now.year, now.month, now.day + 2, 9, 0).toIso8601String(),
        'arrival_time': DateTime(now.year, now.month, now.day + 2, 13, 0).toIso8601String(),
        'train_class': 'Ekonomi',
        'price': 80000.0,
        'available_seats': 100,
        'is_active': 1,
        'created_at': now.toIso8601String(),
      },
    ];

    for (final schedule in schedules) {
      await db.insert('schedules', schedule);
    }
  }

  // Passenger operations
  Future<int> insertPassenger(PassengerModel passenger) async {
    final db = await database;
    return await db.insert('passengers', passenger.toMap());
  }

  Future<List<PassengerModel>> getAllPassengers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('passengers');
    return List.generate(maps.length, (i) => PassengerModel.fromMap(maps[i]));
  }

  Future<PassengerModel?> getPassengerById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'passengers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return PassengerModel.fromMap(maps.first);
    }
    return null;
  }

  Future<PassengerModel?> getPassengerByUsername(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'passengers',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return PassengerModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updatePassenger(PassengerModel passenger) async {
    final db = await database;
    return await db.update(
      'passengers',
      passenger.toMap(),
      where: 'id = ?',
      whereArgs: [passenger.id],
    );
  }

  Future<int> deletePassenger(int id) async {
    final db = await database;
    return await db.delete(
      'passengers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Schedule operations
  Future<int> insertSchedule(ScheduleModel schedule) async {
    final db = await database;
    return await db.insert('schedules', schedule.toMap());
  }

  Future<List<ScheduleModel>> getAllSchedules() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('schedules');
    return List.generate(maps.length, (i) => ScheduleModel.fromMap(maps[i]));
  }

  Future<List<ScheduleModel>> getSchedulesByRoute(String origin, String destination) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'schedules',
      where: 'origin = ? AND destination = ? AND is_active = 1',
      whereArgs: [origin, destination],
    );
    return List.generate(maps.length, (i) => ScheduleModel.fromMap(maps[i]));
  }

  Future<ScheduleModel?> getScheduleById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'schedules',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ScheduleModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateSchedule(ScheduleModel schedule) async {
    final db = await database;
    return await db.update(
      'schedules',
      schedule.toMap(),
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  Future<int> deleteSchedule(int id) async {
    final db = await database;
    return await db.delete(
      'schedules',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Ticket operations
  Future<int> insertTicket(TicketModel ticket) async {
    final db = await database;
    return await db.insert('tickets', ticket.toMap());
  }

  Future<List<TicketModel>> getAllTickets() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tickets');
    return List.generate(maps.length, (i) => TicketModel.fromMap(maps[i]));
  }

  Future<List<TicketModel>> getTicketsByPassengerId(int passengerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tickets',
      where: 'passenger_id = ?',
      whereArgs: [passengerId],
    );
    return List.generate(maps.length, (i) => TicketModel.fromMap(maps[i]));
  }

  Future<TicketModel?> getTicketById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tickets',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return TicketModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateTicket(TicketModel ticket) async {
    final db = await database;
    return await db.update(
      'tickets',
      ticket.toMap(),
      where: 'id = ?',
      whereArgs: [ticket.id],
    );
  }

  Future<int> deleteTicket(int id) async {
    final db = await database;
    return await db.delete(
      'tickets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 