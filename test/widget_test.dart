import 'package:caritalent_mobile/app/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('renders CariTalent app shell', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CariTalentApp()));

    expect(find.text('CariTalent'), findsOneWidget);
  });
}
