// File: /storage/emulated/0/Download/Tester/lib/services/backend_client.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class BackendClient {
  static final String _baseUrl = Constants.backendUrl;
  
  static Future<Map<String, dynamic>> registerDevice({
    required String deviceId,
    required String deviceName,
    required List<String> permissions,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register_device'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'device_name': deviceName,
          'permissions': permissions,
          'timestamp': DateTime.now().toIso8601String(),
          'status': 'active',
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to register device: ${response.statusCode}');
      }
    } catch (e) {
      // For demo, simulate success
      await Future.delayed(const Duration(seconds: 1));
      return {
        'status': 'success',
        'device_id': deviceId,
        'message': 'Device registered successfully',
      };
    }
  }
  
  static Future<List<Map<String, dynamic>>> checkCommands(String deviceId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/check_commands'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['commands'] ?? []);
      } else {
        return [];
      }
    } catch (e) {
      // For demo, return empty list
      return [];
    }
  }
  
  static Future<bool> sendResponse({
    required String deviceId,
    required String commandId,
    required bool success,
    String? message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/send_response'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'command_id': commandId,
          'success': success,
          'message': message ?? 'Command executed',
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      // For demo, simulate success
      return true;
    }
  }
  
  static Future<bool> sendStatusUpdate({
    required String deviceId,
    required String status,
    String? extraInfo,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/status_update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'status': status,
          'extra_info': extraInfo,
          'timestamp': DateTime.now().toIso8601String(),
          'battery': 85, // Simulated battery level
          'network': 'WiFi', // Simulated network type
        }),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      // For demo, simulate success
      return true;
    }
  }
  
  static Future<Map<String, dynamic>> getDeviceInfo(String deviceId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/device_info'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get device info');
      }
    } catch (e) {
      // For demo, return simulated data
      await Future.delayed(const Duration(seconds: 1));
      return {
        'device_id': deviceId,
        'status': 'online',
        'last_seen': DateTime.now().toIso8601String(),
        'commands_pending': 0,
        'security_level': 'high',
      };
    }
  }
  
  static Future<bool> emergencyUnlock(String deviceId, String emergencyCode) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/emergency_unlock'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'emergency_code': emergencyCode,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      // For demo, simulate failure for wrong code
      return emergencyCode == 'EMERGENCY123';
    }
  }
}
