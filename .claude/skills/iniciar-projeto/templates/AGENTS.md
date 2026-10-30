# AGENTS.md

Instruções para agentes de IA (Claude Code, Codex, Cursor, Copilot e similares) que trabalham em <!-- AJUSTE: nome do projeto e, numa frase, o que ele faz e para quem -->. O código que você entrega passa pela mesma revisão que o de uma pessoa e é recusado pelos mesmos motivos. Leia também o [`CONTRIBUTING.md`](CONTRIBUTING.md), se existir.

## Regras invioláveis

1. **Não faça commit, branch nem PR.** Não use o Git para gravar nada: nada de `add`, `rm`, `commit`, `push`, `merge`, `rebase`, `reset`, `stash` ou `tag`, nada de criar ou trocar de branch, e nada de abrir ou mesclar PR. Comandos de leitura (`status`, `diff`, `log`, `show`) estão liberados. As alterações ficam no working tree; quem revisa, cria a branch e commita é o dev.
2. **Código sem comentários, inclusive o gerado por IA.** O nome explica o quê; a sua resposta ao dev explica o porquê, e o porquê que precisa durar vai para `docs/`. Não escreva comentário sobre a linha seguinte, cabeçalho de função, GoDoc, JSDoc, dartdoc, banner de seção, `TODO`, `FIXME`, código antigo comentado nem registro de alteração. Se um trecho parece precisar de comentário, renomeie, extraia uma função, nomeie a constante ou dê um tipo ao valor. As exceções são o que uma ferramenta lê: diretivas `//go:`, `-- name:` do sqlc, anotações `// @` do swag, `//nolint:<regra> // motivo`, `// eslint-disable-next-line <regra> -- motivo`, `// @ts-expect-error motivo`, `// ignore: <regra>` do Dart e o cabeçalho de arquivo gerado. Os comentários que já existem ficam; não os apague sem pedido.
3. **Segurança não se negocia.** Todo código novo ou alterado segue o [`docs/seguranca.md`](docs/seguranca.md) e, no que ele não cobrir, a skill `secure-coding`. Nunca enfraqueça uma proteção para um teste passar ou para simplificar: nada de remover middleware, abrir o CORS, pular validação, desligar regra de lint, pular teste ou baixar a catraca de cobertura.
4. **Segredo não se lê nem se escreve.** Não abra nem exiba `.env*` nem arquivo de chave; os nomes das variáveis estão no `.env.example`. Não ponha segredo em código, teste, log, documentação ou resposta.
5. **Produção é intocável.** Nada contra servidor, banco, API ou workflow de produção. No ambiente local, comando destrutivo (`DROP`, `DELETE` sem `WHERE`, migration down, `docker compose down -v`, `docker volume rm`) só com pedido explícito.
6. **Fora do combinado, pergunte.** Dependência nova e mudança em CI, deploy, Docker, `.gitignore`, login ou configuração de segurança só com pedido explícito.
7. **Um padrão por coisa.** Antes de criar, ache o molde no projeto (seção Moldes) e copie; não invente um segundo padrão. Arquivo gerado nunca é editado à mão: muda-se a fonte e gera-se de novo.
8. **Regra de negócio tem lugar certo.** Handler só trata HTTP; o service tem a regra e não conhece HTTP; SQL fica em `db/query/*.sql` e é gerado pelo sqlc. Tela e widget só montam a interface; a regra vai para uma função pura, testável sem rede. <!-- AJUSTE se o projeto não usa sqlc -->
9. **Negar por padrão.** Rota nova exige autenticação e autorização explícitas; rota pública só com justificativa no PR. Quem autoriza é o servidor; o que a tela esconde é só conforto.

## Como trabalhar

1. Comece pelo Índice: leia só os docs que a tarefa toca. Depois leia o código que ela muda e quem o chama. Correção vai na causa, no ponto por onde todos os chamadores passam, não só no caminho que o bug citou.
2. Se mudou comportamento, escreva o teste junto (skill `writing-tests`). Se corrigiu bug, o teste precisa falhar sem a correção.
3. Antes de dizer que terminou, rode a verificação (seção Comandos). Se algo falhar e você não conseguir resolver, diga o que falhou. Nunca declare concluída uma tarefa com verificação vermelha.
4. Confira o próprio diff: nenhum comentário novo, nenhum resto de depuração (`console.log`, `print`, `fmt.Println`, `debugger`, `.only`, `.skip`), nenhum segredo, nada fora do assunto.
5. Mudança no contrato da API (rota, campo, formato ou status) é combinada antes com quem consome (web e mobile) e vai destacada no resumo.
6. O porquê que precisa durar vai para `docs/` no mesmo trabalho (skill `writing-docs`). Decisão estrutural vira ADR.
7. Entregue ao dev um resumo pronto para a descrição do PR: o que mudou e por quê, como testar, o que ficou pendente e uma sugestão de commit no formato `tipo: descrição`, em português (`feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `chore`).

## Índice

Este arquivo é o índice; o detalhe mora no arquivo apontado. Leia só a linha que a tarefa toca.

| Arquivo | Leia quando |
| --- | --- |
| [`docs/seguranca.md`](docs/seguranca.md) | a mudança tocar rota, sessão, entrada externa, SQL, upload, segredo, dado pessoal ou configuração |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | a mudança cruzar módulos ou mexer numa decisão transversal; leia só a seção do assunto |
| `docs/dominios/<dominio>.md` | a tarefa for de um domínio: regras, fluxo, onde está no código e armadilhas dele |
| [`docs/adr/`](docs/adr/) | a mudança contrariar uma decisão; ache o ADR pelo nome do arquivo antes de abrir |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | for montar o resumo do PR |

<!-- AJUSTE: uma linha por domínio, como as abaixo -->
| Domínio | Leia quando |
| --- | --- |
| [`docs/dominios/pagamento.md`](docs/dominios/pagamento.md) | cobrança, Pix, repasse, reembolso |
| [`docs/dominios/identidade.md`](docs/dominios/identidade.md) | login, usuário, papel, permissão |

## Como buscar

- Índice e Moldes primeiro; exploração só para o que eles não respondem.
- Com a ferramenta LSP disponível, ache definição, referências e símbolos por ela: é mais precisa que busca por texto.
- Sem LSP, Grep ou Glob com termo específico (nome da função, rota, tabela) antes de abrir arquivo. Arquivo grande se lê pelo trecho que a busca apontou.
- Não leia lockfile, `node_modules`, `build`, `.next`, dump nem arquivo gerado inteiro; do gerado, só a assinatura que você precisa.
- Busca ampla, que varre muitos arquivos, vai para um subagent de exploração, que devolve só a conclusão.
- Não releia o que já está no contexto.

## Padrões de código

Valem para todas as linguagens. Os padrões de cada uma estão nos agentes `backend-go`, `frontend-ts` e `mobile-flutter`.

- O padrão do repositório vale mais que preferência pessoal ou costume de outro projeto.
- Nome revela intenção, no vocabulário do domínio. Booleano como pergunta (`estaAtivo`, `podeEditar`). Sem abreviação que só o autor entende.
- Função pequena, com uma responsabilidade e retorno antecipado em vez de `if` aninhado.
- Sem abstração especulativa: interface com uma implementação só, factory de um produto, opção de configuração para valor que nunca muda. Duplicação vira abstração na terceira ocorrência, não na segunda.
- Dependência entra pelo construtor. Nada de estado global mutável nem singleton escondido.
- Imutável por padrão (`const`, `final`, `readonly`).
- Dinheiro em inteiro (centavos) ou decimal, nunca `float`. Valor cobrado é gravado na emissão, não recalculado depois.
- "Agora" e "hoje" vêm de um relógio injetado ou da função de calendário do projeto, nunca de `time.Now()`, `new Date()` ou `DateTime.now()` espalhado numa regra.
- Configuração é lida e validada na subida: faltou a obrigatória, o app não sobe. Nenhum outro código lê variável de ambiente.
- Erro nunca é engolido: trate ou propague com contexto, uma vez só. Logar e devolver o mesmo erro duplica o log.
- Prefira a biblioteca padrão. Dependência nova só com justificativa, mantenedor ativo, licença compatível e sem vulnerabilidade conhecida.

## Comandos

<!-- AJUSTE para o projeto -->
- **Backend:** `make check`, que roda `gitleaks`, `golangci-lint run`, `govulncheck ./...` e `go test -race ./...`.
- **Web:** `npm run check`, que roda lint, type-check, testes e a catraca de cobertura.
- **Mobile:** `dart format --output=none --set-exit-if-changed . && flutter analyze && flutter test`.
- **CI local:** `/ci-local` no Claude Code, ou `bash .claude/skills/ci-local/ci-local.sh` no terminal, sem gastar token. Roda o mesmo que o CI do GitHub. Quem dispara é o dev, ao fim da implementação; o agente roda só a verificação da camada que mexeu.

O workflow do CI chama estes mesmos comandos, para que o resultado local e o do GitHub sejam iguais.

## O projeto em uma página

<!-- AJUSTE: tudo abaixo -->
- **Stack:** Go (versão do `go.mod`) com Gin, PostgreSQL via pgx/v5 e sqlc, migrations com golang-migrate e Swagger com swag. Web em Next.js, React e TypeScript estrito, com Tailwind, shadcn/ui, Zod e Vitest. Mobile em Flutter, com <Bloc/Riverpod> e freezed.
- **Rodar:** <comando para subir o ambiente local, portas e URLs>.
- **Estrutura:** <pastas principais e o que vive em cada uma>.

## Moldes

Copie daqui; não invente um segundo padrão. <!-- AJUSTE: aponte para o melhor exemplo real de cada um -->

- **Módulo de backend:** `<caminho>`: rota, handler sem regra, service com erro tipado, query no sqlc e teste de autorização.
- **Formulário web:** `<caminho>`.
- **Lista web:** `<caminho>`.
- **Tela mobile:** `<caminho>`.

## Mantendo este arquivo

Este arquivo é carregado inteiro em toda sessão, por isso fica curto: o alvo é caber em 10 KB. Regra nova e detalhada vai para um arquivo em `docs/` e ganha no Índice uma linha com o link e o "leia quando". Domínio novo ganha um `docs/dominios/<dominio>.md` (skill `writing-docs`) e uma linha na tabela de domínios. O `CLAUDE.md` importa este arquivo e só acrescenta o que é exclusivo do Claude Code.

Não registre aqui o que foi feito. O andamento fica no roadmap ou no checklist do projeto e o histórico, no Git.
