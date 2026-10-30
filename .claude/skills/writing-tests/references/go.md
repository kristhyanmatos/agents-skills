# Testes em Go

Use `testing` e `httptest` da biblioteca padrão. Se o projeto já usa outra biblioteca de asserção, siga-a; não misture as duas.

## Tabela de casos

```go
func TestCalcularDesconto(t *testing.T) {
	tests := []struct {
		name          string
		totalCentavos int64
		cupom         string
		want          int64
		wantErr       error
	}{
		{name: "sem cupom não dá desconto", totalCentavos: 10000, want: 10000},
		{name: "cupom de 10% aplica desconto", totalCentavos: 10000, cupom: "DEZ", want: 9000},
		{name: "cupom inválido retorna erro", totalCentavos: 10000, cupom: "XXX", wantErr: ErrCupomInvalido},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()

			got, err := CalcularDesconto(tt.totalCentavos, tt.cupom)

			if !errors.Is(err, tt.wantErr) {
				t.Fatalf("erro = %v, esperado %v", err, tt.wantErr)
			}
			if got != tt.want {
				t.Errorf("CalcularDesconto() = %d, esperado %d", got, tt.want)
			}
		})
	}
}
```

- `t.Parallel()` quando o teste não compartilha estado. Desde o Go 1.22 não é preciso copiar a variável do laço.
- Helper chama `t.Helper()`; limpeza com `t.Cleanup()`; contexto com `t.Context()` (Go 1.24+).
- Rode sempre com `-race`.

## Integração com PostgreSQL

- Banco de verdade, nunca dublê das queries. O teste lê a URL do banco de teste e se pula quando ela não está definida; o CI sempre a define. Nunca aponte para o banco de desenvolvimento.

  ```go
  func bancoDeTeste(t *testing.T) *pgxpool.Pool {
  	t.Helper()
  	url := os.Getenv("DATABASE_URL")
  	if url == "" {
  		t.Skip("DATABASE_URL não definida")
  	}
  	pool, err := pgxpool.New(context.Background(), url)
  	if err != nil {
  		t.Fatalf("conectando ao banco de teste: %v", err)
  	}
  	t.Cleanup(pool.Close)
  	return pool
  }
  ```

- Isolamento: cada teste cria os próprios dados com IDs novos, ou roda numa transação desfeita no `t.Cleanup`.
- As migrations reais rodam antes da suíte, no `TestMain`.

## Rotas

- `httptest.NewRecorder()` e `httptest.NewRequest()` contra o roteador montado como em produção, com os middlewares reais. Assim o teste de autorização prova a rota, não o handler solto.
- Confira status, corpo e cabeçalhos relevantes, inclusive nas respostas de erro, e que uma 5xx não traz detalhe interno.
- `httptest.NewServer()` para simular API de terceiros.

## Autorização

```go
{name: "sem sessão responde 401", token: "", wantStatus: http.StatusUnauthorized},
{name: "dono do pedido recebe o pedido", token: tokenDoDono, wantStatus: http.StatusOK},
{name: "pedido de outro usuário responde 404", token: tokenDeOutro, wantStatus: http.StatusNotFound},
```

## Fuzzing

```go
func FuzzLerHorario(f *testing.F) {
	for _, semente := range []string{"00:00", "23:59", "24:00", "25:00", "", "9:5"} {
		f.Add(semente)
	}
	f.Fuzz(func(t *testing.T, entrada string) {
		minutos, err := lerHorario(entrada)
		if err == nil && (minutos < 0 || minutos > 24*60) {
			t.Fatalf("lerHorario(%q) = %d, fora do dia", entrada, minutos)
		}
	})
}
```

As sementes rodam em todo `go test`; a exploração roda com `go test -fuzz=FuzzLerHorario -fuzztime=30s`. Entrada que quebrou o alvo vira semente no PR da correção.

## Tempo

Injete o relógio (`agora func() time.Time`) em vez de chamar `time.Now()` no código testado.
