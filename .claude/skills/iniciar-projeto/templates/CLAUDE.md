# Instruções para o Claude Code

@AGENTS.md

## Time de subagents

Para funcionalidade nova, delegue nesta ordem:

1. **product-owner**: transforma o pedido em histórias e critérios de aceite. Se sobrar pergunta pendente, pare e pergunte ao dev antes de seguir.
2. **backend-go**, **frontend-ts** e **mobile-flutter**: implementam cada parte usando os critérios de aceite como contrato. O backend vem primeiro quando a API muda.
3. **qa-engineer**: confere a implementação contra os critérios de aceite e aponta os casos que faltam.
4. **revisor-pr**: revisa as alterações locais contra as regras do projeto.
5. Corrija o que o QA reprovou e o que o revisor pôs em "Precisa mudar" antes de dar a tarefa por pronta.
6. O dev roda `/ci-local` para saber se o CI do GitHub vai passar. Não rode o CI local por conta própria.

Tarefa pequena (bug simples, ajuste pontual) vai direto ao especialista e depois ao revisor-pr.

## Comandos do kit

- `/iniciar-projeto`: prepara o repositório para o kit ou migra um `CLAUDE.md` grande para o formato de índice.
- `/ci-local`: roda a esteira do CI na máquina e resume só o que falhou.

## Skills

- `writing-tests`: como testar. Use ao escrever ou corrigir qualquer teste.
- `secure-coding`: base de segurança. Use quando a mudança toca autenticação, autorização, entrada externa, SQL, upload, segredo, dado pessoal, dependência ou configuração.
- `writing-docs`: README, ADR, endpoint e `docs/`. Use quando mudar contrato, setup ou tomar decisão estrutural.
