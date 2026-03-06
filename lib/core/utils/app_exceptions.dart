/// Custom exceptions for SoundScribe app

class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

class MicrophoneException extends AppException {
  MicrophoneException(super.message, {super.code});
}

class ApiException extends AppException {
  final int? statusCode;

  ApiException(super.message, {super.code, this.statusCode});

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (status: $statusCode)' : ''}';
}

class StorageException extends AppException {
  StorageException(super.message, {super.code});
}
