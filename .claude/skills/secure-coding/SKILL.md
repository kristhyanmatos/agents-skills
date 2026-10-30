---
name: secure-coding
description: Base de segurança do time para Go com PostgreSQL, web em TypeScript e Flutter, organizada pelo OWASP Top 10:2025, OWASP API Security Top 10 e MASVS. Use SEMPRE que a mudança tocar autenticação, sessão, autorização, entrada externa, upload, SQL, segredo, criptografia, dado pessoal (LGPD), CORS, cabeçalhos, log, dependência, Docker ou CI, e em toda revisão de segurança. Use também como ponto de partida ao escrever o doc de segurança de um projeto.
---
# Codificação segura

O doc de segurança do projeto, apontado no Índice do `AGENTS.md`, prevalece; esta skill vale no que ele não cobrir. Parte do código antigo pode não seguir estas regras: não copie o padrão antigo.

Para cada mudança, responda: quem pode chamar isso, com que dados, e o que acontece se a entrada for maliciosa, enorme, repetida ou fora de ordem? O que vaza se der erro?

## O que ler

Leia só a referência da camada que a mudança toca. Os códigos entre parênteses nelas são do OWASP Top 10:2025.

| Referência | Leia quando a mudança toca |
| --- | --- |
| `references/api.md` | rota, autenticação, sessão, autorização, entrada, resposta de erro, SQL, criptografia, configuração, CORS, cabeçalhos, log ou auditoria no backend |
| `references/web.md` | tela, sessão no navegador, link ou HTML vindo de dado, chamada à API, variável de ambiente pública |
| `references/mobile.md` | token no app, armazenamento local, rede, deep link, push ou build de release |
| `references/entrega.md` | dependência, lockfile, Dockerfile, compose, CI ou deploy |

Ao escrever o doc de segurança de um projeto que ainda não tem um, use as seções das referências da camada dele como esqueleto e troque os exemplos pelos nomes reais (middlewares, funções, variáveis).

## Checklist rápido de revisão

- [ ] Rota nova autenticada e autorizada no servidor; consulta por ID filtra pelo dono ou tenant
- [ ] Identidade vem da sessão, não do request
- [ ] Entrada validada na borda, com tamanho máximo e DTO de entrada
- [ ] SQL parametrizado; nada de dado externo em shell, caminho, HTML, redirect ou URL
- [ ] Erro interno não volta para o cliente; resposta com tipo próprio
- [ ] Nenhum segredo ou dado pessoal em código, log, resposta ou bundle
- [ ] Limites: corpo, lista, paginação, timeout e taxa de requisições
- [ ] Ação sensível registrada em auditoria
- [ ] Dependência nova justificada e sem vulnerabilidade conhecida
- [ ] Teste de autorização: sem sessão, sem permissão e recurso de outro usuário ou tenant
