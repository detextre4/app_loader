import 'dart:async';

import 'package:app_loader/app_loader.dart';
import 'package:app_loader/src/loader_wrapper.dart';
import 'package:app_loader/src/utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Global loader used for asynchronous processes.
/// If it should be used on initState, need to call with
/// [SchedulerBinding.instance.addPostFrameCallback] method.
class AppLoader {
  AppLoader(
    this.context, {
    this.child,
    this.openCondition,
    this.closeCondition,
  }) : defaultAppLoaderConfig = Utils.defaultAppLoaderConfig(context);

  /// The BuildContext of the widget where the loader will be displayed.
  final BuildContext context;

  /// Default AppLoader configuration.
  final AppLoaderWrapper? defaultAppLoaderConfig;

  /// The child widget to display inside the loader.
  final Widget? child;
  Widget? get _child => child ?? defaultAppLoaderConfig?.defaultLoader;

  /// Condition for opening the loader.
  final bool Function()? openCondition;
  bool Function()? get _openCondition =>
      openCondition ?? defaultAppLoaderConfig?.openCondition;

  /// Condition for closing the loader.
  final bool Function()? closeCondition;
  bool Function()? get _closeCondition =>
      closeCondition ?? defaultAppLoaderConfig?.closeCondition;

  BuildContext? loaderContext;
  var cancelToken = CancelToken();

  /// ValueNotifier to control the loading state.
  final controller = ValueNotifier<bool>(false);

  /// Returns the current loading state.
  bool get loading => controller.value;

  /// Indicates whether the loader has been disposed.
  bool disposed = false;

  /// Disposes the loader and cleans up resources.
  void dispose() {
    disposed = true;
    if (!loading) return;

    Navigator.pop(context);
    controller.value = false;
    controller.dispose();
  }

  /// Stops the loader. If [cancelCurrentToken] is true, cancels the current token.
  void stop({bool cancelCurrentToken = false}) {
    if (disposed || !loading) return;

    if (cancelCurrentToken) cancelToken.cancel();

    controller.value = false;
  }

  /// Closes the loader. Optionally returns a value and cancels the current token.
  void close<T>({T? value, bool cancelCurrentToken = false}) {
    if (disposed ||
        !loading ||
        (_closeCondition != null && !_closeCondition!())) {
      return;
    }

    if (cancelCurrentToken) cancelToken.cancel();

    if (Navigator.canPop(loaderContext!)) {
      Navigator.pop<T>(loaderContext!, value);
    }

    controller.value = false;
    loaderContext = null;
  }

  /// Starts the loader and optionally executes an asynchronous function [future].
  Future<T?> start<T>({Future<T> Function()? future}) async {
    if (disposed || loading) return null;
    controller.value = true;
    cancelToken = CancelToken();

    if (future != null) {
      return await future().whenComplete(() => controller.value = false);
    }

    return null;
  }

  /// Opens the loader with a custom [message]. Optionally executes an asynchronous function [future].
  Future<T?> open<T>({
    String message = "Processing...",
    Future<T> Function(CancelToken cancelToken)? future,
    void Function(CancelToken cancelToken)? onUserWillPop,
    CancelToken? customCancelToken,
  }) async {
    if (disposed || loading || (_openCondition != null && !_openCondition!())) {
      return null;
    }

    controller.value = true;
    cancelToken = CancelToken();
    final loaderContextSet = Completer<void>();

    if (!disposed && loading) {
      showDialog(
          context: context,
          builder: (context) {
            if (loading) loaderContext ??= context;

            if (!loaderContextSet.isCompleted) loaderContextSet.complete();

            return WillPopCustom(
              onWillPop: () async {
                if (onUserWillPop != null) {
                  close(cancelCurrentToken: true);
                  customCancelToken?.cancel();
                  onUserWillPop(customCancelToken ?? cancelToken);
                }
                return false;
              },
              child: _child ?? _AppLoader<T>(message: message),
            );
          });
    }

    if (future != null) {
      try {
        final value = await future(customCancelToken ?? cancelToken);
        await loaderContextSet.future;

        close(value: value);
        return value;
      } catch (error) {
        close();
        rethrow;
      }
    }

    return null;
  }
}

/// A widget representing the loader UI.
class _AppLoader<T> extends StatelessWidget {
  const _AppLoader({required this.message})
      : super(key: const Key('loader_widget'));

  /// The message to display inside the loader.
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  strokeWidth: 8,
                  color: theme.colorScheme.secondary,
                  backgroundColor: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: theme.primaryTextTheme.titleLarge,
              ),
            ],
          ),
        ));
  }
}
