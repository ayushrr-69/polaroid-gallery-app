import 'package:flutter_test/flutter_test.dart';

import 'package:polaroid_gallery_app/app.dart';

void main() {
  testWidgets('App renders with CURATOR title', (WidgetTester tester) async {
    await tester.pumpWidget(const CuratorApp());
    await tester.pumpAndSettle();

    // Verify the app title is visible.
    expect(find.text('CURATOR'), findsOneWidget);

    // Verify the bottom navigation has three items.
    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Albums'), findsOneWidget);
  });
}
