import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dovix_calling_app/main.dart';
import 'package:dovix_calling_app/store/app_store.dart';
import 'package:dovix_calling_app/widgets/app_icon.dart';

Finder findAppIcon(AppIcons icon) => find.byWidgetPredicate((w) => w is AppIcon && w.icon == icon);

void main() {
  testWidgets('splash → login → dashboard → leads → lead details', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final store = AppStore();
    await tester.pumpWidget(DovixApp(store: store));
    expect(find.text('Smarter Conversations\nStronger Business'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();
    expect(find.text('Welcome Back!'), findsOneWidget);

    // Validation errors on empty submit.
    await tester.tap(find.text('Login'));
    await tester.pump();
    expect(find.text('Enter your email or mobile number'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'kamlesh@dovixai.com');
    await tester.enterText(find.byType(TextField).at(1), 'secret123');
    await tester.tap(find.text('Login'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(store.isLoggedIn, isTrue);
    expect(find.text('Total Leads'), findsOneWidget);

    await tester.tap(find.text('Leads').last);
    await tester.pumpAndSettle();
    expect(find.text('Leads (10)'), findsOneWidget);

    await tester.tap(find.text('Rohit Sharma'));
    await tester.pumpAndSettle();
    expect(find.text('Contact Information'), findsOneWidget);
    expect(find.text('Call Now'), findsOneWidget);
  });

  testWidgets('a simulated call is logged when it ends', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final store = AppStore()..login('a@b.com');
    await tester.pumpWidget(DovixApp(store: store));
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open dialer'));
    await tester.pumpAndSettle();
    for (final d in '9876543210'.split('')) {
      await tester.tap(find.text(d).last);
    }
    await tester.pump();
    await tester.tap(findAppIcon(AppIcons.phone).last);
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 1),
    );
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Live Call'), findsOneWidget);

    final before = store.calls.length;
    await tester.tap(findAppIcon(AppIcons.phoneEnd));
    await tester.pump();
    expect(store.calls.length, before + 1);
    expect(store.calls.first.name, 'Rohit Sharma'); // matched the lead by number
    expect(find.text('Done'), findsOneWidget);
  });
}
