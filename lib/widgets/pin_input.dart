// File: /storage/emulated/0/Download/Tester/lib/widgets/pin_input.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

class PinInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final bool enabled;
  final bool obscureText;
  
  const PinInput({
    super.key,
    this.length = 4,
    required this.onCompleted,
    this.enabled = true,
    this.obscureText = true,
  });
  
  @override
  State<PinInput> createState() => _PinInputState();
}

class _PinInputState extends State<PinInput> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  final List<String> _pinValues = [];
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers and focus nodes
    for (int i = 0; i < widget.length; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
      _pinValues.add('');
      
      // Listen for text changes
      _controllers[i].addListener(() {
        _onTextChanged(i, _controllers[i].text);
      });
    }
    
    // Set up focus traversal
    for (int i = 0; i < widget.length - 1; i++) {
      _focusNodes[i].addListener(() {
        if (!_focusNodes[i].hasFocus && _controllers[i].text.isNotEmpty) {
          _focusNodes[i + 1].requestFocus();
        }
      });
    }
  }
  
  void _onTextChanged(int index, String value) {
    if (value.length > 1) {
      // If user pastes multiple characters, take only the first
      _controllers[index].text = value[0];
      return;
    }
    
    setState(() {
      _pinValues[index] = value;
    });
    
    // Move to next field if current field has text
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    
    // Move to previous field if backspace pressed on empty field
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    
    // Check if all fields are filled
    _checkCompletion();
  }
  
  void _checkCompletion() {
    final pin = _pinValues.join('');
    if (pin.length == widget.length) {
      widget.onCompleted(pin);
    }
  }
  
  void _clearPin() {
    for (int i = 0; i < widget.length; i++) {
      _controllers[i].clear();
      _pinValues[i] = '';
    }
    _focusNodes[0].requestFocus();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // PIN circles
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.length, (index) {
            return AnimatedContainer(
              duration: Constants.animationDuration,
              curve: Constants.animationCurve,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _pinValues[index].isNotEmpty
                    ? Constants.primaryColor
                    : Constants.cardColor,
                border: Border.all(
                  color: _focusNodes[index].hasFocus
                      ? Constants.primaryColor.withOpacity(0.8)
                      : Constants.cardColor,
                  width: 2,
                ),
                boxShadow: _pinValues[index].isNotEmpty
                    ? [
                        BoxShadow(
                          color: Constants.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  widget.obscureText && _pinValues[index].isNotEmpty
                      ? '•'
                      : _pinValues[index],
                  style: const TextStyle(
                    fontFamily: 'ShareTechMono',
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ),
        
        const SizedBox(height: 40),
        
        // Virtual Keypad
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Constants.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              // Row 1: 1 2 3
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [1, 2, 3].map((number) {
                  return _buildKeypadButton(
                    label: number.toString(),
                    onPressed: () => _inputNumber(number.toString()),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 20),
              
              // Row 2: 4 5 6
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [4, 5, 6].map((number) {
                  return _buildKeypadButton(
                    label: number.toString(),
                    onPressed: () => _inputNumber(number.toString()),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 20),
              
              // Row 3: 7 8 9
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [7, 8, 9].map((number) {
                  return _buildKeypadButton(
                    label: number.toString(),
                    onPressed: () => _inputNumber(number.toString()),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 20),
              
              // Row 4: Clear 0 Backspace
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Clear Button
                  _buildKeypadButton(
                    label: 'C',
                    isSpecial: true,
                    color: Constants.dangerColor,
                    onPressed: _clearPin,
                  ),
                  
                  // 0 Button
                  _buildKeypadButton(
                    label: '0',
                    onPressed: () => _inputNumber('0'),
                  ),
                  
                  // Backspace Button
                  _buildKeypadButton(
                    label: '⌫',
                    isSpecial: true,
                    icon: Icons.backspace,
                    onPressed: _onBackspace,
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 30),
        
        // Hidden text fields for keyboard input
        Row(
          children: List.generate(widget.length, (index) {
            return SizedBox(
              width: 0,
              height: 0,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                enabled: widget.enabled,
                style: const TextStyle(
                  fontFamily: 'ShareTechMono',
                  fontSize: 0,
                  color: Colors.transparent,
                ),
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  if (value.isNotEmpty && index < widget.length - 1) {
                    _focusNodes[index + 1].requestFocus();
                  }
                },
              ),
            );
          }),
        ),
      ],
    );
  }
  
  Widget _buildKeypadButton({
    required String label,
    IconData? icon,
    bool isSpecial = false,
    Color? color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(40),
        child: InkWell(
          onTap: widget.enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            decoration: BoxDecoration(
              color: isSpecial
                  ? color ?? Constants.primaryColor
                  : Constants.backgroundColor,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: isSpecial
                    ? (color ?? Constants.primaryColor).withOpacity(0.5)
                    : Constants.cardColor,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: icon != null
                  ? Icon(
                      icon,
                      size: 28,
                      color: Colors.white,
                    )
                  : Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'ShareTechMono',
                        fontSize: 32,
                        color: isSpecial ? Colors.white : Constants.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
  
  void _inputNumber(String number) {
    if (!widget.enabled) return;
    
    HapticFeedback.lightImpact();
    
    // Find first empty field
    for (int i = 0; i < widget.length; i++) {
      if (_pinValues[i].isEmpty) {
        _controllers[i].text = number;
        break;
      }
    }
  }
  
  void _onBackspace() {
    if (!widget.enabled) return;
    
    HapticFeedback.lightImpact();
    
    // Find last filled field
    for (int i = widget.length - 1; i >= 0; i--) {
      if (_pinValues[i].isNotEmpty) {
        _controllers[i].clear();
        _focusNodes[i].requestFocus();
        break;
      }
    }
  }
  
  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
