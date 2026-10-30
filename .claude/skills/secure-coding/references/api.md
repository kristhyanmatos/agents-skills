# Segurança no backend (API)

## 1. Autenticação (A07)

- **Negar por padrão.** Rota nova passa pelo middleware de autenticação ou por um mais restrito. Rota pública precisa de justificativa no PR.
- **Login, recuperação de senha e código de verificação têm limite de requisições** por IP e por conta, com 429 e `Retry-After`. O IP vem do endereço da conexão; o `X-Forwarded-For` só vale vindo de proxy confiável configurado.
- **Mensagem de login não revela** se a conta existe.
- **Senha com argon2id ou bcrypt**, nos parâmetros mínimos da OWASP. Nunca hash rápido (MD5, SHA-1, SHA-256 puro) para senha.
- **Segredo se gera com `crypto/rand`** (`rand.Text()`). CUID e `math/rand` são previsíveis e servem só para ID.
- **Sessão com estado no servidor.** O banco guarda só o hash do token; logout apaga a sessão. JWT, se o projeto usar, tem algoritmo fixo, `exp`, `iss` e `aud` conferidos e expiração curta.
- **Login social** confere a audiência (client ID), o e-mail verificado e identifica a conta pelo `sub`, não pelo e-mail.
- **Comparação de segredo** em tempo constante (`subtle.ConstantTimeCompare`).

## 2. Autorização e isolamento (A01)

- **Quem autoriza é o servidor**, em toda rota.
- **Identidade vem da sessão.** Usuário, dono e tenant saem do contexto que o middleware preencheu, nunca do corpo, da query ou de um cabeçalho lido pelo handler.
- **Toda consulta por ID filtra também pelo dono ou pelo tenant** (`WHERE id = $1 AND sistema_id = $2`). ID difícil de adivinhar não é autorização.
- **Sem acesso e não encontrado respondem igual: 404.** Um 403 para o ID de outro tenant confirma que ele existe.
- **Ação de gestão** (agir em nome de outro, mudar papel) confere no service que quem pede pode fazer isso.
- **Menor privilégio.** Papel padrão só recebe permissão que pode ser dada a qualquer conta. Permissão nova entra numa lista conhecida; outra responde 400.
- **Teste de isolamento:** toda rota registrada entra numa matriz que tenta acessá-la com dados de outro usuário e de outro tenant, e o teste falha se uma rota ficar de fora.

## 3. Entrada (A05, A06)

- **Valide na borda**, com allowlist: tipo, formato, faixa e tamanho. Texto livre tem máximo (por exemplo, 200 para nome, 254 para e-mail, 2.048 para URL); valor enumerado é `oneof`.
- **Corpo tem limite global** (por exemplo, 1 MB, com 413); só upload tem teto próprio. Lista recebida tem máximo; paginação tem tamanho e página máximos.
- **Entrada vira DTO de entrada** com só os campos permitidos (`DisallowUnknownFields`). Nunca faça bind direto na entidade: é assim que alguém altera `papel`, `dono` ou `preco`.
- **Data ou número inválido responde 400**, nunca vira `NULL` ou zero em silêncio. `strconv.ParseInt(v, 10, 32)` para `int32`, nunca conversão sem checar a faixa.
- **Valor que vira cast no SQL é validado antes de gravar:** um valor fora da faixa derruba a consulta inteira, não só a linha.
- **URL que vira link num front** só aceita `http` e `https`, com host, conferidos com `url.Parse`.
- **Nada de dado do usuário montando** SQL, comando de shell, caminho de arquivo, URL de redirect ou HTML. Caminho de arquivo com dado externo passa por `os.Root` (Go 1.24+) ou é resolvido e conferido contra o diretório base. Comando externo com `exec.Command` e argumentos separados, nunca por shell.
- **URL buscada pelo servidor** (webhook, imagem remota) passa por allowlist de hosts e bloqueia IP interno e de metadados (SSRF).
- **Upload:** tipo detectado pelos bytes contra uma allowlist, tamanho máximo, nome e caminho gerados pelo servidor, download com `Content-Disposition: attachment`.
- **Parser de texto do cliente** (data, hora, filtro, documento) ganha alvo de fuzzing.

## 4. Saída e erros (A10)

- **Erro interno não volta para o cliente.** Domínio vira 4xx com mensagem amigável; o resto vira 500 genérico e vai para o log com o ID da requisição. Nunca devolva `err.Error()`, stack trace ou mensagem de outro serviço.
- **Resposta tem tipo próprio**, não a struct do banco, para que coluna nova não vire campo público sem decisão.
- **Falha fecha, não abre:** erro ao checar permissão nega o acesso.
- **Mudança no nome ou na caixa de uma chave da resposta quebra os clientes:** só entra junto com eles e vai destacada no PR.

## 5. Banco de dados (A05)

- **SQL só parametrizado** (sqlc, `$1`). Nunca `fmt.Sprintf` ou concatenação. Coluna ou ordenação dinâmica vem de allowlist.
- **Consulta tem limite de tempo** (`statement_timeout`); carga pesada em pool separado para não esgotar as conexões do login.
- **Usuário do app com menor privilégio:** sem superuser e sem DDL em execução. Fora do ambiente local, conexão com TLS.
- **Escritas dependentes numa transação.** Referência entre tabelas de tenant inclui o tenant na FK.
- **Dado sensível** (documento, saúde, financeiro) cifrado quando a lei ou o risco pedem. Cartão nunca é guardado: fica tokenizado no gateway.

## 6. Criptografia (A04)

- Nunca invente criptografia. Use a biblioteca padrão ou uma consagrada, com AES-GCM ou ChaCha20-Poly1305 para cifrar e HMAC-SHA-256 para assinar.
- Chave vem da configuração, nunca do código, e tem rotação prevista.
- Só HTTPS. Nunca desligue a validação de certificado, nem em teste que vá para o repositório.

## 7. Segredos e configuração (A02)

- **Segredo não entra em código, teste, log, commit, documentação ou resposta.** `.env*` nunca é versionado; os nomes ficam no `.env.example`, com valor fictício.
- **Variável nova** vai para o `.env.example` e para o deploy, e é lida e validada na subida. Faltou a obrigatória ou veio inválida, o app não sobe.
- **CORS por lista** de origens exatas (`esquema://host[:porta]`), validada na subida. Nunca `*`, regex ou função que aceite qualquer origem.
- **Cabeçalhos em toda resposta:** `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Referrer-Policy: no-referrer` e `Content-Security-Policy: default-src 'none'; frame-ancestors 'none'`. Resposta autenticada leva `Cache-Control: no-store`. HSTS no proxy.
- **Cookie de sessão** `HttpOnly`, `Secure` e `SameSite=Lax` ou `Strict`. Rota mutável autenticada por cookie tem proteção CSRF.
- **Documentação interativa** (Swagger) só fora de produção.
- **CORS, cabeçalhos, proxies confiáveis e middlewares globais** só mudam em PR dedicado, com o motivo na descrição.
- **Segredo vazado é revogado e trocado.** Apagar do histórico não basta.

## 8. Logs e auditoria (A09)

- **Log estruturado em JSON** (`log/slog`), com atributos, não texto formatado.
- **Toda requisição tem ID** (`X-Request-ID`), devolvido no cabeçalho e presente em todo log dela, com método, caminho, status, duração, usuário, tenant e IP.
- **Ação sensível deixa rastro** depois do sucesso: login aceito e recusado, mudança de papel e permissão, toda exclusão. Padrão do nome: `recurso.particípio` (`papel.alterado`).
- **Nunca registre** token, senha, `.env`, cabeçalho `Authorization` ou corpo com dado pessoal (CPF, e-mail, telefone, endereço). Um teste confere que o token não aparece no log.
- **Dado pessoal (LGPD):** colete o mínimo, mostre mascarado quando possível e saiba responder onde ele está para atender um pedido de exclusão.
