import 'package:app_loader/src/loader_wrapper.dart';
import 'package:flutter/material.dart';

class Utils {
  /// Retrieves the nearest ancestor [AppLoaderWrapper] widget from the context.
  ///
  /// @param context The build context to search for the ancestor.
  /// @return The nearest ancestor [AppLoaderWrapper] widget.
  static AppLoaderWrapper? defaultAppLoaderConfig(BuildContext context) =>
      context.findAncestorWidgetOfExactType<AppLoaderWrapper>();
}
