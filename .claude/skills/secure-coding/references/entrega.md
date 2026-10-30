# Segurança na entrega (dependências, CI e infraestrutura)

## 1. Dependências e cadeia de suprimentos (A03, A08)

- **Dependência nova precisa de justificativa** no PR: mantenedor ativo, licença compatível, tamanho aceitável e nenhuma alternativa na biblioteca padrão.
- **Varredura de vulnerabilidade** na verificação local e no CI: `govulncheck ./...` no Go, `npm audit --omit=dev` no web e `osv-scanner` para o `pubspec.lock`.
- **Lockfile versionado** e instalação reprodutível (`npm ci`, `go mod verify`). Lockfile não muda sem o manifesto, nem o contrário.
- **Varredura de segredos** (`gitleaks`) na verificação local e no CI. Um achado só vai para o arquivo de exceções depois de conferido como falso positivo, com o motivo no PR. Segredo real é revogado, não ignorado.

## 2. CI (A08)

- **Action do GitHub fixada pelo SHA do commit**, com a versão na mesma linha.
- **Runner self-hosted nunca roda em `pull_request`.** Workflow disparado por PR usa runner hospedado.
- Permissões do workflow no mínimo (`permissions:` explícito); segredo só no job que precisa.
- CI e deploy só mudam com pedido explícito e motivo na descrição.

## 3. Imagens e containers (A02)

- **Imagem sempre com versão** no `FROM` e no compose; nunca `latest` nem imagem sem tag.
- **Container sem root** em produção.
- **Health check sem detalhe:** responde só ok ou indisponível; a causa vai para o log. O deploy espera o container ficar saudável.

## 4. Rede e servidor (A02)

- **Banco e storage só em rede interna**, fora da rede compartilhada com o proxy.
- HSTS e TLS no proxy; a aplicação confia só nos proxies listados.
- Publicar em produção só pelo workflow de deploy.
