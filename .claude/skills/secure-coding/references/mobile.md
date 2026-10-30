# Segurança no mobile (OWASP MASVS)

## 1. Armazenamento (MASVS-STORAGE)

- **Token e credencial só no `flutter_secure_storage`** (Keychain e Keystore). Nunca em `SharedPreferences`, arquivo ou banco local sem criptografia.
- Cache local guarda o mínimo de dado pessoal e é apagado no logout.

## 2. Segredos no binário (MASVS-RESILIENCE)

- **Tudo o que vai no binário é público:** APK e IPA se descompilam. Chave privada de API fica no backend, que faz a chamada ao terceiro.
- Release com `--obfuscate --split-debug-info=<pasta>`; guarde os símbolos fora do repositório.

## 3. Rede (MASVS-NETWORK)

- **Só HTTPS.** `badCertificateCallback` devolvendo `true` é proibido, inclusive em código de depuração que vá para o repositório.
- Pinning de certificado em app de risco alto (pagamento, saúde).
- A camada de rede espelha o cliente da API do web: mesmos cabeçalhos, mesmo tratamento de erro, sessão expirada leva ao login.

## 4. Entrada externa (MASVS-PLATFORM)

- **Deep link e payload de push são entrada externa:** valide o formato e confirme a sessão antes de qualquer ação sensível. Nunca execute ação só porque um link mandou.
- Conteúdo HTML em WebView só de origem confiável, com JavaScript desligado quando não for preciso.

## 5. Logs (MASVS-PRIVACY)

- **`print` e `debugPrint` aparecem no build de release.** Use um logger desligado em release e nunca registre token, senha ou dado pessoal.
- Crash reporting sem dado pessoal no contexto.

## 6. Autenticação (MASVS-AUTH)

- Biometria só como atalho para uma credencial guardada no armazenamento seguro, nunca como única checagem local de uma ação que o servidor deveria autorizar.
- Quem autoriza é a API; esconder botão no app é só conforto.
