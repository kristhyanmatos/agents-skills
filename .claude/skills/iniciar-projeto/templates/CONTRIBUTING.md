# Como contribuir com <!-- AJUSTE: nome do projeto -->

Este guia diz o que fazer antes de abrir um Pull Request, quais requisitos ele cumpre e como é avaliado. Vale para todos, inclusive para quem mantém o repositório.

> **Um PR que não cumpre os requisitos obrigatórios é recusado.** A recusa é sobre o PR, não sobre a pessoa: quem revisa aponta o item deste guia que faltou, você corrige e pede nova revisão.

## Resumo

1. A branch saiu da `develop` e trata de um assunto só.
2. A verificação local passa (seção 3).
3. O que mudou tem teste.
4. O template do PR está preenchido, com o checklist marcado com honestidade.
5. Se você usou um agente de IA, revisou cada linha que ele gerou (seção 8).

## 1. Antes de começar

- Para montar o ambiente, siga o `README.md`.
- As regras para agentes e pessoas estão no `AGENTS.md`; a segurança, no `docs/seguranca.md`; as decisões, no `docs/ARCHITECTURE.md` e em `docs/adr/`.

## 2. Branch, commits e tamanho

- **Branch:** a partir da `develop`, com prefixo e descrição curta: `feat/`, `fix/`, `refactor/`, `perf/`, `docs/`, `test/` ou `chore/` (ex.: `fix/filtro-por-tenant`). <!-- AJUSTE: branch base -->
- **Destino:** o PR vai para a `develop`. A `main` só recebe o PR da `develop` que leva a versão para produção.
- **Commits:** `tipo: descrição`, em português, com os mesmos tipos da branch.
- **Um assunto por PR:** não misture funcionalidade, refatoração e formatação.
- **Tamanho:** até umas 400 linhas alteradas, fora o código gerado. PR maior pode voltar com pedido para ser dividido.

## 3. Verificações locais

Antes de abrir o PR, rode a esteira do CI na sua máquina:

```bash
bash .claude/skills/ci-local/ci-local.sh
```

No Claude Code, o mesmo é `/ci-local`. O CI roda os mesmos comandos, com `-race` no Go. PR com CI vermelho não é revisado.

Testes de integração rodam contra o banco de teste, nunca o de desenvolvimento. <!-- AJUSTE: como subir o banco de teste -->

Se a cobertura subiu, atualize a catraca no mesmo PR; se caiu, cubra o código ou explique no PR por que a queda é deliberada.

## 4. Requisitos do código

Valem para o que o PR adiciona ou altera. Problema antigo não bloqueia um PR de outro assunto.

- **Arquitetura:** handler só trata HTTP; regra de negócio fica no service; SQL só em `db/query/`, gerado; arquivo gerado nunca é editado à mão; migration nova com `up` e `down`.
- **Código sem comentários:** o nome explica o quê; o porquê vai para `docs/`. Só diretivas de ferramenta são aceitas.
- **Segurança:** o `docs/seguranca.md` é obrigatório. Leia o arquivo inteiro antes do primeiro PR.
- **Testes:** comportamento novo ou alterado tem teste; correção de bug vem com o teste que falhava antes dela; rota nova ou alterada tem teste de autorização (quem pode consegue; quem não pode recebe 401, 403 ou 404).

## 5. Abrindo o PR

- Preencha o template: o que muda e por quê, como testar e o que ficou pendente.
- Marque no checklist só o que você fez.
- Destaque qualquer mudança de contrato da API (rota, campo, formato ou status): ela quebra web e mobile.
- Mudança visível na tela vai com print de antes e depois, no desktop e no celular.

## 6. Revisão

- O merge exige o CI verde e a aprovação de uma pessoa que não seja a autora. Ninguém faz merge do próprio PR.
- Cada pedido de ajuste cita o item deste guia.
- Commit novo depois da aprovação exige nova aprovação.

## 7. Quando o PR é recusado

Sem revisão detalhada, quando:

- o CI está vermelho;
- o template não foi preenchido ou não diz como testar;
- o PR mistura assuntos, ou tem item do checklist marcado sem ter sido feito;
- uma rota nova não tem autenticação, ou uma consulta por ID não filtra pelo dono ou pelo tenant;
- um dado de identidade vem do corpo do request;
- um erro interno volta na resposta;
- há comentário em código novo, SQL fora de `db/query/` ou arquivo gerado editado à mão;
- uma migration não tem `down`;
- uma mudança de comportamento não tem teste, ou a cobertura caiu sem justificativa;
- há segredo no diff;
- entrou dependência nova sem justificativa ou com vulnerabilidade conhecida.

A recusa não é definitiva: corrija, comente o que mudou e peça nova revisão. Se a regra estiver errada, proponha a mudança deste guia em outro PR.

## 8. Agentes de IA

Pode usar agentes de IA. O agente segue o `AGENTS.md`: não comenta o código, não faz commit, branch nem PR, e cumpre as regras de segurança. Quem abre o PR responde pelo código como se o tivesse escrito: revise cada linha gerada e confira se nenhum segredo nem resto de colagem foi parar no diff.
