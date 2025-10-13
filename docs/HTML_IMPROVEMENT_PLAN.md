# HTML改善計画書

**作成日**: 2025-10-12
**対象**: AI開発ツール完全活用マニュアル（session-1-basics.html, session-2-quality.html, session-3-advanced.html）
**目的**: 初心者にとってわかりやすく、離脱しにくい章構成への改善

---

## 📊 レビュー総合評価

**総合スコア**: 72/100点

### 評価内訳
- ❌ 章番号整合性: 50/100（session-1の目次が崩壊）
- ⭐⭐⭐ 説明のわかりやすさ: 75/100
- ⭐⭐ 段階性: 65/100（5章→6章の難易度ジャンプが大きい）
- ⭐⭐⭐ 離脱リスク対策: 70/100
- ⭐⭐⭐⭐ ハンズオン配置: 85/100

---

## 🚨 発見された重大な問題

### 1. 章番号の不整合（最優先修正項目）

**ファイル**: `site/ai/session-1-basics.html`

#### 問題箇所

Phase 2の目次（行107-129）:
- ❌ 行111: 「5. GitHub連携」→ 正しくは「6章」
- ❌ 行119: 「5. モダン技術スタック」→ 正しくは「7章」
- ❌ 行123: 「5. あなたのアプリを進化させよう」→ 正しくは「8章」
- ❌ 行127: 「5. 企業導入のためのSDD組織変革ガイド」→ 正しくは「9章」

Phase 4の目次（行135-141）:
- ❌ 行135: 「5. 裏側の技術：MCP」→ 正しくは「13章」
- ❌ 行139: 「5. トラブルシューティング」→ 正しくは「10章」

**追加問題**:
- `session-3-advanced.html` 行110: h3タグ「11.1 一般的な問題」→ 正しくは「10.1」

---

### 2. 難易度ジャンプの問題

#### 📊 難易度推移グラフ

```
難易度
⭐⭐⭐⭐⭐ |              ┌─7章
⭐⭐⭐⭐   |           ┌─6章──┬8章─┬9章────┬11章─┐
⭐⭐⭐     |        ┌5章┘         │       │      └12章
⭐⭐       |  ┌2章─┼4章           │       └10章   │
⭐         | 0章─1章               │              └13章
           └────────────────────────────────────────
           0  1  2  3  4  5  6  7  8  9 10 11 12 13 章
```

**最大の問題**: 5章 → 6章の難易度ジャンプ
- 5章まで: AIに指示するだけの「魔法体験」
- 6章以降: Git/GitHub、ターミナル操作など従来のエンジニアリング知識が必要

**離脱リスク**: 初心者が「急に難しくなった」と感じ、学習を中断する可能性が高い

---

### 3. 説明のわかりやすさの問題

#### ⚠️ 改善が必要な箇所

**0章（session-1-basics.html）**:
- ターミナル操作の説明不足
- エラー時の対処法が不明

**3章（session-1-basics.html）**:
- プロンプトエンジニアリングが抽象的
- 実例なしでテクニック羅列

**6章（session-2-quality.html）**:
- 「issue」の概念説明が遅い（7.4で詳細説明だが、7.3で既に使用）

**7章（session-2-quality.html）**:
- 「ブランチ」の説明が抽象的
- ブランチ、issue、PRの3概念を一気に説明

---

## 🎯 改善計画

### Phase 1: 緊急修正（即日対応）

#### 1-1. 章番号の修正【最優先】

**作業時間**: 10分
**対象ファイル**: `site/ai/session-1-basics.html`

| 行番号 | 修正前 | 修正後 |
|--------|--------|--------|
| 111 | `<strong>5. GitHub連携</strong>` | `<strong>6. GitHub連携</strong>` |
| 119 | `<strong>5. モダン技術スタックの構築</strong>` | `<strong>7. モダン技術スタックの構築</strong>` |
| 123 | `<strong>5. あなたのアプリを進化させよう！</strong>` | `<strong>8. あなたのアプリを進化させよう！</strong>` |
| 127 | `<strong>5. 企業導入のためのSDD組織変革ガイド</strong>` | `<strong>9. 企業導入のためのSDD組織変革ガイド</strong>` |
| 135 | `<strong>5. 裏側の技術：MCP</strong>` | `<strong>13. 裏側の技術：MCP</strong>` |
| 139 | `<strong>5. トラブルシューティング</strong>` | `<strong>10. トラブルシューティング</strong>` |

**対象ファイル**: `site/ai/session-3-advanced.html`

| 行番号 | 修正前 | 修正後 |
|--------|--------|--------|
| 110 | `<h3 id="111-一般的な問題と解決策">11.1 一般的な問題と解決策</h3>` | `<h3 id="101-一般的な問題と解決策">10.1 一般的な問題と解決策</h3>` |

---

### Phase 2: 高優先修正（1週間以内）

#### 2-1. 5章→6章の難易度緩和【高優先】

**作業時間**: 3-4時間

##### 2-1-1. 5.5章「GitHub超入門」の新設（30分のミニ体験）

**挿入位置**: `session-1-basics.html` 5章の末尾

**内容**:
```html
<h3 id="55-githubって何超入門">5.5 GitHubって何？超入門</h3>

<div style="background: グラスモーフィズム">
  <h4>🎮 まずはゲーム感覚で体験してみよう</h4>

  <p>次の章（6章）では、GitHubというツールを使います。</p>
  <p>「難しそう...」と思うかもしれませんが、実は<strong>ゲームのセーブ機能</strong>と同じです！</p>

  <h5>📝 GitHubを一言で表すと？</h5>
  <ul>
    <li><strong>コミット</strong> = ゲームのセーブ</li>
    <li><strong>プッシュ</strong> = クラウドにバックアップ</li>
    <li><strong>ブランチ</strong> = セーブデータのコピー（実験用）</li>
  </ul>

  <h5>🚀 3分でできる体験ミッション</h5>
  <p>Claude Codeに以下のように依頼してみましょう：</p>
  <pre><code>「GitHubに新しいリポジトリを作成して、今のプロジェクトをアップロードしてください」</code></pre>

  <p>これだけで、あなたのコードがクラウドに保存されます！</p>
</div>

<div style="background: アンバー系のグラスモーフィズム">
  <p><strong>💡 6章からは少し難易度が上がります</strong></p>
  <p>でも大丈夫！この5.5章で体験したことを、6章で詳しく学びます。</p>
  <p>焦らず、ゆっくり進めましょう。</p>
</div>
```

##### 2-1-2. 6章冒頭に難易度注意書きを追加

**挿入位置**: `session-2-quality.html` 6章の冒頭（h2タグの直後）

**内容**:
```html
<div style="background: 薄い赤のグラスモーフィズム; border: 2px dashed #ef4444;">
  <h5>⚠️ この章から難易度が少し上がります</h5>
  <p>5章までは「AIに指示するだけ」で完結していましたが、6章以降は<strong>GitやGitHubなどの従来のエンジニアリングツール</strong>も使います。</p>
  <p>最初は難しく感じるかもしれませんが、<strong>ゆっくり読み進めれば必ず理解できます</strong>。</p>
  <p>分からないところは、遠慮なくClaude Codeに質問してください！</p>
</div>
```

##### 2-1-3. 6章に図解とスクリーンショットを追加

**対象セクション**:
- 7.1 GitとGitHubの基本
- 7.2 なぜGitHubが必要か？

**追加内容**:
- コミット・プッシュのフローチャート
- GitHub Desktopのスクリーンショット
- 「ゲームのセーブデータ」との比較図

---

#### 2-2. ハンズオン所要時間の明記【中優先】

**作業時間**: 30分

**対象ファイル**: 各HTMLファイルのハンズオンセクション

| ハンズオン | ファイル | 現状 | 修正後 |
|-----------|---------|------|--------|
| H1 | session-1-basics.html | 所要時間なし | 「60分」を追加 |
| H2 | session-2-quality.html 7.7 | 所要時間なし | 「30分」を追加 |
| H3 | session-2-quality.html 8.5 | 所要時間なし | 「90分」を追加 |
| H6 | session-3-advanced.html 12章 | 所要時間なし | 「120分」を追加 |

**追加位置**: 各ハンズオンのh3タグまたはh4タグの直後

**記述例**:
```html
<h3 id="57-実践ハンズオンあなただけのwebアプリ開発">5.7 実践ハンズオン：あなただけのWebアプリ開発</h3>

<div style="background: グリーン系のグラスモーフィズム">
  <p style="font-size: 1.1em; font-weight: bold;">⏱️ 所要時間：約60分</p>
  <p>休憩を入れながら、ゆっくり進めましょう。</p>
</div>
```

---

### Phase 3: 中優先修正（2週間以内）

#### 3-1. 0章のターミナル操作説明追加

**作業時間**: 1時間

**挿入位置**: `session-1-basics.html` 0章の「自動セットアップ実行方法」の前

**内容**:
```html
<h3 id="04-ターミナルって何">0.4 ターミナルって何？</h3>

<div style="background: グラスモーフィズム">
  <p>「ターミナル」と聞くと難しそうですが、<strong>コンピュータに文字で指示を出すツール</strong>です。</p>

  <h5>🎯 Windowsの「コマンドプロンプト」やMacの「ターミナル」がこれに該当します</h5>

  <details>
    <summary><strong>📸 ターミナルの開き方（クリックで表示）</strong></summary>
    <div>
      <h6>macOS の場合：</h6>
      <ol>
        <li>Launchpad を開く（Dock の一番左のロケットアイコン）</li>
        <li>「その他」フォルダを開く</li>
        <li>「ターミナル」をクリック</li>
      </ol>
      <img src="../assets/images/terminal-mac-screenshot.png" alt="macOS ターミナル" style="max-width: 100%; border-radius: 12px; margin: 16px 0;">

      <h6>Windows の場合：</h6>
      <ol>
        <li>スタートメニューを開く</li>
        <li>「PowerShell」と検索</li>
        <li>「Windows PowerShell」をクリック</li>
      </ol>
      <img src="../assets/images/terminal-win-screenshot.png" alt="Windows PowerShell" style="max-width: 100%; border-radius: 12px; margin: 16px 0;">
    </div>
  </details>

  <h5>📋 コマンドのコピー＆ペースト方法</h5>
  <ul>
    <li><strong>コピー</strong>: このマニュアルのコードブロックにある「コピー」ボタンをクリック</li>
    <li><strong>ペースト</strong>:
      <ul>
        <li>macOS: Command + V</li>
        <li>Windows: Ctrl + V または右クリック → 貼り付け</li>
      </ul>
    </li>
    <li><strong>実行</strong>: Enter キーを押す</li>
  </ul>
</div>
```

---

#### 3-2. エラー対処法セクションの追加

**作業時間**: 1時間

**挿入位置**: `session-1-basics.html` 0章の末尾

**内容**:
```html
<h3 id="07-よくあるエラーと対処法">0.7 よくあるエラーと対処法</h3>

<div style="background: 赤系のグラスモーフィズム">
  <h5>🚨 エラーが出ても焦らないで！</h5>
  <p>初めて開発環境を構築するとき、エラーが出るのは<strong>とても普通のこと</strong>です。</p>
  <p>以下のよくあるエラーと対処法を参考にしてください。</p>
</div>

<details>
  <summary><strong>エラー1: 「権限がありません」「Permission denied」</strong></summary>
  <div>
    <p><strong>原因</strong>: 管理者権限が必要なコマンドを実行しようとしている</p>
    <p><strong>対処法</strong>:</p>
    <ul>
      <li>macOS: コマンドの前に <code>sudo</code> を付ける（例: <code>sudo ./install-ai-dev-tools-mac.sh</code>）</li>
      <li>Windows: PowerShellを「管理者として実行」で開き直す</li>
    </ul>
  </div>
</details>

<details>
  <summary><strong>エラー2: 「コマンドが見つかりません」「command not found」</strong></summary>
  <div>
    <p><strong>原因</strong>: インストールしたツールがまだ認識されていない</p>
    <p><strong>対処法</strong>:</p>
    <ul>
      <li>ターミナル（PowerShell）を一度閉じて、再度開く</li>
      <li>macOS: <code>source ~/.zshrc</code> を実行</li>
      <li>Windows: <code>$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")</code> を実行</li>
    </ul>
  </div>
</details>

<details>
  <summary><strong>エラー3: 「ネットワークエラー」「Network error」</strong></summary>
  <div>
    <p><strong>原因</strong>: インターネット接続が不安定、またはファイアウォールがブロックしている</p>
    <p><strong>対処法</strong>:</p>
    <ul>
      <li>Wi-Fi接続を確認</li>
      <li>企業のネットワークを使用している場合は、IT部門に相談</li>
      <li>VPNを使用している場合は、一時的にオフにして試す</li>
    </ul>
  </div>
</details>

<div style="background: グリーン系のグラスモーフィズム; margin-top: 20px;">
  <p><strong>💡 それでも解決しない場合は？</strong></p>
  <p>Claude Codeに相談してみましょう！</p>
  <pre><code>「インストールスクリプトで以下のエラーが出ました。対処法を教えてください。
[エラーメッセージをコピー＆ペースト]」</code></pre>
</div>
```

---

#### 3-3. プロンプトエンジニアリング（3章）の実例追加

**作業時間**: 2時間

**修正位置**: `session-1-basics.html` 3章の各テクニックセクション

**追加内容**: 各テクニックに「Before/After」の具体例

**例**: 3.1.1 役割を明示する

```html
<h4>3.1.1 役割を明示する</h4>

<div style="background: グラスモーフィズム">
  <p>AIに「どんな立場で答えてほしいか」を伝えると、より適切な回答が得られます。</p>

  <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin: 20px 0;">
    <!-- Before -->
    <div style="background: rgba(239, 68, 68, 0.1); padding: 16px; border-radius: 12px; border: 2px solid #ef4444;">
      <h5 style="color: #dc2626; margin: 0 0 12px 0;">❌ Before（悪い例）</h5>
      <pre style="background: rgba(255, 255, 255, 0.8); padding: 12px; border-radius: 8px; margin: 0;"><code>「ログイン機能を作ってください」</code></pre>
      <p style="font-size: 0.9em; color: #7f1d1d; margin: 12px 0 0 0;">
        → 役割が不明確なため、AIがどのレベルの実装を返すべきか判断できない
      </p>
    </div>

    <!-- After -->
    <div style="background: rgba(16, 185, 129, 0.1); padding: 16px; border-radius: 12px; border: 2px solid #10b981;">
      <h5 style="color: #059669; margin: 0 0 12px 0;">✅ After（良い例）</h5>
      <pre style="background: rgba(255, 255, 255, 0.8); padding: 12px; border-radius: 8px; margin: 0;"><code>「あなたはセキュリティに詳しいWebエンジニアです。
初心者向けのログイン機能を作ってください。
セキュリティのベストプラクティスに従い、
分かりやすいコメントを付けてください。」</code></pre>
      <p style="font-size: 0.9em; color: #065f46; margin: 12px 0 0 0;">
        → 役割とレベル感が明確で、AIが適切な実装を返しやすい
      </p>
    </div>
  </div>
</div>
```

---

#### 3-4. 7章のブランチ・issue・PR説明に図解追加

**作業時間**: 3時間

**対象ファイル**: `session-2-quality.html` 7.4

**追加内容**:

##### 3-4-1. ブランチの図解

```html
<h4>7.4.1 ブランチ戦略</h4>

<div style="background: グラスモーフィズム">
  <p>ブランチは、<strong>並行して複数の作業を進めるための仕組み</strong>です。</p>

  <h5>📝 Wordファイルで例えると：</h5>
  <div style="background: rgba(254, 243, 199, 0.8); padding: 16px; border-radius: 12px; margin: 16px 0;">
    <p style="margin: 0 0 8px 0;">従来のやり方（Wordファイル）：</p>
    <ul style="margin: 0;">
      <li>レポート.docx</li>
      <li>レポート_最終版.docx</li>
      <li>レポート_最終版_修正.docx</li>
      <li>レポート_最終版_修正_20250112.docx ← どれが最新か分からない！</li>
    </ul>
  </div>

  <div style="background: rgba(209, 250, 229, 0.8); padding: 16px; border-radius: 12px; margin: 16px 0;">
    <p style="margin: 0 0 8px 0;">Gitのブランチ：</p>
    <pre style="background: rgba(255, 255, 255, 0.9); padding: 16px; border-radius: 8px; margin: 0; font-family: monospace; line-height: 1.8;"><code>main（本番用）──────────────┐
                              │
feature/login（ログイン機能） ──┤
                              │
feature/dashboard（ダッシュボード）┘

← 全て同じファイルから派生し、最後に統合（マージ）する</code></pre>
  </div>

  <h5>🌳 ブランチ図解</h5>
  <img src="../assets/images/git-branch-diagram.png" alt="ブランチの図解" style="max-width: 100%; border-radius: 12px; margin: 16px 0; border: 2px solid rgba(16, 185, 129, 0.3);">
</div>
```

##### 3-4-2. issueの図解

```html
<h4>7.4.2 issue（課題管理）</h4>

<div style="background: グラスモーフィズム">
  <p>issueは、<strong>やるべきこと（タスク）を管理する付箋のようなもの</strong>です。</p>

  <h5>📋 Trelloのカードボードをイメージしてください</h5>
  <img src="../assets/images/github-issues-board.png" alt="GitHub issueボード" style="max-width: 100%; border-radius: 12px; margin: 16px 0; border: 2px solid rgba(99, 102, 241, 0.3);">

  <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; margin: 20px 0;">
    <div style="background: rgba(239, 68, 68, 0.1); padding: 12px; border-radius: 8px; border-left: 4px solid #ef4444;">
      <h6 style="margin: 0 0 8px 0; color: #dc2626;">🔴 ToDo（未着手）</h6>
      <p style="font-size: 0.85em; margin: 0;">issue #1: ログイン機能の実装</p>
    </div>
    <div style="background: rgba(251, 191, 36, 0.1); padding: 12px; border-radius: 8px; border-left: 4px solid #f59e0b;">
      <h6 style="margin: 0 0 8px 0; color: #d97706;">🟡 In Progress（作業中）</h6>
      <p style="font-size: 0.85em; margin: 0;">issue #2: ダッシュボードUI</p>
    </div>
    <div style="background: rgba(16, 185, 129, 0.1); padding: 12px; border-radius: 8px; border-left: 4px solid #10b981;">
      <h6 style="margin: 0 0 8px 0; color: #059669;">🟢 Done（完了）</h6>
      <p style="font-size: 0.85em; margin: 0;">issue #3: 初期セットアップ</p>
    </div>
  </div>
</div>
```

##### 3-4-3. プルリクエストの図解

```html
<h4>7.4.3 プルリクエスト（PR）</h4>

<div style="background: グラスモーフィズム">
  <p>プルリクエストは、<strong>「この変更を本番に反映していいか確認してください」というお願い</strong>です。</p>

  <h5>🔄 プルリクエストのフロー</h5>
  <div style="background: rgba(255, 255, 255, 0.9); padding: 20px; border-radius: 12px; margin: 16px 0;">
    <pre style="margin: 0; font-family: monospace; line-height: 2;"><code>1️⃣ ブランチで作業
   │
   ▼
2️⃣ GitHubにプッシュ
   │
   ▼
3️⃣ プルリクエスト作成 ← 「レビューしてください！」
   │
   ├──→ 👀 レビュアーがコードをチェック
   │     │
   │     ├─ ✅ 承認（LGTM: Looks Good To Me）
   │     └─ ❌ 修正依頼（コメント付き）
   │
   ▼
4️⃣ マージ（本番に反映）
   │
   ▼
5️⃣ 🎉 完了！
</code></pre>
  </div>

  <img src="../assets/images/github-pr-flow.png" alt="プルリクエストのフロー" style="max-width: 100%; border-radius: 12px; margin: 16px 0; border: 2px solid rgba(168, 85, 247, 0.3);">
</div>
```

---

### Phase 4: 低優先修正（1ヶ月以内）

#### 4-1. 7章の分割（ブランチ・issue・PRの段階的学習）

**作業時間**: 5-6時間

**内容**: 7章を2つに分割し、概念を段階的に学習できるようにする

##### 現状の問題
- 7章でブランチ、issue、PRの3概念を一気に導入
- 初心者には情報量が多すぎる

##### 改善案

**新7章「ブランチとissueの基礎」**:
- 7.1 GitとGitHubの基本（既存）
- 7.2 なぜGitHubが必要か？（既存）
- 7.3 開発スタイル別のGitHub活用法（既存）
- 7.4 ブランチ戦略（新規：図解付き）
- 7.5 issue（課題管理）（新規：図解付き）
- 7.6 実践ハンズオン：ブランチでissueを解決（30分）

**新8章「プルリクエストとレビュー」**:
- 8.1 プルリクエストとは？（新規：図解付き）
- 8.2 コードレビューの基本（新規）
- 8.3 マージとコンフリクト解決（新規）
- 8.4 実践ハンズオン：PR作成とレビュー（30分）

**章番号の繰り下げ**:
- 現8章 → 新9章（モダン技術スタックの構築）
- 現9章 → 新10章（機能追加プロジェクト）
- 現10章以降も全て+1

---

#### 4-2. 息抜きハンズオンの追加

**作業時間**: 2時間

**挿入位置**: 新9章と新10章の間（現8章と9章の間）

**内容**:
```html
<h2 id="95-コーヒーブレイクclaude-codeでミニゲーム作成"><strong>9.5 コーヒーブレイク：Claude Codeでミニゲーム作成</strong></h2>

<div style="background: グラスモーフィズム">
  <p>ここまでお疲れさまでした！</p>
  <p>9章までで、かなり本格的な内容を学びましたね。</p>
  <p>次の10章に進む前に、<strong>15分だけ息抜き</strong>しませんか？</p>

  <h3>🎮 ミニゲームを作って気分転換</h3>
  <p>Claude Codeに以下のように依頼してみましょう：</p>

  <pre><code>「シンプルなテトリスゲームを作ってください。
ブラウザで動くHTML/CSS/JavaScriptで、
矢印キーで操作できるようにしてください。」</code></pre>

  <p>たった1つの指示で、遊べるゲームが完成します！</p>
  <p>15分遊んだら、また次の章に進みましょう。</p>
</div>

<div style="background: グリーン系のグラスモーフィズム">
  <p><strong>💡 このミニゲーム作成の目的</strong></p>
  <ul>
    <li>学習のペースダウンと気分転換</li>
    <li>Claude Codeの威力を再確認</li>
    <li>「楽しい！」という感覚を取り戻す</li>
  </ul>
</div>
```

---

#### 4-3. 11章のPlaywright MCP座学の簡潔化

**作業時間**: 1時間

**対象ファイル**: `session-3-advanced.html` 行174-232

**現状**: 座学が長すぎる（約60行）

**改善**: 座学を1/2に圧縮（約30行）

**削除する内容**:
- E2Eテストの歴史や理論的背景
- 他のテストツールとの比較

**残す内容**:
- E2Eテストとは何か（1段落）
- Playwright MCPの特徴（箇条書き3つ）
- なぜ必要か？（1段落）

---

## 📅 実装スケジュール

### Week 1（緊急）
- [x] Phase 1-1: 章番号の修正（10分）
  - session-1-basics.html（行111, 119, 123, 127, 135, 139）
  - session-3-advanced.html（行110）

### Week 2（高優先）
- [ ] Phase 2-1-1: 5.5章「GitHub超入門」の新設（3時間）
- [ ] Phase 2-1-2: 6章冒頭に難易度注意書き（30分）
- [ ] Phase 2-1-3: 6章に図解とスクリーンショット（2時間）
- [ ] Phase 2-2: ハンズオン所要時間の明記（30分）

### Week 3-4（中優先）
- [ ] Phase 3-1: 0章のターミナル操作説明（1時間）
- [ ] Phase 3-2: エラー対処法セクション（1時間）
- [ ] Phase 3-3: プロンプトエンジニアリングの実例追加（2時間）
- [ ] Phase 3-4-1: ブランチの図解（1時間）
- [ ] Phase 3-4-2: issueの図解（1時間）
- [ ] Phase 3-4-3: プルリクエストの図解（1時間）

### Month 2（低優先）
- [ ] Phase 4-1: 7章の分割（5-6時間）
- [ ] Phase 4-2: 息抜きハンズオンの追加（2時間）
- [ ] Phase 4-3: 11章の座学簡潔化（1時間）

**総作業時間**: 約23-24時間

---

## 🎯 改善後の目標スコア

| 項目 | 現在 | 目標 | 改善策 |
|-----|------|------|--------|
| 章番号整合性 | 50/100 | **100/100** | Phase 1-1で修正 |
| わかりやすさ | 75/100 | **90/100** | Phase 2-3で実例・図解追加 |
| 段階性 | 65/100 | **85/100** | Phase 2-1, 4-1で難易度緩和 |
| 離脱リスク対策 | 70/100 | **85/100** | Phase 2-1, 3-2で注意書き追加 |
| ハンズオン配置 | 85/100 | **95/100** | Phase 2-2, 4-2で所要時間明記・息抜き追加 |

**総合スコア**: 72/100 → **91/100** 🎉

---

## 📝 実装時の注意事項

### HTMLファイル編集の厳守事項
1. **既存のHTMLを必ず確認**してから編集
2. **グラスモーフィズムデザインを維持**
3. **文章量を増やしすぎない**（簡潔に）
4. **追加箇所のみを編集**（全体を書き換えない）
5. **既存のh2, h3タグの構造を維持**

### グラスモーフィズムデザインのコピー元
- アンバー系（警告）: 行238-265（session-1-basics.html）
- グリーン系（成功・ポイント）: 行224-235（session-2-quality.html）
- 赤系（エラー・注意）: session-3-advanced.html参照
- 紫系（情報）: 行200-235（session-1-basics.html）

### 画像ファイルの準備
**Phase 2-1-3, Phase 3-1, Phase 3-4で必要**

画像ファイル格納先: `/Users/takahashiyuuta/Documents/scripts/proto-manual-tech/site/assets/images/`

必要な画像:
1. `terminal-mac-screenshot.png` - macOSターミナルのスクリーンショット
2. `terminal-win-screenshot.png` - Windows PowerShellのスクリーンショット
3. `git-branch-diagram.png` - ブランチの図解
4. `github-issues-board.png` - GitHub issueボードのスクリーンショット
5. `github-pr-flow.png` - プルリクエストフローの図解

---

## ✅ 完了チェックリスト

### Phase 1（即日）
- [ ] session-1-basics.html 行111修正
- [ ] session-1-basics.html 行119修正
- [ ] session-1-basics.html 行123修正
- [ ] session-1-basics.html 行127修正
- [ ] session-1-basics.html 行135修正
- [ ] session-1-basics.html 行139修正
- [ ] session-3-advanced.html 行110修正
- [ ] ブラウザで表示確認（ハードリロード）

### Phase 2（1週間）
- [ ] 5.5章「GitHub超入門」挿入
- [ ] 6章冒頭に難易度注意書き挿入
- [ ] 画像ファイル準備（5枚）
- [ ] 6章に図解追加（3箇所）
- [ ] ハンズオン所要時間明記（H1, H2, H3, H6）
- [ ] ブラウザで表示確認

### Phase 3（2週間）
- [ ] 0章にターミナル説明追加
- [ ] 0章にエラー対処法追加
- [ ] 3章に実例追加（最低3箇所）
- [ ] 7章にブランチ図解追加
- [ ] 7章にissue図解追加
- [ ] 7章にPR図解追加
- [ ] ブラウザで表示確認

### Phase 4（1ヶ月）
- [ ] 7章分割（新7章・新8章）
- [ ] 章番号繰り下げ（8章以降）
- [ ] Quick Links更新（全ファイル）
- [ ] 息抜きハンズオン追加（9.5章）
- [ ] 11章座学簡潔化
- [ ] ブラウザで表示確認
- [ ] 全章通読テスト

---

**作成者**: Claude Code
**最終更新**: 2025-10-12
**承認待ち**: Phase 1の即時実装
