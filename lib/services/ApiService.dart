import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'https://backend-laravel-cuarta2-v12-main-hzlxlw.laravel.cloud';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Interceptor para agregar el token automáticamente
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) {
        if (error.response?.statusCode == 401) {
          // Token expirado o inválido, limpiar el token
          deleteToken();
        }
        return handler.next(error);
      },
    ));
  }

  // Registro de usuario
  Future<Response> registerUser(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post('/api/register', data: userData);
      
      // Guardar el token si el registro es exitoso
      if (response.data['token'] != null) {
        await saveToken(response.data['token']);
      }
      
      return response;
    } on DioException catch (e) {
      if (e.response != null) {
        // Error del servidor con respuesta
        throw Exception(e.response?.data['message'] ?? 'Error en el registro');
      } else {
        // Error de red
        throw Exception('Error de conexión: ${e.message}');
      }
    }
  }

  // Login de usuario
  Future<Response> loginUser(Map<String, dynamic> credentials) async {
    try {
      final response = await _dio.post('/api/login', data: credentials);
      
      // Guardar el token si el login es exitoso
      if (response.data['token'] != null) {
        await saveToken(response.data['token']);
      }
      
      return response;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Credenciales incorrectas');
      } else {
        throw Exception('Error de conexión: ${e.message}');
      }
    }
  }

  // Logout de usuario
  Future<Response> logoutUser() async {
    try {
      final response = await _dio.post('/api/logout');
      await deleteToken();
      return response;
    } on DioException catch (e) {
      throw Exception('Error al cerrar sesión: ${e.message}');
    }
  }

  // Obtener información del usuario autenticado
  Future<Response> getUser() async {
    try {
      final response = await _dio.get('/api/user');
      return response;
    } on DioException catch (e) {
      throw Exception('Error al obtener usuario: ${e.message}');
    }
  }

  // Métodos para gestión del token
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }
}