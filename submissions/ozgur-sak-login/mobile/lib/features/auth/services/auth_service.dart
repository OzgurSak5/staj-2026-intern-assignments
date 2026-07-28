import '../../../core/constants/app_constants.dart';
import '../../../core/network/dio_client.dart';
import 'package:openapi/api.dart';
import 'package:dio/dio.dart';

class AuthService {
  final DioClient _dioClient;

  AuthService(this._dioClient);

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        AppConstants.loginEndpoint,
        data: LoginRequest(email: email, password: password).toJson(),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Giriş yapılamadı.';
      throw Exception(message);
    }
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    try {
      await _dioClient.dio.post(
        AppConstants.registerEndpoint,
        data: RegisterRequest(email: email, password: password).toJson(),
      );
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Kayıt yapılamadı.';
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _dioClient.dio.get(AppConstants.meEndpoint);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Kullanıcı bilgileri alınamadı.');
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _dioClient.dio.post(
        AppConstants.logoutEndpoint,
        data: RefreshRequest(refreshToken: refreshToken).toJson(),
      );
    } catch (_) {
      throw Exception('Çıkış yapılamadı');
    }
  }
}
