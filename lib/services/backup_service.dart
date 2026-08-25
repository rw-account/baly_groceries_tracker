// lib/services/backup_service.dart

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:baly_groceries_tracker/services/storage_service.dart';
import 'package:baly_groceries_tracker/services/backup_exception.dart';

class BackupService {
  static const String _dbName = 'baly_groceries_tracker.db';

  /// Creates a backup of the database file using the system file picker.
  /// Shows a Save dialog with a timestamped filename.
  /// Throws [BackupException] on failure.
  static Future<void> runBackup(StorageService storage) async {
    File? tempBackupFile;
    bool databaseWasClosed = false;

    try {
      // 1. Verify the original database path exists
      final dbPath = await getDatabasesPath();
      final dbFile = File(p.join(dbPath, _dbName));

      if (!await dbFile.exists()) {
        throw const BackupException(BackupErrorType.backupFileNotFound);
      }

      // 2. Prepare a temporary directory and generate a timestamped backup filename
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final fileName = 'baly_groceries_tracker_backup_$timestamp.db';
      tempBackupFile = File(p.join(tempDir.path, fileName));

      // -------------------------------------------------------------
      // 3. Critical Section (Fast Copy)
      // -------------------------------------------------------------
      await storage.checkpointDatabase();
      
      // Close the database to prevent file locks or corruption during the copy
      await storage.closeDatabase();
      databaseWasClosed = true;

      // Safely copy the database file while it's closed
      await dbFile.copy(tempBackupFile.path);

      // Immediately reopen the database to resume normal app operation
      await storage.reopenDatabase();
      databaseWasClosed = false;
      // -------------------------------------------------------------

      // 4. Open the system save dialog using the temporary file instead of the live database
      final params = SaveFileDialogParams(
        sourceFilePath: tempBackupFile.path,
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
    } finally {
      // Ensure the database is reopened if an error occurred during the copy process
      if (databaseWasClosed) {
        try {
          await storage.reopenDatabase();
        } catch (_) {
          // Swallow reopen error to avoid masking the original exception.
        }
      }

      // System Cleanup: Delete the temporary file after saving is complete or if it was cancelled
      if (tempBackupFile != null && await tempBackupFile.exists()) {
        try {
          await tempBackupFile.delete();
        } catch (_) {
          // Swallow deletion errors
        }
      }
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
    File? selectedFile;

    try {
      final params = OpenFileDialogParams();

      final filePath = await FlutterFileDialog.pickFile(params: params);

      if (filePath == null) {
        throw const BackupException(BackupErrorType.restoreCancelled);
      }

      selectedFile = File(filePath);
      if (!await selectedFile.exists()) {
        throw const BackupException(BackupErrorType.restoreFileNotFound);
      }

      // 1. Validate the SQLite header to ensure file integrity before touching the current database
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

      // 2. Flush WAL and close the current database to prepare for file replacement
      await storage.checkpointDatabase();
      await storage.closeDatabase();
      databaseWasClosed = true;

      final dbPath = await getDatabasesPath();
      final targetPath = p.join(dbPath, _dbName);
      final targetFile = File(targetPath);
      final walFile = File('$targetPath-wal');
      final shmFile = File('$targetPath-shm');

      // 3. Rename current files to (.bak) to preserve them and allow rollback on failure
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

      // 4. Copy the selected restore file into the main database path
      await selectedFile.copy(targetPath);

      // 5. Reopen the database with the newly restored data
      await storage.reopenDatabase();
      databaseWasClosed = false; // Reopen succeeded; rollback is no longer needed

      // 6. Safe Cleanup: Delete old backup files. 
      // Errors are handled gracefully inside _deleteIfExists to prevent triggering a false rollback.
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
    } on PlatformException catch (e) {
      await _rollbackRestore(
        storage,
        databaseWasClosed,
        originalDbBackup,
        originalWalBackup,
        originalShmBackup,
      );
      throw BackupException(
        BackupErrorType.restoreFailed,
        details: e.message,
        cause: e,
      );
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

        // Delete the partially restored or failed file if it exists
        await _deleteIfExists(File(targetPath));

        // Restore the original files to their proper paths
        await originalDbBackup.rename(targetPath);

        if (originalWalBackup != null) {
          await File(originalWalBackup).rename('$targetPath-wal');
        }
        if (originalShmBackup != null) {
          await File(originalShmBackup).rename('$targetPath-shm');
        }
      } catch (_) {
        // Best effort
      }
    }

    if (databaseWasClosed) {
      try {
        await storage.reopenDatabase();
      } catch (_) {}
    }
  }

  /// Safely deletes a file if it exists. Swallows errors to ensure 
  /// cleanup operations do not crash the app.
  static Future<void> _deleteIfExists(File? file) async {
    if (file == null) return;
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }
}