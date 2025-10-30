# AI�J���������Z�b�g�A�b�v�X�N���v�g (Windows)
#
# �ړI: 0�́u�����Z�b�g�A�b�v�ŊJ�����𐮂���v�Ŏg�p����
#      �S�c�[���̎����C���X�g�[���E�F�؁E�A�J�E���g�쐬���i
#
# ���s���@ (PowerShell�Ǘ��Ҍ���):
#   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
#   .\install-ai-dev-tools-win.ps1
#
# �Ή�OS: Windows 10 / 11

#Requires -Version 5.1

################################################################################
# �G���[�n���h�����O�ݒ�
################################################################################

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

################################################################################
# �J���[��`
################################################################################

function Write-Section {
    param([string]$Message)
    Write-Host "`n============================================================" -ForegroundColor Blue
    Write-Host "[>>>] $Message" -ForegroundColor Blue
    Write-Host "============================================================`n" -ForegroundColor Blue
}

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Err {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

################################################################################
# ��ԊǗ�
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
        Write-Success "��ԃt�@�C�����쐬���܂���: $StateFile"
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
        Write-Err "��Ԃ̍X�V�Ɏ��s���܂���: $_"
    }
}

################################################################################
# �C���X�g�[���֐�
################################################################################

function Install-Winget {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Info "winget �͊��ɃC���X�g�[������Ă��܂� (�X�L�b�v)"
        return
    }

    Write-Section "winget �̃C���X�g�[��"

    Write-Info "winget �͒ʏ� Windows 10/11 �Ƀv���C���X�g�[������Ă��܂�"
    Write-Info "Microsoft Store ����u�A�v�� �C���X�g�[���[�v���C���X�g�[�����Ă�������"

    Start-Process "ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1"

    $confirm = Read-Host "winget �̃C���X�g�[�������������� Enter �L�[�������Ă�������"
}

function Install-Node {
    if (Get-InstallState -Tool "node" -Key "installed") {
        Write-Info "Node.js �͊��ɃC���X�g�[������Ă��܂� (�X�L�b�v)"
        return
    }

    Write-Section "Node.js �̃C���X�g�[��"

    if (Get-Command node -ErrorAction SilentlyContinue) {
        Write-Info "Node.js �͊��ɃC���X�g�[������Ă��܂�"
        Update-InstallState -Tool "node" -Key "installed" -Value $true
        return
    }

    winget install OpenJS.NodeJS --silent

    # PATH �̍X�V
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    # �m�F
    if (Get-Command node -ErrorAction SilentlyContinue) {
        $nodeVersion = node --version
        Write-Success "Node.js �C���X�g�[������: $nodeVersion"
        Update-InstallState -Tool "node" -Key "installed" -Value $true
    } else {
        Write-Err "Node.js �̃C���X�g�[���Ɏ��s���܂���"
        exit 1
    }
}

function Install-Git {
    if (Get-InstallState -Tool "git" -Key "installed") {
        Write-Info "Git �͊��ɃC���X�g�[������Ă��܂� (�X�L�b�v)"
        return
    }

    Write-Section "Git �̃C���X�g�[��"

    if (Get-Command git -ErrorAction SilentlyContinue) {
        Write-Info "Git �͊��ɃC���X�g�[������Ă��܂�"
        Update-InstallState -Tool "git" -Key "installed" -Value $true
        return
    }

    winget install Git.Git --silent

    # PATH �̍X�V
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    # �m�F
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $gitVersion = git --version
        Write-Success "Git �C���X�g�[������: $gitVersion"
        Update-InstallState -Tool "git" -Key "installed" -Value $true
    } else {
        Write-Err "Git �̃C���X�g�[���Ɏ��s���܂���"
        exit 1
    }
}

function Install-GitHubCLI {
    if ((Get-InstallState -Tool "github_cli" -Key "installed") -and (Get-InstallState -Tool "github_cli" -Key "authenticated")) {
        Write-Info "GitHub CLI �͊��ɃC���X�g�[���E�F�؍ς݂ł� (�X�L�b�v)"
        return
    }

    Write-Section "GitHub CLI �̃C���X�g�[��"

    # �C���X�g�[���m�F
    if (-not (Get-InstallState -Tool "github_cli" -Key "installed")) {
        if (Get-Command gh -ErrorAction SilentlyContinue) {
            Write-Info "GitHub CLI �͊��ɃC���X�g�[������Ă��܂�"
            Update-InstallState -Tool "github_cli" -Key "installed" -Value $true
        } else {
            Write-Info "GitHub CLI ���C���X�g�[����..."
            npm install -g @github/gh

            # PATH �̍X�V
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

            Update-InstallState -Tool "github_cli" -Key "installed" -Value $true
            Write-Success "GitHub CLI �C���X�g�[������"
        }
    }

    # �A�J�E���g�쐬���i�ƔF��
    if (-not (Get-InstallState -Tool "github_cli" -Key "authenticated")) {
        Write-Host "============================================================" -ForegroundColor Yellow
        Write-Host "GitHub �A�J�E���g���������ł����H" -ForegroundColor Cyan
        Write-Host "============================================================" -ForegroundColor Yellow

        $hasAccount = Read-Host "GitHub �A�J�E���g���������ł����H (y/n)"

        if ($hasAccount -ne "y") {
            Write-Warn "GitHub �A�J�E���g���K�v�ł��B�u���E�U�ŃT�C���A�b�v�y�[�W���J���܂�..."
            Write-Host "����: �uSign up with Google�v�{�^���� Google �A�J�E���g���g�p���Ă�������" -ForegroundColor Cyan

            Start-Process "https://github.com/signup"

            $confirm = Read-Host "`n�A�J�E���g�쐬������������ Enter �L�[�������Ă�������"
        }

        # �F��
        Write-Info "GitHub CLI �̔F�؂��J�n���܂�..."

        try {
            gh auth login
            Update-InstallState -Tool "github_cli" -Key "authenticated" -Value $true
            Write-Success "GitHub CLI �F�؊���"
        } catch {
            Write-Err "GitHub CLI �̔F�؂Ɏ��s���܂���"
            exit 1
        }
    }
}

function Install-NetlifyCLI {
    if ((Get-InstallState -Tool "netlify_cli" -Key "installed") -and (Get-InstallState -Tool "netlify_cli" -Key "authenticated")) {
        Write-Info "Netlify CLI �͊��ɃC���X�g�[���E�F�؍ς݂ł� (�X�L�b�v)"
        return
    }

    Write-Section "Netlify CLI �̃C���X�g�[��"

    # �C���X�g�[���m�F
    if (-not (Get-InstallState -Tool "netlify_cli" -Key "installed")) {
        if (Get-Command netlify -ErrorAction SilentlyContinue) {
            Write-Info "Netlify CLI �͊��ɃC���X�g�[������Ă��܂�"
            Update-InstallState -Tool "netlify_cli" -Key "installed" -Value $true
        } else {
            npm install -g netlify-cli
            Update-InstallState -Tool "netlify_cli" -Key "installed" -Value $true
            Write-Success "Netlify CLI �C���X�g�[������"
        }
    }

    # �A�J�E���g�쐬���i�ƔF��
    if (-not (Get-InstallState -Tool "netlify_cli" -Key "authenticated")) {
        Write-Host "============================================================" -ForegroundColor Yellow
        Write-Host "Netlify �͎����f�v���C�Ɏg�p���܂�" -ForegroundColor Cyan
        Write-Host "CLI�o�R��GitHub�A�g��ݒ肵�܂�" -ForegroundColor Cyan
        Write-Host "============================================================" -ForegroundColor Yellow

        $hasAccount = Read-Host "Netlify �A�J�E���g���������ł����H (y/n)"

        if ($hasAccount -ne "y") {
            Write-Warn "Netlify �A�J�E���g���K�v�ł��B�u���E�U�ŃT�C���A�b�v�y�[�W���J���܂�..."
            Write-Host "����: �uSign up with GitHub�v�{�^���� GitHub �A�J�E���g���g�p���Ă�������" -ForegroundColor Cyan

            Start-Process "https://app.netlify.com/signup"

            $confirm = Read-Host "`n�A�J�E���g�쐬������������ Enter �L�[�������Ă�������"
        }

        # �F��
        Write-Info "Netlify CLI �̔F�؂��J�n���܂�..."

        try {
            netlify login
            Update-InstallState -Tool "netlify_cli" -Key "authenticated" -Value $true
            Write-Success "Netlify CLI �F�؊���"
        } catch {
            Write-Err "Netlify CLI �̔F�؂Ɏ��s���܂���"
            exit 1
        }
    }
}

function Install-ClaudeCode {
    if ((Get-InstallState -Tool "claude_code" -Key "installed") -and (Get-InstallState -Tool "claude_code" -Key "authenticated")) {
        Write-Info "Claude Code �͊��ɃC���X�g�[���E�F�؍ς݂ł� (�X�L�b�v)"
        return
    }

    Write-Section "Claude Code �̃C���X�g�[��"

    # �C���X�g�[���m�F
    if (-not (Get-InstallState -Tool "claude_code" -Key "installed")) {
        if (Get-Command claude -ErrorAction SilentlyContinue) {
            Write-Info "Claude Code �͊��ɃC���X�g�[������Ă��܂�"
            Update-InstallState -Tool "claude_code" -Key "installed" -Value $true
        } else {
            Write-Info "Claude Code ���C���X�g�[�����܂�..."
            Write-Host "Claude Pro �A�J�E���g���K�v�ł�" -ForegroundColor Cyan

            try {
                # npm�o�R�ŃC���X�g�[��
                npm install -g claude-code

                if ($LASTEXITCODE -eq 0) {
                    Update-InstallState -Tool "claude_code" -Key "installed" -Value $true
                    Write-Success "Claude Code �C���X�g�[������"
                } else {
                    Write-Err "Claude Code �̃C���X�g�[���Ɏ��s���܂���"
                    Write-Warn "�蓮�ŃC���X�g�[�����Ă�������: npm install -g claude-code"
                    exit 1
                }
            } catch {
                Write-Err "Claude Code �̃C���X�g�[���Ɏ��s���܂���: $_"
                Write-Warn "�蓮�ŃC���X�g�[�����Ă�������: npm install -g claude-code"
                exit 1
            }
        }
    }

    # �F�؊m�F�i�C���X�g�[�����Ɏ����ŔF�؃v���Z�X�����s�����j
    if (-not (Get-InstallState -Tool "claude_code" -Key "authenticated")) {
        # claude doctor �R�}���h�ŔF�؊m�F
        try {
            $null = claude doctor 2>&1
            if ($LASTEXITCODE -eq 0) {
                Update-InstallState -Tool "claude_code" -Key "authenticated" -Value $true
                Write-Success "Claude Code �F�؊���"
            } else {
                Write-Warn "Claude Code �̔F�؂��������Ă�������"
                Write-Host "  �R�}���h: claude doctor" -ForegroundColor Cyan
            }
        } catch {
            Write-Warn "Claude Code �̔F�؊m�F���X�L�b�v���܂���"
        }
    }
}

function Install-SupabaseCLI {
    if ((Get-InstallState -Tool "supabase_cli" -Key "installed") -and (Get-InstallState -Tool "supabase_cli" -Key "authenticated")) {
        Write-Info "Supabase CLI �͊��ɃC���X�g�[���E�F�؍ς݂ł� (�X�L�b�v)"
        return
    }

    Write-Section "Supabase CLI �̃C���X�g�[��"

    # �C���X�g�[���m�F
    if (-not (Get-InstallState -Tool "supabase_cli" -Key "installed")) {
        if (Get-Command supabase -ErrorAction SilentlyContinue) {
            Write-Info "Supabase CLI �͊��ɃC���X�g�[������Ă��܂�"
            Update-InstallState -Tool "supabase_cli" -Key "installed" -Value $true
        } else {
            npm install -g supabase
            Update-InstallState -Tool "supabase_cli" -Key "installed" -Value $true
            Write-Success "Supabase CLI �C���X�g�[������"
        }
    }

    # �A�J�E���g�쐬���i�ƔF��
    if (-not (Get-InstallState -Tool "supabase_cli" -Key "authenticated")) {
        Write-Host "============================================================" -ForegroundColor Yellow
        Write-Host "Supabase �A�J�E���g���������ł����H" -ForegroundColor Cyan
        Write-Host "============================================================" -ForegroundColor Yellow

        $hasAccount = Read-Host "Supabase �A�J�E���g���������ł����H (y/n)"

        if ($hasAccount -ne "y") {
            Write-Warn "Supabase �A�J�E���g���K�v�ł��B�u���E�U�ŃT�C���A�b�v�y�[�W���J���܂�..."
            Write-Host "����: �uContinue with GitHub�v�{�^���� GitHub �A�J�E���g���g�p���Ă�������" -ForegroundColor Cyan

            Start-Process "https://supabase.com/dashboard/sign-up"

            $confirm = Read-Host "`n�A�J�E���g�쐬������������ Enter �L�[�������Ă�������"
        }

        # �F��
        Write-Info "Supabase CLI �̔F�؂��J�n���܂�..."

        try {
            supabase login

            # �F�؊m�F
            $null = supabase projects list 2>&1
            if ($LASTEXITCODE -eq 0) {
                Update-InstallState -Tool "supabase_cli" -Key "authenticated" -Value $true
                Write-Success "Supabase CLI �F�؊���"
            } else {
                Write-Err "Supabase CLI �̔F�؊m�F�Ɏ��s���܂���"
                exit 1
            }
        } catch {
            Write-Err "Supabase CLI �̔F�؂Ɏ��s���܂���"
            exit 1
        }
    }
}

function Install-SuperClaude {
    if ((Get-InstallState -Tool "super_claude" -Key "installed") -and (Get-InstallState -Tool "super_claude" -Key "mcp_servers_installed")) {
        Write-Info "Super Claude �� MCP Servers �͊��ɃC���X�g�[���ς݂ł� (�X�L�b�v)"
        return
    }

    Write-Section "Super Claude �̃C���X�g�[��"

    # Super Claude �C���X�g�[��
    if (-not (Get-InstallState -Tool "super_claude" -Key "installed")) {
        # npm �o�R�� Super Claude ���C���X�g�[��
        Write-Info "Super Claude ���C���X�g�[�����Ă��܂�..."
        npm install -g @bifrost_inc/superclaude

        # Claude Code �ւ̓����i�J�X�^���R�}���h sc: �̓o�^�Ȃǁj
        Write-Info "Claude Code �� SuperClaude �𓝍����Ă��܂�..."
        try {
            $integrationResult = superclaude install 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Success "SuperClaude �� Claude Code ��������"
            } else {
                Write-Warn "SuperClaude �̓��������Ōx�����������܂���"
                Write-Host "  ��Ŏ蓮���s���Ă�������: superclaude install" -ForegroundColor Yellow
            }
        } catch {
            Write-Warn "SuperClaude �̓��������Ɏ��s���܂���"
            Write-Host "  ��Ŏ蓮���s���Ă�������: superclaude install" -ForegroundColor Yellow
            Write-Host "  ������� /sc: �R�}���h�� Claude Code �Ŏg�p�ł��܂�" -ForegroundColor Cyan
        }

        Update-InstallState -Tool "super_claude" -Key "installed" -Value $true
        Write-Success "Super Claude �C���X�g�[������"
    }

    # MCP Servers �� superclaude install �R�}���h�Ŏ����C���X�g�[�������
    Update-InstallState -Tool "super_claude" -Key "mcp_servers_installed" -Value $true
}

function Install-PlaywrightBrowsers {
    if (Get-InstallState -Tool "playwright_mcp" -Key "installed") {
        Write-Info "Playwright �u���E�U�͊��ɃC���X�g�[������Ă��܂� (�X�L�b�v)"
        return
    }

    Write-Section "Playwright �u���E�U�̃C���X�g�[��"
    Write-Host "============================================================" -ForegroundColor Yellow
    Write-Host "Playwright �u���E�U (Chromium, Firefox, WebKit) ���C���X�g�[�����܂�" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Yellow

    # Playwright �u���E�U�̃C���X�g�[��
    Write-Info "Playwright �u���E�U���C���X�g�[�����Ă��܂�..."
    npx playwright install

    Update-InstallState -Tool "playwright_mcp" -Key "installed" -Value $true
    Write-Success "Playwright �u���E�U�C���X�g�[������"
}

function Install-CursorIDE {
    if (Get-InstallState -Tool "cursor_ide" -Key "installed") {
        Write-Info "Cursor IDE �͊��ɃC���X�g�[������Ă��܂� (�X�L�b�v)"
        return
    }

    Write-Section "Cursor IDE �̃C���X�g�[��"

    Write-Host "Cursor IDE �͎蓮�ŃC���X�g�[������K�v������܂�" -ForegroundColor Yellow
    Write-Host "�u���E�U�Ń_�E�����[�h�y�[�W���J���܂�..." -ForegroundColor Cyan

    Start-Process "https://cursor.sh"

    $confirm = Read-Host "`nCursor IDE �̃C���X�g�[�������������� Enter �L�[�������Ă�������"

    Update-InstallState -Tool "cursor_ide" -Key "installed" -Value $true
    Write-Success "Cursor IDE �C���X�g�[���m�F����"
}

################################################################################
# ���C�����s�t���[
################################################################################

function Main {
    Write-Section "AI�J���������Z�b�g�A�b�v (Windows)"
    Write-Host "���̃X�N���v�g�͈ȉ��̃c�[�����C���X�g�[�����܂�:" -ForegroundColor Cyan
    Write-Host "  1. winget (�p�b�P�[�W�}�l�[�W���[)" -ForegroundColor Cyan
    Write-Host "  2. Node.js (JavaScript���s��)" -ForegroundColor Cyan
    Write-Host "  3. Git (�o�[�W�����Ǘ�)" -ForegroundColor Cyan
    Write-Host "  4. GitHub CLI (GitHub����)" -ForegroundColor Cyan
    Write-Host "  5. Netlify CLI (�f�v���C)" -ForegroundColor Cyan
    Write-Host "  6. Claude Code (AI�J���c�[��)" -ForegroundColor Cyan
    Write-Host "  7. Supabase CLI (�f�[�^�x�[�X)" -ForegroundColor Cyan
    Write-Host "  8. Super Claude + MCP Servers (�g���@�\)" -ForegroundColor Cyan
    Write-Host "  9. Playwright �u���E�U (E2E�e�X�g)" -ForegroundColor Cyan
    Write-Host " 10. Cursor IDE (�����J����)" -ForegroundColor Cyan
    Write-Host ""

    $confirm = Read-Host "�C���X�g�[�����J�n���܂����H (y/n)"
    if ($confirm -ne "y") {
        Write-Warn "�C���X�g�[�����L�����Z�����܂���"
        exit 0
    }

    # ��ԃt�@�C��������
    Initialize-State

    # �C���X�g�[�����s
    Install-Winget
    Install-Node
    Install-Git
    Install-GitHubCLI
    Install-NetlifyCLI
    Install-ClaudeCode
    Install-SupabaseCLI
    Install-SuperClaude
    Install-PlaywrightBrowsers
    Install-CursorIDE

    # �������b�Z�[�W
    Write-Section "�Z�b�g�A�b�v�����I"
    Write-Success "���ׂẴc�[���̃C���X�g�[�����������܂����I"
    Write-Host ""
    Write-Host "���̃X�e�b�v:" -ForegroundColor Cyan
    Write-Host "  1. PowerShell ���ċN�����Ă�������" -ForegroundColor Cyan
    Write-Host "  2. Cursor IDE ���N�����Ă�������" -ForegroundColor Cyan
    Write-Host "  3. �}�j���A����1�͂���w�K���J�n�ł��܂�" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "��ԃt�@�C��: $StateFile" -ForegroundColor Yellow
    Write-Host "  (���̃t�@�C�����폜����ƁA�ăC���X�g�[�����K�v�ɂȂ�܂�)" -ForegroundColor Yellow
}

# �X�N���v�g���s
Main
