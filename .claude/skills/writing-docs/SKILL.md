---
name: writing-docs
description: Padrões do time para documentação técnica, como README, AGENTS.md, docs/ARCHITECTURE.md, ADR, documentação de endpoint e changelog. Use SEMPRE que for criar ou atualizar documentação, quando uma decisão técnica relevante for tomada (vira ADR), quando um endpoint for criado ou alterado, quando uma regra de negócio não óbvia for implementada, ou ao terminar algo que muda como o sistema é usado, configurado ou executado.
---
# Escrevendo documentação

## Princípios

- **O porquê mora em `docs/`, nunca em comentário no código.** O código não tem comentários (`AGENTS.md`, regra 2). O nome explica o quê; o doc explica a decisão e o que é frágil.
- **Índice e detalhe.** O `AGENTS.md` é o índice: uma linha por doc, com "leia quando". O detalhe mora num arquivo pequeno e focado, para que o agente carregue só o que a tarefa toca. Doc que passa de uns 15 KB se divide por assunto.
- **O doc descreve como o sistema está**, não a história de como chegou lá. Histórico fica no Git e no roadmap.
- **Uma ideia mora num lugar só;** nos outros, link.
- **Nada de número que envelhece:** contagem de arquivos, "verificado em N pontos", data de quando alguém conferiu.
- **Escreva para quem chega amanhã sem contexto.** A primeira pergunta é "como eu rodo isso?".
- **Todo comando citado funciona** se for copiado e colado. Teste antes.
- **Documentação muda no mesmo PR** que muda o comportamento.
- **Português, frases curtas, exemplo antes de descrição.** Sem emoji em título.

## Onde vai cada coisa

Projeto que já tem estrutura própria de docs (numerada, com outros nomes) mantém a dele: os nomes abaixo valem só para quem ainda não tem equivalente, e o Índice do `AGENTS.md` aponta para o arquivo real.

| Situação | Onde |
| --- | --- |
| Regra que todo agente precisa em toda sessão | Uma linha no `AGENTS.md`, com link para o detalhe em `docs/` |
| Regra de negócio, fluxo, armadilha ou porquê de um domínio | `docs/dominios/<dominio>.md`, a partir de `templates/DOMINIO.md`, e uma linha na tabela de domínios do `AGENTS.md` |
| Decisão transversal, que cruza domínios | `docs/ARCHITECTURE.md`, na seção do assunto |
| Decisão estrutural, difícil de reverter (biblioteca, arquitetura, modelagem) | Novo ADR em `docs/adr/NNNN-titulo.md`, a partir de `templates/ADR.md` |
| Regra de segurança do projeto | `docs/seguranca.md` (a skill `secure-coding` serve de base) |
| Serviço novo, ou mudança em setup, variável de ambiente ou comando | README, a partir de `templates/README.md`, e `.env.example` |
| Endpoint criado ou alterado | Anotações do Swagger ou o OpenAPI, se o projeto tiver; senão `templates/API_ENDPOINT.md` |
| Mudança visível para quem usa ou consome a API | `CHANGELOG.md`, no formato Keep a Changelog |

Leia o template antes de escrever e mantenha a estrutura dele.

## Regras

- `AGENTS.md` é carregado em toda sessão: fica curto e não recebe histórico. Muda quando muda regra, comando ou molde.
- ADR aceito não se edita. Se a decisão mudar, escreva outro ADR que substitui o anterior e marque o antigo como substituído.
- Mudança de contrato que quebra web ou mobile é marcada como **BREAKING** no changelog e no endpoint.
- Exemplo nunca leva segredo real: use valor fictício, como no `.env.example`.
