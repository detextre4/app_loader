import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:app_loader/app_loader.dart';

void main() {
  testWidgets('AppLoader opens and closes correctly',
      (WidgetTester tester) async {
    // Create a test key for the loader widget.
    const loaderKey = Key('loader');

    // Build the _TestWidget.
    await tester.pumpWidget(const MaterialApp(
      home: _TestWidget(loaderKey: loaderKey),
    ));

    // Tap the button to open the loader.
    await tester.tap(find.byKey(loaderKey));
    await tester.pump(); // Start the loader

    // Verify that the loader dialog is shown.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Advance the timer by 2 seconds to simulate the delay.
    await tester.pump(const Duration(seconds: 2));

    // Verify that the loader dialog is closed.
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}

// Define a simple widget with a button to trigger loader.
class _TestWidget extends StatelessWidget {
  const _TestWidget({required this.loaderKey});
  final Key loaderKey;

  @override
  Widget build(BuildContext context) {
    final loader = AppLoader(context);

    Future<void> onPressed() async {
      loader.open();
      await Future.delayed(const Duration(seconds: 2)); // Simulating a delay
      loader.close();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Test Widget')),
      body: Center(
        child: ElevatedButton(
          key: loaderKey,
          onPressed: onPressed,
          child: const Text('Open Loader'),
        ),
      ),
    );
  }
}
