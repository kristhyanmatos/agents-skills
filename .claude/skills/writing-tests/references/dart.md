# Testes em Dart/Flutter

## Unitários (`package:test` / `flutter_test`)
```dart
group('CarrinhoService', () {
  test('soma o total dos itens', () {
    final carrinho = Carrinho()..adicionar(item(preco: 1000, qtd: 2));
    expect(carrinho.total, 2000);
  });

  test('lança erro ao adicionar quantidade negativa', () {
    expect(() => Carrinho().adicionar(item(qtd: -1)), throwsArgumentError);
  });
});
```
- Mocks com o pacote que o projeto já usa (mocktail ou mockito).
- Lógica de negócio fica fora dos widgets — e é testada sem Flutter.

## Widget tests
```dart
testWidgets('mostra estado vazio quando não há pedidos', (tester) async {
  await tester.pumpWidget(MaterialApp(home: ListaPedidos(repo: FakeRepoVazio())));
  await tester.pumpAndSettle();
  expect(find.text('Nenhum pedido ainda'), findsOneWidget);
});
```
- Teste os estados: carregando, erro, vazio, sucesso e sem conexão.
- Prefira `find.byType`/`find.text`/`find.bySemanticsLabel`; use `Key` só quando necessário.
- Com gerenciador de estado (Riverpod/Bloc), sobrescreva providers/blocs com fakes no teste.

## Integração
Fluxos críticos com `integration_test`, rodando em emulador. Poucos e focados.

Rode com `flutter test` (e `flutter test --coverage` para cobertura).
