# AI開発環境 自動セットアップスクリプト - 技術仕様書

## 目次
- [概要](#概要)
- [アーキテクチャ設計](#アーキテクチャ設計)
- [状態管理システム](#状態管理システム)
- [インストールフロー](#インストールフロー)
- [認証メカニズム](#認証メカニズム)
- [関数リファレンス](#関数リファレンス)
- [エラーハンドリング](#エラーハンドリング)
- [プラットフォーム別実装](#プラットフォーム別実装)

---

## 概要

### 目的
AI開発に必要な以下のツールを自動でインストールし、セットアップする:
- Node.js 18+
- Git
- Claude Code
- Super Claude
- Cursor IDE
- OpenAI Codex CLI

### 設計原則
1. **冪等性**: 何度実行しても安全（既にインストール済みのソフトはスキップ）
2. **レジューム性**: 中断しても続きから再開可能
3. **対話型認証**: 認証が必要な箇所で一時停止し、完了後自動で次へ進む
4. **進捗の可視化**: アニメーション付きの進捗表示でユーザー体験を向上
5. **クロスプラットフォーム**: macOS（Bash）とWindows（PowerShell）の両対応

---

## アーキテクチャ設計

### 全体構成図

```
┌─────────────────────────────────────────┐
│         User Execution                   │
│  ./install-ai-dev-tools-mac.sh          │
│  .\install-ai-dev-tools-win.ps1         │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│      State Initialization                │
│  - Create .install_progress.json        │
│  - Check for existing state              │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│    Install Check & Execution Loop        │
│  For each software:                      │
│   1. Check state                         │
│   2. Skip if installed                   │
│   3. Install if needed                   │
│   4. Update state                        │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│      Authentication Handling             │
│  - Pause script                          │
│  - Prompt user to authenticate           │
│  - Wait for confirmation                 │
│  - Verify authentication                 │
│  - Continue to next step                 │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│         Completion Report                │
│  - Display summary                       │
│  - Show installed versions               │
│  - Provide next steps                    │
└─────────────────────────────────────────┘
```

### コンポーネント構成

```
install-ai-dev-tools-{mac,win}.{sh,ps1}
├── Color Output Functions
│   ├── print_header()
│   ├── print_info()
│   ├── print_success()
│   ├── print_error()
│   └── print_section()
│
├── State Management Functions
│   ├── init_state()
│   ├── get_state()
│   ├── update_state()
│   └── has_state()
│
├── Installation Functions
│   ├── install_nodejs()
│   ├── install_git()
│   ├── install_claude_code()
│   ├── install_super_claude()
│   ├── install_cursor()
│   └── install_codex()
│
├── Utility Functions
│   ├── show_spinner()
│   ├── draw_progress_bar()
│   ├── check_command()
│   └── wait_for_authentication()
│
└── Main Execution Flow
    └── main()
```

---

## 状態管理システム

### `.install_progress.json` スキーマ

```json
{
  "nodejs": {
    "installed": false,
    "version": ""
  },
  "git": {
    "installed": false,
    "configured": false,
    "ssh_key": false
  },
  "claude_code": {
    "installed": false,
    "authenticated": false
  },
  "super_claude": {
    "installed": false,
    "mcp_servers_installed": false
  },
  "cursor": {
    "installed": false
  },
  "codex": {
    "installed": false,
    "authenticated": false
  }
}
```

### 状態遷移図

```
[未インストール]
    │
    ├─ installed: false
    │
    ▼ (インストール実行)
    │
[インストール済み]
    │
    ├─ installed: true
    ├─ version: "x.x.x"
    │
    ▼ (認証が必要な場合)
    │
[認証待ち]
    │
    ├─ authenticated: false
    │
    ▼ (ユーザー認証完了)
    │
[完全セットアップ完了]
    │
    └─ authenticated: true
```

### 状態管理関数

#### macOS (Bash)

```bash
# 状態ファイルの初期化
init_state() {
    if [[ ! -f "$STATE_FILE" ]]; then
        cat > "$STATE_FILE" << EOF
{
  "nodejs": {"installed": false, "version": ""},
  ...
}
EOF
    fi
}

# 状態の取得 (Python JSON パース)
get_state() {
    local key=$1
    local subkey=$2
    python3 -c "import json; data=json.load(open('$STATE_FILE')); print(data['$key']['$subkey'])"
}

# 状態の更新
update_state() {
    local key=$1
    local subkey=$2
    local value=$3
    python3 << EOF
import json
with open('$STATE_FILE', 'r') as f:
    data = json.load(f)
data['$key']['$subkey'] = $value
with open('$STATE_FILE', 'w') as f:
    json.dump(data, f, indent=2)
EOF
}
```

#### Windows (PowerShell)

```powershell
# 状態の取得
function Get-State {
    param(
        [string]$Key,
        [string]$SubKey
    )
    $state = Get-Content $StateFile | ConvertFrom-Json
    return $state.$Key.$SubKey
}

# 状態の更新
function Update-State {
    param(
        [string]$Key,
        [string]$SubKey,
        $Value
    )
    $state = Get-Content $StateFile | ConvertFrom-Json
    $state.$Key.$SubKey = $Value
    $state | ConvertTo-Json -Depth 10 | Out-File -FilePath $StateFile -Encoding UTF8
}
```

---

## インストールフロー

### 全体フロー

```
Start
  │
  ├─ 1. Display Banner
  ├─ 2. Initialize State File
  ├─ 3. Check for Resume
  │
  ▼
[Node.js]
  ├─ Check if installed
  ├─ Install via Homebrew/Winget
  ├─ Verify installation
  └─ Update state
  │
  ▼
[Git]
  ├─ Check if installed
  ├─ Install via Homebrew/Winget
  ├─ Configure user.name and user.email
  ├─ Generate SSH key (if needed)
  └─ Update state
  │
  ▼
[Claude Code]
  ├─ Check if installed
  ├─ Install via npm (global)
  ├─ PAUSE: Wait for user authentication
  ├─ Verify authentication with `claude-code --version`
  └─ Update state
  │
  ▼
[Super Claude]
  ├─ Check if installed
  ├─ Install via pipx
  ├─ Install with --force --yes flags
  ├─ Verify installation
  └─ Update state
  │
  ▼
[Cursor IDE]
  ├─ Check if installed
  ├─ macOS: Install via Homebrew cask
  ├─ Windows: Open download page (manual)
  └─ Update state
  │
  ▼
[OpenAI Codex CLI]
  ├─ Check if installed
  ├─ Install via npm (global)
  ├─ PAUSE: Wait for user authentication
  ├─ Verify authentication with `codex --version`
  └─ Update state
  │
  ▼
[Completion]
  ├─ Display summary
  ├─ Show installed versions
  └─ Provide next steps
  │
End
```

### 各ツールのインストール詳細

#### 1. Node.js

**macOS**:
```bash
install_nodejs() {
    if [[ $(get_state nodejs installed) == "True" ]]; then
        print_info "Node.js は既にインストールされています (スキップ)"
        return
    fi

    print_section "Node.js のインストール"
    brew install node

    local version=$(node --version)
    update_state nodejs installed True
    update_state nodejs version "$version"
    print_success "Node.js $version インストール完了"
}
```

**Windows**:
```powershell
function Install-NodeJS {
    if ((Get-State nodejs installed) -eq $true) {
        Write-Info "Node.js は既にインストールされています (スキップ)"
        return
    }

    Write-Section "Node.js のインストール"
    winget install OpenJS.NodeJS --silent

    # パスのリフレッシュ
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    $version = node --version
    Update-State nodejs installed $true
    Update-State nodejs version $version
    Write-Success "Node.js $version インストール完了"
}
```

#### 2. Git

**macOS**:
```bash
install_git() {
    if [[ $(get_state git installed) == "True" ]]; then
        print_info "Git は既にインストールされています (スキップ)"
    else
        print_section "Git のインストール"
        brew install git
        update_state git installed True
        print_success "Git インストール完了"
    fi

    # Git設定
    local git_name=$(git config --global user.name 2>/dev/null || echo "")
    local git_email=$(git config --global user.email 2>/dev/null || echo "")

    if [[ -z "$git_name" ]]; then
        echo -ne "${CYAN}ユーザー名を入力してください: ${RESET}"
        read git_name
        git config --global user.name "$git_name"
    else
        print_success "user.name: $git_name (設定済み)"
    fi

    if [[ -z "$git_email" ]]; then
        echo -ne "${CYAN}メールアドレスを入力してください: ${RESET}"
        read git_email
        git config --global user.email "$git_email"
    else
        print_success "user.email: $git_email (設定済み)"
    fi

    update_state git configured True

    # SSH鍵生成
    if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
        print_info "SSH鍵を生成しています..."
        ssh-keygen -t ed25519 -C "$git_email" -f "$HOME/.ssh/id_ed25519" -N ""
        update_state git ssh_key True
        print_success "SSH鍵生成完了"
    else
        print_info "SSH鍵は既に存在します (スキップ)"
    fi
}
```

#### 3. Claude Code (認証あり)

**macOS**:
```bash
install_claude_code() {
    if [[ $(get_state claude_code installed) == "True" ]]; then
        print_info "Claude Code は既にインストールされています (スキップ)"
    else
        print_section "Claude Code のインストール"
        npm install -g @anthropic/claude-code
        update_state claude_code installed True
        print_success "Claude Code インストール完了"
    fi

    if [[ $(get_state claude_code authenticated) == "True" ]]; then
        print_info "Claude Code 認証済み (スキップ)"
        return
    fi

    # 認証プロセス
    print_section "Claude Code 認証"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${CYAN}1. ブラウザが自動で開きます${RESET}"
    echo -e "${CYAN}2. Claude Pro アカウントでログインしてください${RESET}"
    echo -e "${CYAN}3. 認証が完了したら、このターミナルに戻ってください${RESET}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    # 認証コマンド実行（バックグラウンド）
    claude-code login &

    # 認証完了待ち
    while true; do
        echo -ne "\n${CYAN}認証が完了したら Enter を押してください...${RESET}"
        read

        if claude-code --version &> /dev/null; then
            print_success "認証成功！"
            update_state claude_code authenticated True
            break
        else
            print_error "認証が確認できませんでした。もう一度お試しください。"
        fi
    done
}
```

#### 4. Super Claude

**macOS**:
```bash
install_super_claude() {
    if [[ $(get_state super_claude installed) == "True" ]]; then
        print_info "Super Claude は既にインストールされています (スキップ)"
        return
    fi

    print_section "Super Claude のインストール"

    # pipx がインストールされているか確認
    if ! command -v pipx &> /dev/null; then
        print_info "pipx をインストールしています..."
        brew install pipx
        pipx ensurepath
    fi

    # Super Claude インストール (非対話モード)
    SuperClaude install --force --yes

    update_state super_claude installed True
    print_success "Super Claude インストール完了"
}
```

#### 5. Cursor IDE

**macOS**:
```bash
install_cursor() {
    if [[ $(get_state cursor installed) == "True" ]]; then
        print_info "Cursor IDE は既にインストールされています (スキップ)"
        return
    fi

    print_section "Cursor IDE のインストール"
    brew install --cask cursor

    update_state cursor installed True
    print_success "Cursor IDE インストール完了"
}
```

**Windows**:
```powershell
function Install-Cursor {
    if ((Get-State cursor installed) -eq $true) {
        Write-Info "Cursor IDE は既にインストールされています (スキップ)"
        return
    }

    Write-Section "Cursor IDE のインストール"
    Write-Warning "Cursor IDE は手動インストールが必要です"
    Write-Info "ブラウザでダウンロードページを開きます..."

    Start-Process "https://cursor.sh"

    Write-Info "ダウンロード・インストールが完了したら Enter を押してください..."
    Read-Host

    Update-State cursor installed $true
    Write-Success "Cursor IDE インストール完了"
}
```

#### 6. OpenAI Codex CLI (認証あり)

**macOS**:
```bash
install_codex() {
    if [[ $(get_state codex installed) == "True" ]]; then
        print_info "OpenAI Codex CLI は既にインストールされています (スキップ)"
    else
        print_section "OpenAI Codex CLI のインストール"
        npm install -g @openai/codex
        update_state codex installed True
        print_success "OpenAI Codex CLI インストール完了"
    fi

    if [[ $(get_state codex authenticated) == "True" ]]; then
        print_info "Codex CLI 認証済み (スキップ)"
        return
    fi

    # 認証プロセス
    print_section "Codex CLI 認証"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${CYAN}1. ターミナルで 'codex' コマンドを実行します${RESET}"
    echo -e "${CYAN}2. ChatGPT Plus/Pro アカウントでサインインしてください${RESET}"
    echo -e "${CYAN}3. 認証が完了したら、このターミナルに戻ってください${RESET}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    # 認証コマンド実行
    codex login &

    # 認証完了待ち
    while true; do
        echo -ne "\n${CYAN}認証が完了したら Enter を押してください...${RESET}"
        read

        if codex --version &> /dev/null; then
            print_success "認証成功！"
            update_state codex authenticated True
            break
        else
            print_error "認証が確認できませんでした。もう一度お試しください。"
        fi
    done
}
```

---

## 認証メカニズム

### 認証が必要なツール
1. **Claude Code**: Claude Pro アカウントが必要
2. **OpenAI Codex CLI**: ChatGPT Plus/Pro アカウントが必要

### 認証フロー

```
[インストール完了]
     │
     ▼
[認証コマンド実行]
  (バックグラウンド)
     │
     ▼
[スクリプト一時停止]
     │
     ├─ ユーザーへガイド表示
     ├─ ブラウザ/ターミナルで認証実行
     │
     ▼
[Enter待機ループ]
     │
     ├─ ユーザーがEnter押下
     │
     ▼
[認証検証]
  (--version コマンド)
     │
     ├─ 成功 → 状態更新 → 次へ進む
     └─ 失敗 → 再度Enter待機
```

### 認証検証方法

| ツール | 検証コマンド | 成功条件 |
|--------|--------------|----------|
| Claude Code | `claude-code --version` | 終了コード 0 |
| Codex CLI | `codex --version` | 終了コード 0 |

---

## 関数リファレンス

### 出力関数（macOS）

```bash
# ANSIカラーコード定義
RESET="\033[0m"
BOLD="\033[1m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
CYAN="\033[36m"

# ヘッダー表示
print_header() {
    echo -e "${BOLD}${BLUE}$1${RESET}"
}

# 情報表示
print_info() {
    echo -e "${CYAN}ℹ️  $1${RESET}"
}

# 成功表示
print_success() {
    echo -e "${GREEN}✅ $1${RESET}"
}

# エラー表示
print_error() {
    echo -e "${RED}❌ $1${RESET}"
}

# セクション区切り
print_section() {
    echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BOLD}${BLUE}[$1]${RESET}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
}
```

### 出力関数（Windows）

```powershell
# カラー定義
$ColorInfo = "Cyan"
$ColorSuccess = "Green"
$ColorError = "Red"
$ColorWarning = "Yellow"
$ColorHeader = "Blue"

# 情報表示
function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor $ColorInfo
}

# 成功表示
function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor $ColorSuccess
}

# エラー表示
function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor $ColorError
}

# セクション表示
function Write-Section {
    param([string]$Title)
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor $ColorWarning
    Write-Host "[$Title]" -ForegroundColor $ColorHeader
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor $ColorWarning
}
```

### アニメーション関数

**スピナー（macOS）**:
```bash
show_spinner() {
    local pid=$1
    local message=$2
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0

    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 10 ))
        echo -ne "\r${CYAN}${message} [${spin:$i:1}]${RESET}"
        sleep 0.1
    done
    echo -ne "\r"
}
```

**プログレスバー（macOS）**:
```bash
draw_progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))

    echo -ne "\r${CYAN}["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    echo -ne "] ${percentage}%${RESET}"
}
```

---

## エラーハンドリング

### エラー分類

| エラーカテゴリ | 例 | 対処方法 |
|----------------|----|-----------|
| **インストール失敗** | Homebrew/Wingetエラー | エラーメッセージ表示、スクリプト継続 |
| **認証失敗** | Claude Code認証タイムアウト | 再試行プロンプト、無限ループで待機 |
| **設定エラー** | Git設定の入力ミス | 再入力プロンプト |
| **状態ファイル破損** | JSONパースエラー | 状態ファイル再初期化 |

### エラーハンドリング例

**macOS**:
```bash
install_nodejs() {
    if ! brew install node; then
        print_error "Node.jsのインストールに失敗しました"
        print_info "手動でインストールしてください: https://nodejs.org/"
        return 1
    fi
}
```

**Windows**:
```powershell
function Install-NodeJS {
    try {
        winget install OpenJS.NodeJS --silent
        Write-Success "Node.js インストール完了"
    } catch {
        Write-Error "Node.jsのインストールに失敗しました"
        Write-Info "手動でインストールしてください: https://nodejs.org/"
        return
    }
}
```

---

## プラットフォーム別実装

### macOS (Bash)

**必須環境**:
- macOS 11 (Big Sur) 以降
- Homebrew (自動インストール)
- Python 3 (プリインストール)

**パッケージマネージャー**:
```bash
# Homebrew がなければインストール
if ! command -v brew &> /dev/null; then
    echo "Homebrew をインストールしています..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
```

**インストールコマンド**:
```bash
brew install node          # Node.js
brew install git           # Git
npm install -g @anthropic/claude-code  # Claude Code
brew install pipx          # pipx
pipx install SuperClaude   # Super Claude
brew install --cask cursor # Cursor IDE
npm install -g @openai/codex  # Codex CLI
```

### Windows (PowerShell)

**必須環境**:
- Windows 10 (1809以降) または Windows 11
- Winget (標準搭載)
- 管理者権限推奨

**パッケージマネージャー**:
```powershell
# Winget の確認
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "Winget がインストールされていません"
    Write-Info "Microsoft Store から 'アプリ インストーラー' をインストールしてください"
    exit 1
}
```

**インストールコマンド**:
```powershell
winget install OpenJS.NodeJS --silent  # Node.js
winget install Git.Git --silent        # Git
npm install -g @anthropic/claude-code  # Claude Code
pip install pipx                       # pipx
pipx install SuperClaude               # Super Claude
# Cursor IDE: 手動ダウンロード（https://cursor.sh）
npm install -g @openai/codex           # Codex CLI
```

**パスのリフレッシュ**:
```powershell
# インストール後、PowerShellのPATH環境変数を更新
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

---

## パフォーマンス最適化

### 並列処理の考慮

現在の実装は順次実行ですが、以下の最適化が可能:

**macOS (バックグラウンドジョブ)**:
```bash
# 並列インストール（認証不要なものだけ）
install_nodejs &
PID_NODE=$!

install_git &
PID_GIT=$!

# 完了待ち
wait $PID_NODE
wait $PID_GIT
```

**Windows (ジョブ管理)**:
```powershell
# 並列実行
$jobs = @()
$jobs += Start-Job -ScriptBlock { Install-NodeJS }
$jobs += Start-Job -ScriptBlock { Install-Git }

# 完了待ち
$jobs | Wait-Job | Receive-Job
```

### キャッシュ戦略

**Homebrewキャッシュ**:
```bash
# Homebrew のボトルキャッシュを活用
export HOMEBREW_NO_AUTO_UPDATE=1  # 自動更新を無効化（高速化）
```

**状態ファイルの最適化**:
- 状態ファイルは軽量（<1KB）
- JSON形式で高速パース
- Python標準ライブラリのみ使用（外部依存なし）

---

## セキュリティ考慮事項

### 認証情報の取り扱い

**保存しない情報**:
- Claude Pro パスワード
- ChatGPT Plus/Pro パスワード
- GitHub Personal Access Token

**保存する情報**:
- Git user.name（公開情報）
- Git user.email（公開情報）
- インストール状態（機密性なし）

### SSH鍵管理

```bash
# Ed25519鍵の生成（推奨）
ssh-keygen -t ed25519 -C "$git_email" -f "$HOME/.ssh/id_ed25519" -N ""

# パスフレーズは空（自動化のため）
# ユーザーに後で設定を促す
echo -e "${YELLOW}⚠️  セキュリティのため、SSH鍵にパスフレーズを設定することを推奨します${RESET}"
echo -e "${CYAN}ssh-keygen -p -f ~/.ssh/id_ed25519${RESET}"
```

---

## トラブルシューティング

### よくある問題と解決方法

| 問題 | 原因 | 解決方法 |
|------|------|----------|
| Homebrew インストールエラー | Xcode Command Line Tools未インストール | `xcode-select --install` 実行 |
| Winget が見つからない | Windows標準アプリ不足 | Microsoft Storeから「アプリ インストーラー」をインストール |
| Claude Code 認証失敗 | ブラウザでログインしていない | ブラウザで https://claude.ai/code にアクセスしてログイン |
| PATH に追加されない（Windows） | 環境変数の更新が反映されていない | PowerShell再起動、または手動でパス更新 |
| 状態ファイルが壊れた | JSON形式が不正 | `.install_progress.json` を削除して再実行 |

### デバッグモード

**macOS**:
```bash
# デバッグ出力を有効化
set -x  # すべてのコマンドを表示
./install-ai-dev-tools-mac.sh
```

**Windows**:
```powershell
# デバッグ出力を有効化
Set-PSDebug -Trace 1
.\install-ai-dev-tools-win.ps1
```

---

## 今後の拡張予定

### 機能追加案
1. **アンインストールスクリプト**: 全ツールを一括削除
2. **アップデートスクリプト**: インストール済みツールの一括更新
3. **ログ記録**: 詳細なインストールログファイル作成
4. **エラーリカバリ**: 失敗したステップの自動リトライ
5. **設定バックアップ**: Git設定やSSH鍵のバックアップ機能

### 対応予定プラットフォーム
- Linux (Debian/Ubuntu)
- Linux (Red Hat/CentOS)

---

## 変更履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|----------|
| 1.0.0 | 2025-06-15 | 初版作成 - macOS/Windows対応 |

---

**作成者**: Development Team
**最終更新**: 2025-06-15
**ライセンス**: MIT License
