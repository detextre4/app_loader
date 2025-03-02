import 'package:app_loader/app_loader.dart';
import 'package:flutter/material.dart';

class AppLoaderWrapper extends StatelessWidget {
  const AppLoaderWrapper({
    super.key,
    required this.child,
    this.loaderOptions,
    this.openCondition,
    this.closeCondition,
  });

  /// Child to be wrapped by the [AppLoaderWrapper]
  final Widget child;

  /// Options used to render de loader widget.
  final LoaderOptions? loaderOptions;

  /// Condition for opening the loader.
  final bool Function()? openCondition;

  /// Condition for closing the loader.
  final bool Function()? closeCondition;

  @override
  Widget build(BuildContext context) => child;
}
