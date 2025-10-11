# AI開発環境 自動セットアップガイド

## 概要

このガイドでは、AI開発に必要なツールを一括で自動インストールするスクリプトの使い方を説明します。

**対応OS**:
- macOS 11 (Big Sur) 以降
- Windows 10 (1809以降) / Windows 11

**所要時間**: 約15-30分（ネットワーク速度による）

---

## インストールされるツール

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

## 事前準備

### 必須アカウント

インストール前に以下のアカウントを準備してください：

#### 1. Claude Pro（必須）
- **料金**: $20/月
- **登録URL**: https://claude.ai/
- **用途**: Claude Code の利用に必須
- **登録方法**:
  1. 「Continue with Google」でログイン
  2. 「Upgrade to Claude Pro」を選択
  3. クレジットカード情報を入力

#### 2. GitHub（推奨）
- **料金**: 無料
- **登録URL**: https://github.com/
- **用途**: コード管理、Git連携
- **注意**: スクリプトが登録をガイドします

#### 3. ChatGPT Plus/Pro（任意）
- **料金**: $20/月
- **登録URL**: https://chat.openai.com/
- **用途**: Codex CLI 使用時のみ必要
- **注意**: Codex CLI を使わない場合は不要

### システム要件

**macOS**:
- macOS 11 (Big Sur) 以降
- インターネット接続
- 管理者権限

**Windows**:
- Windows 10 (1809以降) または Windows 11
- Winget が利用可能（通常は標準搭載）
- インターネット接続
- 管理者権限（推奨）

---

## インストール手順

### macOS

#### 1. スクリプトをダウンロード

```bash
# スクリプトに実行権限を付与
chmod +x install-ai-dev-tools-mac.sh
```

#### 2. スクリプトを実行

```bash
./install-ai-dev-tools-mac.sh
```

#### 3. ガイドに従う

スクリプトが自動的に進行します。以下の2箇所で対話が必要です：

**① GitHub CLI 認証**
- 「GitHub 認証を開始しますか? (y/N):」→ `y` を入力
- 画面の指示に従って GitHub にログイン
- SSH鍵が自動生成・登録されます

**② Claude Code 認証**
- 「認証を開始しますか? (y/N):」→ `y` を入力
- ブラウザが開くので Claude Pro でログイン
- 認証完了後、自動で次へ進みます

### Windows

#### 1. PowerShell を管理者権限で起動

- PowerShell を右クリック → **「管理者として実行」**

#### 2. スクリプトを実行

```powershell
.\install-ai-dev-tools-win.ps1
```

**実行ポリシーエラーが出た場合**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\install-ai-dev-tools-win.ps1
```

#### 3. ガイドに従う

macOS版と同じく、以下の2箇所で対話が必要です：

**① GitHub CLI 認証**
- 「GitHub 認証を開始しますか? (y/N):」→ `y` を入力
- 画面の指示に従って GitHub にログイン
- SSH鍵が自動生成・登録されます

**② Claude Code 認証**
- 「認証を開始しますか? (y/N):」→ `y` を入力
- ブラウザが開くので Claude Pro でログイン
- 認証完了後、自動で次へ進みます

---

## インストールフロー詳細

スクリプトは以下の順序で実行されます：

### ステップ 0: アカウント登録ガイド

```
Claude Pro アカウント登録（必須）
├─ 登録ページを開くか確認
├─ ブラウザで登録手順を表示
└─ 登録完了後 Enter で次へ

GitHub アカウント登録（推奨）
├─ アカウントの有無を確認
├─ ない場合は登録をガイド
└─ ユーザー名を入力
```

### ステップ 1: Node.js インストール

```
✅ 完全自動（対話不要）
├─ macOS: Homebrew経由でインストール
├─ Windows: Winget経由でインストール
└─ バージョン確認: node --version
```

### ステップ 2: Git インストール

```
✅ 完全自動（対話不要）
├─ macOS: Homebrew経由でインストール
├─ Windows: Winget経由でインストール
├─ Git設定（名前・メールアドレス入力）
└─ バージョン確認: git --version
```

**Git設定例**:
```
ユーザー名を入力してください: Taro Yamada
メールアドレスを入力してください: taro@example.com
```

### ステップ 3: GitHub CLI インストール

```
✅ インストール: 完全自動
⚠️ 認証: 対話型（SSH鍵自動生成）

手順:
1. gh auth login コマンド実行
2. GitHub.com を選択
3. HTTPS を選択
4. Login with a web browser を選択
5. 表示されるコードをコピー
6. ブラウザで GitHub にログイン
7. コードを貼り付けて認証
8. SSH鍵が自動で生成・登録される
```

**重要**: この手順により、手動でのSSH鍵生成作業が不要になります。

### ステップ 4: Claude Code インストール

```
✅ インストール: 完全自動（npm install）
⚠️ 認証: 対話型（Claude Pro必須）

手順:
1. claude-code コマンド実行
2. 質問に答える
3. ブラウザが開く
4. Claude Pro でログイン
5. 認証完了後、自動で次へ進む
```

### ステップ 5: Super Claude インストール

```
✅ 完全自動（対話不要）
├─ pipx 経由でインストール
├─ --quick --yes オプションで自動設定
├─ Core framework インストール
├─ MCP servers インストール
│   ├─ Context7
│   ├─ Sequential
│   ├─ Magic
│   └─ Playwright
└─ Slash commands セットアップ
```

### ステップ 6: Cursor IDE インストール

```
✅ 完全自動（対話不要）
├─ macOS: Homebrew Cask経由
├─ Windows: Winget経由
└─ 初回起動は手動（ユーザーが後で実行）
```

**注意**: Cursor は自動起動しません。インストール後、手動で起動してください。

### ステップ 7: Codex CLI インストール（オプション）

```
⚠️ ChatGPT Plus/Pro 登録確認
├─ 登録済み → インストール実行
└─ 未登録 → スキップ可能

✅ インストール: 完全自動（npm install）
⚠️ 認証: 手動（後で実行）
└─ 後で codex コマンドで認証
```

---

## インストール後の確認

### 1. GitHub 接続確認

```bash
ssh -T git@github.com
```

**正常な応答**:
```
Hi username! You've successfully authenticated, but GitHub does not provide shell access.
```

### 2. Claude Code 起動

```bash
claude-code
```

認証済みの場合、正常に起動します。

### 3. Super Claude 確認

```bash
SuperClaude --help
```

利用可能なコマンド一覧が表示されます。

### 4. Cursor IDE 起動

- **macOS**: アプリケーションフォルダから起動
- **Windows**: スタートメニューから起動

初回起動時に設定ウィザードが表示されます。

### 5. Codex CLI 認証（インストール済みの場合）

```bash
codex
```

ChatGPT Plus/Pro アカウントでサインインします。

---

## トラブルシューティング

### macOS: Homebrew がインストールできない

**症状**: Homebrew のインストールに失敗する

**解決方法**:
```bash
# Xcode Command Line Tools を手動インストール
xcode-select --install
```

### Windows: Winget が見つからない

**症状**: winget コマンドが認識されない

**解決方法**:
1. Microsoft Store を開く
2. 「アプリ インストーラー」を検索
3. インストールまたは更新

### Claude Code 認証に失敗する

**症状**: 認証が完了しない

**確認事項**:
- ブラウザで正しくログインできているか
- Claude Pro プランに契約しているか
- ネットワーク接続は正常か

**解決方法**:
```bash
# 後で手動で認証
claude-code
```

### 管理者権限エラー（Windows）

**症状**: 「管理者権限が必要です」エラー

**解決方法**:
- PowerShell を右クリック → **「管理者として実行」**
- スクリプトを再実行

### スクリプトが途中で止まった

**心配不要**: スクリプトには**レジューム機能**があります。

**対処方法**:
1. もう一度スクリプトを実行
2. `.install_progress.json` を読み込み
3. 完了済みのステップは自動スキップ
4. 未完了のステップから再開

**例**:
```
🔄 前回の続きから再開します...

✅ Node.js - インストール済み (スキップ)
✅ Git - インストール済み (スキップ)
⏸️  GitHub CLI - 認証待ち

🔐 GitHub CLI 認証が必要です
...
```

---

## 自動化の詳細

### 完全自動化されているツール

以下のツールは**対話不要**で自動インストールされます：

| ツール | macOS | Windows |
|--------|-------|---------|
| Node.js | `brew install node` | `winget install --silent` |
| Git | `brew install git` | `winget install --silent` |
| GitHub CLI | `brew install gh` | `winget install --silent` |
| Claude Code | `npm install -g` | `npm install -g` |
| Super Claude | `pipx install` + `--quick --yes` | `pipx install` + `--quick --yes` |
| Cursor IDE | `brew install --cask` | `winget install --silent` |
| Codex CLI | `npm install -g` | `npm install -g` |

### 認証が必要なツール

以下のツールは**インストール後に認証**が必要です：

| ツール | 認証タイミング | 認証方法 |
|--------|---------------|----------|
| GitHub CLI | スクリプト実行中 | ブラウザで GitHub ログイン + SSH鍵自動設定 |
| Claude Code | スクリプト実行中 | ブラウザで Claude Pro ログイン |
| Cursor IDE | 初回起動時 | GUIで設定ウィザード |
| Codex CLI | ユーザーが後で実行 | `codex` コマンドで ChatGPT Plus/Pro ログイン |

---

## 進捗管理ファイル

スクリプトは `.install_progress.json` に状態を保存します：

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
    "authenticated": true
  }
}
```

このファイルにより：
- ✅ 中断しても続きから再開可能
- ✅ 完了済みステップは自動スキップ
- ✅ 何度実行しても安全（冪等性）

---

## 次のステップ

インストール完了後、以下のドキュメントを参照してください：

1. **Claude Code 使い方**: 基本的な使い方とコマンド
2. **Super Claude フレームワーク**: 高度な開発支援機能
3. **GitHub 連携**: リポジトリ操作とワークフロー
4. **Cursor IDE**: AI支援コーディングの実践

---

## よくある質問

### Q1: Claude Pro は必須ですか？

**A**: はい、Claude Code を使用するには Claude Pro（$20/月）の契約が必須です。

### Q2: GitHub アカウントは必須ですか？

**A**: 推奨ですが必須ではありません。ただし、Git連携やコード管理には GitHub アカウントが必要です。

### Q3: ChatGPT Plus は必要ですか？

**A**: Codex CLI を使用する場合のみ必要です。使わない場合はスキップできます。

### Q4: インストールに失敗したらどうすれば？

**A**: もう一度スクリプトを実行してください。レジューム機能により、完了済みのステップは自動スキップされ、失敗したステップから再開されます。

### Q5: 途中でやめたい場合は？

**A**: Ctrl+C でスクリプトを停止できます。次回実行時に続きから再開されます。

### Q6: アンインストール方法は？

**A**: 各ツールは標準的な方法でアンインストールできます：
- macOS: `brew uninstall [ツール名]`
- Windows: `winget uninstall [ツール名]`
- npm: `npm uninstall -g [ツール名]`
- pipx: `pipx uninstall [ツール名]`

---

## サポート

問題が発生した場合や改善提案がある場合は、Issue を作成してください。

**スクリプトバージョン**: 1.0
**最終更新**: 2025年
