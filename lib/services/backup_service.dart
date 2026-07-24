// lib/services/backup_service.dart

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:home_orders_tracker/services/storage_service.dart';
import 'package:home_orders_tracker/services/backup_exception.dart';

class BackupService {
  static const String _dbName = 'home_orders.db';

  /// Creates a backup of the database file using the system file picker.
  /// Shows a Save dialog with a timestamped filename.
  /// Throws [BackupException] on failure.
  static Future<void> runBackup(StorageService storage) async {
    try {
      await storage.checkpointDatabase();

      final dbPath = await getDatabasesPath();
      final dbFile = File(p.join(dbPath, _dbName));

      if (!await dbFile.exists()) {
        throw const BackupException(BackupErrorType.backupFileNotFound);
      }

      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final fileName = 'home_orders_backup_$timestamp.db';

      final params = SaveFileDialogParams(
        sourceFilePath: dbFile.path,
        fileName: fileName,
        mimeTypesFilter: ['application/x-sqlite3'],
      );

      final filePath = await FlutterFileDialog.saveFile(params: params);

      if (filePath == null) {
        throw const BackupException(BackupErrorType.backupCancelled);
      }
    } on BackupException {
      rethrow;
    } on PlatformException catch (e) {
      throw BackupException(
        BackupErrorType.backupSaveError,
        details: e.message,
        cause: e,
      );
    } catch (e) {
      throw BackupException(
        BackupErrorType.backupSaveError,
        details: e.toString(),
        cause: e,
      );
    }
  }

  /// Restores the database from a user-selected file.
  ///
  /// The selected file is only accepted once it passes a lightweight
  /// SQLite header check. The current database and its `-wal`/`-shm`
  /// sidecar files are then moved aside (not deleted) before the new
  /// file is copied into place. If anything fails after that point —
  /// the copy, or reopening the database — the original files are
  /// moved back and the database is reopened, so a failed restore
  /// never leaves the app without a working database.
  ///
  /// Throws [BackupException] on failure or cancellation.
  static Future<void> runRestore(StorageService storage) async {
    bool databaseWasClosed = false;
    File? originalDbBackup;
    String? originalWalBackup;
    String? originalShmBackup;

    try {
      final params = OpenFileDialogParams();

      final filePath = await FlutterFileDialog.pickFile(params: params);

      if (filePath == null) {
        throw const BackupException(BackupErrorType.restoreCancelled);
      }

      final selectedFile = File(filePath);
      if (!await selectedFile.exists()) {
        throw const BackupException(BackupErrorType.restoreFileNotFound);
      }

      // Lightweight SQLite header check. Nothing about the current
      // database is touched unless this passes.
      final raf = await selectedFile.open();
      try {
        final bytes = await raf.read(16);
        final header = String.fromCharCodes(bytes);
        if (!header.startsWith('SQLite format 3')) {
          throw const BackupException(BackupErrorType.restoreInvalidFile);
        }
      } finally {
        await raf.close();
      }

      // Selected file is accepted as valid enough to proceed. Flush the
      // WAL into the main db file, then close it before touching it.
      await storage.checkpointDatabase();
      await storage.closeDatabase();
      databaseWasClosed = true;

      final dbPath = await getDatabasesPath();
      final targetPath = p.join(dbPath, _dbName);
      final targetFile = File(targetPath);
      final walFile = File('$targetPath-wal');
      final shmFile = File('$targetPath-shm');

      // Move the current database (and any sidecar files) aside instead
      // of deleting them, so we can roll back if anything below fails.
      if (await targetFile.exists()) {
        originalDbBackup = await targetFile.rename('$targetPath.bak');
      }
      if (await walFile.exists()) {
        originalWalBackup = '$targetPath-wal.bak';
        await walFile.rename(originalWalBackup);
      }
      if (await shmFile.exists()) {
        originalShmBackup = '$targetPath-shm.bak';
        await shmFile.rename(originalShmBackup);
      }

      // Copy the selected file into place.
      await selectedFile.copy(targetPath);

      // Reopen with the restored database.
      await storage.reopenDatabase();
      databaseWasClosed = false;

      // Restore succeeded: the old database is no longer needed.
      await _deleteIfExists(originalDbBackup);
      await _deleteIfExists(
        originalWalBackup == null ? null : File(originalWalBackup),
      );
      await _deleteIfExists(
        originalShmBackup == null ? null : File(originalShmBackup),
      );
    } on BackupException {
      await _rollbackRestore(
        storage,
        databaseWasClosed,
        originalDbBackup,
        originalWalBackup,
        originalShmBackup,
      );
      rethrow;
    } catch (e) {
      await _rollbackRestore(
        storage,
        databaseWasClosed,
        originalDbBackup,
        originalWalBackup,
        originalShmBackup,
      );
      throw BackupException(
        BackupErrorType.restoreFailed,
        details: e.toString(),
        cause: e,
      );
    }
  }

  /// Puts the original database (and sidecars) back if they were moved
  /// aside, deleting any partially-restored file at the target path
  /// first, then reopens the database. Best-effort: failures here are
  /// swallowed so the original error from [runRestore] is what surfaces.
  static Future<void> _rollbackRestore(
    StorageService storage,
    bool databaseWasClosed,
    File? originalDbBackup,
    String? originalWalBackup,
    String? originalShmBackup,
  ) async {
    if (originalDbBackup != null) {
      try {
        final dbPath = await getDatabasesPath();
        final targetPath = p.join(dbPath, _dbName);

        await _deleteIfExists(File(targetPath));
        await originalDbBackup.rename(targetPath);

        if (originalWalBackup != null) {
          await File(originalWalBackup).rename('$targetPath-wal');
        }
        if (originalShmBackup != null) {
          await File(originalShmBackup).rename('$targetPath-shm');
        }
      } catch (_) {
        // Best effort; the reopen below still runs against whatever
        // file ended up at targetPath.
      }
    }

    if (databaseWasClosed) {
      try {
        await storage.reopenDatabase();
      } catch (_) {}
    }
  }

  static Future<void> _deleteIfExists(File? file) async {
    if (file == null) return;
    if (await file.exists()) await file.delete();
  }
}