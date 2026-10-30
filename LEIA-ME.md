# Time de agentes e skills para Claude Code

Kit de regras, subagents, skills e comandos para projetos com backend Go e PostgreSQL, web em TypeScript e mobile em Flutter. As regras seguem o padrão dos projetos mais maduros do repositório (ceuci, presenca, sep) e acrescentam as referências de mercado de cada linguagem.

## Conteúdo

```
.claude/agents/
  product-owner.md           requisitos, critérios de aceite, segurança e LGPD (só leitura)
  backend-go.md              Go e PostgreSQL
  frontend-ts.md             web em TypeScript (Next.js e React por padrão)
  mobile-flutter.md          Dart e Flutter
  qa-engineer.md             plano de testes e validação (só leitura e testes)
  revisor-pr.md              revisão das alterações locais ou de uma PR (só leitura)
.claude/skills/
  iniciar-projeto/           comando /iniciar-projeto
    templates/               AGENTS.md, CLAUDE.md, CONTRIBUTING.md, golangci.yml, analysis_options.yaml
  ci-local/                  comando /ci-local
    ci-local.sh              a esteira do CI na máquina
  secure-coding/             base de segurança pelo OWASP Top 10:2025, API Top 10 e MASVS
    references/              api, web, mobile e entrega, um arquivo por camada
  writing-tests/             padrões de teste
    references/              Go, TypeScript e Dart, um arquivo por linguagem
  writing-docs/              onde vai cada documento
    templates/               README, ADR, endpoint e doc de domínio
```

## Instalação

**Global (recomendado):** copie `.claude/agents/*` para `~/.claude/agents/` e `.claude/skills/*` para `~/.claude/skills/`. Assim os comandos e agentes valem em todos os seus projetos. O `revisor-pr.md` é o mesmo que já está no seu `~/.claude/agents/`, com uma linha a mais que aponta para a skill `secure-coding`.

**Em cada projeto:** abra o Claude Code na raiz e rode `/iniciar-projeto`. Ele cria o `AGENTS.md` e o `CLAUDE.md` (ou migra os que existem para o formato de índice), os docs de segurança, arquitetura e domínios, o `CONTRIBUTING.md`, as configs de lint e o `.env.example`, e pergunta se os agentes e as skills devem ir para dentro do repositório, para o time inteiro usar. Quando há um agente com o mesmo nome no projeto e no global, vale o do projeto.

## Comandos

| Comando | O que faz | Custo enquanto não é usado |
| --- | --- | --- |
| `/iniciar-projeto [o que é o projeto]` | Prepara ou migra o repositório para o kit, com plano aprovado antes | zero: nem a descrição entra no contexto |
| `/ci-local` | Roda a esteira do CI e resume só o que falhou | zero |

Os dois usam `disable-model-invocation: true`: só você os dispara, e o Claude não os carrega por conta própria.

O CI local também roda direto no terminal, sem gastar nenhum token:

```bash
bash ~/.claude/skills/ci-local/ci-local.sh
```

(ou `bash .claude/skills/ci-local/ci-local.sh`, se o kit estiver dentro do repositório). O script acha as camadas sozinho. Se o projeto declara a própria esteira (`make ci`, `make check`, `npm run ci` ou `npm run check`), ele a usa; se não, roda formatação, lint, `go vet`, `govulncheck`, testes, build, `npm audit` ou `pnpm audit` (o gerenciador vem do lockfile), `flutter analyze`, `gitleaks` e `actionlint`. Ferramenta que falta aparece como etapa pulada, e o veredito avisa. Sem `gcc`, o `go test` roda sem `-race`, que o CI usa.

O local só reproduz o GitHub se o workflow chamar os mesmos comandos. O `/iniciar-projeto` confere isso.

## Economia de contexto (indexação)

1. **`AGENTS.md` é o índice.** Fica perto de 10 KB e diz, para cada doc, quando lê-lo. O detalhe mora em arquivos pequenos em `docs/`, um por domínio.
2. **Skills entram pela `description`**, e os comandos nem isso. Quando usada, a skill traz um índice curto que aponta a referência da linguagem ou da camada.
3. **Subagents isolam a exploração** e devolvem só o resumo.
4. **Busca barata:** LSP quando houver, Grep com termo específico antes de abrir arquivo, leitura por trecho, nada de lockfile, build ou gerado inteiro.
5. **CI local compacto:** uma linha por etapa e as últimas linhas só do que falhou.

## Uso

- Automático: o Claude Code escolhe o subagent pela `description`.
- Explícito: "use o product-owner para refinar esta funcionalidade: ...", "peça ao revisor-pr para revisar minhas alterações".
- `/agents` lista e edita os subagents.
