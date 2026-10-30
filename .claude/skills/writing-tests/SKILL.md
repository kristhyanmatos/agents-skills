---
name: writing-tests
description: Padrões do time para testes automatizados em Go (com PostgreSQL de verdade), TypeScript (Vitest e Testing Library) e Dart/Flutter, incluindo teste de autorização, fuzzing e catraca de cobertura. Use SEMPRE que for criar, corrigir ou revisar testes, ao implementar funcionalidade ou corrigir bug (todo bug corrigido ganha teste de regressão), ou quando pedirem para aumentar a cobertura.
---
# Escrevendo testes

O teste é parte da entrega, não uma etapa depois dela.

## Princípios

- **Teste comportamento observável**, não detalhe de implementação. Se uma refatoração que não muda o comportamento quebra o teste, o teste está errado.
- **O nome é a especificação.** Ele descreve a regra e o resultado: `pedido de outro usuário responde 404`. Critério de aceite do product-owner vira teste com o texto dele.
- **Sem comentários.** Nada de `// Arrange`, `// Act`, `// Assert`: separe as três partes com uma linha em branco. Se o cenário precisa de explicação, o nome ou o dado de teste está ruim.
- **Um comportamento por teste**, com tabela de casos quando várias entradas provam a mesma regra.
- **Correção começa por um teste que falha** pelo motivo do defeito. Escreva, veja falhar, corrija, veja passar.
- **Refatoração não muda asserção** no mesmo commit.
- **Determinístico:** nada de horário real, ordem de execução, rede externa ou `sleep`. Injete o relógio e as dependências de fora.
- **Dublê só na fronteira** (HTTP de terceiros, relógio, fila, e-mail). O banco é o de verdade; não se cria dublê para as queries.
- **Teste instável não se pula:** ache a causa no sistema ou no teste.
- **Dado de teste é sintético.** Nunca dump real em `testdata/`, nem anonimizado.
- **Monte o dado com funções construtoras** que deixam explícito só o que importa para o cenário (`novoPedido(t, comStatus(Pago))`), em vez de fixtures enormes.

## O que todo projeto testa

- **Autorização em toda rota nova ou alterada:** sem sessão recebe 401; sem permissão, 403 ou 404, conforme o projeto; recurso de outro usuário ou de outro tenant, 404. Quem pode acessar consegue.
- **Isolamento:** a rota nova entra na matriz de isolamento do projeto, se houver.
- **Fuzzing:** função nova que interpreta texto do cliente (data, hora, filtro, documento) ganha um alvo de fuzzing com as sementes dos casos conhecidos.
- **Estados da tela:** carregando, erro, vazio e pronto (e sem conexão, no mobile).

## Cobertura

Cobertura é consequência, não meta. Priorize regra de negócio, caminho de erro e bug já corrigido. Se o projeto tem catraca, a cobertura de nenhum pacote ou diretório cai; se subiu, atualize a catraca no mesmo PR.

## Por linguagem

Leia só a referência da linguagem que está testando:

- Go e PostgreSQL: `references/go.md`
- TypeScript (web): `references/typescript.md`
- Dart e Flutter: `references/dart.md`

## Antes de entregar

- [ ] Os testes rodam isolados e em qualquer ordem
- [ ] Cada teste falha pelo motivo certo (confira quebrando o código de propósito)
- [ ] Nenhum `.only`, `.skip` ou `t.Skip` esquecido
- [ ] Nenhum comentário; os nomes descrevem a regra
- [ ] Nenhum teste chega à rede nem ao banco de desenvolvimento
- [ ] A mensagem de falha mostra o que veio e o que se esperava
