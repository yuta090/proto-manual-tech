## **6. AIと作ろう！"あなただけ"のオリジナルWebアプリ開発**

---

### 6.1 ハンズオンの準備：旅の始まり

Super Claudeを活用して、あなた自身のアイデアを基にしたオリジナルWebアプリを開発します。

**必要なもの:**
- Claude CodeとSuper Claude（4章まででインストール済み）
- 漠然としたアイデア（例：「読んだ本を記録するアプリ」「献立提案アプリ」）

**Step 1: プロジェクトフォルダの作成**

```bash
# アプリ名は好きな名前に変更
mkdir my-first-app
cd my-first-app
```

### 6.2 Step 2: アイデアの壁打ち - `brainstorm`コマンドで要件定義

漠然としたアイデアを、AIとの対話で具体的な機能に落とし込みます。

**コマンドフローチャート:** 新規開発 → **アイデアがある** → `/sc:brainstorm`

**手順:**
1. **AIにアイデアを投げかける** - Super Claudeが質問を投げかけてきます
2. **AIと対話を深める** - 必要な機能や技術的考慮事項を明確化
3. **要件定義の完成** - AIがやり取りをまとめて要件定義を生成

### 6.3 Step 3: 設計図の作成 - `design`コマンドでアーキテクチャとUI/UXを具体化

要件を基に、具体的な設計図を作成します。

**コマンドフローチャート:** 新規開発 → **設計が必要** → `/sc:design`

**手順:**
1. **設計をAIに依頼** - 技術スタック、画面構成、データ構造をAIが提案
2. **設計図のレビューと調整** - 必要に応じて対話形式で修正

### 6.4 Step 4: 実装計画 - `workflow`コマンドでタスクを明確化

開発順序を計画し、タスクリストを作成します。

**コマンドフローチャート:** 新規開発 → **計画を立てる** → `/sc:workflow`

**手順:**
1. **開発計画の作成を依頼**
2. **タスクリストの確認と調整**
3. **タスクリストをファイルとして保存** - セッションが切れても参照できるように

以下のプロンプトでファイル保存を依頼：
```
個人での開発なので、issueは使わずに、タスクリストをドキュメントとして保存し、セッションが切れても参照できるようにしてください。
```

AIが `tasks.md` や `TODO.md` を作成し、進捗管理が可能になります。

### 6.5 Step 5: コーディング開始 - `implement`コマンドでコードを生成

タスクリストに従って、AIに実際のコードを書いてもらいます。

**コマンドフローチャート:** 新規開発 → **実装する** → `/sc:implement`

**手順:**
1. **タスクを指定して実装を依頼** - タスクを一つずつ`implement`コマンドで依頼
2. **コードの生成と確認** - 生成されたファイルを確認、必要に応じて修正
3. **動作確認とE2Eテスト（2段階の品質保証）:**

#### ステップ1: 目視確認（手動テスト）
`index.html`をブラウザで開いて、以下を確認：
- 見た目が正しく表示されているか
- ボタンやフォームが動作するか
- データが保存・表示されるか

#### ステップ2: E2Eテスト（自動テスト）
AIが自動でユーザー操作をシミュレーションしてテストします。

以下のプロンプトで実行：
```
/sc:test 今作成した内容をe2eテストしたい。問題なければタスク完了。次のタスクへ
```

**テスト失敗時の対処:**
1. エラーメッセージを確認
2. AIに修正を依頼
3. 再度テスト

**2段階チェックの理由:**
- 目視確認：見た目の違和感や使いづらさを発見
- E2Eテスト：細かいバグを自動で発見、何度でも実行可能

### 6.6 Step 6: 問題解決と改善 - `troubleshoot`, `analyze`, `improve`コマンド

開発中のエラーやコード改善に対応するコマンド：

- **`troubleshoot`** - エラー発生時、AIが原因を特定し解決策を提案
- **`improve`** - コード品質向上、可読性改善（`--type quality`オプション使用可）
- **`analyze`** - パフォーマンス分析、ボトルネック特定（`--focus performance`オプション使用可）

---

### 6.7 実践プロジェクト：営業日報自動生成アプリを開発しよう！

Super Claudeの全コマンドを連携させ、実践的なWebアプリケーションを開発します。

**プロジェクト概要:**
- **アプリ名**: Daily Reporter
- **主要機能**: 日報の入力・一覧表示・検索・週報自動生成
- **技術スタック（Phase 1）**: HTML/CSS/JavaScript、localStorage

**TODOアプリより優れている理由:**
✅ 実務で使われている業務、ポートフォリオとして強力
✅ 段階的に本格化可能、学習要素が豊富

---

#### Step 1: アイデアの壁打ちと要件定義 (`brainstorm`)

```bash
mkdir daily-reporter && cd daily-reporter && claude
/sc:brainstorm "営業日報を簡単に作成・管理できるアプリ"
```

AIとの対話で要件を明確化：訪問日時、訪問先、商談内容、次回アクション、案件ステータスなど

---

#### Step 2: 設計図の作成 (`design`)

```bash
/sc:design "営業日報アプリの設計"
```

AIがデータ構造、UI構成、基本機能を提案します。

---

#### Step 3: 実装計画の策定 (`workflow`)

```bash
/sc:workflow "営業日報アプリの実装計画"
```

タスクリスト例：HTML構造作成 → フォーム実装 → localStorage保存 → 一覧表示 → 編集/削除 → 検索 → 週報生成

**タスクリストをファイル保存:**
```
個人での開発なので、issueは使わずに、タスクリストをドキュメントとして保存し、セッションが切れても参照できるようにしてください。
```

---

#### Step 4: コーディング開始 (`implement`)

```bash
/sc:implement "営業日報アプリの基本的なHTML構造とCSSスタイル。モダンでプロフェッショナルなデザインにしてください"
/sc:implement "日報入力フォーム（訪問日時、訪問先企業名、商談内容、次回アクション、案件ステータス選択）を実装してください"
/sc:implement "JavaScriptでlocalStorageにデータを保存・取得する機能を実装してください"
/sc:implement "localStorageから日報を取得し、カード形式で一覧表示する機能を実装してください"
```

---

#### Step 5: 動作確認とテスト

1. `index.html`をブラウザで開き、テストデータを入力
2. 保存→一覧表示→リロード後もデータが残ることを確認
3. E2Eテスト実行: `/sc:test 今作成した内容をe2eテストしたい。問題なければタスク完了。次のタスクへ`

---

#### 🎉 Phase 1 完成！

ここまでで、**localStorageを使った個人用の営業日報アプリ**が完成しました。このアプリは以下の機能を持っています：

✅ 日報の入力と保存
✅ 日報の一覧表示
✅ ブラウザを閉じてもデータが残る
✅ 基本的な検索・フィルタリング
✅ 週報の自動生成

---

#### 📚 アプリをさらに進化させる：機能追加の実践例

Phase 1のアプリができたら、以下のような機能を追加して、より実用的なアプリに進化させましょう。AIに具体的な指示を出すことで、段階的に機能を拡張できます。

<details style="background: linear-gradient(135deg, rgba(16, 185, 129, 0.1) 0%, rgba(5, 150, 105, 0.05) 100%); border: 1px solid rgba(16, 185, 129, 0.3); border-radius: 12px; padding: 20px; margin: 20px 0; cursor: pointer;">
  <summary style="font-weight: bold; color: #065f46; font-size: 1.15em; cursor: pointer; list-style: none; display: flex; align-items: center;">
    <span style="display: inline-block; margin-right: 8px; transition: transform 0.2s;">▶</span>
    <span>🎨 機能追加例1：日報の編集機能を追加する</span>
  </summary>

  <div style="margin-top: 20px; padding: 16px; background: rgba(255, 255, 255, 0.5); border-radius: 8px;">
    <p style="margin: 0 0 16px 0; color: #4b5563; line-height: 1.7;">
      一度作成した日報を後から修正できるようにしましょう。
    </p>

    <pre style="background: #1e293b; color: #e2e8f0; padding: 16px; border-radius: 8px; margin: 12px 0; overflow-x: auto;"><code>各日報カードに「編集」ボタンを追加して、クリックすると入力フォームにデータが読み込まれ、修正後に保存できるようにしてください。</code></pre>

    <p style="margin: 12px 0; color: #065f46; font-weight: 600;">
      → AIが編集ボタンとデータ読み込みロジックを自動生成してくれます！
    </p>
  </div>
</details>

<details style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1) 0%, rgba(217, 119, 6, 0.05) 100%); border: 1px solid rgba(245, 158, 11, 0.3); border-radius: 12px; padding: 20px; margin: 20px 0; cursor: pointer;">
  <summary style="font-weight: bold; color: #92400e; font-size: 1.15em; cursor: pointer; list-style: none; display: flex; align-items: center;">
    <span style="display: inline-block; margin-right: 8px; transition: transform 0.2s;">▶</span>
    <span>🔍 機能追加例2：高度な検索・フィルタリング機能</span>
  </summary>

  <div style="margin-top: 20px; padding: 16px; background: rgba(255, 255, 255, 0.5); border-radius: 8px;">
    <p style="margin: 0 0 16px 0; color: #4b5563; line-height: 1.7;">
      日付範囲やステータスで日報を絞り込めるようにします。
    </p>

    <pre style="background: #1e293b; color: #e2e8f0; padding: 16px; border-radius: 8px; margin: 12px 0; overflow-x: auto;"><code>日報一覧の上に検索バーを追加してください。開始日と終了日を選択できる日付範囲フィルター、企業名での部分一致検索、ステータス（初回訪問/提案中/受注/失注）でのフィルタリング機能を実装してください。</code></pre>

    <p style="margin: 12px 0; color: #92400e; font-weight: 600;">
      → 複数の条件を組み合わせた高度な検索機能が追加されます！
    </p>
  </div>
</details>

<details style="background: linear-gradient(135deg, rgba(99, 102, 241, 0.1) 0%, rgba(79, 70, 229, 0.05) 100%); border: 1px solid rgba(99, 102, 241, 0.3); border-radius: 12px; padding: 20px; margin: 20px 0; cursor: pointer;">
  <summary style="font-weight: bold; color: #4338ca; font-size: 1.15em; cursor: pointer; list-style: none; display: flex; align-items: center;">
    <span style="display: inline-block; margin-right: 8px; transition: transform 0.2s;">▶</span>
    <span>📊 機能追加例3：ダッシュボードと統計機能</span>
  </summary>

  <div style="margin-top: 20px; padding: 16px; background: rgba(255, 255, 255, 0.5); border-radius: 8px;">
    <p style="margin: 0 0 16px 0; color: #4b5563; line-height: 1.7;">
      活動状況を一目で把握できるダッシュボードを追加します。
    </p>

    <pre style="background: #1e293b; color: #e2e8f0; padding: 16px; border-radius: 8px; margin: 12px 0; overflow-x: auto;"><code>ダッシュボード画面を作成してください。今月の訪問件数、案件ステータス別の件数（初回訪問・提案中・受注・失注）をカウントして表示してください。できれば簡単な棒グラフも表示したいです。</code></pre>

    <p style="margin: 12px 0; color: #4338ca; font-weight: 600;">
      → Chart.jsなどを使った視覚的なダッシュボードが作成されます！
    </p>
  </div>
</details>

<details style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1) 0%, rgba(220, 38, 38, 0.05) 100%); border: 1px solid rgba(239, 68, 68, 0.3); border-radius: 12px; padding: 20px; margin: 20px 0; cursor: pointer;">
  <summary style="font-weight: bold; color: #991b1b; font-size: 1.15em; cursor: pointer; list-style: none; display: flex; align-items: center;">
    <span style="display: inline-block; margin-right: 8px; transition: transform 0.2s;">▶</span>
    <span>📄 機能追加例4：週報・月報のPDFエクスポート機能</span>
  </summary>

  <div style="margin-top: 20px; padding: 16px; background: rgba(255, 255, 255, 0.5); border-radius: 8px;">
    <p style="margin: 0 0 16px 0; color: #4b5563; line-height: 1.7;">
      指定した期間の日報をまとめてレポート化し、PDFで保存できるようにします。
    </p>

    <pre style="background: #1e293b; color: #e2e8f0; padding: 16px; border-radius: 8px; margin: 12px 0; overflow-x: auto;"><code>週報生成機能を実装してください。開始日と終了日を指定すると、その期間の全日報を整形してPDFでダウンロードできるようにしてください。レポートには期間の合計訪問件数、ステータス別サマリー、各日報の詳細を含めてください。</code></pre>

    <p style="margin: 12px 0; color: #991b1b; font-weight: 600;">
      → jsPDFなどを使った自動レポート生成機能が追加されます！
    </p>
  </div>
</details>

<details style="background: linear-gradient(135deg, rgba(168, 85, 247, 0.1) 0%, rgba(147, 51, 234, 0.05) 100%); border: 1px solid rgba(168, 85, 247, 0.3); border-radius: 12px; padding: 20px; margin: 20px 0; cursor: pointer;">
  <summary style="font-weight: bold; color: #6b21a8; font-size: 1.15em; cursor: pointer; list-style: none; display: flex; align-items: center;">
    <span style="display: inline-block; margin-right: 8px; transition: transform 0.2s;">▶</span>
    <span>📱 機能追加例5：モバイル対応とPWA化</span>
  </summary>

  <div style="margin-top: 20px; padding: 16px; background: rgba(255, 255, 255, 0.5); border-radius: 8px;">
    <p style="margin: 0 0 16px 0; color: #4b5563; line-height: 1.7;">
      スマートフォンでも快適に使えるようにし、アプリとしてインストール可能にします。
    </p>

    <pre style="background: #1e293b; color: #e2e8f0; padding: 16px; border-radius: 8px; margin: 12px 0; overflow-x: auto;"><code>このアプリをスマートフォンでも使いやすくしたいです。レスポンシブデザインを適用して、画面幅が狭くてもレイアウトが崩れないようにしてください。さらに、PWA（Progressive Web App）として動作するように、manifest.jsonとService Workerを追加してホーム画面に追加できるようにしてください。</code></pre>

    <p style="margin: 12px 0; color: #6b21a8; font-weight: 600;">
      → スマホアプリのように使えるPWA対応のアプリに進化します！
    </p>
  </div>
</details>

<details style="background: linear-gradient(135deg, rgba(20, 184, 166, 0.1) 0%, rgba(13, 148, 136, 0.05) 100%); border: 1px solid rgba(20, 184, 166, 0.3); border-radius: 12px; padding: 20px; margin: 20px 0; cursor: pointer;">
  <summary style="font-weight: bold; color: #115e59; font-size: 1.15em; cursor: pointer; list-style: none; display: flex; align-items: center;">
    <span style="display: inline-block; margin-right: 8px; transition: transform 0.2s;">▶</span>
    <span>🏷️ 機能追加例6：タグ機能とカテゴリ分類</span>
  </summary>

  <div style="margin-top: 20px; padding: 16px; background: rgba(255, 255, 255, 0.5); border-radius: 8px;">
    <p style="margin: 0 0 16px 0; color: #4b5563; line-height: 1.7;">
      日報に自由にタグを付けて、後から柔軟に分類・検索できるようにします。
    </p>

    <pre style="background: #1e293b; color: #e2e8f0; padding: 16px; border-radius: 8px; margin: 12px 0; overflow-x: auto;"><code>日報フォームにタグ入力欄を追加してください。カンマ区切りで複数のタグ（例: 新規案件, 緊急, 大口）を入力できるようにし、日報一覧ではタグをクリックして同じタグの日報を絞り込めるようにしてください。</code></pre>

    <p style="margin: 12px 0; color: #115e59; font-weight: 600;">
      → 柔軟なタグ管理システムが追加され、整理がさらに便利に！
    </p>
  </div>
</details>

---

<details style="background: linear-gradient(135deg, rgba(79, 70, 229, 0.1) 0%, rgba(99, 102, 241, 0.05) 100%); border: 1px solid rgba(99, 102, 241, 0.3); border-radius: 12px; padding: 20px; margin: 20px 0; cursor: pointer;">
  <summary style="font-weight: bold; color: #4f46e5; font-size: 1.15em; cursor: pointer; list-style: none; display: flex; align-items: center;">
    <span style="display: inline-block; margin-right: 8px; transition: transform 0.2s;">▶</span>
    <span>🚀 Phase 2: Supabaseで本格的なアプリに進化させよう！（発展編）</span>
  </summary>

  <div style="margin-top: 20px; padding: 16px; background: rgba(255, 255, 255, 0.5); border-radius: 8px;">
    <p style="margin: 0 0 16px 0; color: #4b5563; line-height: 1.7;">
      Phase 1で作成したアプリを、**チームで使える本格的なWebアプリケーション**に進化させましょう。Supabaseを使うことで、以下のような機能が追加できます：
    </p>

    <ul style="color: #374151; line-height: 1.8; margin: 16px 0;">
      <li>✅ <strong>複数人での利用</strong> - チームメンバー全員で日報を共有</li>
      <li>✅ <strong>どこからでもアクセス</strong> - インターネット経由でどのデバイスからでもアクセス可能</li>
      <li>✅ <strong>ユーザー認証</strong> - メールアドレスでのログイン機能</li>
      <li>✅ <strong>データの永続化</strong> - ブラウザキャッシュに依存しない安全なデータ保存</li>
    </ul>

    <h4 style="color: #4f46e5; margin: 24px 0 12px 0;">📦 Supabaseプロジェクトの作成</h4>

    <p style="margin: 12px 0; color: #4b5563; line-height: 1.7;">
      まずは、Supabase CLIを使ってローカル開発環境を準備しましょう。すでに第4章でSupabase CLIはインストール済みのはずです。
    </p>

    <pre style="background: #1e293b; color: #e2e8f0; padding: 16px; border-radius: 8px; margin: 12px 0; overflow-x: auto;"><code># プロジェクトフォルダ内で実行
supabase init

# ローカルSupabase環境を起動（Dockerが必要）
supabase start</code></pre>

    <p style="margin: 12px 0; color: #4b5563; line-height: 1.7;">
      <code>supabase start</code>を実行すると、以下のような接続情報が表示されます：
    </p>

    <pre style="background: #1e293b; color: #e2e8f0; padding: 16px; border-radius: 8px; margin: 12px 0; overflow-x: auto;"><code>API URL: http://localhost:54321
DB URL: postgresql://postgres:postgres@localhost:54322/postgres
anon key: eyJh...</code></pre>

    <h4 style="color: #4f46e5; margin: 24px 0 12px 0;">🗄️ データベーステーブルの作成</h4>

    <p style="margin: 12px 0; color: #4b5563; line-height: 1.7;">
      AIにSupabase用のテーブル設計をお願いしましょう：
    </p>

    <pre style="background: #1e293b; color: #e2e8f0; padding: 16px; border-radius: 8px; margin: 12px 0; overflow-x: auto;"><code>/sc:implement "Supabaseで営業日報テーブル（daily_reports）を作成するマイグレーションファイルを生成してください。カラムは id, created_at, date, company, content, next_action, status を含めてください"</code></pre>

    <p style="margin: 12px 0; color: #4b5563; line-height: 1.7;">
      AIが <code>supabase/migrations/xxxxx_create_daily_reports.sql</code> というファイルを生成してくれます。マイグレーションを適用：
    </p>

    <pre style="background: #1e293b; color: #e2e8f0; padding: 16px; border-radius: 8px; margin: 12px 0; overflow-x: auto;"><code># マイグレーション適用
supabase db reset</code></pre>

    <h4 style="color: #4f46e5; margin: 24px 0 12px 0;">🔄 localStorageからSupabaseへの移行</h4>

    <p style="margin: 12px 0; color: #4b5563; line-height: 1.7;">
      既存のlocalStorage版のコードをSupabase版に書き換えます：
    </p>

    <pre style="background: #1e293b; color: #e2e8f0; padding: 16px; border-radius: 8px; margin: 12px 0; overflow-x: auto;"><code>/sc:improve "現在のlocalStorageでのデータ保存をSupabaseに置き換えてください。Supabase JavaScriptクライアントを使用してください。既存のlocalStorageデータをSupabaseにインポートする機能も追加してください"</code></pre>

    <h4 style="color: #4f46e5; margin: 24px 0 12px 0;">🌐 本番環境へのデプロイ</h4>

    <p style="margin: 12px 0; color: #4b5563; line-height: 1.7;">
      ローカルで動作確認できたら、本番環境にデプロイしましょう：
    </p>

    <pre style="background: #1e293b; color: #e2e8f0; padding: 16px; border-radius: 8px; margin: 12px 0; overflow-x: auto;"><code># Supabaseにログイン
supabase login

# 本番プロジェクト作成
supabase projects create daily-reporter \
  --org-id <your-org-id> \
  --db-password <secure-password> \
  --region ap-northeast-1

# ローカルと本番をリンク
supabase link --project-ref <project-ref>

# マイグレーションを本番にプッシュ
supabase db push</code></pre>

    <p style="margin: 12px 0; color: #4b5563; line-height: 1.7;">
      フロントエンドはNetlifyにデプロイ：
    </p>

    <pre style="background: #1e293b; color: #e2e8f0; padding: 16px; border-radius: 8px; margin: 12px 0; overflow-x: auto;"><code># Netlifyにログイン
netlify login

# 本番デプロイ
netlify deploy --prod</code></pre>

    <div style="background: linear-gradient(135deg, rgba(16, 185, 129, 0.1) 0%, rgba(5, 150, 105, 0.05) 100%); border-left: 4px solid #10b981; padding: 16px; margin: 20px 0; border-radius: 8px;">
      <p style="margin: 0; color: #065f46; font-weight: 600; line-height: 1.8;">
        🎉 <strong>完成！</strong> これで、チーム全員がインターネット経由でアクセスできる本格的な営業日報アプリが完成しました。URLをチームメンバーに共有して、実際の業務で使ってみましょう！
      </p>
    </div>

    <h4 style="color: #4f46e5; margin: 24px 0 12px 0;">📚 さらなる拡張アイデア</h4>

    <ul style="color: #374151; line-height: 1.8; margin: 16px 0;">
      <li>🔐 <strong>ユーザー認証</strong> - Supabase Authで各営業担当者がログイン</li>
      <li>📊 <strong>チームダッシュボード</strong> - チーム全体の活動状況を可視化</li>
      <li>📧 <strong>メール通知</strong> - 週報を自動でメール送信</li>
      <li>📱 <strong>モバイルアプリ化</strong> - React NativeやFlutterでネイティブアプリに</li>
      <li>🤖 <strong>AI要約機能</strong> - Claude APIで商談内容を自動要約</li>
    </ul>

  </div>
</details>

---

### まとめ

おめでとうございます！ あなたは今、AIを相棒にして、**実務で使える本格的なアプリケーション**を開発しました。この章で体験したように、`brainstorm`でアイデアを形にし、`design`で設計を固め、`workflow`で計画を立て、`implement`で実現する、というサイクルを回すことで、どんなアイデアもプログラムにすることができます。

Phase 1で作成したlocalStorage版でも十分実用的ですし、Phase 2のSupabase版に進化させれば、チーム全体で活用できる業務アプリになります。さらに、機能追加の実践例を参考に、あなた独自の機能を追加していくことで、より強力なツールに成長させることができます。

この楽しさを忘れずに、次の章でさらなるステップアップを目指しましょう！

---

---
