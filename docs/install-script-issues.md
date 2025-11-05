# install-ai-dev-tools スクリプトの既知の問題と対応履歴

## macOS 版 (`site/install-ai-dev-tools-mac.sh`)

- （修正済）`update_state` 関数で値を Python コードへ直埋めしていたために `NameError` が発生していた問題を、環境変数経由で安全に値を受け渡す実装に変更。
- （修正済）Codex CLI 導入手順を Homebrew 依存から `npm install -g @openai/codex` へ変更し、実際に取得できる配布形態に合わせた。
- （修正済）`pipx ensurepath` 後に現在のシェルへ `~/.local/bin` を追加することで、`SuperClaude` コマンド探索に必要なパスを即時反映。
- （修正済）Claude Pro 契約が未完了でも処理を継続できるようにし、後から手動登録できる導線を提示。

## Windows 版 (`site/install-ai-dev-tools-win.ps1`)

- （修正済）Claude Pro 登録を任意化し、未登録でも残りのツールをセットアップできるようにした。
- （修正済）管理者権限がない場合は明示的に再実行を求めて終了し、`winget` の失敗で途中停止しないようにした。
- （修正済）`install-ai-dev-tools-win-broken.ps1` を UTF-8 のプレースホルダーに差し替え、最新スクリプトへの誘導メッセージを表示。

## 修正状況メモ

- macOS 版: `update_state` の値埋め込みを Python で安全に処理するよう変更し、Codex CLI の導入経路を `npm install -g @openai/codex` に修正。`pipx` インストール直後に `PATH` を補正し、Claude Pro 登録は任意スキップ可能にした。
- Windows 版: Claude Pro 登録を任意化し、管理者権限がない場合は明示的に再実行を促して終了するよう変更。旧 `install-ai-dev-tools-win-broken.ps1` はプレースホルダーに差し替え済み。
