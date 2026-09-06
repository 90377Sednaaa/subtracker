import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ALL visual design decisions live here for the MVP phase. The design phase
/// (docs/superpowers/plans/2026-09-06-subly-design.md) rewrites this file and
/// screen composition only — never logic or data layers.
final appThemeProvider = Provider<ThemeData>((ref) => ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.indigo,
    ));
