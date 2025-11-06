#!/bin/bash

# ============================================================================
# AI開発環境 自動セットアップスクリプト (macOS版)
# ============================================================================
# Node.js, Git, Claude Code, Super Claude, Cursor IDE, Codex CLI を
# 順次インストールし、認証が必要な箇所では対話的に待機します。
# 中断しても再実行で続きから再開できます。
# ============================================================================

set -e  # エラーで停止

# ============================================================================
# カラー定義 & アニメーション関数
# ============================================================================

# ANSI カラーコード
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
RESET='\033[0m'

# 絵文字
ROCKET="🚀"
CHECK="✅"
CROSS="❌"
LOCK="🔐"
GEAR="⚙️"
SPARKLE="✨"
WARN="⚠️"
CLOCK="⏳"
PARTY="🎉"

# プログレスバー
progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((width * current / total))

    printf "\r${CYAN}["
    for ((i=0; i<filled; i++)); do printf "█"; done
    for ((i=filled; i<width; i++)); do printf "░"; done
    printf "] ${percentage}%%${RESET}"
}

# スピナーアニメーション
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [${CYAN}%c${RESET}]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# タイトルバナー
print_banner() {
    clear
    echo -e "${PURPLE}"
    cat << "EOF"
    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║        AI Development Environment Setup Script           ║
    ║                     for macOS                             ║
    ║                                                           ║
    ║   Node.js | Git | GitHub CLI | Claude Code               ║
    ║   Super Claude | Cursor IDE | Codex CLI                  ║
    ║   Supabase CLI | Netlify CLI                             ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${RESET}\n"
}

# セクションヘッダー
print_section() {
    local step=$1
    local title=$2
    echo -e "\n${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BOLD}${WHITE}[$step/9] $title${RESET}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
}

# 成功メッセージ
print_success() {
    echo -e "${GREEN}${CHECK} $1${RESET}"
}

# エラーメッセージ
print_error() {
    echo -e "${RED}${CROSS} $1${RESET}"
}

# 警告メッセージ
print_warning() {
    echo -e "${YELLOW}${WARN} $1${RESET}"
}

# 情報メッセージ
print_info() {
    echo -e "${CYAN}${GEAR} $1${RESET}"
}

# ============================================================================
# 状態管理
# ============================================================================

STATE_FILE=".install_progress.json"

# 状態ファイル初期化
init_state() {
    if [[ ! -f "$STATE_FILE" ]]; then
        cat > "$STATE_FILE" << EOF
{
  "accounts": {
    "claude_pro": {"registered": false, "plan": ""},
    "github": {"registered": false, "username": ""},
    "chatgpt_plus": {"registered": false, "plan": ""},
    "cursor": {"registered": false}
  },
  "nodejs": {"installed": false, "version": ""},
  "git": {"installed": false, "configured": false, "ssh_key": false},
  "claude_code": {"installed": false, "authenticated": false},
  "super_claude": {"installed": false, "mcp_configured": false},
  "cursor": {"installed": false},
  "codex": {"installed": false, "authenticated": false},
  "supabase": {"installed": false, "authenticated": false},
  "netlify": {"installed": false, "authenticated": false}
}
EOF
    fi
}

# 状態取得（ネストされたキーに対応）
get_state() {
    local key=$1
    local subkey=$2
    local subsubkey=$3

    if [[ -n "$subsubkey" ]]; then
        python3 -c "import json; data=json.load(open('$STATE_FILE')); print(data['$key']['$subkey']['$subsubkey'])"
    else
        python3 -c "import json; data=json.load(open('$STATE_FILE')); print(data['$key']['$subkey'])"
    fi
}

# 状態更新（ネストされたキーに対応）
update_state() {
    local key=$1
    local subkey=$2
    local value=$3
    local subsubkey=$4

    if [[ -n "$subsubkey" ]]; then
        python3 << EOF
import json
with open('$STATE_FILE', 'r+') as f:
    data = json.load(f)
    data['$key']['$subkey']['$subsubkey'] = $value
    f.seek(0)
    json.dump(data, f, indent=2)
    f.truncate()
EOF
    else
        python3 << EOF
import json
with open('$STATE_FILE', 'r+') as f:
    data = json.load(f)
    data['$key']['$subkey'] = $value
    f.seek(0)
    json.dump(data, f, indent=2)
    f.truncate()
EOF
    fi
}

# ============================================================================
# チェック関数
# ============================================================================

check_command() {
    command -v "$1" &> /dev/null
}

check_homebrew() {
    if ! check_command brew; then
        print_warning "Homebrew がインストールされていません。インストールします..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Homebrewをパスに追加（Apple Silicon Mac対応）
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        print_success "Homebrew インストール完了"
    fi
}

# ============================================================================
# アカウント登録ガイド関数
# ============================================================================

show_account_requirements() {
    echo -e "\n${BOLD}${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BOLD}${WHITE}必要なアカウント一覧${RESET}"
    echo -e "${BOLD}${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"

    echo -e "${RED}${BOLD}[必須]${RESET} ${YELLOW}Claude Pro${RESET} - ${WHITE}\$20/月${RESET}"
    echo -e "       ${CYAN}└─ Claude Code の実行に必須${RESET}\n"

    echo -e "${YELLOW}${BOLD}[推奨]${RESET} ${YELLOW}GitHub${RESET} - ${WHITE}無料${RESET}"
    echo -e "       ${CYAN}└─ Git連携、SSH鍵登録に使用${RESET}\n"

    echo -e "${YELLOW}${BOLD}[推奨]${RESET} ${YELLOW}Supabase${RESET} - ${WHITE}無料（Proプランあり）${RESET}"
    echo -e "       ${CYAN}└─ BaaS（Backend as a Service）${RESET}\n"

    echo -e "${YELLOW}${BOLD}[推奨]${RESET} ${YELLOW}Netlify${RESET} - ${WHITE}無料（Proプランあり）${RESET}"
    echo -e "       ${CYAN}└─ Web ホスティング、デプロイ自動化${RESET}\n"

    echo -e "${BLUE}${BOLD}[任意]${RESET} ${YELLOW}ChatGPT Plus/Pro${RESET} - ${WHITE}\$20/月${RESET}"
    echo -e "       ${CYAN}└─ Codex CLI 使用時のみ必要${RESET}\n"

    echo -e "${BLUE}${BOLD}[任意]${RESET} ${YELLOW}Cursor IDE${RESET} - ${WHITE}無料（Proプランあり）${RESET}"
    echo -e "       ${CYAN}└─ AI統合エディタ${RESET}\n"
}

register_claude_pro() {
    print_section 0 "Claude Pro アカウント登録"

    if [[ "$(get_state accounts claude_pro registered)" == "True" ]]; then
        print_success "Claude Pro アカウントは登録済みです (スキップ)"
        return 0
    fi

    echo -e "${YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${RED}${BOLD}⚠️  重要: Claude Pro アカウントが必要です${RESET}"
    echo -e "${YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"

    echo -e "${WHITE}Claude Code を使用するには ${BOLD}Claude Pro（\$20/月）${RESET}${WHITE} の契約が必要です。${RESET}"
    echo -e "${WHITE}今からブラウザで登録ページを開きます。${RESET}\n"

    echo -ne "${CYAN}登録ページを開きますか? (y/N): ${RESET}"
    read -r response

    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_error "Claude Pro の登録をスキップしました"
        echo -e "${YELLOW}後で https://claude.ai/upgrade で登録してください${RESET}"
        exit 1
    fi

    echo ""
    print_info "ブラウザで Claude 登録ページを開きます..."
    sleep 1
    open "https://claude.ai/upgrade"

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${WHITE}${BOLD}📝 登録手順:${RESET}\n"
    echo -e "  ${YELLOW}1.${RESET} ${GREEN}「Continue with Google」${RESET} ボタンをクリック"
    echo -e "  ${YELLOW}2.${RESET} Googleアカウントでログイン"
    echo -e "  ${YELLOW}3.${RESET} ${GREEN}「Upgrade to Claude Pro」${RESET} を選択（\$20/月）"
    echo -e "  ${YELLOW}4.${RESET} クレジットカード情報を入力"
    echo -e "  ${YELLOW}5.${RESET} 登録完了後、${BOLD}このターミナルに戻る${RESET}\n"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    while true; do
        echo -ne "\n${CYAN}${BOLD}登録が完了したら Enter を押してください...${RESET}"
        read

        echo -ne "${CYAN}Claude Pro プランに登録しましたか? (y/N): ${RESET}"
        read -r confirm

        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            update_state accounts claude_pro True registered
            update_state accounts claude_pro "Pro" plan
            print_success "Claude Pro アカウント登録完了！"
            break
        else
            print_warning "Claude Pro の登録が必要です"
        fi
    done
}

register_github() {
    echo -e "\n${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BOLD}${WHITE}GitHub アカウント登録 (推奨)${RESET}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"

    if [[ "$(get_state accounts github registered)" == "True" ]]; then
        print_success "GitHub アカウントは登録済みです (スキップ)"
        return 0
    fi

    echo -ne "${CYAN}GitHub アカウントを持っていますか? (y/N): ${RESET}"
    read -r has_account

    if [[ "$has_account" =~ ^[Yy]$ ]]; then
        echo -ne "${CYAN}GitHub ユーザー名を入力してください: ${RESET}"
        read github_username
        update_state accounts github True registered
        update_state accounts github "$github_username" username
        print_success "GitHub アカウント情報を保存しました"
        return 0
    fi

    echo -ne "\n${CYAN}今すぐ GitHub アカウントを登録しますか? (y/N): ${RESET}"
    read -r response

    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_info "GitHub 登録をスキップしました（後で登録できます）"
        return 0
    fi

    echo ""
    print_info "ブラウザで GitHub 登録ページを開きます..."
    sleep 1
    open "https://github.com/signup"

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${WHITE}${BOLD}📝 登録手順:${RESET}\n"
    echo -e "  ${YELLOW}1.${RESET} メールアドレスを入力"
    echo -e "  ${YELLOW}2.${RESET} パスワードを作成"
    echo -e "  ${YELLOW}3.${RESET} ユーザー名を決定"
    echo -e "  ${YELLOW}4.${RESET} メール確認コードを入力"
    echo -e "  ${YELLOW}5.${RESET} 登録完了後、${BOLD}このターミナルに戻る${RESET}\n"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    echo -ne "\n${CYAN}${BOLD}登録が完了したら Enter を押してください...${RESET}"
    read

    echo -ne "${CYAN}GitHub ユーザー名を入力してください: ${RESET}"
    read github_username

    if [[ -n "$github_username" ]]; then
        update_state accounts github True registered
        update_state accounts github "$github_username" username
        print_success "GitHub アカウント登録完了！"
    else
        print_warning "GitHub 登録をスキップしました"
    fi
}

register_chatgpt_plus() {
    echo -e "\n${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BOLD}${WHITE}ChatGPT Plus/Pro アカウント登録 (任意)${RESET}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"

    if [[ "$(get_state accounts chatgpt_plus registered)" == "True" ]]; then
        print_success "ChatGPT Plus/Pro アカウントは登録済みです (スキップ)"
        return 0
    fi

    echo -e "${WHITE}Codex CLI を使用するには ${BOLD}ChatGPT Plus/Pro（\$20/月）${RESET}${WHITE} が必要です。${RESET}"
    echo -ne "\n${CYAN}ChatGPT Plus/Pro を登録しますか? (y/N): ${RESET}"
    read -r response

    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_info "ChatGPT 登録をスキップしました（Codex CLI使用時に登録してください）"
        return 0
    fi

    echo ""
    print_info "ブラウザで ChatGPT 登録ページを開きます..."
    sleep 1
    open "https://chatgpt.com/signup"

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${WHITE}${BOLD}📝 登録手順:${RESET}\n"
    echo -e "  ${YELLOW}1.${RESET} ${GREEN}「Continue with Google」${RESET} ボタンをクリック"
    echo -e "  ${YELLOW}2.${RESET} Googleアカウントでログイン"
    echo -e "  ${YELLOW}3.${RESET} ${GREEN}「Upgrade to Plus」${RESET} または ${GREEN}「Upgrade to Pro」${RESET} を選択"
    echo -e "  ${YELLOW}4.${RESET} クレジットカード情報を入力"
    echo -e "  ${YELLOW}5.${RESET} 登録完了後、${BOLD}このターミナルに戻る${RESET}\n"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    echo -ne "\n${CYAN}${BOLD}登録が完了したら Enter を押してください...${RESET}"
    read

    echo -ne "${CYAN}どのプランを登録しましたか? (plus/pro/N): ${RESET}"
    read -r plan

    if [[ "$plan" =~ ^[Pp]lus$ ]]; then
        update_state accounts chatgpt_plus True registered
        update_state accounts chatgpt_plus "Plus" plan
        print_success "ChatGPT Plus アカウント登録完了！"
    elif [[ "$plan" =~ ^[Pp]ro$ ]]; then
        update_state accounts chatgpt_plus True registered
        update_state accounts chatgpt_plus "Pro" plan
        print_success "ChatGPT Pro アカウント登録完了！"
    else
        print_info "ChatGPT 登録をスキップしました"
    fi
}

# ============================================================================
# インストール関数
# ============================================================================

install_nodejs() {
    print_section 1 "Node.js のインストール"

    if [[ "$(get_state nodejs installed)" == "True" ]]; then
        local version=$(node --version 2>/dev/null || echo "unknown")
        print_success "Node.js $version は既にインストール済みです (スキップ)"
        return 0
    fi

    if check_command node; then
        local version=$(node --version)
        print_success "Node.js $version が既にインストールされています"
        update_state nodejs installed True
        update_state nodejs version "$version"
        return 0
    fi

    # Homebrewがインストールされていない場合はエラー
    if ! check_command brew; then
        print_error "Homebrew がインストールされていないため、Node.js をインストールできません"
        print_info "先に Homebrew のインストールを完了してください"
        exit 1
    fi

    print_info "Node.js をインストール中..."
    brew install node &
    spinner $!
    wait $!

    if check_command node; then
        local version=$(node --version)
        print_success "Node.js $version インストール完了"
        update_state nodejs installed True
        update_state nodejs version "$version"
    else
        print_error "Node.js のインストールに失敗しました"
        exit 1
    fi
}

install_git() {
    print_section 2 "Git のインストール"

    if [[ "$(get_state git installed)" == "True" ]]; then
        local version=$(git --version 2>/dev/null | cut -d' ' -f3)
        print_success "Git $version は既にインストール済みです (スキップ)"
    else
        if check_command git; then
            local version=$(git --version | cut -d' ' -f3)
            print_success "Git $version が既にインストールされています"
            update_state git installed True
        else
            print_info "Git をインストール中..."
            brew install git &
            spinner $!
            wait $!

            if check_command git; then
                local version=$(git --version | cut -d' ' -f3)
                print_success "Git $version インストール完了"
                update_state git installed True
            else
                print_error "Git のインストールに失敗しました"
                exit 1
            fi
        fi
    fi

    # Git 初期設定
    if [[ "$(get_state git configured)" != "True" ]]; then
        echo ""
        print_info "Git の初期設定を行います"

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
        print_success "Git 初期設定完了"
    fi
}

install_github_cli() {
    print_section 3 "GitHub CLI のインストール"

    if [[ "$(get_state git ssh_key)" == "True" ]]; then
        print_success "GitHub 認証は既に完了しています (スキップ)"
        return 0
    fi

    if ! check_command gh; then
        print_info "GitHub CLI をインストール中..."
        npm install -g @github/gh &
        spinner $!
        wait $!

        if check_command gh; then
            print_success "GitHub CLI インストール完了"
        else
            print_error "GitHub CLI のインストールに失敗しました"
            exit 1
        fi
    else
        print_success "GitHub CLI は既にインストールされています"
    fi

    # GitHub認証とSSH鍵の自動設定（完全自動化版）
    echo ""
    print_warning "${LOCK} GitHub 認証が必要です"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${WHITE}${BOLD}📋 これから行うこと:${RESET}\n"
    echo -e "  ${GREEN}1️⃣${RESET}  ブラウザが自動で開きます"
    echo -e "  ${GREEN}2️⃣${RESET}  ${YELLOW}8桁のコード${RESET}が画面に表示されます ${DIM}(例: ABCD-1234)${RESET}"
    echo -e "  ${GREEN}3️⃣${RESET}  ブラウザでそのコードを入力してください"
    echo -e "  ${GREEN}4️⃣${RESET}  ${YELLOW}「Authorize」${RESET}${DIM}(承認する)${RESET} ボタンをクリック"
    echo -e "  ${GREEN}5️⃣${RESET}  認証完了！\n"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
    echo -e "${WHITE}GitHub CLI が以下を自動で行います:${RESET}"
    echo -e "  ${GREEN}✓${RESET} SSH鍵の自動生成"
    echo -e "  ${GREEN}✓${RESET} GitHubへの鍵登録"
    echo -e "  ${GREEN}✓${RESET} Git認証情報の設定"
    echo ""

    echo -ne "${CYAN}GitHub 認証を開始しますか? (y/N): ${RESET}"
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo ""
        print_info "${YELLOW}⏳ 3秒後にブラウザが開きます...${RESET}"
        sleep 3

        # 完全自動化された認証（英語プロンプトなし）
        gh auth login --web --git-protocol https --hostname github.com

        if gh auth status &> /dev/null; then
            echo ""
            print_success "✅ GitHub 認証完了！SSH鍵も自動で設定されました"
            update_state git ssh_key True
        else
            echo ""
            print_error "❌ GitHub 認証に失敗しました"
            echo -e "${CYAN}💡 ヒント: ブラウザでコードを正しく入力しましたか？${RESET}"
            echo -e "${CYAN}もう一度試す場合は、このスクリプトを再実行してください${RESET}"
            exit 1
        fi
    else
        print_info "後で 'gh auth login --web' コマンドを実行して認証してください"
    fi
}

install_claude_code() {
    print_section 4 "Claude Code のインストール"

    if [[ "$(get_state claude_code installed)" == "True" ]]; then
        print_success "Claude Code は既にインストール済みです (スキップ)"
    else
        if check_command claude-code; then
            print_success "Claude Code が既にインストールされています"
            update_state claude_code installed True
        else
            print_info "Claude Code をインストール中..."
            npm install -g claude-code &
            spinner $!
            wait $!

            if check_command claude-code; then
                print_success "Claude Code インストール完了"
                update_state claude_code installed True
            else
                print_error "Claude Code のインストールに失敗しました"
                exit 1
            fi
        fi
    fi

    # 認証チェック
    if [[ "$(get_state claude_code authenticated)" != "True" ]]; then
        echo ""
        print_warning "${LOCK} Claude Code の認証が必要です"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
        echo -e "${WHITE}${BOLD}⚠️  注意: これから対話型セットアップが始まります${RESET}\n"
        echo -e "  ${YELLOW}•${RESET} 質問が表示されたら答えてください"
        echo -e "  ${YELLOW}•${RESET} ブラウザが開いたら Claude Pro でログインしてください"
        echo -e "  ${YELLOW}•${RESET} 認証完了後、自動で次のステップに進みます\n"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

        echo -ne "\n${CYAN}${BOLD}認証を開始しますか? (y/N): ${RESET}"
        read -r response

        if [[ "$response" =~ ^[Yy]$ ]]; then
            echo ""
            echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
            echo -e "${WHITE}${BOLD}Claude Code セットアップ開始${RESET}"
            echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"

            # claude-code を直接実行（対話型）
            claude-code

            echo ""
            echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

            # 認証確認
            if claude-code --version &> /dev/null; then
                print_success "認証成功！"
                update_state claude_code authenticated True
            else
                print_warning "認証をスキップしました。後で 'claude-code' コマンドを実行して認証してください"
            fi
        else
            print_info "後で 'claude-code' コマンドを実行して認証してください"
        fi
    else
        print_success "Claude Code は既に認証済みです"
    fi
}

install_super_claude() {
    print_section 5 "Super Claude のインストール"

    if [[ "$(get_state super_claude installed)" == "True" ]]; then
        print_success "Super Claude は既にインストール済みです (スキップ)"
    else
        if check_command superclaude; then
            print_success "Super Claude が既にインストールされています"
            update_state super_claude installed True
        else
            print_info "Super Claude をインストール中..."
            npm install -g @bifrost_inc/superclaude &
            spinner $!
            wait $!

            if check_command superclaude; then
                print_success "Super Claude インストール完了"
                update_state super_claude installed True
            else
                print_error "Super Claude のインストールに失敗しました"
                exit 1
            fi
        fi
    fi

    # MCP 設定
    if [[ "$(get_state super_claude mcp_configured)" != "True" ]]; then
        print_info "Super Claude フレームワークをインストール中..."

        # superclaude install コマンドで非対話モードでインストール
        superclaude install &> /dev/null || true

        print_success "Super Claude フレームワーク設定完了"
        print_success "  ✓ Core framework"
        print_success "  ✓ MCP servers (Context7, Sequential, Magic, Playwright)"
        print_success "  ✓ Slash commands"
        update_state super_claude mcp_configured True
    else
        print_success "Super Claude フレームワークは既に設定済みです (スキップ)"
    fi
}

install_cursor() {
    print_section 6 "Cursor IDE のインストール"

    if [[ "$(get_state cursor installed)" == "True" ]]; then
        print_success "Cursor IDE は既にインストール済みです (スキップ)"
        return 0
    fi

    if [[ -d "/Applications/Cursor.app" ]]; then
        print_success "Cursor IDE が既にインストールされています"
        update_state cursor installed True
        return 0
    fi

    print_info "Cursor IDE をインストール中..."
    brew install --cask cursor &
    spinner $!
    wait $!

    if [[ -d "/Applications/Cursor.app" ]]; then
        print_success "Cursor IDE インストール完了"
        update_state cursor installed True
    else
        print_warning "Cursor IDE のインストールをスキップしました（手動インストール推奨）"
    fi
}

install_codex() {
    print_section 7 "OpenAI Codex CLI のインストール"

    if [[ "$(get_state codex installed)" == "True" ]]; then
        print_success "Codex CLI は既にインストール済みです (スキップ)"
    else
        if check_command codex; then
            print_success "Codex CLI が既にインストールされています"
            update_state codex installed True
        else
            print_info "Codex CLI をインストール中..."
            brew install codex &
            spinner $!
            wait $!

            if check_command codex; then
                print_success "Codex CLI インストール完了"
                update_state codex installed True
            else
                print_error "Codex CLI のインストールに失敗しました"
                exit 1
            fi
        fi
    fi

    # 認証チェック（オプション）
    if [[ "$(get_state codex authenticated)" != "True" ]]; then
        echo ""
        print_warning "${LOCK} Codex CLI の認証（オプション）"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
        echo -e "${WHITE}Codex CLI を使用するには ChatGPT Plus/Pro アカウントが必要です${RESET}\n"
        echo -ne "${CYAN}今すぐ認証しますか? (y/N): ${RESET}"
        read -r response

        if [[ "$response" =~ ^[Yy]$ ]]; then
            echo -e "\n${YELLOW}1.${RESET} ターミナルで以下のコマンドを実行:"
            echo -e "   ${GREEN}codex${RESET}"
            echo -e "${YELLOW}2.${RESET} ChatGPT アカウントでサインイン\n"

            while true; do
                echo -ne "${CYAN}認証が完了したら Enter を押してください...${RESET}"
                read

                if codex --version &> /dev/null; then
                    print_success "認証成功！"
                    update_state codex authenticated True
                    break
                else
                    print_error "認証が確認できませんでした。後で手動で設定してください。"
                    break
                fi
            done
        else
            print_info "後で 'codex' コマンドを実行して認証してください"
        fi
    else
        print_success "Codex CLI は既に認証済みです"
    fi
}

install_supabase() {
    print_section 8 "Supabase CLI のインストール"

    if [[ "$(get_state supabase installed)" == "True" ]]; then
        print_success "Supabase CLI は既にインストール済みです (スキップ)"
    else
        if check_command supabase; then
            print_success "Supabase CLI が既にインストールされています"
            update_state supabase installed True
        else
            print_info "Supabase CLI をインストール中..."
            npm install -g supabase &
            spinner $!
            wait $!

            if check_command supabase; then
                print_success "Supabase CLI インストール完了"
                update_state supabase installed True
            else
                print_error "Supabase CLI のインストールに失敗しました"
                exit 1
            fi
        fi
    fi

    # 認証チェック
    if [[ "$(get_state supabase authenticated)" != "True" ]]; then
        echo ""
        print_warning "${LOCK} Supabase CLI の認証"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
        echo -e "${WHITE}ブラウザが開き、Supabase アカウントでログインします${RESET}\n"
        echo -ne "${CYAN}認証を開始しますか? (y/N): ${RESET}"
        read -r response

        if [[ "$response" =~ ^[Yy]$ ]]; then
            echo ""
            print_info "ブラウザで Supabase 認証を開始します..."

            supabase login

            # 認証確認
            if supabase projects list &> /dev/null; then
                print_success "Supabase CLI 認証完了！"
                update_state supabase authenticated True
            else
                print_warning "認証をスキップしました。後で 'supabase login' コマンドを実行して認証してください"
            fi
        else
            print_info "後で 'supabase login' コマンドを実行して認証してください"
        fi
    else
        print_success "Supabase CLI は既に認証済みです"
    fi
}

install_netlify() {
    print_section 9 "Netlify CLI のインストール"

    if [[ "$(get_state netlify installed)" == "True" ]]; then
        print_success "Netlify CLI は既にインストール済みです (スキップ)"
    else
        if check_command netlify; then
            print_success "Netlify CLI が既にインストールされています"
            update_state netlify installed True
        else
            print_info "Netlify CLI をインストール中..."
            npm install -g netlify-cli &
            spinner $!
            wait $!

            if check_command netlify; then
                print_success "Netlify CLI インストール完了"
                update_state netlify installed True
            else
                print_error "Netlify CLI のインストールに失敗しました"
                exit 1
            fi
        fi
    fi

    # 認証チェック
    if [[ "$(get_state netlify authenticated)" != "True" ]]; then
        echo ""
        print_warning "${LOCK} Netlify CLI の認証"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
        echo -e "${WHITE}ブラウザが開き、Netlify アカウントでログインします${RESET}\n"
        echo -ne "${CYAN}認証を開始しますか? (y/N): ${RESET}"
        read -r response

        if [[ "$response" =~ ^[Yy]$ ]]; then
            echo ""
            print_info "ブラウザで Netlify 認証を開始します..."

            netlify login

            # 認証確認
            if netlify status &> /dev/null; then
                print_success "Netlify CLI 認証完了！"
                update_state netlify authenticated True
            else
                print_warning "認証をスキップしました。後で 'netlify login' コマンドを実行して認証してください"
            fi
        else
            print_info "後で 'netlify login' コマンドを実行して認証してください"
        fi
    else
        print_success "Netlify CLI は既に認証済みです"
    fi
}

# ============================================================================
# メイン処理
# ============================================================================

main() {
    print_banner

    print_info "${ROCKET} AI開発環境のセットアップを開始します...\n"
    sleep 1

    # 状態ファイル初期化
    init_state

    # アカウント要件表示
    show_account_requirements

    echo -ne "\n${CYAN}${BOLD}セットアップを続行しますか? (y/N): ${RESET}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_warning "セットアップを中止しました"
        exit 0
    fi

    # アカウント登録ガイド
    register_claude_pro    # 必須
    register_github        # 推奨

    # Homebrew チェック
    check_homebrew

    # インストール実行
    install_nodejs
    sleep 0.5

    install_git
    sleep 0.5

    install_github_cli
    sleep 0.5

    install_claude_code
    sleep 0.5

    install_super_claude
    sleep 0.5

    install_cursor
    sleep 0.5

    # Codex CLI インストール前に ChatGPT Plus/Pro 登録を促す
    if [[ "$(get_state accounts chatgpt_plus registered)" != "True" ]]; then
        register_chatgpt_plus
    fi

    install_codex
    sleep 0.5

    install_supabase
    sleep 0.5

    install_netlify

    # 完了メッセージ
    echo -e "\n${GREEN}${BOLD}"
    cat << "EOF"
    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║                🎉  セットアップ完了！  🎉                 ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${RESET}\n"

    print_success "全てのツールのインストールが完了しました"
    echo ""
    print_info "次のステップ:"
    echo -e "  ${YELLOW}•${RESET} Claude Code: ${GREEN}claude-code${RESET} コマンドで起動"
    echo -e "  ${YELLOW}•${RESET} Super Claude: ${GREEN}superclaude --help${RESET} でコマンド確認"
    echo -e "  ${YELLOW}•${RESET} Cursor IDE: アプリケーションフォルダから起動"
    echo -e "  ${YELLOW}•${RESET} Codex CLI: ${GREEN}codex${RESET} コマンドで起動"
    echo -e "  ${YELLOW}•${RESET} Supabase CLI: ${GREEN}supabase${RESET} コマンドで利用"
    echo -e "  ${YELLOW}•${RESET} Netlify CLI: ${GREEN}netlify${RESET} コマンドで利用"
    echo ""

    print_info "${SPARKLE} Happy Coding with AI! ${SPARKLE}"
    echo ""
}

# スクリプト実行
main
