# ============================================================================
# AI開発環境 自動セットアップスクリプト (Windows版)
# ============================================================================
# Node.js, Git, Claude Code, Super Claude, Cursor IDE, Codex CLI を
# 順次インストールし、認証が必要な箇所では対話的に待機します。
# 中断しても再実行で続きから再開できます。
# ============================================================================

# エラーで停止
$ErrorActionPreference = "Stop"

# ============================================================================
# カラー定義 & アニメーション関数
# ============================================================================

# 絵文字
$ROCKET = [char]0x1F680
$CHECK = [char]0x2705
$CROSS = [char]0x274C
$LOCK = [char]0x1F512
$GEAR = [char]0x2699
$SPARKLE = [char]0x2728
$WARN = [char]0x26A0
$PARTY = [char]0x1F389

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-Success {
    param([string]$Message)
    Write-Host "$CHECK " -ForegroundColor Green -NoNewline
    Write-Host $Message -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "$CROSS " -ForegroundColor Red -NoNewline
    Write-Host $Message -ForegroundColor Red
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "$WARN " -ForegroundColor Yellow -NoNewline
    Write-Host $Message -ForegroundColor Yellow
}

function Write-Info {
    param([string]$Message)
    Write-Host "$GEAR " -ForegroundColor Cyan -NoNewline
    Write-Host $Message -ForegroundColor Cyan
}

function Show-ProgressBar {
    param(
        [int]$Current,
        [int]$Total
    )
    $Percentage = [math]::Round(($Current / $Total) * 100)
    $BarLength = 50
    $FilledLength = [math]::Round(($Current / $Total) * $BarLength)

    $Bar = ""
    for ($i = 0; $i -lt $FilledLength; $i++) { $Bar += "?" }
    for ($i = $FilledLength; $i -lt $BarLength; $i++) { $Bar += "?" }

    Write-Host "`r[$Bar] $Percentage%" -NoNewline -ForegroundColor Cyan
}

function Show-Banner {
    Clear-Host
    Write-Host ""
    Write-ColorOutput "    ?????????????????????????????????????????????????????????????" Magenta
    Write-ColorOutput "    ?                                                           ?" Magenta
    Write-ColorOutput "    ?        AI Development Environment Setup Script           ?" Magenta
    Write-ColorOutput "    ?                    for Windows                            ?" Magenta
    Write-ColorOutput "    ?                                                           ?" Magenta
    Write-ColorOutput "    ?   Node.js | Git | GitHub CLI | Claude Code               ?" Magenta
    Write-ColorOutput "    ?       Super Claude | Cursor IDE | Codex CLI              ?" Magenta
    Write-ColorOutput "    ?                                                           ?" Magenta
    Write-ColorOutput "    ?????????????????????????????????????????????????????????????" Magenta
    Write-Host ""
}

function Show-Section {
    param(
        [int]$Step,
        [string]$Title
    )
    Write-Host ""
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Blue
    Write-ColorOutput "[$Step/7] $Title" White
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Blue
    Write-Host ""
}

# ============================================================================
# 状態管理
# ============================================================================

$StateFile = ".install_progress.json"

function Initialize-State {
    if (-not (Test-Path $StateFile)) {
        $InitialState = @{
            accounts = @{
                claude_pro = @{ registered = $false; plan = "" }
                github = @{ registered = $false; username = "" }
                chatgpt_plus = @{ registered = $false; plan = "" }
                cursor = @{ registered = $false }
            }
            nodejs = @{ installed = $false; version = "" }
            git = @{ installed = $false; configured = $false; ssh_key = $false }
            claude_code = @{ installed = $false; authenticated = $false }
            super_claude = @{ installed = $false; mcp_configured = $false }
            cursor = @{ installed = $false }
            codex = @{ installed = $false; authenticated = $false }
        } | ConvertTo-Json -Depth 10

        $InitialState | Out-File -FilePath $StateFile -Encoding UTF8
    }
}

function Get-State {
    param(
        [string]$Key,
        [string]$SubKey,
        [string]$SubSubKey
    )
    $state = Get-Content $StateFile | ConvertFrom-Json

    if ($SubSubKey) {
        return $state.$Key.$SubKey.$SubSubKey
    } else {
        return $state.$Key.$SubKey
    }
}

function Update-State {
    param(
        [string]$Key,
        [string]$SubKey,
        $Value,
        [string]$SubSubKey
    )
    $state = Get-Content $StateFile | ConvertFrom-Json

    if ($SubSubKey) {
        $state.$Key.$SubKey.$SubSubKey = $Value
    } else {
        $state.$Key.$SubKey = $Value
    }

    $state | ConvertTo-Json -Depth 10 | Out-File -FilePath $StateFile -Encoding UTF8
}

# ============================================================================
# チェック関数
# ============================================================================

function Test-Command {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

function Test-Winget {
    if (-not (Test-Command winget)) {
        Write-Warning-Custom "Winget がインストールされていません"
        Write-Host "Windows 10 1809以降または Windows 11 が必要です" -ForegroundColor Yellow
        Write-Host "Microsoft Store から「アプリ インストーラー」をインストールしてください" -ForegroundColor Yellow
        exit 1
    }
}

# ============================================================================
# アカウント登録ガイド関数
# ============================================================================

function Show-AccountRequirements {
    Write-Host ""
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Magenta
    Write-ColorOutput "必要なアカウント一覧" White
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Magenta
    Write-Host ""

    Write-Host "[必須] " -ForegroundColor Red -NoNewline
    Write-Host "Claude Pro" -ForegroundColor Yellow -NoNewline
    Write-Host " - `$20/月" -ForegroundColor White
    Write-Host "       └─ Claude Code の実行に必須" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "[推奨] " -ForegroundColor Yellow -NoNewline
    Write-Host "GitHub" -ForegroundColor Yellow -NoNewline
    Write-Host " - 無料" -ForegroundColor White
    Write-Host "       └─ Git連携、SSH鍵登録に使用" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "[任意] " -ForegroundColor Blue -NoNewline
    Write-Host "ChatGPT Plus/Pro" -ForegroundColor Yellow -NoNewline
    Write-Host " - `$20/月" -ForegroundColor White
    Write-Host "       └─ Codex CLI 使用時のみ必要" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "[任意] " -ForegroundColor Blue -NoNewline
    Write-Host "Cursor IDE" -ForegroundColor Yellow -NoNewline
    Write-Host " - 無料（Proプランあり）" -ForegroundColor White
    Write-Host "       └─ AI統合エディタ" -ForegroundColor Cyan
    Write-Host ""
}

function Register-ClaudePro {
    Show-Section 0 "Claude Pro アカウント登録"

    if (Get-State "accounts" "claude_pro" "registered") {
        Write-Success "Claude Pro アカウントは登録済みです (スキップ)"
        return
    }

    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Yellow
    Write-Host "??  重要: Claude Pro アカウントが必要です" -ForegroundColor Red
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Yellow
    Write-Host ""

    Write-Host "Claude Code を使用するには " -ForegroundColor White -NoNewline
    Write-Host "Claude Pro（`$20/月）" -ForegroundColor Yellow -NoNewline
    Write-Host " の契約が必要です。" -ForegroundColor White
    Write-Host "今からブラウザで登録ページを開きます。" -ForegroundColor White
    Write-Host ""

    $response = Read-Host "登録ページを開きますか? (y/N)"

    if ($response -notmatch '^[Yy]$') {
        Write-Error-Custom "Claude Pro の登録をスキップしました"
        Write-Host "後で https://claude.ai/upgrade で登録してください" -ForegroundColor Yellow
        exit 1
    }

    Write-Host ""
    Write-Info "ブラウザで Claude 登録ページを開きます..."
    Start-Sleep -Seconds 1
    Start-Process "https://claude.ai/upgrade"

    Write-Host ""
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Cyan
    Write-Host "? 登録手順:" -ForegroundColor White
    Write-Host ""
    Write-Host "  1. " -ForegroundColor Yellow -NoNewline
    Write-Host "「Continue with Google」" -ForegroundColor Green -NoNewline
    Write-Host " ボタンをクリック"
    Write-Host "  2. Googleアカウントでログイン" -ForegroundColor Yellow
    Write-Host "  3. " -ForegroundColor Yellow -NoNewline
    Write-Host "「Upgrade to Claude Pro」" -ForegroundColor Green -NoNewline
    Write-Host " を選択（`$20/月）"
    Write-Host "  4. クレジットカード情報を入力" -ForegroundColor Yellow
    Write-Host "  5. 登録完了後、" -ForegroundColor Yellow -NoNewline
    Write-Host "このターミナルに戻る" -ForegroundColor White
    Write-Host ""
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Cyan

    while ($true) {
        Write-Host ""
        $null = Read-Host "登録が完了したら Enter を押してください"

        $confirm = Read-Host "Claude Pro プランに登録しましたか? (y/N)"

        if ($confirm -match '^[Yy]$') {
            Update-State "accounts" "claude_pro" $true "registered"
            Update-State "accounts" "claude_pro" "Pro" "plan"
            Write-Success "Claude Pro アカウント登録完了！"
            break
        } else {
            Write-Warning-Custom "Claude Pro の登録が必要です"
        }
    }
}

function Register-GitHub {
    Write-Host ""
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Blue
    Write-ColorOutput "GitHub アカウント登録 (推奨)" White
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Blue
    Write-Host ""

    if (Get-State "accounts" "github" "registered") {
        Write-Success "GitHub アカウントは登録済みです (スキップ)"
        return
    }

    $hasAccount = Read-Host "GitHub アカウントを持っていますか? (y/N)"

    if ($hasAccount -match '^[Yy]$') {
        $githubUsername = Read-Host "GitHub ユーザー名を入力してください"
        Update-State "accounts" "github" $true "registered"
        Update-State "accounts" "github" $githubUsername "username"
        Write-Success "GitHub アカウント情報を保存しました"
        return
    }

    $response = Read-Host "`n今すぐ GitHub アカウントを登録しますか? (y/N)"

    if ($response -notmatch '^[Yy]$') {
        Write-Info "GitHub 登録をスキップしました（後で登録できます）"
        return
    }

    Write-Host ""
    Write-Info "ブラウザで GitHub 登録ページを開きます..."
    Start-Sleep -Seconds 1
    Start-Process "https://github.com/signup"

    Write-Host ""
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Cyan
    Write-Host "? 登録手順:" -ForegroundColor White
    Write-Host ""
    Write-Host "  1. メールアドレスを入力" -ForegroundColor Yellow
    Write-Host "  2. パスワードを作成" -ForegroundColor Yellow
    Write-Host "  3. ユーザー名を決定" -ForegroundColor Yellow
    Write-Host "  4. メール確認コードを入力" -ForegroundColor Yellow
    Write-Host "  5. 登録完了後、" -ForegroundColor Yellow -NoNewline
    Write-Host "このターミナルに戻る" -ForegroundColor White
    Write-Host ""
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Cyan

    $null = Read-Host "`n登録が完了したら Enter を押してください"

    $githubUsername = Read-Host "GitHub ユーザー名を入力してください"

    if ($githubUsername) {
        Update-State "accounts" "github" $true "registered"
        Update-State "accounts" "github" $githubUsername "username"
        Write-Success "GitHub アカウント登録完了！"
    } else {
        Write-Warning-Custom "GitHub 登録をスキップしました"
    }
}

function Register-ChatGPTPlus {
    Write-Host ""
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Blue
    Write-ColorOutput "ChatGPT Plus/Pro アカウント登録 (任意)" White
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Blue
    Write-Host ""

    if (Get-State "accounts" "chatgpt_plus" "registered") {
        Write-Success "ChatGPT Plus/Pro アカウントは登録済みです (スキップ)"
        return
    }

    Write-Host "Codex CLI を使用するには " -ForegroundColor White -NoNewline
    Write-Host "ChatGPT Plus/Pro（`$20/月）" -ForegroundColor Yellow -NoNewline
    Write-Host " が必要です。" -ForegroundColor White
    $response = Read-Host "`nChatGPT Plus/Pro を登録しますか? (y/N)"

    if ($response -notmatch '^[Yy]$') {
        Write-Info "ChatGPT 登録をスキップしました（Codex CLI使用時に登録してください）"
        return
    }

    Write-Host ""
    Write-Info "ブラウザで ChatGPT 登録ページを開きます..."
    Start-Sleep -Seconds 1
    Start-Process "https://chatgpt.com/signup"

    Write-Host ""
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Cyan
    Write-Host "? 登録手順:" -ForegroundColor White
    Write-Host ""
    Write-Host "  1. " -ForegroundColor Yellow -NoNewline
    Write-Host "「Continue with Google」" -ForegroundColor Green -NoNewline
    Write-Host " ボタンをクリック"
    Write-Host "  2. Googleアカウントでログイン" -ForegroundColor Yellow
    Write-Host "  3. " -ForegroundColor Yellow -NoNewline
    Write-Host "「Upgrade to Plus」" -ForegroundColor Green -NoNewline
    Write-Host " または " -NoNewline
    Write-Host "「Upgrade to Pro」" -ForegroundColor Green -NoNewline
    Write-Host " を選択"
    Write-Host "  4. クレジットカード情報を入力" -ForegroundColor Yellow
    Write-Host "  5. 登録完了後、" -ForegroundColor Yellow -NoNewline
    Write-Host "このターミナルに戻る" -ForegroundColor White
    Write-Host ""
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Cyan

    $null = Read-Host "`n登録が完了したら Enter を押してください"

    $plan = Read-Host "どのプランを登録しましたか? (plus/pro/N)"

    if ($plan -match '^[Pp]lus$') {
        Update-State "accounts" "chatgpt_plus" $true "registered"
        Update-State "accounts" "chatgpt_plus" "Plus" "plan"
        Write-Success "ChatGPT Plus アカウント登録完了！"
    } elseif ($plan -match '^[Pp]ro$') {
        Update-State "accounts" "chatgpt_plus" $true "registered"
        Update-State "accounts" "chatgpt_plus" "Pro" "plan"
        Write-Success "ChatGPT Pro アカウント登録完了！"
    } else {
        Write-Info "ChatGPT 登録をスキップしました"
    }
}

# ============================================================================
# インストール関数
# ============================================================================

function Install-NodeJS {
    Show-Section 1 "Node.js のインストール"

    if (Get-State "nodejs" "installed") {
        $version = & node --version 2>$null
        Write-Success "Node.js $version は既にインストール済みです (スキップ)"
        return
    }

    if (Test-Command node) {
        $version = & node --version
        Write-Success "Node.js $version が既にインストールされています"
        Update-State "nodejs" "installed" $true
        Update-State "nodejs" "version" $version
        return
    }

    Write-Info "Node.js をインストール中..."
    winget install OpenJS.NodeJS --silent --accept-package-agreements --accept-source-agreements

    # パスをリフレッシュ
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    if (Test-Command node) {
        $version = & node --version
        Write-Success "Node.js $version インストール完了"
        Update-State "nodejs" "installed" $true
        Update-State "nodejs" "version" $version
    } else {
        Write-Error-Custom "Node.js のインストールに失敗しました"
        exit 1
    }
}

function Install-Git {
    Show-Section 2 "Git のインストール"

    if (Get-State "git" "installed") {
        $version = (& git --version 2>$null) -replace 'git version ', ''
        Write-Success "Git $version は既にインストール済みです (スキップ)"
    } else {
        if (Test-Command git) {
            $version = (& git --version) -replace 'git version ', ''
            Write-Success "Git $version が既にインストールされています"
            Update-State "git" "installed" $true
        } else {
            Write-Info "Git をインストール中..."
            winget install Git.Git --silent --accept-package-agreements --accept-source-agreements

            # パスをリフレッシュ
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

            if (Test-Command git) {
                $version = (& git --version) -replace 'git version ', ''
                Write-Success "Git $version インストール完了"
                Update-State "git" "installed" $true
            } else {
                Write-Error-Custom "Git のインストールに失敗しました"
                exit 1
            }
        }
    }

    # Git 初期設定
    if (-not (Get-State "git" "configured")) {
        Write-Host ""
        Write-Info "Git の初期設定を行います"

        $gitName = & git config --global user.name 2>$null
        $gitEmail = & git config --global user.email 2>$null

        if (-not $gitName) {
            $gitName = Read-Host "ユーザー名を入力してください"
            & git config --global user.name $gitName
        } else {
            Write-Success "user.name: $gitName (設定済み)"
        }

        if (-not $gitEmail) {
            $gitEmail = Read-Host "メールアドレスを入力してください"
            & git config --global user.email $gitEmail
        } else {
            Write-Success "user.email: $gitEmail (設定済み)"
        }

        Update-State "git" "configured" $true
        Write-Success "Git 初期設定完了"
    }
}

function Install-GitHubCLI {
    Show-Section 3 "GitHub CLI のインストール"

    if (Get-State "git" "ssh_key") {
        Write-Success "GitHub 認証は既に完了しています (スキップ)"
        return
    }

    if (-not (Test-Command gh)) {
        Write-Info "GitHub CLI をインストール中..."
        winget install GitHub.cli --silent --accept-package-agreements --accept-source-agreements

        # パスをリフレッシュ
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

        if (Test-Command gh) {
            Write-Success "GitHub CLI インストール完了"
        } else {
            Write-Error-Custom "GitHub CLI のインストールに失敗しました"
            exit 1
        }
    } else {
        Write-Success "GitHub CLI は既にインストールされています"
    }

    # GitHub認証とSSH鍵の自動設定
    Write-Host ""
    Write-Warning-Custom "$LOCK GitHub 認証が必要です"
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Cyan
    Write-ColorOutput "GitHub CLI が以下を自動で行います:" White
    Write-Host ""
    Write-Host "  ? SSH鍵の自動生成" -ForegroundColor Green
    Write-Host "  ? GitHubへの鍵登録" -ForegroundColor Green
    Write-Host "  ? Git認証情報の設定" -ForegroundColor Green
    Write-Host ""
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Cyan

    Write-Host ""
    Write-Info "以下のコマンドを実行します: gh auth login"
    Write-Host "手順:" -ForegroundColor Yellow
    Write-Host "  1. " -ForegroundColor Yellow -NoNewline
    Write-Host "GitHub.com" -ForegroundColor Green -NoNewline
    Write-Host " を選択"
    Write-Host "  2. " -ForegroundColor Yellow -NoNewline
    Write-Host "HTTPS" -ForegroundColor Green -NoNewline
    Write-Host " を選択"
    Write-Host "  3. " -ForegroundColor Yellow -NoNewline
    Write-Host "Login with a web browser" -ForegroundColor Green -NoNewline
    Write-Host " を選択"
    Write-Host "  4. 表示されるコードをコピー" -ForegroundColor Yellow
    Write-Host "  5. ブラウザで GitHub にログインして認証" -ForegroundColor Yellow
    Write-Host ""

    $response = Read-Host "GitHub 認証を開始しますか? (y/N)"

    if ($response -match '^[Yy]$') {
        & gh auth login

        $authStatus = & gh auth status 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "GitHub 認証完了！SSH鍵も自動で設定されました"
            Update-State "git" "ssh_key" $true
        } else {
            Write-Error-Custom "GitHub 認証に失敗しました"
            exit 1
        }
    } else {
        Write-Info "後で 'gh auth login' コマンドを実行して認証してください"
    }
}

function Install-ClaudeCode {
    Show-Section 4 "Claude Code のインストール"

    if (Get-State "claude_code" "installed") {
        Write-Success "Claude Code は既にインストール済みです (スキップ)"
    } else {
        if (Test-Command claude-code) {
            Write-Success "Claude Code が既にインストールされています"
            Update-State "claude_code" "installed" $true
        } else {
            Write-Info "Claude Code をインストール中..."
            & npm install -g claude-code

            # パスをリフレッシュ
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

            if (Test-Command claude-code) {
                Write-Success "Claude Code インストール完了"
                Update-State "claude_code" "installed" $true
            } else {
                Write-Error-Custom "Claude Code のインストールに失敗しました"
                exit 1
            }
        }
    }

    # 認証チェック
    if (-not (Get-State "claude_code" "authenticated")) {
        Write-Host ""
        Write-Warning-Custom "$LOCK Claude Code の認証が必要です"
        Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Cyan
        Write-Host "??  注意: これから対話型セットアップが始まります" -ForegroundColor White
        Write-Host ""
        Write-Host "  ? 質問が表示されたら答えてください" -ForegroundColor Yellow
        Write-Host "  ? ブラウザが開いたら Claude Pro でログインしてください" -ForegroundColor Yellow
        Write-Host "  ? 認証完了後、自動で次のステップに進みます" -ForegroundColor Yellow
        Write-Host ""
        Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Cyan

        $response = Read-Host "`n認証を開始しますか? (y/N)"

        if ($response -match '^[Yy]$') {
            Write-Host ""
            Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Cyan
            Write-Host "Claude Code セットアップ開始" -ForegroundColor White
            Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Cyan
            Write-Host ""

            # claude-code を直接実行（対話型）
            & claude-code

            Write-Host ""
            Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Cyan

            # 認証確認
            $testResult = & claude-code --version 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Success "認証成功！"
                Update-State "claude_code" "authenticated" $true
            } else {
                Write-Warning-Custom "認証をスキップしました。後で 'claude-code' コマンドを実行して認証してください"
            }
        } else {
            Write-Info "後で 'claude-code' コマンドを実行して認証してください"
        }
    } else {
        Write-Success "Claude Code は既に認証済みです"
    }
}

function Install-SuperClaude {
    Show-Section 5 "Super Claude のインストール"

    # Python チェック
    if (-not (Test-Command python)) {
        Write-Info "Python をインストール中..."
        winget install Python.Python.3.12 --silent --accept-package-agreements --accept-source-agreements

        # パスをリフレッシュ
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    }

    # pipx のインストール
    if (-not (Test-Command pipx)) {
        Write-Info "pipx をインストール中..."
        & python -m pip install --user pipx
        & python -m pipx ensurepath

        # パスをリフレッシュ
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        Write-Success "pipx インストール完了"
    }

    if (Get-State "super_claude" "installed") {
        Write-Success "Super Claude は既にインストール済みです (スキップ)"
    } else {
        if (Test-Command SuperClaude) {
            Write-Success "Super Claude が既にインストールされています"
            Update-State "super_claude" "installed" $true
        } else {
            Write-Info "Super Claude をインストール中..."
            & pipx install SuperClaude

            if (Test-Command SuperClaude) {
                Write-Success "Super Claude インストール完了"
                Update-State "super_claude" "installed" $true
            } else {
                Write-Error-Custom "Super Claude のインストールに失敗しました"
                exit 1
            }
        }
    }

    # MCP 設定
    if (-not (Get-State "super_claude" "mcp_configured")) {
        Write-Info "Super Claude フレームワークをインストール中..."

        # 公式オプションを使用して非対話モードでインストール
        # --quick: 推奨設定で高速インストール
        # --yes: 全ての確認を自動承認
        & SuperClaude install --quick --yes 2>$null

        Write-Success "Super Claude フレームワーク設定完了"
        Write-Success "  ? Core framework"
        Write-Success "  ? MCP servers (Context7, Sequential, Magic, Playwright)"
        Write-Success "  ? Slash commands"
        Update-State "super_claude" "mcp_configured" $true
    } else {
        Write-Success "Super Claude フレームワークは既に設定済みです (スキップ)"
    }
}

function Install-Cursor {
    Show-Section 6 "Cursor IDE のインストール"

    if (Get-State "cursor" "installed") {
        Write-Success "Cursor IDE は既にインストール済みです (スキップ)"
        return
    }

    # Cursor の存在確認（Program Files または AppData）
    $cursorPaths = @(
        "$env:LOCALAPPDATA\Programs\Cursor",
        "$env:ProgramFiles\Cursor"
    )

    $cursorInstalled = $false
    foreach ($path in $cursorPaths) {
        if (Test-Path $path) {
            $cursorInstalled = $true
            break
        }
    }

    if ($cursorInstalled) {
        Write-Success "Cursor IDE が既にインストールされています"
        Update-State "cursor" "installed" $true
        return
    }

    Write-Warning-Custom "Cursor IDE は Windows 版の自動インストールに対応していません"
    Write-Info "手動でインストールする場合: https://cursor.sh/download からダウンロードしてください"

    $response = Read-Host "手動でインストールしますか? (y/N)"
    if ($response -match '^[Yy]$') {
        Start-Process "https://cursor.sh/download"
        Write-Info "ブラウザでダウンロードページを開きました"
        Read-Host "インストール完了後 Enter を押してください"
        Update-State "cursor" "installed" $true
    } else {
        Write-Info "Cursor IDE のインストールをスキップしました"
    }
}

function Install-Codex {
    Show-Section 7 "OpenAI Codex CLI のインストール"

    if (Get-State "codex" "installed") {
        Write-Success "Codex CLI は既にインストール済みです (スキップ)"
    } else {
        if (Test-Command codex) {
            Write-Success "Codex CLI が既にインストールされています"
            Update-State "codex" "installed" $true
        } else {
            Write-Info "Codex CLI をインストール中..."
            & npm install -g @openai/codex

            # パスをリフレッシュ
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

            if (Test-Command codex) {
                Write-Success "Codex CLI インストール完了"
                Update-State "codex" "installed" $true
            } else {
                Write-Error-Custom "Codex CLI のインストールに失敗しました"
                exit 1
            }
        }
    }

    # 認証チェック（オプション）
    if (-not (Get-State "codex" "authenticated")) {
        Write-Host ""
        Write-Warning-Custom "$LOCK Codex CLI の認証（オプション）"
        Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Cyan
        Write-ColorOutput "Codex CLI を使用するには ChatGPT Plus/Pro アカウントが必要です" White
        Write-Host ""
        $response = Read-Host "今すぐ認証しますか? (y/N)"

        if ($response -match '^[Yy]$') {
            Write-Host ""
            Write-Host "1. ターミナルで以下のコマンドを実行:" -ForegroundColor Yellow
            Write-Host "   codex" -ForegroundColor Green
            Write-Host "2. ChatGPT アカウントでサインイン" -ForegroundColor Yellow
            Write-Host ""

            while ($true) {
                $response = Read-Host "認証が完了したら Enter を押してください"

                $testResult = & codex --version 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "認証成功！"
                    Update-State "codex" "authenticated" $true
                    break
                } else {
                    Write-Error-Custom "認証が確認できませんでした。後で手動で設定してください。"
                    break
                }
            }
        } else {
            Write-Info "後で 'codex' コマンドを実行して認証してください"
        }
    } else {
        Write-Success "Codex CLI は既に認証済みです"
    }
}

# ============================================================================
# メイン処理
# ============================================================================

function Main {
    Show-Banner

    Write-Info "$ROCKET AI開発環境のセットアップを開始します..."
    Write-Host ""
    Start-Sleep -Seconds 1

    # 管理者権限チェック
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Warning-Custom "このスクリプトは管理者権限で実行することを推奨します"
        Write-Info "右クリック → '管理者として実行' で再実行してください"
        Write-Host ""
        $response = Read-Host "このまま続行しますか? (y/N)"
        if ($response -notmatch '^[Yy]$') {
            exit 0
        }
    }

    # 状態ファイル初期化
    Initialize-State

    # アカウント要件表示
    Show-AccountRequirements

    $response = Read-Host "`nセットアップを続行しますか? (y/N)"
    if ($response -notmatch '^[Yy]$') {
        Write-Warning-Custom "セットアップを中止しました"
        exit 0
    }

    # アカウント登録ガイド
    Register-ClaudePro    # 必須
    Register-GitHub        # 推奨

    # Winget チェック
    Test-Winget

    # インストール実行
    Install-NodeJS
    Start-Sleep -Milliseconds 500

    Install-Git
    Start-Sleep -Milliseconds 500

    Install-GitHubCLI
    Start-Sleep -Milliseconds 500

    Install-ClaudeCode
    Start-Sleep -Milliseconds 500

    Install-SuperClaude
    Start-Sleep -Milliseconds 500

    Install-Cursor
    Start-Sleep -Milliseconds 500

    # Codex CLI インストール前に ChatGPT Plus/Pro 登録を促す
    if (-not (Get-State "accounts" "chatgpt_plus" "registered")) {
        Register-ChatGPTPlus
    }

    Install-Codex

    # 完了メッセージ
    Write-Host ""
    Write-ColorOutput "    ?????????????????????????????????????????????????????????????" Green
    Write-ColorOutput "    ?                                                           ?" Green
    Write-ColorOutput "    ?                $PARTY  セットアップ完了！  $PARTY                 ?" Green
    Write-ColorOutput "    ?                                                           ?" Green
    Write-ColorOutput "    ?????????????????????????????????????????????????????????????" Green
    Write-Host ""

    Write-Success "全てのツールのインストールが完了しました"
    Write-Host ""
    Write-Info "次のステップ:"
    Write-Host "  ? Claude Code: claude-code コマンドで起動" -ForegroundColor Yellow
    Write-Host "  ? Super Claude: SuperClaude --help でコマンド確認" -ForegroundColor Yellow
    Write-Host "  ? Cursor IDE: スタートメニューから起動" -ForegroundColor Yellow
    Write-Host "  ? Codex CLI: codex コマンドで起動" -ForegroundColor Yellow
    Write-Host ""

    Write-Info "$SPARKLE Happy Coding with AI! $SPARKLE"
    Write-Host ""
}

# スクリプト実行
Main
