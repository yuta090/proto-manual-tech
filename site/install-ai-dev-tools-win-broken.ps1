# ============================================================================
# AI�J���� �����Z�b�g�A�b�v�X�N���v�g (Windows��)
# ============================================================================
# Node.js, Git, Claude Code, Super Claude, Cursor IDE, Codex CLI ��
# �����C���X�g�[�����A�F�؂��K�v�ȉӏ��ł͑Θb�I�ɑҋ@���܂��B
# ���f���Ă��Ď��s�ő�������ĊJ�ł��܂��B
# ============================================================================

# �G���[�Œ�~
$ErrorActionPreference = "Stop"

# ============================================================================
# �J���[��` & �A�j���[�V�����֐�
# ============================================================================

# �G����
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
    Write-ColorOutput "������������������������������������������������������������������������������������������������������������" Blue
    Write-ColorOutput "[$Step/7] $Title" White
    Write-ColorOutput "������������������������������������������������������������������������������������������������������������" Blue
    Write-Host ""
}

# ============================================================================
# ��ԊǗ�
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
# �`�F�b�N�֐�
# ============================================================================

function Test-Command {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

function Test-Winget {
    if (-not (Test-Command winget)) {
        Write-Warning-Custom "Winget ���C���X�g�[������Ă��܂���"
        Write-Host "Windows 10 1809�ȍ~�܂��� Windows 11 ���K�v�ł�" -ForegroundColor Yellow
        Write-Host "Microsoft Store ����u�A�v�� �C���X�g�[���[�v���C���X�g�[�����Ă�������" -ForegroundColor Yellow
        exit 1
    }
}

# ============================================================================
# �A�J�E���g�o�^�K�C�h�֐�
# ============================================================================

function Show-AccountRequirements {
    Write-Host ""
    Write-ColorOutput "������������������������������������������������������������������������������������������������������������" Magenta
    Write-ColorOutput "�K�v�ȃA�J�E���g�ꗗ" White
    Write-ColorOutput "������������������������������������������������������������������������������������������������������������" Magenta
    Write-Host ""

    Write-Host "[�K�{] " -ForegroundColor Red -NoNewline
    Write-Host "Claude Pro" -ForegroundColor Yellow -NoNewline
    Write-Host " - `$20/��" -ForegroundColor White
    Write-Host "       ���� Claude Code �̎��s�ɕK�{" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "[����] " -ForegroundColor Yellow -NoNewline
    Write-Host "GitHub" -ForegroundColor Yellow -NoNewline
    Write-Host " - ����" -ForegroundColor White
    Write-Host "       ���� Git�A�g�ASSH���o�^�Ɏg�p" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "[�C��] " -ForegroundColor Blue -NoNewline
    Write-Host "ChatGPT Plus/Pro" -ForegroundColor Yellow -NoNewline
    Write-Host " - `$20/��" -ForegroundColor White
    Write-Host "       ���� Codex CLI �g�p���̂ݕK�v" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "[�C��] " -ForegroundColor Blue -NoNewline
    Write-Host "Cursor IDE" -ForegroundColor Yellow -NoNewline
    Write-Host " - �����iPro�v��������j" -ForegroundColor White
    Write-Host "       ���� AI�����G�f�B�^" -ForegroundColor Cyan
    Write-Host ""
}

function Register-ClaudePro {
    Show-Section 0 "Claude Pro �A�J�E���g�o�^"

    if (Get-State "accounts" "claude_pro" "registered") {
        Write-Success "Claude Pro �A�J�E���g�͓o�^�ς݂ł� (�X�L�b�v)"
        return
    }

    Write-ColorOutput "������������������������������������������������������������������������������������������������������������" Yellow
    Write-Host "??  �d�v: Claude Pro �A�J�E���g���K�v�ł�" -ForegroundColor Red
    Write-ColorOutput "������������������������������������������������������������������������������������������������������������" Yellow
    Write-Host ""

    Write-Host "Claude Code ���g�p����ɂ� " -ForegroundColor White -NoNewline
    Write-Host "Claude Pro�i`$20/���j" -ForegroundColor Yellow -NoNewline
    Write-Host " �̌_�񂪕K�v�ł��B" -ForegroundColor White
    Write-Host "������u���E�U�œo�^�y�[�W���J���܂��B" -ForegroundColor White
    Write-Host ""

    $response = Read-Host "�o�^�y�[�W���J���܂���? (y/N)"

    if ($response -notmatch '^[Yy]$') {
        Write-Error-Custom "Claude Pro �̓o�^���X�L�b�v���܂���"
        Write-Host "��� https://claude.ai/upgrade �œo�^���Ă�������" -ForegroundColor Yellow
        exit 1
    }

    Write-Host ""
    Write-Info "�u���E�U�� Claude �o�^�y�[�W���J���܂�..."
    Start-Sleep -Seconds 1
    Start-Process "https://claude.ai/upgrade"

    Write-Host ""
    Write-ColorOutput "������������������������������������������������������������������������������������������������������������" Cyan
    Write-Host "? �o�^�菇:" -ForegroundColor White
    Write-Host ""
    Write-Host "  1. " -ForegroundColor Yellow -NoNewline
    Write-Host "�uContinue with Google�v" -ForegroundColor Green -NoNewline
    Write-Host " �{�^�����N���b�N"
    Write-Host "  2. Google�A�J�E���g�Ń��O�C��" -ForegroundColor Yellow
    Write-Host "  3. " -ForegroundColor Yellow -NoNewline
    Write-Host "�uUpgrade to Claude Pro�v" -ForegroundColor Green -NoNewline
    Write-Host " ��I���i`$20/���j"
    Write-Host "  4. �N���W�b�g�J�[�h�������" -ForegroundColor Yellow
    Write-Host "  5. �o�^������A" -ForegroundColor Yellow -NoNewline
    Write-Host "���̃^�[�~�i���ɖ߂�" -ForegroundColor White
    Write-Host ""
    Write-ColorOutput "������������������������������������������������������������������������������������������������������������" Cyan

    while ($true) {
        Write-Host ""
        $null = Read-Host "�o�^������������ Enter �������Ă�������"

        $confirm = Read-Host "Claude Pro �v�����ɓo�^���܂�����? (y/N)"

        if ($confirm -match '^[Yy]$') {
            Update-State "accounts" "claude_pro" $true "registered"
            Update-State "accounts" "claude_pro" "Pro" "plan"
            Write-Success "Claude Pro �A�J�E���g�o�^�����I"
            break
        } else {
            Write-Warning-Custom "Claude Pro �̓o�^���K�v�ł�"
        }
    }
}

function Register-GitHub {
    Write-Host ""
    Write-ColorOutput "������������������������������������������������������������������������������������������������������������" Blue
    Write-ColorOutput "GitHub �A�J�E���g�o�^ (����)" White
    Write-ColorOutput "������������������������������������������������������������������������������������������������������������" Blue
    Write-Host ""

    if (Get-State "accounts" "github" "registered") {
        Write-Success "GitHub �A�J�E���g�͓o�^�ς݂ł� (�X�L�b�v)"
        return
    }

    $hasAccount = Read-Host "GitHub �A�J�E���g�������Ă��܂���? (y/N)"

    if ($hasAccount -match '^[Yy]$') {
        $githubUsername = Read-Host "GitHub ���[�U�[������͂��Ă�������"
        Update-State "accounts" "github" $true "registered"
        Update-State "accounts" "github" $githubUsername "username"
        Write-Success "GitHub �A�J�E���g����ۑ����܂���"
        return
    }

    $response = Read-Host "`n������ GitHub �A�J�E���g��o�^���܂���? (y/N)"

    if ($response -notmatch '^[Yy]$') {
        Write-Info "GitHub �o�^���X�L�b�v���܂����i��œo�^�ł��܂��j"
        return
    }

    Write-Host ""
    Write-Info "�u���E�U�� GitHub �o�^�y�[�W���J���܂�..."
    Start-Sleep -Seconds 1
    Start-Process "https://github.com/signup"

    Write-Host ""
    Write-ColorOutput "������������������������������������������������������������������������������������������������������������" Cyan
    Write-Host "? �o�^�菇:" -ForegroundColor White
    Write-Host ""
    Write-Host "  1. ���[���A�h���X�����" -ForegroundColor Yellow
    Write-Host "  2. �p�X���[�h���쐬" -ForegroundColor Yellow
    Write-Host "  3. ���[�U�[��������" -ForegroundColor Yellow
    Write-Host "  4. ���[���m�F�R�[�h�����" -ForegroundColor Yellow
    Write-Host "  5. �o�^������A" -ForegroundColor Yellow -NoNewline
    Write-Host "���̃^�[�~�i���ɖ߂�" -ForegroundColor White
    Write-Host ""
    Write-ColorOutput "������������������������������������������������������������������������������������������������������������" Cyan

    $null = Read-Host "`n�o�^������������ Enter �������Ă�������"

    $githubUsername = Read-Host "GitHub ���[�U�[������͂��Ă�������"

    if ($githubUsername) {
        Update-State "accounts" "github" $true "registered"
        Update-State "accounts" "github" $githubUsername "username"
        Write-Success "GitHub �A�J�E���g�o�^�����I"
    } else {
        Write-Warning-Custom "GitHub �o�^���X�L�b�v���܂���"
    }
}

function Register-ChatGPTPlus {
    Write-Host ""
    Write-ColorOutput "������������������������������������������������������������������������������������������������������������" Blue
    Write-ColorOutput "ChatGPT Plus/Pro �A�J�E���g�o�^ (�C��)" White
    Write-ColorOutput "������������������������������������������������������������������������������������������������������������" Blue
    Write-Host ""

    if (Get-State "accounts" "chatgpt_plus" "registered") {
        Write-Success "ChatGPT Plus/Pro �A�J�E���g�͓o�^�ς݂ł� (�X�L�b�v)"
        return
    }

    Write-Host "Codex CLI ���g�p����ɂ� " -ForegroundColor White -NoNewline
    Write-Host "ChatGPT Plus/Pro�i`$20/���j" -ForegroundColor Yellow -NoNewline
    Write-Host " ���K�v�ł��B" -ForegroundColor White
    $response = Read-Host "`nChatGPT Plus/Pro ��o�^���܂���? (y/N)"

    if ($response -notmatch '^[Yy]$') {
        Write-Info "ChatGPT �o�^���X�L�b�v���܂����iCodex CLI�g�p���ɓo�^���Ă��������j"
        return
    }

    Write-Host ""
    Write-Info "�u���E�U�� ChatGPT �o�^�y�[�W���J���܂�..."
    Start-Sleep -Seconds 1
    Start-Process "https://chatgpt.com/signup"

    Write-Host ""
    Write-ColorOutput "������������������������������������������������������������������������������������������������������������" Cyan
    Write-Host "? �o�^�菇:" -ForegroundColor White
    Write-Host ""
    Write-Host "  1. " -ForegroundColor Yellow -NoNewline
    Write-Host "�uContinue with Google�v" -ForegroundColor Green -NoNewline
    Write-Host " �{�^�����N���b�N"
    Write-Host "  2. Google�A�J�E���g�Ń��O�C��" -ForegroundColor Yellow
    Write-Host "  3. " -ForegroundColor Yellow -NoNewline
    Write-Host "�uUpgrade to Plus�v" -ForegroundColor Green -NoNewline
    Write-Host " �܂��� " -NoNewline
    Write-Host "�uUpgrade to Pro�v" -ForegroundColor Green -NoNewline
    Write-Host " ��I��"
    Write-Host "  4. �N���W�b�g�J�[�h�������" -ForegroundColor Yellow
    Write-Host "  5. �o�^������A" -ForegroundColor Yellow -NoNewline
    Write-Host "���̃^�[�~�i���ɖ߂�" -ForegroundColor White
    Write-Host ""
    Write-ColorOutput "������������������������������������������������������������������������������������������������������������" Cyan

    $null = Read-Host "`n�o�^������������ Enter �������Ă�������"

    $plan = Read-Host "�ǂ̃v������o�^���܂�����? (plus/pro/N)"

    if ($plan -match '^[Pp]lus$') {
        Update-State "accounts" "chatgpt_plus" $true "registered"
        Update-State "accounts" "chatgpt_plus" "Plus" "plan"
        Write-Success "ChatGPT Plus �A�J�E���g�o�^�����I"
    } elseif ($plan -match '^[Pp]ro$') {
        Update-State "accounts" "chatgpt_plus" $true "registered"
        Update-State "accounts" "chatgpt_plus" "Pro" "plan"
        Write-Success "ChatGPT Pro �A�J�E���g�o�^�����I"
    } else {
        Write-Info "ChatGPT �o�^���X�L�b�v���܂���"
    }
}

# ============================================================================
# �C���X�g�[���֐�
# ============================================================================

function Install-NodeJS {
    Show-Section 1 "Node.js �̃C���X�g�[��"

    if (Get-State "nodejs" "installed") {
        $version = & node --version 2>$null
        Write-Success "Node.js $version �͊��ɃC���X�g�[���ς݂ł� (�X�L�b�v)"
        return
    }

    if (Test-Command node) {
        $version = & node --version
        Write-Success "Node.js $version �����ɃC���X�g�[������Ă��܂�"
        Update-State "nodejs" "installed" $true
        Update-State "nodejs" "version" $version
        return
    }

    Write-Info "Node.js ���C���X�g�[����..."
    winget install OpenJS.NodeJS --silent --accept-package-agreements --accept-source-agreements

    # �p�X�����t���b�V��
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    if (Test-Command node) {
        $version = & node --version
        Write-Success "Node.js $version �C���X�g�[������"
        Update-State "nodejs" "installed" $true
        Update-State "nodejs" "version" $version
    } else {
        Write-Error-Custom "Node.js �̃C���X�g�[���Ɏ��s���܂���"
        exit 1
    }
}

function Install-Git {
    Show-Section 2 "Git �̃C���X�g�[��"

    if (Get-State "git" "installed") {
        $version = (& git --version 2>$null) -replace 'git version ', ''
        Write-Success "Git $version �͊��ɃC���X�g�[���ς݂ł� (�X�L�b�v)"
    } else {
        if (Test-Command git) {
            $version = (& git --version) -replace 'git version ', ''
            Write-Success "Git $version �����ɃC���X�g�[������Ă��܂�"
            Update-State "git" "installed" $true
        } else {
            Write-Info "Git ���C���X�g�[����..."
            winget install Git.Git --silent --accept-package-agreements --accept-source-agreements

            # �p�X�����t���b�V��
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

            if (Test-Command git) {
                $version = (& git --version) -replace 'git version ', ''
                Write-Success "Git $version �C���X�g�[������"
                Update-State "git" "installed" $true
            } else {
                Write-Error-Custom "Git �̃C���X�g�[���Ɏ��s���܂���"
                exit 1
            }
        }
    }

    # Git �����ݒ�
    if (-not (Get-State "git" "configured")) {
        Write-Host ""
        Write-Info "Git �̏����ݒ���s���܂�"

        $gitName = & git config --global user.name 2>$null
        $gitEmail = & git config --global user.email 2>$null

        if (-not $gitName) {
            $gitName = Read-Host "���[�U�[������͂��Ă�������"
            & git config --global user.name $gitName
        } else {
            Write-Success "user.name: $gitName (�ݒ�ς�)"
        }

        if (-not $gitEmail) {
            $gitEmail = Read-Host "���[���A�h���X����͂��Ă�������"
            & git config --global user.email $gitEmail
        } else {
            Write-Success "user.email: $gitEmail (�ݒ�ς�)"
        }

        Update-State "git" "configured" $true
        Write-Success "Git �����ݒ芮��"
    }
}

function Install-GitHubCLI {
    Show-Section 3 "GitHub CLI �̃C���X�g�[��"

    if (Get-State "git" "ssh_key") {
        Write-Success "GitHub �F�؂͊��Ɋ������Ă��܂� (�X�L�b�v)"
        return
    }

    if (-not (Test-Command gh)) {
        Write-Info "GitHub CLI ���C���X�g�[����..."
        winget install GitHub.cli --silent --accept-package-agreements --accept-source-agreements

        # �p�X�����t���b�V��
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

        if (Test-Command gh) {
            Write-Success "GitHub CLI �C���X�g�[������"
        } else {
            Write-Error-Custom "GitHub CLI �̃C���X�g�[���Ɏ��s���܂���"
            exit 1
        }
    } else {
        Write-Success "GitHub CLI �͊��ɃC���X�g�[������Ă��܂�"
    }

    # GitHub�F�؂�SSH���̎����ݒ�
    Write-Host ""
    Write-Warning-Custom "$LOCK GitHub �F�؂��K�v�ł�"
    Write-ColorOutput "������������������������������������������������������������������������������������������������������������" Cyan
    Write-ColorOutput "GitHub CLI ���ȉ��������ōs���܂�:" White
    Write-Host ""
    Write-Host "  ? SSH���̎�������" -ForegroundColor Green
    Write-Host "  ? GitHub�ւ̌��o�^" -ForegroundColor Green
    Write-Host "  ? Git�F�؏��̐ݒ�" -ForegroundColor Green
    Write-Host ""
    Write-ColorOutput "������������������������������������������������������������������������������������������������������������" Cyan

    Write-Host ""
    Write-Info "�ȉ��̃R�}���h�����s���܂�: gh auth login"
    Write-Host "�菇:" -ForegroundColor Yellow
    Write-Host "  1. " -ForegroundColor Yellow -NoNewline
    Write-Host "GitHub.com" -ForegroundColor Green -NoNewline
    Write-Host " ��I��"
    Write-Host "  2. " -ForegroundColor Yellow -NoNewline
    Write-Host "HTTPS" -ForegroundColor Green -NoNewline
    Write-Host " ��I��"
    Write-Host "  3. " -ForegroundColor Yellow -NoNewline
    Write-Host "Login with a web browser" -ForegroundColor Green -NoNewline
    Write-Host " ��I��"
    Write-Host "  4. �\�������R�[�h���R�s�[" -ForegroundColor Yellow
    Write-Host "  5. �u���E�U�� GitHub �Ƀ��O�C�����ĔF��" -ForegroundColor Yellow
    Write-Host ""

    $response = Read-Host "GitHub �F�؂��J�n���܂���? (y/N)"

    if ($response -match '^[Yy]$') {
        & gh auth login

        $authStatus = & gh auth status 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "GitHub �F�؊����ISSH���������Őݒ肳��܂���"
            Update-State "git" "ssh_key" $true
        } else {
            Write-Error-Custom "GitHub �F�؂Ɏ��s���܂���"
            exit 1
        }
    } else {
        Write-Info "��� 'gh auth login' �R�}���h�����s���ĔF�؂��Ă�������"
    }
}

function Install-ClaudeCode {
    Show-Section 4 "Claude Code �̃C���X�g�[��"

    if (Get-State "claude_code" "installed") {
        Write-Success "Claude Code �͊��ɃC���X�g�[���ς݂ł� (�X�L�b�v)"
    } else {
        if (Test-Command claude-code) {
            Write-Success "Claude Code �����ɃC���X�g�[������Ă��܂�"
            Update-State "claude_code" "installed" $true
        } else {
            Write-Info "Claude Code ���C���X�g�[����..."
            & npm install -g claude-code

            # �p�X�����t���b�V��
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

            if (Test-Command claude-code) {
                Write-Success "Claude Code �C���X�g�[������"
                Update-State "claude_code" "installed" $true
            } else {
                Write-Error-Custom "Claude Code �̃C���X�g�[���Ɏ��s���܂���"
                exit 1
            }
        }
    }

    # �F�؃`�F�b�N
    if (-not (Get-State "claude_code" "authenticated")) {
        Write-Host ""
        Write-Warning-Custom "$LOCK Claude Code �̔F�؂��K�v�ł�"
        Write-ColorOutput "������������������������������������������������������������������������������������������������������������" Cyan
        Write-Host "??  ����: ���ꂩ��Θb�^�Z�b�g�A�b�v���n�܂�܂�" -ForegroundColor White
        Write-Host ""
        Write-Host "  ? ���₪�\�����ꂽ�瓚���Ă�������" -ForegroundColor Yellow
        Write-Host "  ? �u���E�U���J������ Claude Pro �Ń��O�C�����Ă�������" -ForegroundColor Yellow
        Write-Host "  ? �F�؊�����A�����Ŏ��̃X�e�b�v�ɐi�݂܂�" -ForegroundColor Yellow
        Write-Host ""
        Write-ColorOutput "������������������������������������������������������������������������������������������������������������" Cyan

        $response = Read-Host "`n�F�؂��J�n���܂���? (y/N)"

        if ($response -match '^[Yy]$') {
            Write-Host ""
            Write-ColorOutput "������������������������������������������������������������������������������������������������������������" Cyan
            Write-Host "Claude Code �Z�b�g�A�b�v�J�n" -ForegroundColor White
            Write-ColorOutput "������������������������������������������������������������������������������������������������������������" Cyan
            Write-Host ""

            # claude-code �𒼐ڎ��s�i�Θb�^�j
            & claude-code

            Write-Host ""
            Write-ColorOutput "������������������������������������������������������������������������������������������������������������" Cyan

            # �F�؊m�F
            $testResult = & claude-code --version 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Success "�F�ؐ����I"
                Update-State "claude_code" "authenticated" $true
            } else {
                Write-Warning-Custom "�F�؂��X�L�b�v���܂����B��� 'claude-code' �R�}���h�����s���ĔF�؂��Ă�������"
            }
        } else {
            Write-Info "��� 'claude-code' �R�}���h�����s���ĔF�؂��Ă�������"
        }
    } else {
        Write-Success "Claude Code �͊��ɔF�؍ς݂ł�"
    }
}

function Install-SuperClaude {
    Show-Section 5 "Super Claude �̃C���X�g�[��"

    # Python �`�F�b�N
    if (-not (Test-Command python)) {
        Write-Info "Python ���C���X�g�[����..."
        winget install Python.Python.3.12 --silent --accept-package-agreements --accept-source-agreements

        # �p�X�����t���b�V��
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    }

    # pipx �̃C���X�g�[��
    if (-not (Test-Command pipx)) {
        Write-Info "pipx ���C���X�g�[����..."
        & python -m pip install --user pipx
        & python -m pipx ensurepath

        # �p�X�����t���b�V��
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        Write-Success "pipx �C���X�g�[������"
    }

    if (Get-State "super_claude" "installed") {
        Write-Success "Super Claude �͊��ɃC���X�g�[���ς݂ł� (�X�L�b�v)"
    } else {
        if (Test-Command SuperClaude) {
            Write-Success "Super Claude �����ɃC���X�g�[������Ă��܂�"
            Update-State "super_claude" "installed" $true
        } else {
            Write-Info "Super Claude ���C���X�g�[����..."
            & pipx install SuperClaude

            if (Test-Command SuperClaude) {
                Write-Success "Super Claude �C���X�g�[������"
                Update-State "super_claude" "installed" $true
            } else {
                Write-Error-Custom "Super Claude �̃C���X�g�[���Ɏ��s���܂���"
                exit 1
            }
        }
    }

    # MCP �ݒ�
    if (-not (Get-State "super_claude" "mcp_configured")) {
        Write-Info "Super Claude �t���[�����[�N���C���X�g�[����..."

        # �����I�v�V�������g�p���Ĕ�Θb���[�h�ŃC���X�g�[��
        # --quick: �����ݒ�ō����C���X�g�[��
        # --yes: �S�Ă̊m�F���������F
        & SuperClaude install --quick --yes 2>$null

        Write-Success "Super Claude �t���[�����[�N�ݒ芮��"
        Write-Success "  ? Core framework"
        Write-Success "  ? MCP servers (Context7, Sequential, Magic, Playwright)"
        Write-Success "  ? Slash commands"
        Update-State "super_claude" "mcp_configured" $true
    } else {
        Write-Success "Super Claude �t���[�����[�N�͊��ɐݒ�ς݂ł� (�X�L�b�v)"
    }
}

function Install-Cursor {
    Show-Section 6 "Cursor IDE �̃C���X�g�[��"

    if (Get-State "cursor" "installed") {
        Write-Success "Cursor IDE �͊��ɃC���X�g�[���ς݂ł� (�X�L�b�v)"
        return
    }

    # Cursor �̑��݊m�F�iProgram Files �܂��� AppData�j
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
        Write-Success "Cursor IDE �����ɃC���X�g�[������Ă��܂�"
        Update-State "cursor" "installed" $true
        return
    }

    Write-Warning-Custom "Cursor IDE �� Windows �ł̎����C���X�g�[���ɑΉ����Ă��܂���"
    Write-Info "�蓮�ŃC���X�g�[������ꍇ: https://cursor.sh/download ����_�E�����[�h���Ă�������"

    $response = Read-Host "�蓮�ŃC���X�g�[�����܂���? (y/N)"
    if ($response -match '^[Yy]$') {
        Start-Process "https://cursor.sh/download"
        Write-Info "�u���E�U�Ń_�E�����[�h�y�[�W���J���܂���"
        Read-Host "�C���X�g�[�������� Enter �������Ă�������"
        Update-State "cursor" "installed" $true
    } else {
        Write-Info "Cursor IDE �̃C���X�g�[�����X�L�b�v���܂���"
    }
}

function Install-Codex {
    Show-Section 7 "OpenAI Codex CLI �̃C���X�g�[��"

    if (Get-State "codex" "installed") {
        Write-Success "Codex CLI �͊��ɃC���X�g�[���ς݂ł� (�X�L�b�v)"
    } else {
        if (Test-Command codex) {
            Write-Success "Codex CLI �����ɃC���X�g�[������Ă��܂�"
            Update-State "codex" "installed" $true
        } else {
            Write-Info "Codex CLI ���C���X�g�[����..."
            & npm install -g @openai/codex

            # �p�X�����t���b�V��
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

            if (Test-Command codex) {
                Write-Success "Codex CLI �C���X�g�[������"
                Update-State "codex" "installed" $true
            } else {
                Write-Error-Custom "Codex CLI �̃C���X�g�[���Ɏ��s���܂���"
                exit 1
            }
        }
    }

    # �F�؃`�F�b�N�i�I�v�V�����j
    if (-not (Get-State "codex" "authenticated")) {
        Write-Host ""
        Write-Warning-Custom "$LOCK Codex CLI �̔F�؁i�I�v�V�����j"
        Write-ColorOutput "������������������������������������������������������������������������������������������������������������" Cyan
        Write-ColorOutput "Codex CLI ���g�p����ɂ� ChatGPT Plus/Pro �A�J�E���g���K�v�ł�" White
        Write-Host ""
        $response = Read-Host "�������F�؂��܂���? (y/N)"

        if ($response -match '^[Yy]$') {
            Write-Host ""
            Write-Host "1. �^�[�~�i���ňȉ��̃R�}���h�����s:" -ForegroundColor Yellow
            Write-Host "   codex" -ForegroundColor Green
            Write-Host "2. ChatGPT �A�J�E���g�ŃT�C���C��" -ForegroundColor Yellow
            Write-Host ""

            while ($true) {
                $response = Read-Host "�F�؂����������� Enter �������Ă�������"

                $testResult = & codex --version 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "�F�ؐ����I"
                    Update-State "codex" "authenticated" $true
                    break
                } else {
                    Write-Error-Custom "�F�؂��m�F�ł��܂���ł����B��Ŏ蓮�Őݒ肵�Ă��������B"
                    break
                }
            }
        } else {
            Write-Info "��� 'codex' �R�}���h�����s���ĔF�؂��Ă�������"
        }
    } else {
        Write-Success "Codex CLI �͊��ɔF�؍ς݂ł�"
    }
}

# ============================================================================
# ���C������
# ============================================================================

function Main {
    Show-Banner

    Write-Info "$ROCKET AI�J�����̃Z�b�g�A�b�v���J�n���܂�..."
    Write-Host ""
    Start-Sleep -Seconds 1

    # �Ǘ��Ҍ����`�F�b�N
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Warning-Custom "���̃X�N���v�g�͊Ǘ��Ҍ����Ŏ��s���邱�Ƃ𐄏����܂�"
        Write-Info "�E�N���b�N �� '�Ǘ��҂Ƃ��Ď��s' �ōĎ��s���Ă�������"
        Write-Host ""
        $response = Read-Host "���̂܂ܑ��s���܂���? (y/N)"
        if ($response -notmatch '^[Yy]$') {
            exit 0
        }
    }

    # ��ԃt�@�C��������
    Initialize-State

    # �A�J�E���g�v���\��
    Show-AccountRequirements

    $response = Read-Host "`n�Z�b�g�A�b�v�𑱍s���܂���? (y/N)"
    if ($response -notmatch '^[Yy]$') {
        Write-Warning-Custom "�Z�b�g�A�b�v�𒆎~���܂���"
        exit 0
    }

    # �A�J�E���g�o�^�K�C�h
    Register-ClaudePro    # �K�{
    Register-GitHub        # ����

    # Winget �`�F�b�N
    Test-Winget

    # �C���X�g�[�����s
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

    # Codex CLI �C���X�g�[���O�� ChatGPT Plus/Pro �o�^�𑣂�
    if (-not (Get-State "accounts" "chatgpt_plus" "registered")) {
        Register-ChatGPTPlus
    }

    Install-Codex

    # �������b�Z�[�W
    Write-Host ""
    Write-ColorOutput "    ?????????????????????????????????????????????????????????????" Green
    Write-ColorOutput "    ?                                                           ?" Green
    Write-ColorOutput "    ?                $PARTY  �Z�b�g�A�b�v�����I  $PARTY                 ?" Green
    Write-ColorOutput "    ?                                                           ?" Green
    Write-ColorOutput "    ?????????????????????????????????????????????????????????????" Green
    Write-Host ""

    Write-Success "�S�Ẵc�[���̃C���X�g�[�����������܂���"
    Write-Host ""
    Write-Info "���̃X�e�b�v:"
    Write-Host "  ? Claude Code: claude-code �R�}���h�ŋN��" -ForegroundColor Yellow
    Write-Host "  ? Super Claude: SuperClaude --help �ŃR�}���h�m�F" -ForegroundColor Yellow
    Write-Host "  ? Cursor IDE: �X�^�[�g���j���[����N��" -ForegroundColor Yellow
    Write-Host "  ? Codex CLI: codex �R�}���h�ŋN��" -ForegroundColor Yellow
    Write-Host ""

    Write-Info "$SPARKLE Happy Coding with AI! $SPARKLE"
    Write-Host ""
}

# �X�N���v�g���s
Main
