import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/permission_handler.dart';
import '../utils/constants.dart';
import 'permission_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _logoAnimation;
  late Animation<double> _formAnimation;
  
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _showPassword = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _logoAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    
    _formAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );
    
    _animationController.forward();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();
      
      // Fake authentication
      if (username == Constants.fakeUsername && 
          password == Constants.fakePassword) {
        setState(() {
          _isLoading = true;
          _errorMessage = '';
        });
        
        // Simulate authentication process
        await Future.delayed(const Duration(seconds: 2));
        
        // Request permissions
        final allGranted = await PermissionHandler.requestAllPermissions();
        
        if (allGranted) {
          // Navigate to permission screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PermissionScreen(),
            ),
          );
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'All permissions are required for security scan';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid credentials. Try: admin / secure123';
        });
        
        // Haptic feedback
        HapticFeedback.heavyImpact();
      }
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo and Title
                AnimatedBuilder(
                  animation: _logoAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - _logoAnimation.value)),
                      child: Opacity(
                        opacity: _logoAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/shield.svg',
                        height: 120,
                        color: Constants.primaryColor,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'SYSTEM SECURITY SCANNER',
                        style: TextStyle(
                          fontFamily: 'ShareTechMono',
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Advanced Threat Detection & Protection',
                        style: TextStyle(
                          fontFamily: 'ShareTechMono',
                          fontSize: 14,
                          color: Constants.subtitleColor,
                          letterSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Login Form
                AnimatedBuilder(
                  animation: _formAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - _formAnimation.value)),
                      child: Opacity(
                        opacity: _formAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Error Message
                        if (_errorMessage.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Constants.dangerColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Constants.dangerColor,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.warning,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage,
                                    style: const TextStyle(
                                      fontFamily: 'ShareTechMono',
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // Username Field
                        TextFormField(
                          controller: _usernameController,
                          style: const TextStyle(
                            fontFamily: 'ShareTechMono',
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'USERNAME',
                            prefixIcon: Icon(
                              Icons.person,
                              color: Color(0xFF8A8DAA),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Username is required';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_showPassword,
                          style: const TextStyle(
                            fontFamily: 'ShareTechMono',
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            labelText: 'PASSWORD',
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Color(0xFF8A8DAA),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xFF8A8DAA),
                              ),
                              onPressed: () {
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Login Button
                        AnimatedContainer(
                          duration: Constants.animationDuration,
                          curve: Constants.animationCurve,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Constants.primaryColor,
                                Constants.secondaryColor,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Constants.primaryColor.withOpacity(0.4),
                                blurRadius: 10,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: _isLoading ? null : _handleLogin,
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Button Text
                                  AnimatedOpacity(
                                    duration: Constants.animationDuration,
                                    opacity: _isLoading ? 0 : 1,
                                    child: const Text(
                                      'SECURE LOGIN',
                                      style: TextStyle(
                                        fontFamily: 'ShareTechMono',
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                  
                                  // Loading Indicator
                                  if (_isLoading)
                                    const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Features List
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SECURITY FEATURES:',
                              style: TextStyle(
                                fontFamily: 'ShareTechMono',
                                fontSize: 12,
                                color: Constants.subtitleColor,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...Constants.securityFeatures.map((feature) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Constants.successColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      feature,
                                      style: const TextStyle(
                                        fontFamily: 'ShareTechMono',
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Footer
                        Text(
                          'v1.0.0 • Enterprise Security Solution',
                          style: TextStyle(
                            fontFamily: 'ShareTechMono',
                            fontSize: 10,
                            color: Constants.subtitleColor.withOpacity(0.6),
                            letterSpacing: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
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
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}