import 'package:app_loader/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Enum representing the status of the MaterialLoader.
enum MaterialLoaderStatus {
  fetching,
  error,
  done;
}

/// A widget that sets up an environment to display a splash page
/// while loading data and then returns the MaterialApp to be rendered.
class MaterialLoader extends StatefulWidget {
  const MaterialLoader({
    super.key,
    required this.materialApp,
    this.materialColor,
    this.animationDuration = const Duration(milliseconds: 1500),
    required this.onFetchData,
    required this.onNextMaterial,
    required this.splashPage,
  });

  /// The MaterialApp to be rendered after data loading is complete.
  final MaterialApp materialApp;

  /// The color of the material.
  final Color Function(BuildContext context)? materialColor;

  /// Duration of the splash screen animation.
  final Duration animationDuration;

  /// Function to fetch data.
  /// Receives [loader], [fetchStatus], and [navigatorKey] as parameters.
  final Future<void> Function(
    BuildContext context, {
    required AppLoader loader,
    required ValueNotifier<MaterialLoaderStatus> fetchStatus,
  }) onFetchData;

  /// Function to handle the transition to the next material after data loading.
  /// Receives [handleNextMaterial] as a parameter.
  final Future<void> Function(VoidCallback handleNextMaterial) onNextMaterial;

  /// Builder function for the splash page.
  /// Receives [animationController], [onFetchData], and [haveError] as parameters.
  final Widget Function(
    AnimationController animationController,
    Future<void> Function() onFetchData,
    bool haveError,
  ) splashPage;

  @override
  State<MaterialLoader> createState() => _MaterialLoaderState();
}

class _MaterialLoaderState extends State<MaterialLoader>
    with SingleTickerProviderStateMixin {
  final navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'MaterialLoaderNavigatorKey');

  final fetchStatus = ValueNotifier(MaterialLoaderStatus.fetching);

  late final AppLoader loader;

  late final animationController = AnimationController(
    lowerBound: 0.0,
    upperBound: 1.0,
    vsync: this,
    duration: widget.animationDuration,
  );

  /// Callback to handle the completion of the splash animation.
  void onFinishAnimation(_) {
    if (!mounted) return;

    if (fetchStatus.value == MaterialLoaderStatus.fetching) loader.open();
    onListenStatusNotifier();
  }

  /// Updates the widget state.
  void updateState(void Function() fn) {
    if (!loader.disposed) setState(fn);
  }

  /// Callback to handle the transition to the next material.
  void handleNextMaterial() => updateState(loader.dispose);

  /// Listener for the fetch status notifier.
  void onListenStatusNotifier() {
    updateState(() {});

    if (!animationController.isCompleted ||
        fetchStatus.value != MaterialLoaderStatus.done ||
        !mounted) {
      return;
    }

    widget.onNextMaterial(handleNextMaterial);
  }

  /// Function to fetch data by calling [widget.onFetchData].
  Future<void> onFetchData() async => await widget.onFetchData(
        navigatorKey.currentContext!,
        fetchStatus: fetchStatus,
        loader: loader,
      );

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      loader = AppLoader(
        navigatorKey.currentContext!,
        openCondition: () => animationController.isCompleted,
      )..controller.addListener(() => updateState(() {}));

      fetchStatus.addListener(onListenStatusNotifier);
      animationController.forward().then(onFinishAnimation);
      onFetchData();
    });
    super.initState();
  }

  @override
  void dispose() {
    fetchStatus.dispose();
    loader.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shouldShowCurrentMaterial =
        fetchStatus.value == MaterialLoaderStatus.done && loader.disposed;

    // Render the original MaterialApp
    if (shouldShowCurrentMaterial) {
      return Material(
        color: widget.materialColor != null
            ? widget.materialColor!(navigatorKey.currentContext!)
            : Theme.of(context).colorScheme.tertiary,
        child: widget.materialApp,
      );
    }

    // Render the splash page MaterialApp
    return MaterialApp(
      debugShowCheckedModeBanner: widget.materialApp.debugShowCheckedModeBanner,
      title: widget.materialApp.title,
      theme: widget.materialApp.theme,
      darkTheme: widget.materialApp.darkTheme,
      themeMode: widget.materialApp.themeMode,
      navigatorKey: navigatorKey,
      home: widget.splashPage(
        animationController,
        onFetchData,
        fetchStatus.value == MaterialLoaderStatus.error && !loader.loading,
      ),
    );
  }
}
