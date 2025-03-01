import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:app_loader/app_loader.dart';

void main() {
  testWidgets('MaterialLoader shows splash page and transitions to MaterialApp',
      (WidgetTester tester) async {
    // Define a key for the splash page text widget.
    const splashTextKey = Key('splashText');
    const homeTextKey = Key('homeText');

    Future<void> onFetchData({
      BuildContext? context,
      required AppLoader loader,
      required ValueNotifier<MaterialLoaderStatus> fetchStatus,
    }) async {
      // Simulate a delay for fetching data.
      await Future.delayed(const Duration(seconds: 1));
      fetchStatus.value = MaterialLoaderStatus.done;
    }

    Future<void> onNextMaterial(VoidCallback handleNextMaterial) async {
      handleNextMaterial();
    }

    // Build the MaterialLoader widget.
    await tester.pumpWidget(MaterialApp(
      home: MaterialLoader(
        onFetchData: onFetchData,
        onNextMaterial: onNextMaterial,
        splashPage: (animationController, getData, haveError) {
          return const Scaffold(
            body: Center(child: Text('Splash Page', key: splashTextKey)),
          );
        },
        materialApp: const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Home Page', key: homeTextKey)),
          ),
        ),
      ),
    ));

    // Verify that the splash page is displayed initially.
    expect(find.byKey(splashTextKey), findsOneWidget);

    // Advance the animation and complete fetchData.
    await tester.pumpAndSettle();

    // Verify that the MaterialApp is displayed after loading.
    expect(find.byKey(homeTextKey), findsOneWidget);
  });
}
