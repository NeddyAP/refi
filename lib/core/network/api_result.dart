/// Generic class to handle API responses
sealed class ApiResult<T> {
  const ApiResult();
}

/// Success state with data
class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  
  const ApiSuccess(this.data);
}

/// Error state with error details
class ApiError<T> extends ApiResult<T> {
  final String message;
  final int? statusCode;
  final dynamic error;
  
  const ApiError({
    required this.message,
    this.statusCode,
    this.error,
  });
}

/// Loading state
class ApiLoading<T> extends ApiResult<T> {
  const ApiLoading();
}

/// Extension methods for easier handling
extension ApiResultExtension<T> on ApiResult<T> {
  /// Check if the result is successful
  bool get isSuccess => this is ApiSuccess<T>;
  
  /// Check if the result is an error
  bool get isError => this is ApiError<T>;
  
  /// Check if the result is loading
  bool get isLoading => this is ApiLoading<T>;
  
  /// Get data if successful, null otherwise
  T? get data => switch (this) {
    ApiSuccess<T> success => success.data,
    _ => null,
  };
  
  /// Get error message if error, null otherwise
  String? get errorMessage => switch (this) {
    ApiError<T> error => error.message,
    _ => null,
  };
  
  /// Execute different callbacks based on state
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, int? statusCode) error,
    required R Function() loading,
  }) {
    return switch (this) {
      ApiSuccess<T> s => success(s.data),
      ApiError<T> e => error(e.message, e.statusCode),
      ApiLoading<T> _ => loading(),
    };
  }
  
  /// Execute callbacks only for specific states
  void whenOrNull({
    void Function(T data)? success,
    void Function(String message, int? statusCode)? error,
    void Function()? loading,
  }) {
    switch (this) {
      case ApiSuccess<T> s:
        success?.call(s.data);
      case ApiError<T> e:
        error?.call(e.message, e.statusCode);
      case ApiLoading<T> _:
        loading?.call();
    }
  }
}
