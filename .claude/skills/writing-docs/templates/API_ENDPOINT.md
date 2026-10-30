## `<MÉTODO> /caminho/{param}`

<O que faz, em uma frase.>

**Autenticação:** <obrigatória? qual middleware?>
**Autorização:** <qual permissão? a pessoa só acessa os próprios recursos ou os do tenant?>

### Parâmetros
| Nome | Onde | Tipo | Obrigatório | Limite | Descrição |
|---|---|---|---|---|---|

### Corpo da requisição
```json
{}
```

### Respostas
**200 OK**
```json
{}
```
| Status | Quando acontece | Corpo |
|---|---|---|
| 400 | entrada inválida | `{"error": "..."}` |
| 401 | sem sessão ou sessão expirada | |
| 403 | sem a permissão exigida | |
| 404 | recurso não existe ou é de outro usuário ou tenant | |
| 409 | conflito, como registro duplicado | |
| 413 | corpo acima do limite | |
| 429 | limite de requisições atingido, com `Retry-After` | |

### Limites
<tamanho máximo do corpo, itens por página (padrão e máximo), limite de requisições>

### Exemplo
```bash
curl -X <MÉTODO> "https://<host>/caminho" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{}'
```

### Observações
<idempotência, quem consome (web, mobile), auditoria registrada, BREAKING changes>
