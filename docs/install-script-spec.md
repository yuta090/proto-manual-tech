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
- GitHub CLI
- Netlify CLI
- Claude Code
- Supabase CLI
- Resend CLI
- Super Claude (MCP Server統合)
- Playwright MCP (E2Eテスト)
- Cursor IDE

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
│   ├── install_github_cli()
│   ├── install_netlify_cli()
│   ├── install_claude_code()
│   ├── install_supabase_cli()
│   ├── install_super_claude()
│   ├── install_playwright_mcp()
│   └── install_cursor()
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
  "github_cli": {
    "installed": false,
    "authenticated": false
  },
  "netlify_cli": {
    "installed": false,
    "authenticated": false
  },
  "claude_code": {
    "installed": false,
    "authenticated": false
  },
  "supabase_cli": {
    "installed": false,
    "authenticated": false
  },
  "resend_cli": {
    "installed": false
  },
  "super_claude": {
    "installed": false,
    "mcp_servers_installed": false
  },
  "playwright_mcp": {
    "installed": false
  },
  "cursor": {
    "installed": false
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
[GitHub CLI]
  ├─ Check if installed
  ├─ Install via Homebrew/Winget
  ├─ Check for GitHub account
  ├─ PROMPT: Open https://github.com/signup if no account
  ├─ PAUSE: Wait for account creation (Sign up with Google)
  ├─ Run `gh auth login` (browser authentication)
  └─ Update state
  │
  ▼
[Netlify CLI]
  ├─ Check if installed
  ├─ Install via npm (global)
  ├─ Check for Netlify account
  ├─ PROMPT: Open https://app.netlify.com/signup if no account
  ├─ PAUSE: Wait for account creation (Sign up with GitHub)
  ├─ Run `netlify login` (browser authentication)
  └─ Update state
  │
  ▼
[Claude Code]
  ├─ Check if installed
  ├─ Install via official installer (`curl -fsSL https://claude.ai/install.sh | sh`)
  ├─ Verify authentication with `claude doctor`
  └─ Update state
  │
  ▼
[Supabase CLI]
  ├─ Check if installed
  ├─ Install via npm (global)
  ├─ Check for Supabase account
  ├─ PROMPT: Open https://supabase.com if no account
  ├─ PAUSE: Wait for account creation (Continue with GitHub)
  ├─ Run `npx supabase login` (browser authentication)
  └─ Update state
  │
  ▼
[Resend CLI]
  ├─ Check if installed
  ├─ Install via npm (global)
  ├─ Verify installation
  └─ Update state
  │
  ▼
[Super Claude]
  ├─ Check if installed
  ├─ Install via pipx
  ├─ Install with --force --yes flags
  ├─ Install MCP servers (Context7, Sequential, etc.)
  └─ Update state
  │
  ▼
[Playwright MCP]
  ├─ Check if installed
  ├─ Install via Super Claude MCP system
  ├─ Install Playwright browsers (Chrome, Firefox, Safari)
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
[Completion]
  ├─ Display summary
  ├─ Show installed versions
  ├─ Confirm all accounts created (GitHub, Netlify, Supabase)
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

#### 3. GitHub CLI (認証あり)

**macOS**:
```bash
install_github_cli() {
    if [[ $(get_state github_cli installed) == "True" ]]; then
        print_info "GitHub CLI は既にインストールされています (スキップ)"
    else
        print_section "GitHub CLI のインストール"
        brew install gh
        update_state github_cli installed True
        print_success "GitHub CLI インストール完了"
    fi

    # GitHubアカウント確認と作成促進
    if [[ $(get_state github_cli account_prompted) == "False" ]]; then
        print_section "GitHub アカウント確認"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
        echo -e "${CYAN}GitHubアカウントをお持ちですか？${RESET}"
        echo -e "${CYAN}  Y: はい（認証に進む）${RESET}"
        echo -e "${CYAN}  N: いいえ（アカウント作成ページを開く）${RESET}"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

        echo -ne "\n${CYAN}選択してください (Y/N): ${RESET}"
        read has_account

        if [[ "$has_account" != "Y" && "$has_account" != "y" ]]; then
            print_info "GitHubアカウント作成ページを開きます..."
            open "https://github.com/signup"  # macOS
            echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
            echo -e "${CYAN}1. ブラウザで GitHub にアクセスします${RESET}"
            echo -e "${CYAN}2. 「Sign up with Google」ボタンをクリック${RESET}"
            echo -e "${CYAN}3. Googleアカウントでサインアップしてください${RESET}"
            echo -e "${CYAN}4. アカウント作成が完了したら Enter を押してください${RESET}"
            echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
            read
        fi

        update_state github_cli account_prompted True
    fi

    # GitHub CLI 認証
    if [[ $(get_state github_cli authenticated) == "True" ]]; then
        print_info "GitHub CLI 認証済み (スキップ)"
        return
    fi

    print_section "GitHub CLI 認証"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${CYAN}ブラウザで GitHub 認証を行います${RESET}"
    echo -e "${CYAN}認証が完了したら、このターミナルに戻ってください${RESET}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    gh auth login

    if gh auth status &> /dev/null; then
        print_success "GitHub CLI 認証成功！"
        update_state github_cli authenticated True
    else
        print_error "認証に失敗しました。もう一度実行してください。"
    fi
}
```

**Windows**:
```powershell
function Install-GitHubCLI {
    if ((Get-State github_cli installed) -eq $true) {
        Write-Info "GitHub CLI は既にインストールされています (スキップ)"
    } else {
        Write-Section "GitHub CLI のインストール"

        if (Get-Command gh -ErrorAction SilentlyContinue) {
            Write-Info "GitHub CLI は既にインストールされています"
        } elseif (Get-Command winget -ErrorAction SilentlyContinue) {
            Write-Info "winget で GitHub CLI をインストール中..."
            winget install GitHub.cli --silent --accept-package-agreements --accept-source-agreements
        } else {
            Write-Warn "winget が利用できないため、MSI パッケージをダウンロードしてインストール"
            Install-GitHubCLIFromMsi
        }

        # パスのリフレッシュ
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

        Update-State github_cli installed $true
        Write-Success "GitHub CLI インストール完了"
    }

    # GitHubアカウント確認と作成促進
    if (-not (Get-State github_cli account_prompted)) {
        Write-Section "GitHub アカウント確認"
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
        Write-Host "GitHubアカウントをお持ちですか？" -ForegroundColor Cyan
        Write-Host "  Y: はい（認証に進む）" -ForegroundColor Cyan
        Write-Host "  N: いいえ（アカウント作成ページを開く）" -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

        $has_account = Read-Host "`n選択してください (Y/N)"

        if ($has_account -ne "Y" -and $has_account -ne "y") {
            Write-Info "GitHubアカウント作成ページを開きます..."
            Start-Process "https://github.com/signup"
            Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
            Write-Host "1. ブラウザで GitHub にアクセスします" -ForegroundColor Cyan
            Write-Host "2. 「Sign up with Google」ボタンをクリック" -ForegroundColor Cyan
            Write-Host "3. Googleアカウントでサインアップしてください" -ForegroundColor Cyan
            Write-Host "4. アカウント作成が完了したら Enter を押してください" -ForegroundColor Cyan
            Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
            Read-Host
        }

        Update-State github_cli account_prompted $true
    }

    # GitHub CLI 認証
    if ((Get-State github_cli authenticated) -eq $true) {
        Write-Info "GitHub CLI 認証済み (スキップ)"
        return
    }

    Write-Section "GitHub CLI 認証"
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
    Write-Host "ブラウザで GitHub 認証を行います" -ForegroundColor Cyan
    Write-Host "認証が完了したら、このターミナルに戻ってください" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

    gh auth login

    if (gh auth status 2>$null) {
        Write-Success "GitHub CLI 認証成功！"
        Update-State github_cli authenticated $true
    } else {
        Write-Error "認証に失敗しました。もう一度実行してください。"
    }
}
```

補助関数 `Install-GitHubCLIFromMsi` では、`winget` が利用できない環境向けに GitHub API から最新の MSI パッケージを取得し、サイレントモードでインストールします。ダウンロードした一時ファイルは処理完了後に削除し、MSI 終了コードを検証します。

#### 4. Netlify CLI (認証あり)

**macOS**:
```bash
install_netlify_cli() {
    if [[ $(get_state netlify_cli installed) == "True" ]] && [[ $(get_state netlify_cli authenticated) == "True" ]]; then
        print_info "Netlify CLI は既にインストール・認証済みです (スキップ)"
        return
    fi

    print_section "Netlify CLI のインストール"

    # インストール確認
    if [[ $(get_state netlify_cli installed) == "False" ]]; then
        if command -v netlify &> /dev/null; then
            print_info "Netlify CLI は既にインストールされています"
            update_state netlify_cli installed True
        else
            npm install -g netlify-cli
            update_state netlify_cli installed True
            print_success "Netlify CLI インストール完了"
        fi
    fi

    # アカウント作成促進と認証
    if [[ $(get_state netlify_cli authenticated) == "False" ]]; then
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
        echo -e "${CYAN}Netlify は自動デプロイに使用します${RESET}"
        echo -e "${CYAN}CLI経由でGitHub連携を設定します${RESET}"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

        read -p "Netlify アカウントをお持ちですか？ (y/n): " has_account

        if [[ "$has_account" != "y" ]]; then
            print_warning "Netlify アカウントが必要です。ブラウザでサインアップページを開きます..."
            echo -e "${CYAN}推奨: 「Sign up with GitHub」ボタンで GitHub アカウントを使用してください${RESET}"
            open "https://app.netlify.com/signup"
            echo ""
            read -p "アカウント作成が完了したら Enter キーを押してください..."
        fi

        # 認証
        print_info "Netlify CLI の認証を開始します..."
        if netlify login; then
            update_state netlify_cli authenticated True
            print_success "Netlify CLI 認証完了"
        else
            print_error "Netlify CLI の認証に失敗しました"
            exit 1
        fi
    fi
}
```

**Windows**:
```powershell
function Install-NetlifyCLI {
    if ((Get-InstallState -Tool "netlify_cli" -Key "installed") -and (Get-InstallState -Tool "netlify_cli" -Key "authenticated")) {
        Write-Info "Netlify CLI は既にインストール・認証済みです (スキップ)"
        return
    }

    Write-Section "Netlify CLI のインストール"

    # インストール確認
    if (-not (Get-InstallState -Tool "netlify_cli" -Key "installed")) {
        if (Get-Command netlify -ErrorAction SilentlyContinue) {
            Write-Info "Netlify CLI は既にインストールされています"
            Update-InstallState -Tool "netlify_cli" -Key "installed" -Value $true
        } else {
            & npm.cmd install -g netlify-cli
            Update-InstallState -Tool "netlify_cli" -Key "installed" -Value $true
            Write-Success "Netlify CLI インストール完了"
        }
    }

    # アカウント作成促進と認証
    if (-not (Get-InstallState -Tool "netlify_cli" -Key "authenticated")) {
        Write-Host "============================================================" -ForegroundColor Yellow
        Write-Host "Netlify は自動デプロイに使用します" -ForegroundColor Cyan
        Write-Host "CLI経由でGitHub連携を設定します" -ForegroundColor Cyan
        Write-Host "============================================================" -ForegroundColor Yellow

        $hasAccount = Read-Host "Netlify アカウントをお持ちですか？ (y/n)"

        if ($hasAccount -ne "y") {
            Write-Warn "Netlify アカウントが必要です。ブラウザでサインアップページを開きます..."
            Write-Host "推奨: 「Sign up with GitHub」ボタンで GitHub アカウントを使用してください" -ForegroundColor Cyan
            Start-Process "https://app.netlify.com/signup"
            $confirm = Read-Host "`nアカウント作成が完了したら Enter キーを押してください"
        }

        # 認証
        Write-Info "Netlify CLI の認証を開始します..."
        try {
            netlify login
            Update-InstallState -Tool "netlify_cli" -Key "authenticated" -Value $true
            Write-Success "Netlify CLI 認証完了"
        } catch {
            Write-Err "Netlify CLI の認証に失敗しました"
            exit 1
        }
    }
}
```

> **補足:** PowerShell では `Set-StrictMode -Version Latest` を有効化しているため、`npm.ps1` が `$MyInvocation.Statement` 参照で失敗します。スクリプトでは `.cmd` ラッパー (`npm.cmd` / `npx.cmd`) を直接呼び出し、Node.js インストール後に `Ensure-NpmShim` で `npm` / `npx` エイリアスを `*.cmd` に差し替えて回避しています。

#### 5. Claude Code (認証あり)

**macOS**:
```bash
install_claude_code() {
    if [[ $(get_state claude_code installed) == "True" ]] && [[ $(get_state claude_code authenticated) == "True" ]]; then
        print_info "Claude Code は既にインストール・認証済みです (スキップ)"
        return
    fi

    print_section "Claude Code のインストール"

    # インストール確認
    if [[ $(get_state claude_code installed) == "False" ]]; then
        if command -v claude &> /dev/null; then
            print_info "Claude Code は既にインストールされています"
            update_state claude_code installed True
        else
            print_info "Claude Code の公式インストーラーを実行します..."
            if curl -fsSL https://claude.ai/install.sh | sh; then
                update_state claude_code installed True
                print_success "Claude Code インストール完了"
            else
                print_error "Claude Code のインストールに失敗しました"
                print_warning "手動でインストールしてください: https://claude.ai/install.sh"
                exit 1
            fi
        fi
    fi

    # 認証確認（インストーラでブラウザインタラクションが求められる想定）
    if [[ $(get_state claude_code authenticated) == "False" ]]; then
        print_info "Claude Code の認証状態を確認します..."
        echo -e "${CYAN}Claude Pro アカウントが必要です${RESET}"

        if claude doctor &> /dev/null; then
            update_state claude_code authenticated True
            print_success "Claude Code 認証完了"
        else
            print_warning "Claude Code の認証を完了してください"
            echo -e "${CYAN}コマンド: claude doctor${RESET}"
        fi
    fi
}
```

#### 6. Supabase CLI (認証あり)

**macOS**:
```bash
install_supabase_cli() {
    if [[ $(get_state supabase_cli installed) == "True" ]]; then
        print_info "Supabase CLI は既にインストールされています (スキップ)"
    else
        print_section "Supabase CLI のインストール"
        npm install -g supabase
        update_state supabase_cli installed True
        print_success "Supabase CLI インストール完了"
    fi

    # Supabaseアカウント確認と作成促進
    if [[ $(get_state supabase_cli account_prompted) == "False" ]]; then
        print_section "Supabase アカウント確認"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
        echo -e "${CYAN}Supabaseアカウントをお持ちですか？${RESET}"
        echo -e "${CYAN}  Y: はい（認証に進む）${RESET}"
        echo -e "${CYAN}  N: いいえ（アカウント作成ページを開く）${RESET}"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

        echo -ne "\n${CYAN}選択してください (Y/N): ${RESET}"
        read has_account

        if [[ "$has_account" != "Y" && "$has_account" != "y" ]]; then
            print_info "Supabaseアカウント作成ページを開きます..."
            open "https://supabase.com"
            echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
            echo -e "${CYAN}1. ブラウザで Supabase にアクセスします${RESET}"
            echo -e "${CYAN}2. 「Continue with GitHub」ボタンをクリック${RESET}"
            echo -e "${CYAN}3. GitHubアカウントで連携してください${RESET}"
            echo -e "${CYAN}4. アカウント作成が完了したら Enter を押してください${RESET}"
            echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
            read
        fi

        update_state supabase_cli account_prompted True
    fi

    # Supabase CLI 認証
    if [[ $(get_state supabase_cli authenticated) == "True" ]]; then
        print_info "Supabase CLI 認証済み (スキップ)"
        return
    fi

    print_section "Supabase CLI 認証"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${CYAN}ブラウザで Supabase 認証を行います${RESET}"
    echo -e "${CYAN}認証が完了したら、このターミナルに戻ってください${RESET}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    npx supabase login

    if npx supabase projects list &> /dev/null; then
        print_success "Supabase CLI 認証成功！"
        update_state supabase_cli authenticated True
    else
        print_error "認証に失敗しました。もう一度実行してください。"
    fi
}
```

**Windows**:
```powershell
function Install-SupabaseCLI {
    if ((Get-State supabase_cli installed) -eq $true) {
        Write-Info "Supabase CLI は既にインストールされています (スキップ)"
    } else {
        Write-Section "Supabase CLI のインストール"
        npm install -g supabase

        # パスのリフレッシュ
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

        Update-State supabase_cli installed $true
        Write-Success "Supabase CLI インストール完了"
    }

    # Supabaseアカウント確認と作成促進
    if (-not (Get-State supabase_cli account_prompted)) {
        Write-Section "Supabase アカウント確認"
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
        Write-Host "Supabaseアカウントをお持ちですか？" -ForegroundColor Cyan
        Write-Host "  Y: はい（認証に進む）" -ForegroundColor Cyan
        Write-Host "  N: いいえ（アカウント作成ページを開く）" -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

        $has_account = Read-Host "`n選択してください (Y/N)"

        if ($has_account -ne "Y" -and $has_account -ne "y") {
            Write-Info "Supabaseアカウント作成ページを開きます..."
            Start-Process "https://supabase.com"
            Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
            Write-Host "1. ブラウザで Supabase にアクセスします" -ForegroundColor Cyan
            Write-Host "2. 「Continue with GitHub」ボタンをクリック" -ForegroundColor Cyan
            Write-Host "3. GitHubアカウントで連携してください" -ForegroundColor Cyan
            Write-Host "4. アカウント作成が完了したら Enter を押してください" -ForegroundColor Cyan
            Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
            Read-Host
        }

        Update-State supabase_cli account_prompted $true
    }

    # Supabase CLI 認証
    if ((Get-State supabase_cli authenticated) -eq $true) {
        Write-Info "Supabase CLI 認証済み (スキップ)"
        return
    }

    Write-Section "Supabase CLI 認証"
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
    Write-Host "ブラウザで Supabase 認証を行います" -ForegroundColor Cyan
    Write-Host "認証が完了したら、このターミナルに戻ってください" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

    & npx.cmd supabase login

    if (& npx.cmd supabase projects list 2>$null) {
        Write-Success "Supabase CLI 認証成功！"
        Update-State supabase_cli authenticated $true
    } else {
        Write-Error "認証に失敗しました。もう一度実行してください。"
    }
}
```

#### 7. Super Claude (MCP Server統合)

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

    # MCP Servers インストール
    if [[ $(get_state super_claude mcp_servers_installed) == "True" ]]; then
        print_info "MCP Servers は既にインストールされています (スキップ)"
        return
    fi

    print_section "MCP Servers のインストール"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${CYAN}以下の MCP Servers をインストールします:${RESET}"
    echo -e "${CYAN}  - Context7 (ライブラリドキュメント)${RESET}"
    echo -e "${CYAN}  - Sequential Thinking (複雑な推論)${RESET}"
    echo -e "${CYAN}  - Magic (UI コンポーネント)${RESET}"
    echo -e "${CYAN}  - Morphllm (パターンベース編集)${RESET}"
    echo -e "${CYAN}  - Serena (プロジェクトメモリ)${RESET}"
    echo -e "${CYAN}  - Tavily (Web検索)${RESET}"
    echo -e "${CYAN}  - Chrome DevTools (ブラウザ自動化)${RESET}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    # MCPサーバーを自動インストール
    SuperClaude mcp install-all

    update_state super_claude mcp_servers_installed True
    print_success "MCP Servers インストール完了"
}
```

**Windows**:
```powershell
function Install-SuperClaude {
    if ((Get-State super_claude installed) -eq $true) {
        Write-Info "Super Claude は既にインストールされています (スキップ)"
        return
    }

    Write-Section "Super Claude のインストール"

    # pipx がインストールされているか確認
    if (-not (Get-Command pipx -ErrorAction SilentlyContinue)) {
        Write-Info "pipx をインストールしています..."
        pip install pipx
        pipx ensurepath
    }

    # パスのリフレッシュ
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    # Super Claude インストール (非対話モード)
    SuperClaude install --force --yes

    Update-State super_claude installed $true
    Write-Success "Super Claude インストール完了"

    # MCP Servers インストール
    if ((Get-State super_claude mcp_servers_installed) -eq $true) {
        Write-Info "MCP Servers は既にインストールされています (スキップ)"
        return
    }

    Write-Section "MCP Servers のインストール"
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
    Write-Host "以下の MCP Servers をインストールします:" -ForegroundColor Cyan
    Write-Host "  - Context7 (ライブラリドキュメント)" -ForegroundColor Cyan
    Write-Host "  - Sequential Thinking (複雑な推論)" -ForegroundColor Cyan
    Write-Host "  - Magic (UI コンポーネント)" -ForegroundColor Cyan
    Write-Host "  - Morphllm (パターンベース編集)" -ForegroundColor Cyan
    Write-Host "  - Serena (プロジェクトメモリ)" -ForegroundColor Cyan
    Write-Host "  - Tavily (Web検索)" -ForegroundColor Cyan
    Write-Host "  - Chrome DevTools (ブラウザ自動化)" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

    # MCPサーバーを自動インストール
    SuperClaude mcp install-all

    Update-State super_claude mcp_servers_installed $true
    Write-Success "MCP Servers インストール完了"
}
```

#### 8. Playwright MCP (E2Eテスト)

**macOS**:
```bash
install_playwright_mcp() {
    if [[ $(get_state playwright_mcp installed) == "True" ]]; then
        print_info "Playwright MCP は既にインストールされています (スキップ)"
        return
    fi

    print_section "Playwright MCP のインストール"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${CYAN}Playwright MCP を Super Claude 経由でインストールします${RESET}"
    echo -e "${CYAN}ブラウザ (Chromium, Firefox, WebKit) も自動インストールされます${RESET}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    # Super Claude 経由で Playwright MCP をインストール
    SuperClaude mcp install playwright

    # Playwright ブラウザのインストール
    print_info "Playwright ブラウザをインストールしています..."
    npx playwright install

    update_state playwright_mcp installed True
    print_success "Playwright MCP インストール完了"
}
```

**Windows**:
```powershell
function Install-PlaywrightMCP {
    if ((Get-State playwright_mcp installed) -eq $true) {
        Write-Info "Playwright MCP は既にインストールされています (スキップ)"
        return
    }

    Write-Section "Playwright MCP のインストール"
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
    Write-Host "Playwright MCP を Super Claude 経由でインストールします" -ForegroundColor Cyan
    Write-Host "ブラウザ (Chromium, Firefox, WebKit) も自動インストールされます" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

    # Super Claude 経由で Playwright MCP をインストール
    SuperClaude mcp install playwright

    # Playwright ブラウザのインストール
    Write-Info "Playwright ブラウザをインストールしています..."
    npx playwright install

    Update-State playwright_mcp installed $true
    Write-Success "Playwright MCP インストール完了"
}
```

#### 9. Cursor IDE

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

---

## 認証メカニズム

### 認証が必要なツール
1. **GitHub CLI**: GitHub アカウントが必要（Googleアカウントで登録推奨）
2. **Netlify CLI**: Netlify アカウントが必要（GitHubアカウントで登録推奨）
3. **Claude Code**: Claude Pro アカウントが必要
4. **Supabase CLI**: Supabase アカウントが必要（GitHubアカウントで登録推奨）

### アカウント登録フロー

```
[GitHub アカウント]
     │
     ├─ Y/N確認
     │
     ▼ (Nの場合)
     │
[ブラウザでサインアップページ]
     │
     ├─ https://github.com/signup
     ├─ 「Sign up with Google」ボタン
     │
     ▼
[Googleアカウントで登録]
     │
     ▼
[GitHub CLI 認証: gh auth login]

[Netlify アカウント]
     │
     ├─ Y/N確認
     │
     ▼ (Nの場合)
     │
[ブラウザでサインアップページ]
     │
     ├─ https://app.netlify.com/signup
     ├─ 「Sign up with GitHub」ボタン
     │
     ▼
[GitHubアカウントで連携]
     │
     ▼
[Netlify CLI 認証: netlify login]

[Supabase アカウント]
     │
     ├─ Y/N確認
     │
     ▼ (Nの場合)
     │
[ブラウザでサインアップページ]
     │
     ├─ https://supabase.com
     ├─ 「Continue with GitHub」ボタン
     │
     ▼
[GitHubアカウントで登録]
     │
     ▼
[Supabase CLI 認証: npx supabase login]
```

### CLI 認証フロー

```
[インストール完了]
     │
     ▼
[認証コマンド実行]
  (バックグラウンドまたは対話式)
     │
     ▼
[スクリプト一時停止]
     │
     ├─ ユーザーへガイド表示
     ├─ ブラウザで認証実行
     │
     ▼
[Enter待機ループ]
     │
     ├─ ユーザーがEnter押下
     │
     ▼
[認証検証]
  (コマンド実行で確認)
     │
     ├─ 成功 → 状態更新 → 次へ進む
     └─ 失敗 → 再度Enter待機
```

### 認証検証方法

| ツール | 検証コマンド | 成功条件 |
|--------|--------------|----------|
| GitHub CLI | `gh auth status` | 終了コード 0 |
| Netlify CLI | `netlify status` | 終了コード 0 |
| Claude Code | `claude doctor` | 終了コード 0 |
| Supabase CLI | `npx supabase projects list` | 終了コード 0 |

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
brew install node                       # Node.js
brew install git                        # Git
brew install gh                         # GitHub CLI
npm install -g netlify-cli              # Netlify CLI
curl -fsSL https://claude.ai/install.sh | sh   # Claude Code
npm install -g supabase                 # Supabase CLI
npm install -g resend                   # Resend CLI
brew install pipx                       # pipx
pipx install SuperClaude                # Super Claude
SuperClaude mcp install-all             # MCP Servers
SuperClaude mcp install playwright      # Playwright MCP
npx playwright install                  # Playwright ブラウザ
brew install --cask cursor              # Cursor IDE
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
winget install OpenJS.NodeJS --silent   # Node.js
winget install Git.Git --silent         # Git
winget install --id GitHub.CLI --silent # GitHub CLI
npm install -g netlify-cli              # Netlify CLI
Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression   # Claude Code
npm install -g supabase                 # Supabase CLI
npm install -g resend                   # Resend CLI
pip install pipx                        # pipx
pipx install SuperClaude                # Super Claude
SuperClaude mcp install-all             # MCP Servers
SuperClaude mcp install playwright      # Playwright MCP
npx playwright install                  # Playwright ブラウザ
# Cursor IDE: 手動ダウンロード（https://cursor.sh）
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
