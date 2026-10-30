# Testes em TypeScript (web)

Use o runner que o projeto já tem (Vitest, por padrão). O teste fica ao lado do arquivo (`preco.ts` e `preco.test.ts`).

## Regra em `src/lib/`

A regra mora em função pura justamente para ser testada sem montar a tela.

```ts
describe("formatarPreco", () => {
  it.each([
    [123456, "R$ 1.234,56"],
    [0, "R$ 0,00"],
  ])("formata %i centavos como %s", (centavos, esperado) => {
    expect(formatarPreco(centavos)).toBe(esperado);
  });
});
```

## Componentes (Testing Library)

- Busque como o usuário: `getByRole`, `getByLabelText`, `getByText`. `getByTestId` só como último recurso; nunca seletor de classe CSS.
- Interação com `userEvent`, não `fireEvent`.
- Teste os estados: carregando, erro, vazio e pronto.

```ts
it("mostra mensagem de erro quando a API falha", async () => {
  server.use(http.get("/api/pedidos", () => HttpResponse.error()));

  render(<ListaPedidos />);

  expect(await screen.findByRole("alert")).toHaveTextContent(/não foi possível/i);
});
```

## Rede e sessão

- Nenhum teste chega à rede nem à API. Simule na fronteira: MSW ou dublê do `fetch`, nunca o módulo do cliente da API por dentro.
- Simule a sessão (NextAuth ou equivalente) em vez de fazer login.
- Fixtures tipadas com os mesmos tipos do contrato da API.

## E2E

Fluxos críticos (login, pagamento, cadastro) com Playwright, se o projeto usar. Poucos e estáveis; não substituem os testes de unidade.
