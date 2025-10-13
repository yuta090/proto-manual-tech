#!/bin/bash

################################################################################
# AI開発環境自動セットアップスクリプト (macOS)
#
# 目的: 0章「自動セットアップで開発環境を整える」で使用する
#      全ツールの自動インストール・認証・アカウント作成促進
#
# 実行方法:
#   chmod +x install-ai-dev-tools-mac.sh
#   ./install-ai-dev-tools-mac.sh
#
# 対応OS: macOS 12 (Monterey) 以降
################################################################################

set -e  # エラー時に即座に終了

# カラー定義
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly RESET='\033[0m'

# 進捗状態ファイル
readonly STATE_FILE=".install_progress.json"

################################################################################
# ユーティリティ関数
################################################################################

print_section() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BLUE}▶ $1${RESET}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
}

print_info() {
    echo -e "${CYAN}ℹ $1${RESET}"
}

print_success() {
    echo -e "${GREEN}✓ $1${RESET}"
}

print_error() {
    echo -e "${RED}✗ $1${RESET}" >&2
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${RESET}"
}

################################################################################
# 状態管理関数
################################################################################

init_state() {
    if [[ ! -f "$STATE_FILE" ]]; then
        cat > "$STATE_FILE" <<EOF
{
  "node": {"installed": false},
  "git": {"installed": false},
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
  "cursor_ide": {"installed": false}
}
EOF
        print_success "状態ファイルを作成しました: $STATE_FILE"
    fi
}

get_state() {
    local tool="$1"
    local key="$2"

    if [[ ! -f "$STATE_FILE" ]]; then
        echo "False"
        return
    fi

    local value=$(python3 -c "
import json
try:
    with open('$STATE_FILE', 'r') as f:
        data = json.load(f)
    result = data.get('$tool', {}).get('$key', False)
    print('True' if result else 'False')
except:
    print('False')
")
    echo "$value"
}

update_state() {
    local tool="$1"
    local key="$2"
    local value="$3"

    python3 -c "
import json
try:
    with open('$STATE_FILE', 'r') as f:
        data = json.load(f)
except FileNotFoundError:
    data = {}

if '$tool' not in data:
    data['$tool'] = {}

data['$tool']['$key'] = $value

with open('$STATE_FILE', 'w') as f:
    json.dump(data, f, indent=2)
"
}

################################################################################
# インストール関数
################################################################################

install_homebrew() {
    if command -v brew &> /dev/null; then
        print_info "Homebrew は既にインストールされています (スキップ)"
        return
    fi

    print_section "Homebrew のインストール"

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Apple Silicon Mac の場合、PATHを追加
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    print_success "Homebrew インストール完了"
}

install_node() {
    if [[ $(get_state node installed) == "True" ]]; then
        print_info "Node.js は既にインストールされています (スキップ)"
        return
    fi

    print_section "Node.js のインストール"

    if command -v node &> /dev/null; then
        print_info "Node.js は既にインストールされています"
        update_state node installed True
        return
    fi

    brew install node

    # 確認
    if command -v node &> /dev/null; then
        local node_version=$(node --version)
        print_success "Node.js インストール完了: $node_version"
        update_state node installed True
    else
        print_error "Node.js のインストールに失敗しました"
        exit 1
    fi
}

install_git() {
    if [[ $(get_state git installed) == "True" ]]; then
        print_info "Git は既にインストールされています (スキップ)"
        return
    fi

    print_section "Git のインストール"

    if command -v git &> /dev/null; then
        print_info "Git は既にインストールされています"
        update_state git installed True
        return
    fi

    brew install git

    # 確認
    if command -v git &> /dev/null; then
        local git_version=$(git --version)
        print_success "Git インストール完了: $git_version"
        update_state git installed True
    else
        print_error "Git のインストールに失敗しました"
        exit 1
    fi
}

install_github_cli() {
    if [[ $(get_state github_cli installed) == "True" ]] && [[ $(get_state github_cli authenticated) == "True" ]]; then
        print_info "GitHub CLI は既にインストール・認証済みです (スキップ)"
        return
    fi

    print_section "GitHub CLI のインストール"

    # インストール確認
    if [[ $(get_state github_cli installed) == "False" ]]; then
        if command -v gh &> /dev/null; then
            print_info "GitHub CLI は既にインストールされています"
            update_state github_cli installed True
        else
            brew install gh
            update_state github_cli installed True
            print_success "GitHub CLI インストール完了"
        fi
    fi

    # アカウント作成促進と認証
    if [[ $(get_state github_cli authenticated) == "False" ]]; then
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
        echo -e "${CYAN}GitHub アカウントをお持ちですか？${RESET}"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

        read -p "GitHub アカウントをお持ちですか？ (y/n): " has_account

        if [[ "$has_account" != "y" ]]; then
            print_warning "GitHub アカウントが必要です。ブラウザでサインアップページを開きます..."
            echo -e "${CYAN}推奨: 「Sign up with Google」ボタンで Google アカウントを使用してください${RESET}"

            open "https://github.com/signup"

            echo ""
            read -p "アカウント作成が完了したら Enter キーを押してください..."
        fi

        # 認証
        print_info "GitHub CLI の認証を開始します..."

        if gh auth login; then
            update_state github_cli authenticated True
            print_success "GitHub CLI 認証完了"
        else
            print_error "GitHub CLI の認証に失敗しました"
            exit 1
        fi
    fi
}

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

install_supabase_cli() {
    if [[ $(get_state supabase_cli installed) == "True" ]] && [[ $(get_state supabase_cli authenticated) == "True" ]]; then
        print_info "Supabase CLI は既にインストール・認証済みです (スキップ)"
        return
    fi

    print_section "Supabase CLI のインストール"

    # インストール確認
    if [[ $(get_state supabase_cli installed) == "False" ]]; then
        if command -v supabase &> /dev/null; then
            print_info "Supabase CLI は既にインストールされています"
            update_state supabase_cli installed True
        else
            npm install -g supabase
            update_state supabase_cli installed True
            print_success "Supabase CLI インストール完了"
        fi
    fi

    # アカウント作成促進と認証
    if [[ $(get_state supabase_cli authenticated) == "False" ]]; then
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
        echo -e "${CYAN}Supabase アカウントをお持ちですか？${RESET}"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

        read -p "Supabase アカウントをお持ちですか？ (y/n): " has_account

        if [[ "$has_account" != "y" ]]; then
            print_warning "Supabase アカウントが必要です。ブラウザでサインアップページを開きます..."
            echo -e "${CYAN}推奨: 「Continue with GitHub」ボタンで GitHub アカウントを使用してください${RESET}"

            open "https://supabase.com/dashboard/sign-up"

            echo ""
            read -p "アカウント作成が完了したら Enter キーを押してください..."
        fi

        # 認証
        print_info "Supabase CLI の認証を開始します..."

        if npx supabase login; then
            # 認証確認
            if npx supabase projects list &> /dev/null; then
                update_state supabase_cli authenticated True
                print_success "Supabase CLI 認証完了"
            else
                print_error "Supabase CLI の認証確認に失敗しました"
                exit 1
            fi
        else
            print_error "Supabase CLI の認証に失敗しました"
            exit 1
        fi
    fi
}

install_resend_cli() {
    if [[ $(get_state resend_cli installed) == "True" ]]; then
        print_info "Resend CLI は既にインストールされています (スキップ)"
        return
    fi

    print_section "Resend CLI のインストール"

    # インストール確認
    if command -v resend &> /dev/null; then
        print_info "Resend CLI は既にインストールされています"
        update_state resend_cli installed True
        return
    fi

    npm install -g resend

    # 確認
    if command -v resend &> /dev/null; then
        local resend_version=$(resend --version 2>/dev/null || echo "installed")
        print_success "Resend CLI インストール完了: $resend_version"
        update_state resend_cli installed True
    else
        print_error "Resend CLI のインストールに失敗しました"
        exit 1
    fi
}

install_super_claude() {
    if [[ $(get_state super_claude installed) == "True" ]] && [[ $(get_state super_claude mcp_servers_installed) == "True" ]]; then
        print_info "Super Claude と MCP Servers は既にインストール済みです (スキップ)"
        return
    fi

    print_section "Super Claude のインストール"

    # Super Claude インストール
    if [[ $(get_state super_claude installed) == "False" ]]; then
        # pipx がインストールされているか確認
        if ! command -v pipx &> /dev/null; then
            print_info "pipx をインストールしています..."
            brew install pipx
            pipx ensurepath
        fi

        # Super Claude インストール
        pipx install SuperClaude --force

        update_state super_claude installed True
        print_success "Super Claude インストール完了"
    fi

    # MCP Servers インストール
    if [[ $(get_state super_claude mcp_servers_installed) == "False" ]]; then
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
    fi
}

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

install_cursor_ide() {
    if [[ $(get_state cursor_ide installed) == "True" ]]; then
        print_info "Cursor IDE は既にインストールされています (スキップ)"
        return
    fi

    print_section "Cursor IDE のインストール"

    # Cursor がインストールされているか確認
    if [[ -d "/Applications/Cursor.app" ]]; then
        print_info "Cursor IDE は既にインストールされています"
        update_state cursor_ide installed True
        return
    fi

    brew install --cask cursor

    # 確認
    if [[ -d "/Applications/Cursor.app" ]]; then
        print_success "Cursor IDE インストール完了"
        update_state cursor_ide installed True
    else
        print_error "Cursor IDE のインストールに失敗しました"
        exit 1
    fi
}

################################################################################
# メイン実行フロー
################################################################################

main() {
    print_section "AI開発環境自動セットアップ (macOS)"
    echo -e "${CYAN}このスクリプトは以下のツールをインストールします:${RESET}"
    echo -e "${CYAN}  1. Homebrew (パッケージマネージャー)${RESET}"
    echo -e "${CYAN}  2. Node.js (JavaScript実行環境)${RESET}"
    echo -e "${CYAN}  3. Git (バージョン管理)${RESET}"
    echo -e "${CYAN}  4. GitHub CLI (GitHub操作)${RESET}"
    echo -e "${CYAN}  5. Netlify CLI (デプロイ)${RESET}"
    echo -e "${CYAN}  6. Claude Code (AI開発ツール)${RESET}"
    echo -e "${CYAN}  7. Supabase CLI (データベース)${RESET}"
    echo -e "${CYAN}  8. Resend CLI (メール送信)${RESET}"
    echo -e "${CYAN}  9. Super Claude + MCP Servers (拡張機能)${RESET}"
    echo -e "${CYAN} 10. Playwright MCP (E2Eテスト)${RESET}"
    echo -e "${CYAN} 11. Cursor IDE (統合開発環境)${RESET}"
    echo ""

    read -p "インストールを開始しますか？ (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then
        print_warning "インストールをキャンセルしました"
        exit 0
    fi

    # 状態ファイル初期化
    init_state

    # インストール実行
    install_homebrew
    install_node
    install_git
    install_github_cli
    install_netlify_cli
    install_claude_code
    install_supabase_cli
    install_resend_cli
    install_super_claude
    install_playwright_mcp
    install_cursor_ide

    # 完了メッセージ
    print_section "🎉 セットアップ完了！"
    echo -e "${GREEN}すべてのツールのインストールが完了しました！${RESET}"
    echo ""
    echo -e "${CYAN}次のステップ:${RESET}"
    echo -e "${CYAN}  1. ターミナルを再起動してください${RESET}"
    echo -e "${CYAN}  2. Cursor IDE を起動してください${RESET}"
    echo -e "${CYAN}  3. マニュアルの1章から学習を開始できます${RESET}"
    echo ""
    echo -e "${YELLOW}状態ファイル: $STATE_FILE${RESET}"
    echo -e "${YELLOW}  (このファイルを削除すると、再インストールが必要になります)${RESET}"
}

# スクリプト実行
main
