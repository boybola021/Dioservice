
class MainModel {
  final dynamic success;
  final String? message;
  final dynamic data;
  final ErrorModel? error;

  const MainModel({
    this.success,
    this.message,
    this.data,
    this.error,
  });

  factory MainModel.fromJson(Map<String, dynamic> json) {
    return MainModel(
      success: json['success'],
      message: json['message'] as String?,
      data: json['data'],
      error: json['errors'] != null
          ? ErrorModel.fromJson((json['errors'] as List).first)
          : json['error'] != null
          ? ErrorModel.fromJson(json['error'])
          : null,
    );
  }

  Map<String, Object?> toJson() => {
    "success": success,
    "message": message,
    "data": data,
    "errors": error?.toJson(),
  };

  MainModel copyWith({
    dynamic success,
    String? message,
    dynamic data,
    ErrorModel? error,
    ErrorModel? errorService,
  }) =>
      MainModel(
        success: success ?? this.success,
        message: message ?? this.message,
        data: data ?? this.data,
        error: error ?? this.error,
      );

  @override
  String toString() {
    return 'MainModel{success: $success, message: $message, data: $data, error: $error}';
  }
}

/// *ERROR MODEL* ///
class ErrorModel {
  final String? message;

  const ErrorModel({
    this.message,
  });

  factory ErrorModel.fromJson(Map<String, dynamic> json) => ErrorModel(
    message: json['message'].toString(),
  );

  Map<String, Object?> toJson() => {
    "msg": message,
  };

  @override
  String toString() {
    return 'ErrorModel{status: status, message: $message}';
  }
}
