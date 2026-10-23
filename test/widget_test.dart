import 'package:flutter_test/flutter_test.dart';
import 'package:cameralocalizacaoflutter/main.dart';

void main() {
  testWidgets('O aplicativo de perfil abre corretamente',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());

    expect(find.text('Meu Perfil'), findsOneWidget);
    expect(find.text('Bem-vinda! 🎀'), findsOneWidget);
    expect(find.text('Minha localização'), findsOneWidget);
    expect(find.text('Alterar foto'), findsOneWidget);
    expect(
      find.text('Usar minha localização'),
      findsOneWidget,
    );
  });
}