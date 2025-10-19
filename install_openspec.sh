#!/bin/bash

echo "🚀 OpenSpec インストールを開始します..."

# Node.jsバージョン確認
echo "📦 Node.js バージョン確認..."
node --version

# プロジェクトディレクトリに移動
cd /Users/takahashiyuuta/Documents/scripts/proto-manual-tech

# OpenSpecをnpm経由でインストール
echo "📥 OpenSpec をグローバルインストール..."
npm install -g @fission-ai/openspec

# インストール確認
echo "✅ インストール確認..."
which openspec || echo "⚠️ openspecコマンドが見つかりません"

echo ""
echo "✨ インストール完了！"
echo ""
echo "📖 使い方:"
echo "  openspec --help         # ヘルプ表示"
echo "  openspec generate       # OpenAPI仕様生成"
echo "  openspec init           # 初期設定"
echo ""
