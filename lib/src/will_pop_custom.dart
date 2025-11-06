import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A widget that handles the willPop action triggered by the user.
class WillPopCustom extends StatelessWidget {
  const WillPopCustom({
    super.key,
    required this.child,
    this.onWillPop,
    this.enabled = true,
  });

  /// The child widget to display inside the WillPopCustom.
  final Widget child;

  /// Callback function to execute when the willPop action is triggered.
  final FutureOr<bool> Function()? onWillPop;

  /// Enables or disables the willPop action.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    // * Web
    if (kIsWeb || !enabled) return child;

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (onWillPop != null) return await onWillPop!();
        return true;
      },
      child: child,
    );
  }
}
