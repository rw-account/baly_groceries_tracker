// lib/services/backup_service.dart

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:home_orders_tracker/services/storage_service.dart';

class BackupService {
  static const String _dbName = 'home_orders.db';

  /// Creates a backup of the database file using the system file picker.
  /// Shows a Save dialog with a timestamped filename.
  /// Throws [Exception] on failure.
  static Future<void> runBackup(StorageService storage) async {
    try {
      await storage.checkpointDatabase();

      final dbPath = await getDatabasesPath();
      final dbFile = File(p.join(dbPath, _dbName));

      if (!await dbFile.exists()) {
        throw Exception('backupFileNotFound');
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
        throw Exception('backupCancelled');
      }
    } on PlatformException catch (e) {
      throw Exception('backupSaveError: ${e.message}');
    } catch (e) {
      throw Exception('backupFailed: $e');
    }
  }

  /// Restores the database from a user-selected .db file.
  /// Closes the database before replacing the file, then reopens it.
  /// Throws [Exception] on failure or cancellation.
  static Future<void> runRestore(StorageService storage) async {
    try {
      final params = OpenFileDialogParams(
        fileExtensionsFilter: ['db'],
      );

      final filePath = await FlutterFileDialog.pickFile(params: params);

      if (filePath == null) {
        throw Exception('restoreCancelled');
      }

      final selectedFile = File(filePath);
      if (!await selectedFile.exists()) {
        throw Exception('restoreFileNotFound');
      }

      // التحقق من توقيع SQLite بشكل آمن للذاكرة
      final raf = await selectedFile.open();
      try {
        final bytes = await raf.read(16);
        final header = String.fromCharCodes(bytes);
        if (!header.startsWith('SQLite format 3')) {
          throw Exception('restoreInvalidFile');
        }
      } finally {
        await raf.close();
      }

      // إغلاق القاعدة قبل استبدال الملف
      await storage.closeDatabase();

      final dbPath = await getDatabasesPath();
      final targetPath = p.join(dbPath, _dbName);

      // حذف ملفات WAL و SHM القديمة
      final walFile = File('$targetPath-wal');
      final shmFile = File('$targetPath-shm');
      if (await walFile.exists()) await walFile.delete();
      if (await shmFile.exists()) await shmFile.delete();

      // نسخ الملف المختار إلى مسار القاعدة الأصلي
      await selectedFile.copy(targetPath);

      // إعادة فتح القاعدة بعد الاستعادة
      await storage.reopenDatabase();
    } catch (e) {
      // محاولة إعادة فتح القاعدة حتى في حالة الخطأ
      try {
        await storage.reopenDatabase();
      } catch (_) {}
      rethrow; // يعيد رمي الخطأ للمستدعي
    }
  }
}