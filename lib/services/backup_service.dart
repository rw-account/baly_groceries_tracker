// lib/services/backup_service.dart

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';
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
    File? tempBackupFile;
    bool databaseWasClosed = false;

    try {
      // 1. التحقق من مسار قاعدة البيانات الأصلية
      final dbPath = await getDatabasesPath();
      final dbFile = File(p.join(dbPath, _dbName));

      if (!await dbFile.exists()) {
        throw const BackupException(BackupErrorType.backupFileNotFound);
      }

      // 2. تجهيز مسار واسم الملف المؤقت
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final fileName = 'home_orders_backup_$timestamp.db';
      tempBackupFile = File(p.join(tempDir.path, fileName));

      // -------------------------------------------------------------
      // 3. المنطقة الحرجة (النسخ السريع جداً)
      // -------------------------------------------------------------
      await storage.checkpointDatabase();
      
      // إغلاق قاعدة البيانات لتجنب أي تعارض (File Locks)
      await storage.closeDatabase();
      databaseWasClosed = true;

      // نسخ الملف بأمان تام وهو مغلق
      await dbFile.copy(tempBackupFile.path);

      // إعادة فتح قاعدة البيانات فوراً ليعود التطبيق للعمل
      await storage.reopenDatabase();
      databaseWasClosed = false;
      // -------------------------------------------------------------

      // 4. فتح نافذة الحفظ للمستخدم (باستخدام الملف المؤقت بدلاً من الأصلي)
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
      // ضمان إعادة فتح قاعدة البيانات في حال حدوث خطأ أثناء عملية النسخ
      if (databaseWasClosed) {
        try {
          await storage.reopenDatabase();
        } catch (_) {
          // Swallow reopen error to avoid masking the original exception.
        }
      }

      // تنظيف النظام: حذف الملف المؤقت بعد انتهاء عملية الحفظ أو في حال الإلغاء
      if (tempBackupFile != null && await tempBackupFile.exists()) {
        try {
          await tempBackupFile.delete();
        } catch (_) {
          // تجاهل أخطاء الحذف
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

      // 1. فحص هيدر SQLite للتأكد من سلامة الملف قبل لمس قاعدة البيانات الحالية
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

      // 2. تفريغ وإغلاق قاعدة البيانات الحالية للتحضير للاستبدال
      await storage.checkpointDatabase();
      await storage.closeDatabase();
      databaseWasClosed = true;

      final dbPath = await getDatabasesPath();
      final targetPath = p.join(dbPath, _dbName);
      final targetFile = File(targetPath);
      final walFile = File('$targetPath-wal');
      final shmFile = File('$targetPath-shm');

      // 3. تغيير أسماء الملفات الحالية إلى (.bak) لحمايتها وإمكانية التراجع عند الفشل
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

      // 4. نسخ الملف المسترجع إلى المسار الرئيسي
      await selectedFile.copy(targetPath);

      // 5. إعادة فتح قاعدة البيانات بالبيانات الجديدة
      await storage.reopenDatabase();
      databaseWasClosed = false; // نجح الفتح، لا يلزم التراجع بعد الآن

      // 6. التنظيف الآمن: حذف الملفات المؤقتة القديمة مع عزل أخطاء التنظيف لكي لا تسبب تراجعاً خاطئاً
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

        // حذف الملف الفاشل/المسترجع جزئياً إن وجد
        await _deleteIfExists(File(targetPath));

        // إرجاع الملفات الأصلية
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

  static Future<void> _deleteIfExists(File? file) async {
    if (file == null) return;
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }
}