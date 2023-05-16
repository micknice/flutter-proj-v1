import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mynotes/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, MissingPlatformDirectoryException;
import 'package:path/path.dart' show join;

class NotesService {
  Database? _db;

  List<DatabaseNotes> _notes = [];

  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance();
  factory NotesService() => _shared;

  final _notesStreamController =
      StreamController<List<DatabaseNotes>>.broadcast();

  Stream<List<DatabaseNotes>> get allNotes => _notesStreamController.stream;

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on UserDoesNotExist {
      final newUser = await createUser(email: email);
      return newUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNotes> updateNotes({
    required DatabaseNotes notes,
    required String result,
    required String job,
    required String room,
  }) async {
    await _checkDbOpen();
    final db = _getDatabaseOrThrow();
    //check exists
    await getNote(id: notes.id);
    //update db
    final updateCount = await db.update(notesTable, {
      resultColumn: result,
      jobColumn: job,
      roomColumn: room,
      cloudSyncedColumn: 0,
    });
    if (updateCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNote = await getNote(id: notes.id);
      //remove old from cache
      _notes.removeWhere((note) => note.id == updatedNote.id);
      //cache updated
      _notes.add(updatedNote);
      //stream updated
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

// need to adddfunctionality for job and room columns
  Future<Iterable<DatabaseNotes>> getAllNotes() async {
    await _checkDbOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      notesTable,
    );
    return results.map((resultRow) => DatabaseNotes.fromRow(resultRow));
  }

  Future<DatabaseNotes> getNote({required int id}) async {
    await _checkDbOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      notesTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) {
      throw NoteDoesNotExist();
    } else {
      final note = DatabaseNotes.fromRow(results.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<int> deleteAllNotes() async {
    await _checkDbOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(notesTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return deleteCount;
  }

  Future<void> deleteNote({required int id}) async {
    await _checkDbOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      notesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<DatabaseNotes> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw UserDoesNotExist();
    }
    const result = '';
    const job = '';
    const room = '';
    //create note
    final noteId = await db.insert(notesTable, {
      userIdColumn: owner.id,
      resultColumn: result,
      jobColumn: job,
      roomColumn: room,
      cloudSyncedColumn: 1,
    });

    final note = DatabaseNotes(
      id: noteId,
      userId: owner.id,
      result: result,
      job: job,
      room: room,
      cloudSynced: true,
    );
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _checkDbOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw UserDoesNotExist();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _checkDbOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }
    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    await _checkDbOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> _checkDbOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      //empty
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      // create user table
      await db.execute(createUserTable);

      //create notes table
      await db.execute(createNotesTable);
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DatabaseNotes {
  final int id;
  final int userId;
  final String result;
  final String job;
  final String room;
  final bool cloudSynced;

  const DatabaseNotes({
    required this.id,
    required this.userId,
    required this.result,
    required this.job,
    required this.room,
    required this.cloudSynced,
  });

  DatabaseNotes.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        result = map[resultColumn] as String,
        job = map[jobColumn] as String,
        room = map[roomColumn] as String,
        cloudSynced = (map[cloudSyncedColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Note, ID = $id, userId = $userId, cloudSynced = $cloudSynced, result = $result, job = $job, room = $room ';

  @override
  bool operator ==(covariant DatabaseNotes other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const notesTable = 'notes';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const resultColumn = 'result';
const jobColumn = 'job';
const roomColumn = 'room';
const cloudSyncedColumn = 'cloud_synced';
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
	      "id"	INTEGER,
	      "email"	TEXT NOT NULL UNIQUE,
	      PRIMARY KEY("id" AUTOINCREMENT)
      )''';
const createNotesTable = '''CREATE TABLE IF NOT EXISTS "notes" (
	      "id"	INTEGER NOT NULL,
	      "user_id"	INTEGER NOT NULL,
        "result"	TEXT NOT NULL,
        "job"	TEXT,
        "room"	TEXT,
        "cloud_synced"	INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY("id" AUTOINCREMENT)
      )''';
