## 1.0.0

* Initial release.
* Added package initialization and initial configuration settings.

## 1.0.1

* Changed `materialColor` property from [MaterialLoader] to type [Color Function(BuildContext context)]

## 1.1.0

* Changed `onFetchData` method properties type to [Future<void> Function(
    BuildContext context, {
    required AppLoader loader,
    required ValueNotifier<MaterialLoaderStatus> fetchStatus,
  })]
