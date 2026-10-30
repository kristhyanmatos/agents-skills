---
name: ci-local
description: Roda na máquina as mesmas verificações do CI do GitHub (formatação, lint, tipos, testes, build, vulnerabilidades e segredos) e resume só o que falhou.
disable-model-invocation: true
allowed-tools: Bash(bash *ci-local.sh*)
---
# CI local

Rode, na raiz do repositório e com timeout de 10 minutos:

```bash
bash "${CLAUDE_SKILL_DIR}/ci-local.sh" .
```

O script acha as camadas sozinho (`go.mod`, `package.json`, `pubspec.yaml`). Se o projeto declara a própria esteira (alvo `ci` ou `check` no `Makefile`, script `ci` ou `check` no `package.json`), roda ela. Imprime uma linha por etapa e, só nas que falharam, as últimas linhas do log.

Responda só com:

1. A última linha do script, que é o veredito.
2. Para cada FALHA: a causa numa frase, com `arquivo:linha` quando houver. Abra o log completo (o caminho está na linha da falha) só se o trecho não bastar, e leia só a parte do erro.
3. Para cada etapa pulada: a ferramenta que falta e o comando de instalação.
4. Se o `go test` rodou sem `-race`, avise que o CI roda com `-race` e pode achar uma condição de corrida que a máquina local não acha.

Não corrija nada e não rode de novo: o dev decide o próximo passo.
