import 'dart:async';

import 'package:app_loader/app_loader.dart';
import 'package:app_loader/src/utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Options used to render de loader widget.
class LoaderOptions {
  const LoaderOptions({
    this.builder,
    this.textStyle,
    this.colors,
  });

  /// TextStyle of the rendered loader text.
  final TextStyle Function(BuildContext context)? textStyle;

  /// Colors of the rendered loader widget.
  final (Color color, Color backgroundColor) Function(BuildContext context)?
      colors;

  /// The child widget to display inside the loader.
  final Widget Function(
    BuildContext context,
    String message,
    (Color color, Color backgroundColor)? colors,
    TextStyle? textStyle,
  )? builder;

  LoaderOptions copyWith({
    TextStyle Function(BuildContext context)? textStyle,
    (Color color, Color backgroundColor) Function(BuildContext context)? colors,
    Widget Function(
      BuildContext context,
      String message,
      (Color color, Color backgroundColor)? colors,
      TextStyle? textStyle,
    )? builder,
  }) =>
      LoaderOptions(
        builder: builder ?? this.builder,
        textStyle: textStyle ?? this.textStyle,
        colors: colors ?? this.colors,
      );
}

/// Global loader used for asynchronous processes.
/// If it should be used on initState, need to call with
/// [SchedulerBinding.instance.addPostFrameCallback] method.
class AppLoader {
  AppLoader(
    this.context, {
    LoaderOptions? loaderOptions,
    bool Function()? openCondition,
    bool Function()? closeCondition,
  }) {
    final defaultAppLoaderConfig = Utils.defaultAppLoaderConfig(context);

    this.loaderOptions = loaderOptions?.copyWith(
            builder: loaderOptions.builder) ??
        defaultAppLoaderConfig?.loaderOptions
            ?.copyWith(builder: defaultAppLoaderConfig.loaderOptions?.builder);

    this.loaderOptions = loaderOptions?.copyWith(
            colors: loaderOptions.colors) ??
        defaultAppLoaderConfig?.loaderOptions
            ?.copyWith(colors: defaultAppLoaderConfig.loaderOptions?.colors);

    this.loaderOptions =
        loaderOptions?.copyWith(textStyle: loaderOptions.textStyle) ??
            defaultAppLoaderConfig?.loaderOptions?.copyWith(
                textStyle: defaultAppLoaderConfig.loaderOptions?.textStyle);

    this.openCondition = openCondition ?? defaultAppLoaderConfig?.openCondition;
    this.closeCondition =
        closeCondition ?? defaultAppLoaderConfig?.closeCondition;
  }

  /// The BuildContext of the widget where the loader will be displayed.
  final BuildContext context;

  /// Options used to render de loader widget.
  LoaderOptions? loaderOptions;

  /// Condition for opening the loader.
  bool Function()? openCondition;

  /// Condition for closing the loader.
  bool Function()? closeCondition;

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
        (closeCondition != null && !closeCondition!())) {
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
    if (disposed || loading || (openCondition != null && !openCondition!())) {
      return null;
    }

    controller.value = true;
    cancelToken = CancelToken();
    final loaderContextSet = Completer<void>();

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
            child: loaderOptions?.builder != null
                ? loaderOptions!.builder!(
                    context,
                    message,
                    loaderOptions?.colors != null
                        ? loaderOptions!.colors!(context)
                        : null,
                    loaderOptions?.textStyle != null
                        ? loaderOptions!.textStyle!(context)
                        : null,
                  )
                : _AppLoader<T>(
                    message: message,
                    textStyle: loaderOptions?.textStyle,
                    colors: loaderOptions?.colors,
                  ),
          );
        });

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
  const _AppLoader({
    required this.message,
    this.textStyle,
    this.colors,
  }) : super(key: const Key('loader_widget'));

  /// The message to display inside the loader.
  final String message;

  /// TextStyle of the rendered loader text.
  final TextStyle Function(BuildContext context)? textStyle;

  /// Colors of the rendered loader widget.
  final (Color color, Color backgroundColor) Function(BuildContext context)?
      colors;

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
                    color: colors != null
                        ? colors!(context).$1
                        : theme.colorScheme.secondary,
                    backgroundColor: colors != null
                        ? colors!(context).$2
                        : theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: textStyle != null
                      ? textStyle!(context)
                      : theme.primaryTextTheme.titleLarge,
                ),
              ]),
        ));
  }
}
