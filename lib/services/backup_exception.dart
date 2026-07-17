// lib/services/backup_exception.dart

/// Strongly-typed categories of errors that can occur during backup
/// or restore operations. Replaces fragile string-matching against
/// `Exception.toString()`.
enum BackupErrorType {
  backupFileNotFound,
  backupCancelled,
  backupSaveError,
  restoreCancelled,
  restoreFileNotFound,
  restoreInvalidFile,
  restoreFailed,
  unknown,
}

/// A typed exception thrown by [BackupService] for backup/restore
/// failures. Carries a [type] enum for reliable, compiler-checked
/// handling at the call site, plus optional [details] / [cause] for
/// logging or debugging.
class BackupException implements Exception {
  final BackupErrorType type;
  final String? details;
  final Object? cause;

  const BackupException(this.type, {this.details, this.cause});

  @override
  String toString() {
    final buffer = StringBuffer('BackupException: $type');
    if (details != null) buffer.write(' ($details)');
    if (cause != null) buffer.write(' [cause: $cause]');
    return buffer.toString();
  }
}
