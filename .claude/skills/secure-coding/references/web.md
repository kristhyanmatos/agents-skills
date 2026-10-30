# Segurança no web (navegador)

## 1. Sessão e autorização (A01, A07)

- **Quem autoriza é a API.** O que a tela esconde de quem não tem permissão é só conforto; a permissão nunca é conferida só na tela.
- **Token nunca em `localStorage`, `sessionStorage`, URL ou log.** Sessão em cookie `HttpOnly` definido pelo servidor, ou trocada no servidor (NextAuth e afins) sem expor o token da API ao JavaScript além do necessário.
- **Redirect depois do login só para rota interna** (caminho que começa com `/` e não com `//`).
- **Login e troca de token** só mudam com pedido explícito: é configuração de segurança.

## 2. Chamadas à API (A05)

- **Toda chamada passa pelo cliente da API do projeto**, que põe os cabeçalhos e trata os erros num lugar só.
- **Valor de fora nunca entra cru no caminho de uma chamada:** valide o formato ou codifique com `encodeURIComponent`. Um `../` num ID muda a rota chamada.
- **Resposta da API é validada com schema** (Zod) antes de ir para a tela.

## 3. Conteúdo na tela (A05)

- Deixe o framework escapar. Proibido `dangerouslySetInnerHTML`, `innerHTML`, `v-html`, `eval`, `new Function` e `setTimeout` com string vinda de fora. HTML inevitável passa pelo DOMPurify.
- **URL vinda de dado só vira link com esquema `http` ou `https`.** Um `javascript:` no `href` roda script com a sessão de quem clica.
- `target="_blank"` com `rel="noopener noreferrer"`.

## 4. Configuração e segredos (A02)

- **Toda variável `NEXT_PUBLIC_` ou `VITE_` vai para o bundle e é pública.** Segredo só em variável de servidor.
- `.env*` nunca é versionado; os nomes ficam no `.env.example`.
- **CSP sem `unsafe-inline` e `unsafe-eval`** sempre que o framework permitir; cabeçalhos de segurança configurados no servidor ou no proxy.
- `next.config`, middleware de autenticação e cabeçalhos só mudam em PR dedicado, com o motivo na descrição.

## 5. Dado pessoal (LGPD)

- Mostre mascarado quando possível (CPF, telefone) e não guarde no navegador o que não precisa.
- Nada de dado pessoal em log do navegador, analytics ou mensagem de erro.
