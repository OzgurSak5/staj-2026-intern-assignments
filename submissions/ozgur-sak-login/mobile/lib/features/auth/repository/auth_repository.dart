import '../../../core/storage/secure_storage_manager.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;
  final SecureStorageManager _storage = SecureStorageManager.instance;

  AuthRepository(this._authService);

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final tokenData = await _authService.login(
      email: email,
      password: password,
    );

    print('🔑 KOPYALANABİLİR ACCESS TOKEN:');
    print("ACCESS TOKEN IS: ${tokenData['accessToken']}");

    await _storage.saveTokens(
      accessToken: tokenData['accessToken'] ?? '',
      refreshToken: tokenData['refreshToken'] ?? '',
    );

    return tokenData;
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    await _authService.register(email: email, password: password);
  }

  Future<Map<String, dynamic>> getMe() async {
    return await _authService.getMe();
  }

  Future<void> logout() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken != null) {
      await _authService.logout(refreshToken);
    }
    await _storage.clearTokens();
  }

  Future<String?> getAccessToken() async {
    return await _storage.getAccessToken();
  }
}
