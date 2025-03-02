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

## 1.1.1

* Fix `null_check_operator_used_on_null_value` error

## 1.2.0

* Added new widget [AppLoaderWrapper]

## 1.2.1

* Fix [AppLoaderWrapper] export

## 1.3.0+stable

* Created [LoaderOptions] class to setup the rendering loader widget.
