# プロジェクト構造ドキュメント

このドキュメントは、proto-manual-techプロジェクトの詳細な構造とコンポーネント間の関係を説明します。

## 目次

1. [アーキテクチャ概要](#アーキテクチャ概要)
2. [ディレクトリ構造](#ディレクトリ構造)
3. [コンポーネント詳細](#コンポーネント詳細)
4. [データフロー](#データフロー)
5. [拡張ガイド](#拡張ガイド)

## アーキテクチャ概要

### 設計原則

proto-manual-techは以下の設計原則に基づいています：

1. **ソースと出力の完全分離**
   - `docs/` = ソース真実（Source of Truth）
   - `site/` = 完全自動生成（手動編集禁止）

2. **シンプルなビルドパイプライン**
   - 依存関係なし（Python標準ライブラリのみ）
   - 単一スクリプトで完結
   - 明確なエラーハンドリング

3. **拡張可能な設計**
   - カスタムMarkdown構文のサポート
   - プラグイン的な機能追加が容易
   - テンプレートベースの柔軟性

### システム構成図

```
┌─────────────────────────────────────────────────────────────┐
│                     Input Layer                              │
│  docs/ai-prep-manual/*.md (Markdownソースファイル)            │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│              Processing Layer                                │
│  tools/build_manual.py (MarkdownConverter)                  │
│  ├─ ファイル発見 (discover_manual_sources)                   │
│  ├─ Markdown → HTML変換 (MarkdownConverter.convert)         │
│  ├─ 目次生成 (build_toc)                                     │
│  ├─ テンプレート適用 (apply_template)                        │
│  └─ 日本語組版 (beautify_japanese_title)                    │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│                Template Layer                                │
│  templates/manual_template.html (ページテンプレート)          │
│  templates/index_template.html (インデックステンプレート)     │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│                 Style Layer                                  │
│  assets/manual.css (デザインシステム)                         │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│                  Output Layer                                │
│  site/ (生成されたHTML + CSS)                                 │
│  ├─ index.html (マニュアル一覧)                               │
│  ├─ assets/manual.css (コピーされたCSS)                      │
│  └─ ai/index.html (個別マニュアル)                            │
└─────────────────────────────────────────────────────────────┘
```

## ディレクトリ構造

### `/docs/` - ソースドキュメント

```
docs/
├── ai-prep-manual/          # AI開発準備マニュアル
│   ├── 00-sdd.md            # 仕様駆動開発について
│   ├── 01-section.md        # セクション概要
│   ├── 02-0-30ai.md         # AI準備（30分）
│   ├── 03-1-ai.md           # Claude Code基礎
│   ├── 04-2-ai.md           # Super Claudeの導入
│   ├── 05-3-ai.md           # コマンド実践
│   ├── 06-4-ai.md           # セットアップ手順
│   ├── 07-5-mcpmodel-context-protocol.md  # MCPの理解
│   ├── 08-6-aiweb.md        # Webアプリ開発
│   ├── 09-7-github.md       # GitHub連携
│   ├── 10-8.md              # バージョン管理
│   ├── 11-9.md              # 実践プロジェクト
│   ├── 12-10-sdd.md         # SDD組織変革
│   └── 13-11.md             # まとめ
└── PROJECT_STRUCTURE.md     # このファイル
```

**命名規則**:
- `NN-slug.md` 形式（NNは表示順序）
- 先頭2桁の数字で章の順序を制御
- スラッグは英数字とハイフン

### `/templates/` - HTMLテンプレート

```
templates/
├── manual_template.html     # 個別マニュアルページのテンプレート
└── index_template.html      # マニュアル一覧ページのテンプレート
```

**テンプレート変数**:
- `{{ title }}` - ドキュメントタイトル（H1から抽出）
- `{{ subtitle_block }}` - サブタイトルブロック（現在未使用）
- `{{ content }}` - 変換されたHTMLコンテンツ
- `{{ toc }}` - 自動生成される目次
- `{{ assets_href }}` - アセットへの相対パス
- `{{ generated_on }}` - 生成日時
- `{{ source_path }}` - ソースファイルパス

### `/assets/` - スタイルとアセット

```
assets/
└── manual.css               # メインスタイルシート
```

**CSSアーキテクチャ**:
1. **CSS変数** (`:root`): デザイントークン定義
2. **基本スタイル**: リセット、タイポグラフィ
3. **レイアウト**: フレックスボックスベースのレスポンシブ設計
4. **コンポーネント**: 目次、テーブル、コードブロック
5. **特殊機能**: フローチャート、カラーテーマセクション

### `/tools/` - ビルドツール

```
tools/
└── build_manual.py          # メインビルドスクリプト（~800行）
```

**主要クラス・関数**:
- `MarkdownConverter`: カスタムMarkdownパーサー
- `format_inlines()`: インライン要素の変換
- `build_toc()`: 目次HTML生成
- `beautify_japanese_title()`: 日本語タイトル改行処理
- `discover_manual_sources()`: ソースファイル発見
- `apply_template()`: テンプレート変数置換
- `main()`: ビルドプロセス実行

### `/site/` - 生成出力（自動生成）

```
site/
├── index.html               # マニュアル一覧ページ
├── assets/
│   └── manual.css           # コピーされたスタイルシート
└── ai/
    └── index.html           # AI開発マニュアル
```

⚠️ **重要**: このディレクトリのファイルは自動生成されます。直接編集しないでください。

## コンポーネント詳細

### 1. MarkdownConverter

**場所**: `tools/build_manual.py` (Line 101-447)

**責務**:
- Markdownテキストを構造化されたHTMLに変換
- 見出しからスラッグ生成とID付与
- 目次用の見出しリスト作成

**サポートされる構文**:

| Markdown | HTML | 備考 |
|----------|------|------|
| `# 見出し` | `<h1 id="slug">` | 自動ID生成 |
| `---` | `<hr />` | 水平線 |
| `- リスト` | `<ul><li>` | ネスト対応 |
| `1. リスト` | `<ol><li>` | ネスト対応 |
| ` ```python ` | `<pre><code>` | 言語クラス付与 |
| `[text](url)` | `<a>` | 外部リンクは別タブ |
| `![alt](url)` | `<img>` | lazy loading |
| `**太字**` | `<strong>` | - |
| `*斜体*` | `<em>` | - |
| `` `code` `` | `<code>` | - |
| テーブル | `<table>` | レスポンシブラッパー |
| フローチャート | カスタムHTML | 視覚的表現 |

**主要メソッド**:

```python
def convert(self, text: str) -> str:
    """Markdownテキストを行単位で解析してHTMLに変換"""

def slugify(self, text: str) -> str:
    """見出しテキストからURLフレンドリーなスラッグを生成"""

@staticmethod
def parse_flowchart(content: str) -> str:
    """フローチャート記法を視覚的HTMLに変換"""
```

### 2. フローチャート変換

**入力形式**:
```markdown
**コマンドフローチャートの位置づけ:** 新規開発 → **アイデアがある** → `/sc:brainstorm`
```

**出力HTML**:
```html
<div class="flowchart-container">
  <div class="flowchart-step">新規開発</div>
  <div class="flowchart-arrow">→</div>
  <div class="flowchart-step flowchart-highlight">アイデアがある</div>
  <div class="flowchart-arrow">→</div>
  <div class="flowchart-step flowchart-command">/sc:brainstorm</div>
</div>
```

**スタイリング**: `assets/manual.css` (Line 1393-1468)
- `.flowchart-container`: フレックスボックスレイアウト
- `.flowchart-step`: 各ステップのボックス
- `.flowchart-highlight`: 強調ステップ（青グラデーション）
- `.flowchart-command`: コマンドステップ（ダークコードスタイル）
- `.flowchart-arrow`: 矢印（モバイルで90度回転）

### 3. 目次生成

**ロジック** (`build_toc()` 関数):

1. **見出しの収集**: H2-H4見出しを使用
2. **階層構造の構築**:
   - H2 → セクション（トップレベル）
   - H3-H4 → サブセクション（ネスト）
3. **HTML生成**: `<ol>` による階層的なリスト
4. **日本語組版**: タイトルに改行処理を適用

**HTML構造**:
```html
<nav class="toc">
  <h2>Quick Links</h2>
  <ol class="toc-list">
    <li><a href="#section-1">セクション1</a>
      <ol>
        <li><a href="#subsection-1-1">サブセクション1.1</a></li>
      </ol>
    </li>
  </ol>
</nav>
```

### 4. 日本語組版処理

**関数**: `beautify_japanese_title(title: str) -> str`

**ルール**:

1. **コロン後の改行**: `：` の後で自然に改行
2. **意味境界での改行**: 18-25文字で可読性向上
3. **助詞での改行回避**: `の`、`と` の後では改行しない
4. **機能語での改行**: `による`、`として`、`について` の後で改行
5. **複合語の保持**: 一体性のある用語をまとめる

**例**:
```
入力: "MCPサーバー活用によるAI開発環境構築：仕様駆動開発とバイブコーディングによる次世代開発戦略"

出力: "MCPサーバー活用によるAI開発環境構築：<br>仕様駆動開発とバイブコーディングによる<br>次世代開発戦略"
```

### 5. テンプレートシステム

**処理**: `apply_template(template: str, context: Dict[str, str]) -> str`

**変数置換メカニズム**:
```python
# テンプレート内の {{ variable }} を context[variable] で置換
result = template.replace("{{ title }}", context["title"])
```

**使用例**:
```python
context = {
    "title": "AI開発ツール完全活用マニュアル",
    "content": "<h2>はじめに</h2><p>...</p>",
    "toc": "<nav>...</nav>",
    "assets_href": "../assets"
}
page_html = apply_template(template, context)
```

## データフロー

### ビルドプロセス全体

```
1. ファイル発見
   ├─ docs/ ディレクトリをスキャン
   ├─ *.md ファイルを収集
   └─ NN-slug.md 形式で並び替え

2. Markdown → HTML変換
   ├─ 各.mdファイルを読み込み
   ├─ MarkdownConverter.convert() で変換
   ├─ 見出しリストの抽出（目次用）
   └─ タイトルの抽出（H1）

3. 目次生成
   ├─ 見出しリストから階層構造を構築
   ├─ HTML <ol> リストを生成
   └─ 日本語組版処理を適用

4. テンプレート適用
   ├─ manual_template.html を読み込み
   ├─ 変数（title, content, toc等）を置換
   └─ 最終HTMLを生成

5. アセットコピー
   ├─ assets/ を site/assets/ にコピー
   └─ 相対パスの調整

6. インデックス生成
   ├─ 全マニュアルのメタデータを収集
   ├─ index_template.html を読み込み
   └─ site/index.html を生成
```

### 変換パイプライン詳細

```
Raw Markdown
    │
    ├─ 行単位で読み込み
    │
    ▼
構文解析
    │
    ├─ 見出しパターンマッチ → H1-H6 + スラッグ生成
    ├─ リストパターンマッチ → UL/OL + ネスト処理
    ├─ テーブルパターンマッチ → TABLE + レスポンシブラッパー
    ├─ コードブロック検出 → PRE + CODE + 言語クラス
    ├─ フローチャート検出 → カスタムHTML
    └─ インライン要素処理 → format_inlines()
    │
    ▼
HTML生成
    │
    ├─ パラグラフバッファの flush
    ├─ リストスタックの管理
    ├─ テーブルバッファの flush
    └─ 最終HTML文字列の結合
    │
    ▼
後処理
    │
    ├─ 日本語組版（タイトル改行）
    ├─ テンプレート適用
    └─ ファイル出力
```

## 拡張ガイド

### 新しいMarkdown構文の追加

**手順**:

1. **パターン定義**: `MarkdownConverter` クラス内で正規表現パターンを定義
   ```python
   custom_pattern = re.compile(r"^@@([A-Z]+):\s+(.+)$")
   ```

2. **パース処理追加**: `convert()` メソッド内でパターンマッチを追加
   ```python
   custom_match = self.custom_pattern.match(stripped)
   if custom_match:
       type_name = custom_match.group(1)
       content = custom_match.group(2)
       html_parts.append(self.parse_custom(type_name, content))
       continue
   ```

3. **変換関数実装**: 静的メソッドまたはインスタンスメソッドで変換ロジックを実装
   ```python
   @staticmethod
   def parse_custom(type_name: str, content: str) -> str:
       """カスタム構文を変換"""
       return f'<div class="custom-{type_name.lower()}">{content}</div>'
   ```

4. **CSS追加**: `assets/manual.css` でスタイルを定義
   ```css
   .custom-note {
       background: #FEF3C7;
       border-left: 4px solid #F59E0B;
       padding: 1rem;
   }
   ```

### 新しいテーマセクションの追加

**例**: MCPサーバー系コマンドのテーマセクション

1. **CSS変数定義**:
   ```css
   :root {
       --color-mcp-primary: #8B5CF6;
       --color-mcp-secondary: #A78BFA;
   }
   ```

2. **セクションスタイル**:
   ```css
   .mcp-section {
       background: linear-gradient(135deg, var(--color-mcp-primary), var(--color-mcp-secondary));
       color: white;
       padding: 2rem;
       border-radius: 1rem;
   }
   ```

3. **ラッパー関数追加** (`build_manual.py`):
   ```python
   html_body = wrap_section_by_heading(
       html_body,
       'MCPサーバーの設定',
       'mcp-section'
   )
   ```

### 新しいマニュアルの追加

**手順**:

1. **ディレクトリ作成**: `docs/new-manual/` を作成

2. **Markdownファイル作成**: チャプター別に `NN-slug.md` ファイルを作成
   ```
   docs/new-manual/
   ├── 00-introduction.md
   ├── 01-getting-started.md
   └── 02-advanced.md
   ```

3. **ビルド実行**: `python tools/build_manual.py`

4. **確認**: `site/index.html` に新しいマニュアルが表示される

**自動処理**:
- `discover_manual_sources()` が自動的にディレクトリを検出
- スラッグは自動生成（ディレクトリ名から）
- インデックスページに自動追加

### カスタムテンプレート変数の追加

**手順**:

1. **テンプレートに変数追加** (`templates/manual_template.html`):
   ```html
   <meta name="author" content="{{ author }}">
   ```

2. **ビルドスクリプトで値を設定** (`build_manual.py`):
   ```python
   context = {
       "title": title,
       "author": "Development Team",  # 新規追加
       # ... 他の変数
   }
   ```

3. **apply_template()** が自動的に置換を実行

## ベストプラクティス

### パフォーマンス

1. **正規表現のコンパイル**: パターンはクラス変数として事前コンパイル
2. **バッファリング**: パラグラフやテーブルのバッファリングで効率的に処理
3. **遅延評価**: 必要になるまでHTMLを生成しない

### 保守性

1. **関数分割**: 各機能を独立した関数に分割
2. **型ヒント**: すべての関数に型アノテーションを付ける
3. **ドキュメント**: docstringで各関数の動作を説明

### 品質

1. **既存テスト**: 変更後は既存マニュアルのビルドを確認
2. **ブラウザテスト**: 複数ブラウザで表示確認
3. **レスポンシブ確認**: モバイル、タブレット、デスクトップで確認

## トラブルシューティング

### よくある問題

**問題**: 見出しIDが重複する
- **原因**: 同じテキストの見出しが複数存在
- **解決**: `slugify()` が自動的に番号サフィックスを追加（`slug-2`, `slug-3`）

**問題**: テーブルが表示されない
- **原因**: Markdownテーブル構文が不正
- **解決**: パイプ `|` の位置とヘッダー区切り行 `|---|---|` を確認

**問題**: フローチャートが変換されない
- **原因**: パターンマッチの失敗
- **解決**: `**コマンドフローチャートの位置づけ:**` という完全一致が必要

**問題**: CSSが反映されない
- **原因**: ブラウザキャッシュ
- **解決**: ハードリロード（Cmd+Shift+R / Ctrl+Shift+R）

---

**最終更新**: 2025-10-10
**ドキュメント作成**: Claude Code
