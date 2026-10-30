---
name: iniciar-projeto
description: Prepara um repositório, novo ou existente, para o kit de agentes. Entrevista o dev, cria ou migra AGENTS.md e CLAUDE.md para o formato de índice, cria os docs de segurança, arquitetura e domínios, CONTRIBUTING, configs de lint e .env.example, e confere tudo com o CI local.
disable-model-invocation: true
argument-hint: "[o que é o projeto, em uma frase]"
---
# Iniciar projeto

Pedido do dev: $ARGUMENTS

Onde está cada coisa do kit:

- modelos: `${CLAUDE_SKILL_DIR}/templates/`
- doc de domínio: `${CLAUDE_SKILL_DIR}/../writing-docs/templates/DOMINIO.md`
- base de segurança: `${CLAUDE_SKILL_DIR}/../secure-coding/references/`
- agentes: `${CLAUDE_SKILL_DIR}/../../agents/`

Valem as regras de `templates/AGENTS.md`: nada de commit, branch ou PR; não leia `.env*`; produção é intocável. Nunca sobrescreva arquivo que já existe: a mudança entra no plano.

## 1. Diagnóstico

Gaste pouco contexto: liste e busque, não leia arquivo grande inteiro.

- Raiz e histórico: `git rev-parse --show-toplevel` e `git log --oneline -3`.
- Camadas: `go.mod`, `package.json` e `pubspec.yaml` até 3 níveis, fora de `node_modules`.
- O que já existe, com `ls` e `wc -c`: `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `docs/`, `.github/workflows/`, alvos `ci` e `check` do `Makefile`, scripts `ci` e `check` do `package.json`, `.golangci.yml`, `analysis_options.yaml`, `tsconfig.json`, `.env.example` e se o `.gitignore` cobre `.env`.
- De um `CLAUDE.md` ou `AGENTS.md` existente, leia primeiro só os títulos (`grep -n '^#'`) e depois só as seções que for migrar.
- Domínios: nomes das pastas de módulo (`modules/`, `internal/`, `src/app/`, `lib/modules/` ou o equivalente).
- Moldes: o módulo, a tela e o teste mais completos de cada camada, achados por Glob e tamanho, sem ler um por um.
- Estrutura de docs que o projeto já usa: índice próprio, docs numerados, onde estão segurança, arquitetura, domínios, ADRs e progresso.
- Sem `CLAUDE.md` na raiz, o Claude Code não carrega o `AGENTS.md`: registre isso como achado.

## Projeto existente

O que o projeto já tem prevalece sobre o template:

- **Docs:** mantenha a estrutura dele. O Índice do `AGENTS.md` aponta para os arquivos reais (por exemplo, o doc de segurança é o `docs/06-seguranca-e-lgpd.md`, se é ele que existe). Só crie doc para o que não tem equivalente; nunca um paralelo.
- **Regras:** as regras invioláveis do projeto ficam todas, com a numeração e o texto dele. Do template entram só as que faltam, sem duplicar o que o projeto já diz de outro jeito.
- **Seções próprias** (moldes, ritual de trabalho, o que não fazer, contexto do cliente) ficam. Se forem longas, o detalhe vai para um doc e o `AGENTS.md` guarda uma linha com o link.
- **Comandos e CI** são os do projeto; o template só preenche lacunas.

## 2. Perguntas

Uma rodada só, com só o que o diagnóstico não respondeu:

- nome e propósito, se o pedido não disse;
- domínios (proponha os que achou);
- agentes e skills dentro do repositório, para o time inteiro, ou só no `~/.claude` do dev;
- em projeto vazio, a stack de cada camada.

## 3. Plano

Mostre os arquivos a criar e a alterar, uma linha cada, com o que entra. Mudança em CI, `.gitignore`, `Makefile` ou lint existente vem marcada. Espere o ok do dev.

## 4. Execução

1. **Projeto vazio:** rode só os geradores oficiais aprovados (`go mod init`, `npx create-next-app@latest`, `flutter create`). Não escreva código de aplicação além do que eles geram.
2. **`AGENTS.md`** a partir de `templates/AGENTS.md`. Preencha os `AJUSTE` com o que o diagnóstico achou (stack, comandos, como rodar, estrutura, moldes, domínios) e tire os marcadores. O que não deu para confirmar fica `PENDENTE`, nunca inventado. Alvo: até 10 KB.
3. **Migração de um `CLAUDE.md` ou `AGENTS.md` grande:** regra vai para as Regras invioláveis ou os Padrões; comando, para Comandos; conteúdo de um domínio, para o doc daquele domínio; decisão transversal, para o doc de arquitetura. Use os docs que o projeto já tem; `docs/dominios/` e `docs/ARCHITECTURE.md` só quando não houver equivalente. Histórico, estado do projeto e registro de alteração saem, porque o Git os guarda. Nenhuma regra se perde: o resumo lista cada bloco tirado e o destino dele.
4. **`CLAUDE.md`** a partir de `templates/CLAUDE.md`.
5. **`docs/seguranca.md`**, se não existir nem houver equivalente: esqueleto das referências de `secure-coding` das camadas do projeto, com os nomes reais (middlewares, funções, variáveis) achados por Grep. O que o código não confirma fica `PENDENTE`.
6. **`docs/dominios/<dominio>.md`** para cada domínio que não tem doc próprio, a partir do `DOMINIO.md`. "Onde está no código" sai do Glob; regra só entra se já está em doc ou teste; o resto fica `PENDENTE`. Uma linha por domínio no Índice do `AGENTS.md`.
7. **`docs/ARCHITECTURE.md`**, se não existir nem houver equivalente: as camadas e a regra de dependência entre elas, sem inventar decisão.
8. **`CONTRIBUTING.md`**, se não existir, a partir de `templates/CONTRIBUTING.md`.
9. **Esteira:** cada camada tem um comando único de verificação (`make check`, `npm run check`); se faltar, crie com os mesmos passos do `ci-local.sh`. Se há workflow de CI, confira se ele chama esse comando e aponte a diferença no resumo. Se não há, proponha um `.github/workflows/ci.yml` que o chame, em runner hospedado, com `permissions: contents: read` e as actions fixadas pelo SHA do commit (`git ls-remote --tags https://github.com/<dono>/<action>`).
10. **Lint**, só se não existir: `templates/golangci.yml` vira `.golangci.yml` e `templates/analysis_options.yaml` vai para a raiz do app Flutter. No web, mantenha a config do framework e aponte se o `tsconfig` não tem `strict` e `noUncheckedIndexedAccess`.
11. **Segredos:** o `.gitignore` cobre `.env*` menos o `.env.example`; o `.env.example` lista as variáveis que o código lê (Grep por `os.Getenv`, `process.env` e `String.fromEnvironment`), com valor fictício.
12. **Kit no repositório**, se o dev escolheu: copie os agentes para `.claude/agents/` e as skills para `.claude/skills/`.

## 5. Conferência

Rode `bash "${CLAUDE_SKILL_DIR}/../ci-local/ci-local.sh" .` e traga o veredito. Falha que já existia antes da preparação vai para o resumo; não corrija código de aplicação aqui.

## 6. Resumo

- Arquivos criados e alterados, uma linha cada.
- Blocos migrados e o destino de cada um.
- Os `PENDENTE` que o dev precisa preencher.
- O veredito do CI local.
- Sugestão de commit: `chore: prepara o projeto para os agentes de IA`.
