#!/bin/bash

################################################################################
# マニュアル送付用パッケージング スクリプト
#
# 目的: スクリプト・HTML・CSS・アセットを一括でZIP圧縮
#
# 実行方法:
#   chmod +x package-for-delivery.sh
#   ./package-for-delivery.sh
#
# 出力: proto-manual-tech-delivery-YYYYMMDD.zip
################################################################################

set -e  # エラー時に即座に終了

# カラー定義
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly RESET='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${BLUE}▶ マニュアル送付用パッケージング${RESET}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"

# 日付取得
DATE=$(date +%Y%m%d)
PACKAGE_NAME="proto-manual-tech-delivery-${DATE}.zip"

# プロジェクトルートに移動
cd "$(dirname "$0")/.."

echo -e "${CYAN}📦 パッケージ名: ${PACKAGE_NAME}${RESET}\n"

# 含めるファイル・ディレクトリを表示
echo -e "${CYAN}📂 パッケージに含まれる内容:${RESET}"
echo -e "  ${GREEN}✓${RESET} scripts/               - インストールスクリプト（Windows/Mac）"
echo -e "  ${GREEN}✓${RESET} site/                  - HTMLマニュアル + アセット"
echo -e "  ${GREEN}✓${RESET} docs/FAQ.md            - よくある質問"
echo -e "  ${GREEN}✓${RESET} docs/install-script-spec.md - スクリプト仕様書"
echo -e "  ${GREEN}✓${RESET} README.md              - プロジェクト概要\n"

# 確認
read -p "パッケージングを開始しますか？ (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    echo -e "${YELLOW}⚠ パッケージングをキャンセルしました${RESET}"
    exit 0
fi

echo -e "\n${CYAN}🔨 ZIP圧縮中...${RESET}"

# 既存のZIPファイルを削除
if [[ -f "$PACKAGE_NAME" ]]; then
    rm "$PACKAGE_NAME"
    echo -e "${YELLOW}⚠ 既存のZIPファイルを削除しました${RESET}"
fi

# ZIP圧縮
zip -r "$PACKAGE_NAME" \
    scripts/install-ai-dev-tools-win.ps1 \
    scripts/install-ai-dev-tools-mac.sh \
    site/ \
    docs/FAQ.md \
    docs/install-script-spec.md \
    README.md \
    -x "*.DS_Store" \
    -x "__pycache__/*" \
    -x "*.pyc" \
    -x "*/.git/*" \
    -x "*/node_modules/*" \
    -x "*/.install_progress.json" \
    -x "*.backup*" \
    -q

# 完了
echo -e "\n${GREEN}✓ パッケージング完了！${RESET}\n"

# ファイルサイズ表示
FILE_SIZE=$(du -h "$PACKAGE_NAME" | cut -f1)
echo -e "${CYAN}📊 パッケージ情報:${RESET}"
echo -e "  ファイル名: ${PACKAGE_NAME}"
echo -e "  ファイルサイズ: ${FILE_SIZE}"
echo -e "  保存場所: $(pwd)/${PACKAGE_NAME}\n"

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}🎉 パッケージングが完了しました！${RESET}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"

echo -e "${CYAN}📤 送付方法:${RESET}"
echo -e "  1. メール添付（ファイルサイズ確認）"
echo -e "  2. Google Drive / Dropbox などのクラウドストレージ"
echo -e "  3. GitHub リポジトリ（プライベート推奨）\n"
