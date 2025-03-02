import 'package:flutter/material.dart';

class AppLoaderWrapper extends StatelessWidget {
  const AppLoaderWrapper({
    super.key,
    required this.child,
    this.defaultLoader,
    this.openCondition,
    this.closeCondition,
  });

  /// child to be wrapped by the [AppLoaderWrapper]
  final Widget child;

  /// The child widget to display inside the loader.
  final Widget? defaultLoader;

  /// Condition for opening the loader.
  final bool Function()? openCondition;

  /// Condition for closing the loader.
  final bool Function()? closeCondition;

  @override
  Widget build(BuildContext context) => child;
}
