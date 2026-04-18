import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
 
// Use localhost for Chrome/Web emulation, 10.0.2.2 for Android emulator
const String baseUrl = 'http://localhost:8000';
 
class AuthService extends ChangeNotifier {
  String? _token;
  String? _username;
  int? _userId;
 
  bool get isLoggedIn => _token != null;
  String? get token => _token;
  String? get username => _username;
  int? get userId => _userId;
 
  Map<String, String> get authHeaders => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };
 
  Future<Map<String, dynamic>> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server'};
    }
  }
 
  Future<Map<String, dynamic>> signin(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _token = data['token'];
        _username = data['username'];
        _userId = data['user_id'];
        notifyListeners();
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Sign in failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server'};
    }
  }
 
  Future<void> signout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/signout'),
        headers: authHeaders,
      );
    } catch (_) {}
    _token = null;
    _username = null;
    _userId = null;
    notifyListeners();
  }
 
  Future<List<dynamic>> getPokemon() async {
    final response = await http.get(Uri.parse('$baseUrl/pokemon'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load Pokemon');
  }
 
  Future<Set<int>> getFavoriteIds() async {
    if (!isLoggedIn) return {};
    final response = await http.get(
      Uri.parse('$baseUrl/favorites'),
      headers: authHeaders,
    );
    if (response.statusCode == 200) {
      final List<dynamic> favs = jsonDecode(response.body);
      return favs.map((p) => p['id'] as int).toSet();
    }
    return {};
  }
 
  Future<bool> addFavorite(int pokemonId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/favorites'),
      headers: authHeaders,
      body: jsonEncode({'pokemon_id': pokemonId}),
    );
    return response.statusCode == 200;
  }
 
  Future<bool> removeFavorite(int pokemonId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/favorites/$pokemonId'),
      headers: authHeaders,
    );
    return response.statusCode == 200;
  }
}