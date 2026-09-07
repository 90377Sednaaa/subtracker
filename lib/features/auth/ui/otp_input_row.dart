import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:subtracker/core/theme.dart';

/// A modern 6-box OTP / PIN input widget:
/// - 6 individual digit boxes with active focus highlight.
/// - Auto-advances focus upon typing a digit.
/// - Handles backspace navigation backwards.
/// - Automatically distributes pasted 6-digit codes across all boxes.
/// - Fires [onCompleted] when all 6 boxes are filled.
class OtpInputRow extends StatefulWidget {
  const OtpInputRow({
    super.key,
    required this.onCompleted,
    this.onChanged,
    this.boxCount = 6,
    this.boxSize = const Size(46, 56),
  });

  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final int boxCount;
  final Size boxSize;

  @override
  State<OtpInputRow> createState() => OtpInputRowState();
}

class OtpInputRowState extends State<OtpInputRow> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.boxCount,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.boxCount,
      (i) => FocusNode(onKeyEvent: (node, event) => _handleKeyEvent(i, event)),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _controllers[index - 1].clear();
        _focusNodes[index - 1].requestFocus();
        _notifyChange();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _onTextChanged(int index, String value) {
    if (value.isEmpty) {
      _notifyChange();
      return;
    }

    // Handle multi-character paste (e.g., user pastes "482915")
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 1) {
      for (var i = 0; i < widget.boxCount; i++) {
        if (i < digits.length) {
          _controllers[i].text = digits[i];
        }
      }
      final nextIndex = digits.length < widget.boxCount
          ? digits.length
          : widget.boxCount - 1;
      _focusNodes[nextIndex].requestFocus();
      _notifyChange();
      return;
    }

    // Single digit input
    final char = digits.isNotEmpty ? digits[0] : '';
    _controllers[index].value = TextEditingValue(
      text: char,
      selection: TextSelection.collapsed(offset: char.length),
    );

    if (char.isNotEmpty && index < widget.boxCount - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    _notifyChange();
  }

  void _notifyChange() {
    final code = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(code);
    if (code.length == widget.boxCount) {
      widget.onCompleted(code);
    }
  }

  /// Clears all boxes and resets focus to the first box.
  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    if (_focusNodes.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }
    _notifyChange();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sublyColors;

    return Center(
      child: Wrap(
        spacing: SublySpace.s8,
        runSpacing: SublySpace.s8,
        alignment: WrapAlignment.center,
        children: List.generate(widget.boxCount, (i) {
          return ListenableBuilder(
            listenable: _focusNodes[i],
            builder: (context, _) {
              final isFocused = _focusNodes[i].hasFocus;
              final hasContent = _controllers[i].text.isNotEmpty;

              return AnimatedContainer(
                duration: SublyMotion.durQuick,
                curve: SublyMotion.curveStandard,
                width: widget.boxSize.width,
                height: widget.boxSize.height,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isFocused ? colors.step2 : colors.step1,
                  borderRadius: BorderRadius.circular(SublySpace.radiusField - 4),
                  border: Border.all(
                    color: isFocused
                        ? colors.inkPrimary
                        : (hasContent
                            ? colors.inkSecondary.withValues(alpha: 0.5)
                            : colors.hairline),
                    width: isFocused ? 1.5 : 1.0,
                  ),
                  boxShadow: isFocused
                      ? [
                          BoxShadow(
                            color: colors.inkPrimary.withValues(alpha: 0.08),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: TextField(
                  key: Key('otp-box-$i'),
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6, // allows paste in any box
                  cursorColor: colors.inkPrimary,
                  style: SublyTypography.titleL.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: colors.inkPrimary,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (val) => _onTextChanged(i, val),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
