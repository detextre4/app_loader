# app_loader

`app_loader` is a Flutter package that provides customizable loading widgets for your Flutter applications. This package includes `AppLoader` and `MaterialLoader` widgets to handle asynchronous processes with ease.

## Features

- Display a global loader for asynchronous processes.
- Show a splash page while loading data.
- Easily manage the loader state with simple methods.

## Getting Started

Add `app_loader` to your `pubspec.yaml` file:

```yaml
dependencies:
  app_loader: ^1.1.1
```

Then run flutter pub get to install the package.

## Usage

### AppLoader

The AppLoader widget is used to display a global loader for asynchronous processes.

### Example: Basic usage to handle a counter

```dart
import 'package:flutter/material.dart';
import 'package:app_loader/app_loader.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final loader = AppLoader(context);

  Future<void> onPressed() async {
    loader.open();
    await Future.delayed(const Duration(seconds: 2)); // Simulates a process
    loader.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Loading: ${loader.loading}'),
            ElevatedButton(
              onPressed: onPressed,
              child: Text('Start loader'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### MaterialLoader

The MaterialLoader widget is used to display a splash page while loading data and then transition to a MaterialApp.

### Example: Display a splash page while loading data

```dart
import 'package:flutter/material.dart';
import 'package:app_loader/app_loader.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialLoader(
      onFetchData: onFetchData,
      onNextMaterial: onNextMaterial,
      splashPage: (animationController, getData, haveError) {
        return Scaffold(
          body: Center(child: Text('Splash Page')),
        );
      },
      materialApp: MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Home Page')),
        ),
      ),
    );
  }

  Future<void> onFetchData({
    required AppLoader loader,
    required ValueNotifier<MaterialLoaderStatus> fetchStatus,
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate data fetch
    fetchStatus.value = MaterialLoaderStatus.done;
  }

  Future<void> onNextMaterial(VoidCallback handleNextMaterial) async {
    handleNextMaterial();
  }
}
```

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request on [GitHub](https://github.com/detextre4/app_loader).

## License

This project is licensed under the MIT License - see the LICENSE file for details.
