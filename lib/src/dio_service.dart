import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';

import 'custom_log.dart';
import 'main_model.dart';

MainModel get defaultModel => const MainModel(success: true, data: null, message: null, error: ErrorModel(message: null));

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late Dio _dio;

  DioClient._internal();

  factory DioClient() {
    _instance._dio =
        Dio()
          ..options.baseUrl = ""
          ..options.connectTimeout = const Duration(seconds: 30)
          ..options.receiveTimeout = const Duration(seconds: 30)
          ..httpClientAdapter
          ..options.headers = {'Content-Type': 'application/json; charset=UTF-8'};
    return _instance;
  }

  // Base URL ni sozlash
  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  // Interceptorni qo'shish
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  /// *GET* ///

  Future<MainModel> get(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? header,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    bool withoutHeader = false,
  }) async {
    try {
      final response = await _dio.get(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: header ?? await headerSet()),
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return _analyzeResponse(response);
    } catch (e) {
      if (e is DioException) {
        return _analyzeResponse(e.response);
      }
      return defaultModel;
    }
  }

  Future<Response?> getNoFilter(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? header,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    bool withoutHeader = false,
  }) async {
    try {
      final response = await _dio.get(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: header ?? await headerSet()),
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        return e.response;
      }
      return null;
    }
  }

  Future<Response?> postNoFilter(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? header,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: await headerSet()),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        log("DioException Error Post method => $e");
        return e.response;
      }
      log("Error Post method => $e");
      return null;
    }
  }

  /// *POST* ///

  Future<MainModel> post(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? header,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: await headerSet()),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return _analyzeResponse(response);
    } catch (e) {
      if (e is DioException) {
        log("DioException Error Post method => $e");
        return _analyzeResponse(e.response);
      }
      log("Error Post method => $e");
      return defaultModel;
    }
  }

  /// *ANALYSE RESPONSE* ///

  MainModel _analyzeResponse(Response? response) {
    if (response != null && response.data != null) {
      MainModel mainModel = MainModel.fromJson(response.data);

      /// ----> 200 ///

      if (response.statusCode == 200 || response.statusCode == 201 || response.data['status'] == 202) {
        return MainModel(
          success: true,
          message: response.data['message'],
          data: response.data,
          error: ErrorModel(
            //status: 200,
            message: response.data['message'],
          ),
        );
      }

      if (response.data['status'] == 400) {
        return MainModel(
          success: false,
          message: response.data['errors']["message"],
          data: null,
          error: ErrorModel(
            //status: 401,
            message: response.data['errors']["message"],
          ),
        );
      }

      /// ----> 500 ///

      if (response.data['status'] == 500) {
        return const MainModel(
          success: false,
          message: 'Error Api',
          data: null,
          error: ErrorModel(
            //status: 500,
            message: "Internal Server Error",
          ),
        );
      }

      /// ----> 403 ///

      if (response.data['status'] == 403) {
        return MainModel(
          success: false,
          message: response.data['message'],
          data: null,
          error: ErrorModel(
            // status: 403,
            message: response.data['message'],
          ),
        );
      }

      if (response.data['status'] == 401 || response.data['status'] == 400) {
        return MainModel(
          success: false,
          message: response.data['errors']["message"],
          data: null,
          error: ErrorModel(
            //   status: 401,
            message: response.data['errors']["message"],
          ),
        );
      }

      return mainModel.copyWith(message: checkKeys(mainModel.error?.toJson()));
    }

    return defaultModel;
  }

  /// *PUT* ///

  Future<MainModel> put(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      var response = await _dio.put(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: await headerSet()),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return _analyzeResponse(response);
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      return defaultModel;
    }
  }

  /// patch
  Future<Response> patch(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? header,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      var response = await _dio.patch(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: header),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

  /// *DELETE* ///

  Future<Response> delete(String uri, {data, Map<String, dynamic>? queryParameters, CancelToken? cancelToken}) async {
    try {
      var response = await _dio.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: await headerSet()),
        cancelToken: cancelToken,
      );
      return response;
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

  /// *HEADER* ///

  Future<Map<String, dynamic>> headerSet({String? token}) async {
    if (token == "") {
      return {};
    } else {
      return {"Authorization": "Bearer $token"};
    }
  }

  /// *CHECK_KEYS* ///

  String? checkKeys(Map<String, dynamic>? data) {
    if (data == null) {
      return null;
    }
    if (data.values.isEmpty) {
      return 'SYSTEM ERROR';
    }
    try {
      for (var i = 0; i < (data.values.length > 20 ? 20 : data.values.length); i++) {
        final value = data.values.elementAt(i);
        if (value is List) {
          if (value.isNotEmpty) {
            return value.first.toString();
          }
        } else if (value is String) {
          return value;
        }
      }
      return 'SYSTEM ERROR';
    } catch (e) {
      return '$e';
    }
  }
}
