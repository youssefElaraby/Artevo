class CustomException implements Exception {
  final String message;

  CustomException({required this.message} );

  @override
  String toString() {
    return message;
  }
}

class ServerException extends CustomException {
  ServerException([String? message]) : super(message: message ?? 'Server Error') ;
}

class CacheException extends CustomException {
  CacheException([String? message]) : super(message: message ?? 'Cache Error') ;
}

class NetworkException extends CustomException {
  NetworkException([String? message]) : super(message: message ?? 'Network Error') ;
}

class UnknownException extends CustomException {
  UnknownException([String? message]) : super(message: message ?? 'Unknown Error') ;
}