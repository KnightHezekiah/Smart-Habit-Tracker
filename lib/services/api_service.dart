import 'dart:convert';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sht/models/habit_model.dart';
import 'package:sht/models/reward_model.dart';
import 'package:sht/models/stats_model.dart';

/// Service for making API calls to the backend (web mode only)
class ApiService {
  // Base URL for API calls - in web mode, this is relative to the current host
  final String baseUrl;

  // Singleton instance
  static ApiService? _instance;

  // Factory constructor to return the singleton instance
  factory ApiService({String? customBaseUrl}) {
    if (_instance == null) {
      final url = customBaseUrl ?? '/api';
      _instance = ApiService._internal(url);
    }
    return _instance!;
  }

  // Private constructor
  ApiService._internal(this.baseUrl);

  // Check if we're running in web mode
  bool get _isWebMode => kIsWeb;

  // Helper method to get the current origin (for web mode)
  String _getOrigin() {
    if (!_isWebMode) return '';
    return html.window.location.origin;
  }

  // Helper method to build the full URL for an endpoint
  String _buildUrl(String endpoint) {
    final base = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    final path = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return '$base$path';
  }

  // Generic method to make HTTP requests
  Future<Map<String, dynamic>> _request({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    if (!_isWebMode) {
      throw Exception('ApiService can only be used in web mode');
    }

    final url = _buildUrl(endpoint);
    final requestHeaders = {
      'Content-Type': 'application/json',
      ...?headers,
    };

    String? encodedBody;
    if (body != null) {
      encodedBody = jsonEncode(body);
    }

    final request = html.HttpRequest();
    final completer = Completer<Map<String, dynamic>>();

    request.open(method, url, async: true);

    // Set headers
    requestHeaders.forEach((key, value) {
      request.setRequestHeader(key, value);
    });

    request.onLoad.listen((event) {
      if (request.status >= 200 && request.status < 300) {
        final responseText = request.responseText;

        // Handle empty responses gracefully
        if (responseText == null || responseText.isEmpty) {
          completer.complete({});
        } else {
          try {
            final data = jsonDecode(responseText);
            completer
                .complete(data is Map<String, dynamic> ? data : {'data': data});
          } catch (e) {
            completer.completeError('Failed to decode response: $e');
          }
        }
      } else {
        completer.completeError('HTTP Error: ${request.status}');
      }
    });

    request.onError.listen((event) {
      completer.completeError('Network Error');
    });

    // Send the request
    if (encodedBody != null) {
      request.send(encodedBody);
    } else {
      request.send();
    }

    return completer.future;
  }

  // GET request helper
  Future<Map<String, dynamic>> get(String endpoint) async {
    return _request(
      endpoint: endpoint,
      method: 'GET',
    );
  }

  // POST request helper
  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> body) async {
    return _request(
      endpoint: endpoint,
      method: 'POST',
      body: body,
    );
  }

  // PUT request helper
  Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> body) async {
    return _request(
      endpoint: endpoint,
      method: 'PUT',
      body: body,
    );
  }

  // DELETE request helper
  Future<Map<String, dynamic>> delete(String endpoint) async {
    return _request(
      endpoint: endpoint,
      method: 'DELETE',
    );
  }

  // PATCH request helper
  Future<Map<String, dynamic>> patch(
      String endpoint, Map<String, dynamic> body) async {
    return _request(
      endpoint: endpoint,
      method: 'PATCH',
      body: body,
    );
  }

  // API methods for habits
  Future<List<Habit>> getHabits() async {
    final response = await get('habits');

    if (response.containsKey('data') && response['data'] is List) {
      return (response['data'] as List)
          .map((item) => Habit.fromJson(item))
          .toList();
    }

    return [];
  }

  Future<Habit?> getHabit(int id) async {
    try {
      final response = await get('habits/$id');
      return Habit.fromJson(response);
    } catch (e) {
      print('Error getting habit: $e');
      return null;
    }
  }

  Future<Habit?> createHabit(Habit habit) async {
    try {
      final response = await post('habits', habit.toJson());
      return Habit.fromJson(response);
    } catch (e) {
      print('Error creating habit: $e');
      return null;
    }
  }

  Future<Habit?> updateHabit(Habit habit) async {
    try {
      final response = await put('habits/${habit.id}', habit.toJson());
      return Habit.fromJson(response);
    } catch (e) {
      print('Error updating habit: $e');
      return null;
    }
  }

  Future<bool> deleteHabit(int id) async {
    try {
      await delete('habits/$id');
      return true;
    } catch (e) {
      print('Error deleting habit: $e');
      return false;
    }
  }

  // API methods for habit logs
  Future<List<HabitLog>> getHabitLogs(int habitId) async {
    try {
      final response = await get('habits/$habitId/logs');

      if (response.containsKey('data') && response['data'] is List) {
        return (response['data'] as List)
            .map((item) => HabitLog.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error getting habit logs: $e');
      return [];
    }
  }

  Future<HabitLog?> createHabitLog(HabitLog log) async {
    try {
      final response = await post('habits/${log.habitId}/logs', log.toJson());
      return HabitLog.fromJson(response);
    } catch (e) {
      print('Error creating habit log: $e');
      return null;
    }
  }

  Future<HabitLog?> updateHabitLog(HabitLog log) async {
    try {
      final response =
          await put('habits/${log.habitId}/logs/${log.id}', log.toJson());
      return HabitLog.fromJson(response);
    } catch (e) {
      print('Error updating habit log: $e');
      return null;
    }
  }

  // API methods for rewards
  Future<List<Reward>> getRewards() async {
    try {
      final response = await get('rewards');

      if (response.containsKey('data') && response['data'] is List) {
        return (response['data'] as List)
            .map((item) => Reward.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error getting rewards: $e');
      return [];
    }
  }

  Future<Reward?> createReward(Reward reward) async {
    try {
      final response = await post('rewards', reward.toJson());
      return Reward.fromJson(response);
    } catch (e) {
      print('Error creating reward: $e');
      return null;
    }
  }

  Future<Reward?> updateReward(Reward reward) async {
    try {
      final response = await put('rewards/${reward.id}', reward.toJson());
      return Reward.fromJson(response);
    } catch (e) {
      print('Error updating reward: $e');
      return null;
    }
  }

  Future<bool> deleteReward(int id) async {
    try {
      await delete('rewards/$id');
      return true;
    } catch (e) {
      print('Error deleting reward: $e');
      return false;
    }
  }

  Future<Reward?> redeemReward(int id) async {
    try {
      final response = await post('rewards/$id/redeem', {});
      return Reward.fromJson(response);
    } catch (e) {
      print('Error redeeming reward: $e');
      return null;
    }
  }

  // API methods for stats
  Future<UserStats> getUserStats() async {
    try {
      final response = await get('stats');
      return UserStats.fromJson(response);
    } catch (e) {
      print('Error getting user stats: $e');
      // Return default stats on error
      return UserStats(
        points: 0,
        totalHabits: 0,
        habitStats: [],
      );
    }
  }

  Future<HabitStats?> getHabitStats(int habitId) async {
    try {
      final response = await get('habits/$habitId/stats');
      return HabitStats.fromJson(response);
    } catch (e) {
      print('Error getting habit stats: $e');
      return null;
    }
  }
}
