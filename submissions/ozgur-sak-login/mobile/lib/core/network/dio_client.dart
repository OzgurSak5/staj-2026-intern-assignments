import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage_manager.dart';

class DioClient {
  late final Dio dio;
  final SecureStorageManager _storage = SecureStorageManager.instance;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshToken = await _storage.getRefreshToken();
            if (refreshToken != null) {
              try {
                final refreshDio = Dio(
                  BaseOptions(baseUrl: AppConstants.baseUrl),
                );
                final response = await refreshDio.post(
                  AppConstants.refreshEndpoint,
                  data: {'refreshToken': refreshToken},
                );

                if (response.statusCode == 200) {
                  final newAccessToken = response.data['accessToken'];
                  final newRefreshToken = response.data['refreshToken'];

                  await _storage.saveTokens(
                    accessToken: newAccessToken,
                    refreshToken: newRefreshToken,
                  );

                  final options = error.requestOptions;
                  options.headers['Authorization'] = 'Bearer $newAccessToken';

                  final retryResponse = await dio.fetch(options);
                  return handler.resolve(retryResponse);
                }
              } catch (e) {
                await _storage.clearTokens();
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }
}
