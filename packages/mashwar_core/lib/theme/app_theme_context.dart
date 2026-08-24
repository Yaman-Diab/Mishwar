import 'package:flutter/material.dart';

import 'app_semantic_colors.dart';

extension AppThemeContext on BuildContext {
  AppSemanticColors get colors => Theme.of(this).extension<AppSemanticColors>()!;
}
