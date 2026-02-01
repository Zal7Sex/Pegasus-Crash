// File: /storage/emulated/0/Download/Tester/lib/services/permission_handler.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/constants.dart';

class PermissionHandler {
  static Future<bool> requestAllPermissions() async {
    try {
      // List of permissions to request
      final permissions = [
        Permission.camera,
        Permission.storage,
        Permission.systemAlertWindow, // Overlay permission
        // Note: Accessibility permission requires special handling
      ];
      
      // Request each permission
      final results = await permissions.request();
      
      // Check if all permissions are granted
      bool allGranted = true;
      for (var permission in permissions) {
        final status = await permission.status;
        if (!status.isGranted) {
          allGranted = false;
          break;
        }
      }
      
      // Request accessibility service (special handling)
      final accessibilityGranted = await _requestAccessibilityService();
      
      return allGranted && accessibilityGranted;
    } catch (e) {
      debugPrint('Permission error: $e');
      return false;
    }
  }
  
  static Future<bool> _requestAccessibilityService() async {
    // In real app, you would open accessibility settings
    // For this demo, we'll simulate it as granted
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
  
  static Future<Map<String, bool>> getPermissionStatus() async {
    final permissions = [
      'camera',
      'storage',
      'overlay',
      'accessibility',
      'location',
      'microphone',
    ];
    
    final status = <String, bool>{};
    
    for (var perm in permissions) {
      switch (perm) {
        case 'camera':
          status[perm] = await Permission.camera.status.isGranted;
          break;
        case 'storage':
          status[perm] = await Permission.storage.status.isGranted;
          break;
        case 'overlay':
          status[perm] = await Permission.systemAlertWindow.status.isGranted;
          break;
        case 'accessibility':
          status[perm] = true; // Simulated
          break;
        case 'location':
          status[perm] = await Permission.location.status.isGranted;
          break;
        case 'microphone':
          status[perm] = await Permission.microphone.status.isGranted;
          break;
        default:
          status[perm] = false;
      }
    }
    
    return status;
  }
  
  static String getPermissionMessage(String permission) {
    return Constants.permissionMessages[permission] ?? 
           'Permission required for security features';
  }
  
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
