# <Domínio>

<Uma frase: o que o domínio resolve e para quem.>

## Regras de negócio
- <regra, com o porquê quando não for óbvio>

## Fluxo
<estados e transições, numa lista ou tabela curta>

## Onde está no código
| O quê | Onde |
| --- | --- |
| Rotas | `modules/<dominio>/routes.go` |
| Regra | `modules/<dominio>/service.go` |
| Queries | `db/query/<dominio>.sql` |
| Tela web | `src/app/<rota>/` |
| Tela mobile | `lib/modules/<dominio>/` |

## Armadilhas
- <o que já quebrou ou é fácil de errar, e como não errar>

## Provado por
- <testes que provam as regras acima>
