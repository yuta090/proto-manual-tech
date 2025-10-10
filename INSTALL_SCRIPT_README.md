# AI開発環境 自動セットアップスクリプト

Win/Mac対応の、AI開発に必要なツールを一括で自動インストールするスクリプトです。
**おしゃれなアニメーション付き**で、楽しくワクワクしながらセットアップできます！

![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Windows-blue)
![License](https://img.shields.io/badge/license-MIT-green)

---

## 🚀 インストールされるツール

| ツール | 説明 | 用途 |
|-------|------|------|
| **Node.js 18+** | JavaScriptランタイム | Claude Code, Codex CLI実行環境 |
| **Git** | バージョン管理システム | コード管理、GitHub連携 |
| **GitHub CLI** | GitHub公式CLIツール | GitHub認証、SSH鍵自動生成・登録 |
| **Claude Code** | AnthropicのAI開発CLI | AI支援コーディング |
| **Super Claude** | Claude Code拡張フレームワーク | 高度な開発支援機能 |
| **Cursor IDE** | AIファーストコードエディタ | 統合開発環境 |
| **OpenAI Codex CLI** | OpenAIコーディングエージェント | AIコーディング支援 |

---

## ✨ スクリプトの特徴

✅ **アカウント登録ガイド**: Claude Pro/GitHub/ChatGPT Plus の登録を段階的にサポート
✅ **SSH鍵自動設定**: GitHub CLI が SSH鍵を自動生成・登録（初心者でも簡単）
✅ **レジューム機能**: 中断しても続きから再開可能
✅ **冪等性**: 何度実行しても安全（既存インストールは自動スキップ）
✅ **対話型認証**: 認証完了まで待機、完了後自動で次へ進む
✅ **進捗表示**: プログレスバー + おしゃれなアニメーション
✅ **詳細ログ**: `.install_progress.json` に全実行履歴を記録
✅ **エラーハンドリング**: 失敗時も安全に処理

---

## 📋 前提条件

### 共通
- インターネット接続
- **重要**: Claude Pro アカウント登録が必要（スクリプトがガイドします）

### macOS
- macOS 11 (Big Sur) 以降

### Windows
- Windows 10 (1809以降) または Windows 11
- **Winget** が利用可能（通常は標準搭載）

### 必要なアカウント（スクリプトが登録をガイド）
- **[必須]** Claude Pro（$20/月）- スクリプト起動時に登録ガイド
- **[推奨]** GitHub（無料）- Git連携用、スクリプトが登録をサポート
- **[任意]** ChatGPT Plus/Pro（$20/月）- Codex CLI使用時のみ

---

## 🎯 使い方

### macOS

1. **スクリプトに実行権限を付与**
```bash
chmod +x install-ai-dev-tools-mac.sh
```

2. **スクリプト実行**
```bash
./install-ai-dev-tools-mac.sh
```

3. **ガイドに従う**
   - アカウント登録ガイドが表示されます
   - Claude Pro（必須）→ GitHub（推奨）の順で登録
   - ツールのインストールが自動で進みます

### Windows

1. **PowerShellを管理者権限で起動**（推奨）
   - PowerShellを右クリック → **「管理者として実行」**

2. **スクリプト実行**
```powershell
.\install-ai-dev-tools-win.ps1
```

3. **実行ポリシーエラーが出た場合**
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\install-ai-dev-tools-win.ps1
```

4. **ガイドに従う**
   - アカウント登録ガイドが表示されます
   - Claude Pro（必須）→ GitHub（推奨）の順で登録
   - ツールのインストールが自動で進みます

---

## 📝 アカウント登録ガイド機能

スクリプト起動時に、必要なアカウントの登録をステップバイステップでガイドします。

### ステップ0: Claude Pro アカウント登録（必須）

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️  重要: Claude Pro アカウントが必要です
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Claude Code を使用するには Claude Pro（$20/月） の契約が必要です。
今からブラウザで登録ページを開きます。

登録ページを開きますか? (y/N):
```

**登録手順:**
1. **「Continue with Google」** ボタンをクリック
2. Googleアカウントでログイン
3. **「Upgrade to Claude Pro」** を選択（$20/月）
4. クレジットカード情報を入力
5. 登録完了後、ターミナルに戻って Enter を押す

### ステップ1: GitHub アカウント登録（推奨）

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
GitHub アカウント登録 (推奨)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

GitHub アカウントを持っていますか? (y/N):
```

- 既にアカウントがある場合: ユーザー名を入力
- まだアカウントがない場合: 新規登録をガイド

### ステップ2以降: ツールのインストール

アカウント登録完了後、自動でツールのインストールが始まります。

---

## 🔐 認証が必要なツール

スクリプト実行中、以下のツールで認証が必要になります。
認証が必要な箇所では**スクリプトが一時停止**し、手順がガイドされます。

### 1. Claude Code
- ブラウザが自動で開きます
- **Claude Pro アカウント**でログイン
- 認証完了後、元のターミナルに戻って Enter を押す

### 2. Codex CLI（オプション）
- Codex CLI インストール前に ChatGPT Plus/Pro 登録を促します
- ターミナルで `codex` コマンドを実行
- **ChatGPT Plus/Pro アカウント**でサインイン
- 認証完了後、元のターミナルに戻って Enter を押す

---

## 🎨 実行画面イメージ

```
    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║        AI Development Environment Setup Script           ║
    ║                     for macOS                             ║
    ║                                                           ║
    ║     Node.js | Git | Claude Code | Super Claude           ║
    ║           Cursor IDE | OpenAI Codex CLI                  ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝


🚀 AI開発環境のセットアップを開始します...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[1/6] Node.js のインストール
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙️ Node.js をインストール中... [⠋]
✅ Node.js v20.11.0 インストール完了
```

---

## 📂 生成されるファイル

スクリプト実行により、以下のファイルが生成されます：

### `.install_progress.json`
インストール状態を記録する JSON ファイル（自動生成）

```json
{
  "nodejs": {
    "installed": true,
    "version": "v20.11.0"
  },
  "git": {
    "installed": true,
    "configured": true,
    "ssh_key": true
  },
  "claude_code": {
    "installed": true,
    "authenticated": false  ← 認証待ちの場合 false
  },
  ...
}
```

このファイルがあることで、**中断しても続きから再開**できます。

---

## 🔄 中断後の再開方法

スクリプトを途中で止めた場合、**もう一度実行するだけ**でOK！

```bash
# macOS
./install-ai-dev-tools-mac.sh

# Windows
.\install-ai-dev-tools-win.ps1
```

スクリプトが `.install_progress.json` を読み込み、**完了済みのステップはスキップ**されます。

例：
```
🔄 前回の続きから再開します...

✅ Node.js - インストール済み (スキップ)
✅ Git - インストール済み (スキップ)
⏸️  Claude Code - 認証待ち

🔐 Claude Code 認証が必要です
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
...
```

---

## ⚙️ Git初期設定について

スクリプト実行中、**Git のユーザー名とメールアドレスの入力を求められます**。

```
📝 Git初期設定
ユーザー名を入力してください: Taro Yamada
メールアドレスを入力してください: taro@example.com
✅ Git設定完了
```

**なぜ必要？**
- GitHub にコミットする際、作者情報として使用されます
- GitHub アカウントと紐付けるため、**GitHub登録メールアドレス**を推奨します

**既に設定済みの場合**
- スクリプトが自動検出し、スキップします
- 変更したい場合は手動で `git config --global user.name "新しい名前"` を実行してください

---

## 🛠 トラブルシューティング

### macOS: Homebrew がインストールできない
```bash
# Xcode Command Line Tools を手動インストール
xcode-select --install
```

### Windows: Winget が見つからない
Windows 10/11 では通常標準搭載されていますが、ない場合：

1. Microsoft Store を開く
2. 「アプリ インストーラー」を検索してインストール

### Claude Code 認証に失敗する
- ブラウザでログインできているか確認
- Claude Pro プランに契約しているか確認
- ネットワーク接続を確認

### 管理者権限エラー（Windows）
PowerShell を**右クリック → 管理者として実行**してから再実行

### スクリプトが途中で止まった
安心してください！再度実行すれば、**続きから自動で再開**されます。

---

## 📚 インストール後の次のステップ

### 1. GitHub に接続できるか確認
```bash
ssh -T git@github.com
# "Hi username!" と表示されればSSH鍵が正しく設定されています
```

### 2. Claude Code を起動
```bash
claude-code
```

### 3. Super Claude のコマンドを確認
```bash
SuperClaude --help
```

### 4. Cursor IDE を起動
- **macOS**: アプリケーションフォルダから起動
- **Windows**: スタートメニューから起動

### 5. Codex CLI を起動（認証済みの場合）
```bash
codex
```

---

## 🎉 完了！

これであなたのPCに最新のAI開発環境が整いました！
**Happy Coding with AI!** ✨🚀

---

## 📖 詳細ドキュメント

より詳しい仕様や内部構造については、[docs/install-script-spec.md](docs/install-script-spec.md) をご覧ください。

---

## 📄 ライセンス

MIT License

---

## 🤝 サポート

問題が発生した場合や改善提案がある場合は、Issue を作成してください。
