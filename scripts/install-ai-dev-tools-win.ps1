# AI開発環境自動セットアップスクリプト (Windows)
#
# 目的: 0章「自動セットアップで開発環境を整える」で使用する
#      全ツールの自動インストール・認証・アカウント作成促進
#
# 実行方法 (PowerShell管理者権限):
#   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
#   .\install-ai-dev-tools-win.ps1
#
# 対応OS: Windows 10 / 11

#Requires -Version 5.1

################################################################################
# エラーハンドリング設定
################################################################################

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

################################################################################
# カラー定義
################################################################################

function Write-Section {
    param([string]$Message)
    Write-Host "`n============================================================" -ForegroundColor Blue
    Write-Host "▶ $Message" -ForegroundColor Blue
    Write-Host "============================================================`n" -ForegroundColor Blue
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Err {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Write-Warn {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

################################################################################
# 状態管理
################################################################################

$StateFile = ".install_progress.json"

function Initialize-State {
    if (-not (Test-Path $StateFile)) {
        $state = @{
            node = @{ installed = $false }
            git = @{ installed = $false }
            github_cli = @{
                installed = $false
                authenticated = $false
            }
            netlify_cli = @{
                installed = $false
                authenticated = $false
            }
            claude_code = @{
                installed = $false
                authenticated = $false
            }
            supabase_cli = @{
                installed = $false
                authenticated = $false
            }
            super_claude = @{
                installed = $false
                mcp_servers_installed = $false
            }
            playwright_mcp = @{
                installed = $false
            }
            cursor_ide = @{ installed = $false }
        }

        $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
        Write-Success "状態ファイルを作成しました: $StateFile"
    }
}

function Get-InstallState {
    param(
        [string]$Tool,
        [string]$Key
    )

    if (-not (Test-Path $StateFile)) {
        return $false
    }

    try {
        $state = Get-Content $StateFile -Raw | ConvertFrom-Json
        $value = $state.$Tool.$Key
        return [bool]$value
    } catch {
        return $false
    }
}

function Update-InstallState {
    param(
        [string]$Tool,
        [string]$Key,
        [bool]$Value
    )

    try {
        if (Test-Path $StateFile) {
            $state = Get-Content $StateFile -Raw | ConvertFrom-Json
        } else {
            $state = @{}
        }

        if (-not $state.$Tool) {
            $state | Add-Member -MemberType NoteProperty -Name $Tool -Value @{} -Force
        }

        $state.$Tool.$Key = $Value

        $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
    } catch {
        Write-Err "状態の更新に失敗しました: $_"
    }
}

################################################################################
# インストール関数
################################################################################

function Install-Winget {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Info "winget は既にインストールされています (スキップ)"
        return
    }

    Write-Section "winget のインストール"

    Write-Info "winget は通常 Windows 10/11 にプリインストールされています"
    Write-Info "Microsoft Store から「アプリ インストーラー」をインストールしてください"

    Start-Process "ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1"

    $confirm = Read-Host "winget のインストールが完了したら Enter キーを押してください"
}

function Install-Node {
    if (Get-InstallState -Tool "node" -Key "installed") {
        Write-Info "Node.js は既にインストールされています (スキップ)"
        return
    }

    Write-Section "Node.js のインストール"

    if (Get-Command node -ErrorAction SilentlyContinue) {
        Write-Info "Node.js は既にインストールされています"
        Update-InstallState -Tool "node" -Key "installed" -Value $true
        return
    }

    winget install OpenJS.NodeJS --silent

    # PATH の更新
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    # 確認
    if (Get-Command node -ErrorAction SilentlyContinue) {
        $nodeVersion = node --version
        Write-Success "Node.js インストール完了: $nodeVersion"
        Update-InstallState -Tool "node" -Key "installed" -Value $true
    } else {
        Write-Err "Node.js のインストールに失敗しました"
        exit 1
    }
}

function Install-Git {
    if (Get-InstallState -Tool "git" -Key "installed") {
        Write-Info "Git は既にインストールされています (スキップ)"
        return
    }

    Write-Section "Git のインストール"

    if (Get-Command git -ErrorAction SilentlyContinue) {
        Write-Info "Git は既にインストールされています"
        Update-InstallState -Tool "git" -Key "installed" -Value $true
        return
    }

    winget install Git.Git --silent

    # PATH の更新
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    # 確認
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $gitVersion = git --version
        Write-Success "Git インストール完了: $gitVersion"
        Update-InstallState -Tool "git" -Key "installed" -Value $true
    } else {
        Write-Err "Git のインストールに失敗しました"
        exit 1
    }
}

function Install-GitHubCLI {
    if ((Get-InstallState -Tool "github_cli" -Key "installed") -and (Get-InstallState -Tool "github_cli" -Key "authenticated")) {
        Write-Info "GitHub CLI は既にインストール・認証済みです (スキップ)"
        return
    }

    Write-Section "GitHub CLI のインストール"

    # インストール確認
    if (-not (Get-InstallState -Tool "github_cli" -Key "installed")) {
        if (Get-Command gh -ErrorAction SilentlyContinue) {
            Write-Info "GitHub CLI は既にインストールされています"
            Update-InstallState -Tool "github_cli" -Key "installed" -Value $true
        } else {
            winget install --id GitHub.CLI --silent

            # PATH の更新
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

            Update-InstallState -Tool "github_cli" -Key "installed" -Value $true
            Write-Success "GitHub CLI インストール完了"
        }
    }

    # アカウント作成促進と認証
    if (-not (Get-InstallState -Tool "github_cli" -Key "authenticated")) {
        Write-Host "============================================================" -ForegroundColor Yellow
        Write-Host "GitHub アカウントをお持ちですか？" -ForegroundColor Cyan
        Write-Host "============================================================" -ForegroundColor Yellow

        $hasAccount = Read-Host "GitHub アカウントをお持ちですか？ (y/n)"

        if ($hasAccount -ne "y") {
            Write-Warn "GitHub アカウントが必要です。ブラウザでサインアップページを開きます..."
            Write-Host "推奨: 「Sign up with Google」ボタンで Google アカウントを使用してください" -ForegroundColor Cyan

            Start-Process "https://github.com/signup"

            $confirm = Read-Host "`nアカウント作成が完了したら Enter キーを押してください"
        }

        # 認証
        Write-Info "GitHub CLI の認証を開始します..."

        try {
            gh auth login
            Update-InstallState -Tool "github_cli" -Key "authenticated" -Value $true
            Write-Success "GitHub CLI 認証完了"
        } catch {
            Write-Err "GitHub CLI の認証に失敗しました"
            exit 1
        }
    }
}

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
            npm install -g netlify-cli
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

function Install-ClaudeCode {
    if ((Get-InstallState -Tool "claude_code" -Key "installed") -and (Get-InstallState -Tool "claude_code" -Key "authenticated")) {
        Write-Info "Claude Code は既にインストール・認証済みです (スキップ)"
        return
    }

    Write-Section "Claude Code のインストール"

    # インストール確認
    if (-not (Get-InstallState -Tool "claude_code" -Key "installed")) {
        if (Get-Command claude -ErrorAction SilentlyContinue) {
            Write-Info "Claude Code は既にインストールされています"
            Update-InstallState -Tool "claude_code" -Key "installed" -Value $true
        } else {
            Write-Info "Claude Code の認証を開始します..."
            Write-Host "Claude Pro アカウントが必要です" -ForegroundColor Cyan

            try {
                # 公式インストールスクリプトを実行
                Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression

                if ($LASTEXITCODE -eq 0) {
                    Update-InstallState -Tool "claude_code" -Key "installed" -Value $true
                    Write-Success "Claude Code インストール完了"
                } else {
                    Write-Err "Claude Code のインストールに失敗しました"
                    Write-Warn "手動でインストールしてください: https://claude.ai/install.ps1"
                    exit 1
                }
            } catch {
                Write-Err "Claude Code のインストールに失敗しました: $_"
                Write-Warn "手動でインストールしてください: https://claude.ai/install.ps1"
                exit 1
            }
        }
    }

    # 認証確認（インストール時に自動で認証プロセスが実行される）
    if (-not (Get-InstallState -Tool "claude_code" -Key "authenticated")) {
        # claude doctor コマンドで認証確認
        try {
            $null = claude doctor 2>&1
            if ($LASTEXITCODE -eq 0) {
                Update-InstallState -Tool "claude_code" -Key "authenticated" -Value $true
                Write-Success "Claude Code 認証完了"
            } else {
                Write-Warn "Claude Code の認証を完了してください"
                Write-Host "  コマンド: claude doctor" -ForegroundColor Cyan
            }
        } catch {
            Write-Warn "Claude Code の認証確認をスキップしました"
        }
    }
}

function Install-SupabaseCLI {
    if ((Get-InstallState -Tool "supabase_cli" -Key "installed") -and (Get-InstallState -Tool "supabase_cli" -Key "authenticated")) {
        Write-Info "Supabase CLI は既にインストール・認証済みです (スキップ)"
        return
    }

    Write-Section "Supabase CLI のインストール"

    # インストール確認
    if (-not (Get-InstallState -Tool "supabase_cli" -Key "installed")) {
        if (Get-Command supabase -ErrorAction SilentlyContinue) {
            Write-Info "Supabase CLI は既にインストールされています"
            Update-InstallState -Tool "supabase_cli" -Key "installed" -Value $true
        } else {
            npm install -g supabase
            Update-InstallState -Tool "supabase_cli" -Key "installed" -Value $true
            Write-Success "Supabase CLI インストール完了"
        }
    }

    # アカウント作成促進と認証
    if (-not (Get-InstallState -Tool "supabase_cli" -Key "authenticated")) {
        Write-Host "============================================================" -ForegroundColor Yellow
        Write-Host "Supabase アカウントをお持ちですか？" -ForegroundColor Cyan
        Write-Host "============================================================" -ForegroundColor Yellow

        $hasAccount = Read-Host "Supabase アカウントをお持ちですか？ (y/n)"

        if ($hasAccount -ne "y") {
            Write-Warn "Supabase アカウントが必要です。ブラウザでサインアップページを開きます..."
            Write-Host "推奨: 「Continue with GitHub」ボタンで GitHub アカウントを使用してください" -ForegroundColor Cyan

            Start-Process "https://supabase.com/dashboard/sign-up"

            $confirm = Read-Host "`nアカウント作成が完了したら Enter キーを押してください"
        }

        # 認証
        Write-Info "Supabase CLI の認証を開始します..."

        try {
            npx supabase login

            # 認証確認
            $null = npx supabase projects list 2>&1
            if ($LASTEXITCODE -eq 0) {
                Update-InstallState -Tool "supabase_cli" -Key "authenticated" -Value $true
                Write-Success "Supabase CLI 認証完了"
            } else {
                Write-Err "Supabase CLI の認証確認に失敗しました"
                exit 1
            }
        } catch {
            Write-Err "Supabase CLI の認証に失敗しました"
            exit 1
        }
    }
}

function Install-SuperClaude {
    if ((Get-InstallState -Tool "super_claude" -Key "installed") -and (Get-InstallState -Tool "super_claude" -Key "mcp_servers_installed")) {
        Write-Info "Super Claude と MCP Servers は既にインストール済みです (スキップ)"
        return
    }

    Write-Section "Super Claude のインストール"

    # Super Claude インストール
    if (-not (Get-InstallState -Tool "super_claude" -Key "installed")) {
        # pip がインストールされているか確認
        if (-not (Get-Command pip -ErrorAction SilentlyContinue)) {
            Write-Info "pip をインストールしています..."
            # Python がインストールされていない場合
            if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
                winget install Python.Python.3.11 --silent
                # PATH の更新
                $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            }
        }

        # pipx のインストール
        if (-not (Get-Command pipx -ErrorAction SilentlyContinue)) {
            Write-Info "pipx をインストールしています..."
            pip install pipx
            pipx ensurepath
            # PATH の更新
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        }

        # Super Claude インストール
        pipx install SuperClaude --force

        Update-InstallState -Tool "super_claude" -Key "installed" -Value $true
        Write-Success "Super Claude インストール完了"
    }

    # MCP Servers インストール
    if (-not (Get-InstallState -Tool "super_claude" -Key "mcp_servers_installed")) {
        Write-Section "MCP Servers のインストール"
        Write-Host "============================================================" -ForegroundColor Yellow
        Write-Host "以下の MCP Servers をインストールします:" -ForegroundColor Cyan
        Write-Host "  - Context7 (ライブラリドキュメント)" -ForegroundColor Cyan
        Write-Host "  - Sequential Thinking (複雑な推論)" -ForegroundColor Cyan
        Write-Host "  - Magic (UI コンポーネント)" -ForegroundColor Cyan
        Write-Host "  - Morphllm (パターンベース編集)" -ForegroundColor Cyan
        Write-Host "  - Serena (プロジェクトメモリ)" -ForegroundColor Cyan
        Write-Host "  - Tavily (Web検索)" -ForegroundColor Cyan
        Write-Host "  - Chrome DevTools (ブラウザ自動化)" -ForegroundColor Cyan
        Write-Host "============================================================" -ForegroundColor Yellow

        # MCPサーバーを自動インストール
        SuperClaude mcp install-all

        Update-InstallState -Tool "super_claude" -Key "mcp_servers_installed" -Value $true
        Write-Success "MCP Servers インストール完了"
    }
}

function Install-PlaywrightMCP {
    if (Get-InstallState -Tool "playwright_mcp" -Key "installed") {
        Write-Info "Playwright MCP は既にインストールされています (スキップ)"
        return
    }

    Write-Section "Playwright MCP のインストール"
    Write-Host "============================================================" -ForegroundColor Yellow
    Write-Host "Playwright MCP を Super Claude 経由でインストールします" -ForegroundColor Cyan
    Write-Host "ブラウザ (Chromium, Firefox, WebKit) も自動インストールされます" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Yellow

    # Super Claude 経由で Playwright MCP をインストール
    SuperClaude mcp install playwright

    # Playwright ブラウザのインストール
    Write-Info "Playwright ブラウザをインストールしています..."
    npx playwright install

    Update-InstallState -Tool "playwright_mcp" -Key "installed" -Value $true
    Write-Success "Playwright MCP インストール完了"
}

function Install-CursorIDE {
    if (Get-InstallState -Tool "cursor_ide" -Key "installed") {
        Write-Info "Cursor IDE は既にインストールされています (スキップ)"
        return
    }

    Write-Section "Cursor IDE のインストール"

    Write-Host "Cursor IDE は手動でインストールする必要があります" -ForegroundColor Yellow
    Write-Host "ブラウザでダウンロードページを開きます..." -ForegroundColor Cyan

    Start-Process "https://cursor.sh"

    $confirm = Read-Host "`nCursor IDE のインストールが完了したら Enter キーを押してください"

    Update-InstallState -Tool "cursor_ide" -Key "installed" -Value $true
    Write-Success "Cursor IDE インストール確認完了"
}

################################################################################
# メイン実行フロー
################################################################################

function Main {
    Write-Section "AI開発環境自動セットアップ (Windows)"
    Write-Host "このスクリプトは以下のツールをインストールします:" -ForegroundColor Cyan
    Write-Host "  1. winget (パッケージマネージャー)" -ForegroundColor Cyan
    Write-Host "  2. Node.js (JavaScript実行環境)" -ForegroundColor Cyan
    Write-Host "  3. Git (バージョン管理)" -ForegroundColor Cyan
    Write-Host "  4. GitHub CLI (GitHub操作)" -ForegroundColor Cyan
    Write-Host "  5. Netlify CLI (デプロイ)" -ForegroundColor Cyan
    Write-Host "  6. Claude Code (AI開発ツール)" -ForegroundColor Cyan
    Write-Host "  7. Supabase CLI (データベース)" -ForegroundColor Cyan
    Write-Host "  8. Super Claude + MCP Servers (拡張機能)" -ForegroundColor Cyan
    Write-Host "  9. Playwright MCP (E2Eテスト)" -ForegroundColor Cyan
    Write-Host " 10. Cursor IDE (統合開発環境)" -ForegroundColor Cyan
    Write-Host ""

    $confirm = Read-Host "インストールを開始しますか？ (y/n)"
    if ($confirm -ne "y") {
        Write-Warn "インストールをキャンセルしました"
        exit 0
    }

    # 状態ファイル初期化
    Initialize-State

    # インストール実行
    Install-Winget
    Install-Node
    Install-Git
    Install-GitHubCLI
    Install-NetlifyCLI
    Install-ClaudeCode
    Install-SupabaseCLI
    Install-SuperClaude
    Install-PlaywrightMCP
    Install-CursorIDE

    # 完了メッセージ
    Write-Section "🎉 セットアップ完了！"
    Write-Success "すべてのツールのインストールが完了しました！"
    Write-Host ""
    Write-Host "次のステップ:" -ForegroundColor Cyan
    Write-Host "  1. PowerShell を再起動してください" -ForegroundColor Cyan
    Write-Host "  2. Cursor IDE を起動してください" -ForegroundColor Cyan
    Write-Host "  3. マニュアルの1章から学習を開始できます" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "状態ファイル: $StateFile" -ForegroundColor Yellow
    Write-Host "  (このファイルを削除すると、再インストールが必要になります)" -ForegroundColor Yellow
}

# スクリプト実行
Main
