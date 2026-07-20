import 'package:flutter_test/flutter_test.dart';
import 'package:structo/app/app.dart';
import 'package:structo/features/editor/widgets/molecule_canvas.dart';

void main() {
  testWidgets('Structo app shell loads editor screen', (WidgetTester tester) async {
    await tester.pumpWidget(const StructoApp());

    expect(find.text('Structo'), findsOneWidget);
    expect(find.byType(MoleculeCanvas), findsOneWidget);
  });
}
