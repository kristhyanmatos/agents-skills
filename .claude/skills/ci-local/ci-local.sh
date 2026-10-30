#!/usr/bin/env bash
set -uo pipefail

export CI=true
raiz="$(git -C "${1:-.}" rev-parse --show-toplevel 2>/dev/null || (cd "${1:-.}" && pwd))"
logs="$(mktemp -d)"
falhas=0
puladas=0

caminho_legivel() {
  cygpath -w "$1" 2>/dev/null || printf '%s' "$1"
}

etapa() {
  local nome="$1" pasta="$2"
  shift 2
  local log="$logs/${nome//[^[:alnum:]]/_}.log"
  local inicio=$SECONDS
  if (cd "$pasta" && "$@") </dev/null >"$log" 2>&1; then
    printf 'ok      %-50s %4ss\n' "$nome" "$((SECONDS - inicio))"
  else
    printf 'FALHA   %-50s %4ss  %s\n' "$nome" "$((SECONDS - inicio))" "$(caminho_legivel "$log")"
    tail -n 25 "$log" | sed 's/^/        /'
    falhas=$((falhas + 1))
  fi
}

pular() {
  printf 'pulada  %-50s sem %s\n' "$1" "$2"
  puladas=$((puladas + 1))
}

opcional() {
  local ferramenta="$1"
  shift
  if command -v "$ferramenta" >/dev/null 2>&1; then
    etapa "$@"
  else
    pular "$1" "$ferramenta"
  fi
}

rotulo() {
  local relativo="${2#"$raiz"}"
  relativo="${relativo#/}"
  printf '%s%s' "$1" "${relativo:+ ($relativo)}"
}

alvo_make() {
  [ -f "$1/Makefile" ] || return 0
  if grep -qE '^ci:' "$1/Makefile"; then
    echo ci
  elif grep -qE '^check:' "$1/Makefile"; then
    echo check
  fi
}

gerenciador() {
  if [ -f "$1/pnpm-lock.yaml" ]; then
    echo pnpm
  elif [ -f "$1/yarn.lock" ]; then
    echo yarn
  else
    echo npm
  fi
}

tem_script() {
  (cd "$1" && node -e 'const s = require("./package.json").scripts || {}; process.exit(s[process.argv[1]] ? 0 : 1)' "$2") 2>/dev/null
}

go_ci() {
  local p="$1" r alvo
  r="$(rotulo go "$p")"
  command -v go >/dev/null 2>&1 || { pular "$r" go; return; }
  alvo="$(alvo_make "$p")"
  if [ -n "$alvo" ]; then
    opcional make "$r: make $alvo" "$p" make "$alvo"
    return
  fi
  etapa "$r: gofmt" "$p" bash -c 'pendentes=""; while IFS= read -r f; do [ -z "$(tr -d "\r" < "$f" | gofmt -l)" ] || pendentes="$pendentes $f"; done < <(git ls-files "*.go" 2>/dev/null || find . -name "*.go" -not -path "./vendor/*"); [ -z "$pendentes" ] || { echo "gofmt pendente:$pendentes"; exit 1; }'
  etapa "$r: go vet" "$p" go vet ./...
  opcional golangci-lint "$r: golangci-lint" "$p" golangci-lint run
  opcional govulncheck "$r: govulncheck" "$p" govulncheck ./...
  if [ "$(cd "$p" && go env CGO_ENABLED)" = 1 ]; then
    etapa "$r: go test -race" "$p" go test -race ./...
  else
    etapa "$r: go test (sem -race: falta gcc)" "$p" go test ./...
  fi
}

node_ci() {
  local p="$1" r pm s
  r="$(rotulo web "$p")"
  pm="$(gerenciador "$p")"
  command -v node >/dev/null 2>&1 || { pular "$r" node; return; }
  command -v "$pm" >/dev/null 2>&1 || { pular "$r" "$pm"; return; }
  if [ ! -d "$p/node_modules" ]; then
    if [ "$pm" = npm ]; then
      etapa "$r: npm ci" "$p" npm ci
    else
      etapa "$r: $pm install" "$p" "$pm" install --frozen-lockfile
    fi
  fi
  if tem_script "$p" ci; then
    etapa "$r: $pm run ci" "$p" "$pm" run ci
    return
  fi
  if tem_script "$p" check; then
    etapa "$r: $pm run check" "$p" "$pm" run check
  else
    for s in lint typecheck test; do
      tem_script "$p" "$s" && etapa "$r: $pm run $s" "$p" "$pm" run "$s"
    done
  fi
  tem_script "$p" build && etapa "$r: $pm run build" "$p" "$pm" run build
  case "$pm" in
    npm) etapa "$r: npm audit" "$p" npm audit --omit=dev --audit-level=high ;;
    pnpm) etapa "$r: pnpm audit" "$p" pnpm audit --prod --audit-level high ;;
  esac
}

dart_ci() {
  local p="$1" r
  r="$(rotulo mobile "$p")"
  if grep -qE 'sdk:[[:space:]]*flutter' "$p/pubspec.yaml"; then
    command -v flutter >/dev/null 2>&1 || { pular "$r" flutter; return; }
    etapa "$r: dart format" "$p" dart format --output=none --set-exit-if-changed .
    etapa "$r: flutter analyze" "$p" flutter analyze
    [ -d "$p/test" ] && etapa "$r: flutter test" "$p" flutter test
  else
    command -v dart >/dev/null 2>&1 || { pular "$r" dart; return; }
    etapa "$r: dart format" "$p" dart format --output=none --set-exit-if-changed .
    etapa "$r: dart analyze" "$p" dart analyze --fatal-infos
    [ -d "$p/test" ] && etapa "$r: dart test" "$p" dart test
  fi
}

encontrar() {
  find "$raiz" -maxdepth 3 \( -name node_modules -o -name .git -o -name vendor -o -name build -o -name dist -o -name .next -o -name .dart_tool \) -prune -o -name "$1" -print
}

printf 'CI local em %s\n\n' "$(caminho_legivel "$raiz")"

alvo_raiz="$(alvo_make "$raiz")"
if [ -n "$alvo_raiz" ] && [ ! -f "$raiz/go.mod" ]; then
  opcional make "make $alvo_raiz" "$raiz" make "$alvo_raiz"
else
  achou=0
  while IFS= read -r arquivo; do achou=1; go_ci "$(dirname "$arquivo")"; done < <(encontrar go.mod)
  while IFS= read -r arquivo; do achou=1; node_ci "$(dirname "$arquivo")"; done < <(encontrar package.json)
  while IFS= read -r arquivo; do achou=1; dart_ci "$(dirname "$arquivo")"; done < <(encontrar pubspec.yaml)
  if [ "$achou" = 0 ]; then
    echo "Nenhum go.mod, package.json, pubspec.yaml ou alvo ci/check no Makefile encontrado."
    exit 2
  fi
  [ -n "$alvo_raiz" ] || opcional gitleaks "segredos: gitleaks" "$raiz" gitleaks git --no-banner --redact
fi
[ -d "$raiz/.github/workflows" ] && opcional actionlint "workflows: actionlint" "$raiz" actionlint

echo
if [ "$falhas" -gt 0 ]; then
  echo "CI local: VERMELHO ($falhas falha(s), $puladas pulada(s)). Logs em $(caminho_legivel "$logs")"
  exit 1
fi
rm -rf "$logs"
if [ "$puladas" -gt 0 ]; then
  echo "CI local: VERDE, mas $puladas etapa(s) pulada(s); instale o que falta para ter o resultado do CI."
else
  echo "CI local: VERDE"
fi
