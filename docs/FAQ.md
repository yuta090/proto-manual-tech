# よくある質問（FAQ）

## 📋 目次
- [セットアップ全般](#セットアップ全般)
- [Windows環境](#windows環境)
- [macOS環境](#macos環境)
- [ツール別の質問](#ツール別の質問)
- [トラブルシューティング](#トラブルシューティング)

---

## セットアップ全般

### Q1. このマニュアルは初心者でも使えますか？
**A:** はい、プログラミング初心者を想定して作成されています。0章の自動セットアップスクリプトを実行すれば、必要なツールが自動でインストールされます。

### Q2. セットアップにどのくらい時間がかかりますか？
**A:** 環境や回線速度にもよりますが、通常30分〜1時間程度です。
- スクリプト実行: 20-40分
- アカウント作成・認証: 10-20分

### Q3. インストール中にエラーが出た場合はどうすればいいですか？
**A:** 以下の順序で対処してください：
1. エラーメッセージをよく読む
2. スクリプトを再実行する（既にインストール済みのツールはスキップされます）
3. それでも解決しない場合は、該当ツールの公式ドキュメントを確認
4. 状態ファイル（`.install_progress.json`）を削除して最初からやり直す

### Q4. 有料サービスはどれが必須ですか？
**A:** 以下が必須です：
- **Claude Pro** ($20/月) - AI開発アシスタント
- **Cursor** ($20/月) - 統合開発環境（2週間無料トライアルあり）

その他のサービス（GitHub, Netlify, Supabase, Resend）は無料プランで十分です。

---

## Windows環境

### Q5. Windows に PowerShell は最初から入っていますか？
**A:** はい、Windows 10/11 には PowerShell 5.1 が標準でインストールされています。

**確認方法:**
1. スタートメニューで「PowerShell」と検索
2. 「Windows PowerShell」が表示されればOK

**バージョン確認:**
```powershell
$PSVersionTable.PSVersion
```

### Q6. PowerShell で「このスクリプトの実行は無効になっています」と表示されます
**A:** 実行ポリシーを変更する必要があります。

**解決方法:**
1. PowerShell を**管理者権限**で起動
2. 以下のコマンドを実行：
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```
3. 確認メッセージで「Y」を入力

### Q6-1. PowerShell の管理者権限での起動方法がわかりません
**A:** 以下の手順で PowerShell を管理者権限で起動できます。

**手順:**
1. **Windowsキー**を押す
2. 「PowerShell」と入力して検索
3. 検索結果の「Windows PowerShell」を**右クリック**
4. メニューから「**管理者として実行**」を選択
5. ユーザーアカウント制御（UAC）のダイアログが表示されたら「はい」をクリック

**確認方法:**
- ウィンドウのタイトルバーに「**管理者: Windows PowerShell**」と表示されていればOK

**重要:** スクリプトファイルをダブルクリックしても管理者権限では起動しません。必ず上記の手順で起動してください。

### Q7. winget が見つからないエラーが出ます
**A:** Windows 10/11 でも winget がインストールされていない場合があります。

**解決方法:**
1. Microsoft Store を開く
2. 「アプリ インストーラー」を検索してインストール
3. PowerShell を再起動

または、スクリプトが自動的に Microsoft Store を開くので、そこからインストールしてください。

### Q8. Windows 11 でないと動きませんか？
**A:** いいえ、Windows 10（バージョン 1809以降）でも動作します。ただし、一部機能は Windows 11 の方が安定しています。

---

## macOS環境

### Q9. macOS のバージョンはどれが必要ですか？
**A:** macOS 12 (Monterey) 以降を推奨します。それ以前のバージョンでも動作する可能性はありますが、サポート対象外です。

### Q10. Homebrew がインストールされていないとダメですか？
**A:** いいえ、スクリプトが自動的に Homebrew をインストールします。既にインストール済みの場合はスキップされます。

### Q11. Apple Silicon (M1/M2/M3) Mac でも動作しますか？
**A:** はい、完全対応しています。スクリプトが自動的に Apple Silicon 用の設定を行います。

### Q12. ターミナルで「許可がありません」と表示されます
**A:** スクリプトに実行権限を付与する必要があります。

**解決方法:**
```bash
chmod +x install-ai-dev-tools-mac.sh
./install-ai-dev-tools-mac.sh
```

---

## ツール別の質問

### Q13. Claude Code と Cursor の違いは何ですか？
**A:**
- **Claude Code**: コマンドライン（ターミナル）で動作するAIアシスタント
- **Cursor**: VSCode ベースの統合開発環境（IDE）でAI機能が統合されている

両方を組み合わせて使うことで、最大限の効果が得られます。

### Q14. GitHub アカウントは必須ですか？
**A:** はい、以下の理由で必須です：
- コードのバージョン管理
- Netlify との連携（自動デプロイ）
- Supabase のアカウント作成時に使用（推奨）

### Q15. Netlify と Supabase は何に使いますか？
**A:**
- **Netlify**: Webアプリケーションの自動デプロイ・ホスティング
- **Supabase**: データベース（PostgreSQL）とバックエンド機能

### Q16. Super Claude って何ですか？
**A:** Claude Code を拡張するフレームワークで、以下の機能を追加します：
- `/sc:` で始まるカスタムコマンド
- MCP (Model Context Protocol) サーバーの管理
- プロジェクトメモリ機能

### Q17. MCP サーバーって何ですか？
**A:** Claude Code の機能を拡張するプラグインのようなものです。例：
- **Context7**: ライブラリドキュメントの検索
- **Sequential Thinking**: 複雑な推論
- **Playwright**: ブラウザ自動テスト
- **Serena**: プロジェクトメモリ管理

---

## トラブルシューティング

### Q18. インストールが途中で止まってしまいます
**A:** 以下を確認してください：
1. インターネット接続が安定しているか
2. ディスク容量が十分にあるか（最低10GB推奨）
3. ウイルス対策ソフトがインストールをブロックしていないか

**解決策:**
- Ctrl+C（Windows）または Command+C（Mac）でスクリプトを中断
- スクリプトを再実行（進捗は保存されています）

### Q19. 「認証に失敗しました」と表示されます
**A:** 各サービスの認証手順を確認してください：

**GitHub CLI:**
```bash
gh auth login
```
ブラウザで認証コードを入力

**Netlify CLI:**
```bash
netlify login
```
ブラウザで認証

**Supabase CLI:**
```bash
npx supabase login
```
アクセストークンを入力

### Q20. Claude Code で「Claude Pro アカウントが必要です」と表示されます
**A:** Claude Code を使用するには Claude Pro サブスクリプション（$20/月）が必要です。

**サブスクリプション開始方法:**
1. https://claude.ai/ にアクセス
2. ログイン後、アップグレードボタンをクリック
3. クレジットカードで支払い手続き

### Q21. `command not found` エラーが出ます
**A:** ツールのインストール後、PATH が更新されていない可能性があります。

**解決方法:**
- **Windows**: PowerShell を再起動
- **macOS**: ターミナルを再起動、または以下を実行：
```bash
source ~/.zshrc
# または
source ~/.bash_profile
```

### Q22. Cursor が起動しません
**A:** 以下を試してください：
1. アプリケーションを完全に終了して再起動
2. macOS の場合: セキュリティとプライバシー設定で許可
3. 再インストール:
   ```bash
   # macOS
   brew reinstall --cask cursor

   # Windows
   winget uninstall Cursor
   winget install --id anysphere.cursor
   ```

### Q23. Python や Node.js が見つからないエラーが出ます
**A:** インストール後に PATH が反映されていない可能性があります。

**解決方法:**
1. ターミナル/PowerShell を再起動
2. それでもダメな場合：
   ```bash
   # macOS
   which python3
   which node

   # Windows
   where python
   where node
   ```
   コマンドでインストール場所を確認

### Q24. Git のコミットで「Author identity unknown」エラーが出ます
**A:** Git の初期設定が必要です。

**解決方法:**
```bash
git config --global user.name "あなたの名前"
git config --global user.email "your.email@example.com"
```

### Q25. Playwright のブラウザダウンロードが失敗します
**A:** ネットワークやディスク容量の問題が考えられます。

**解決方法:**
```bash
# 再試行
npx playwright install

# 特定のブラウザのみインストール
npx playwright install chromium
```

---

## セキュリティとプライバシー

### Q26. このスクリプトは安全ですか？
**A:** はい、以下の理由で安全です：
- オープンソースで内容を確認できる
- 公式のインストールコマンドのみを使用
- 個人情報を外部に送信しない
- 認証情報はローカルに保存

### Q27. API キーや認証情報はどこに保存されますか？
**A:** 各ツールが標準的な場所に保存します：
- **macOS**: `~/.config/`, `~/.netrc`, `~/Library/Application Support/`
- **Windows**: `%APPDATA%`, `%USERPROFILE%\.config\`

これらのファイルは暗号化されているか、アクセス権限が制限されています。

---

## その他

### Q28. 状態ファイル（.install_progress.json）は削除してもいいですか？
**A:** 削除すると、次回スクリプト実行時に全てのツールが再インストールされます。インストール済みのツールに問題がある場合のみ削除してください。

### Q29. アンインストールしたい場合は？
**A:** 各ツールのアンインストール方法：

**Windows:**
```powershell
winget uninstall <ツール名>
npm uninstall -g <パッケージ名>
```

**macOS:**
```bash
brew uninstall <ツール名>
npm uninstall -g <パッケージ名>
pipx uninstall <パッケージ名>
```

### Q30. SuperClaude をインストールしたのに、Claude Code で `/sc:` コマンドが表示されません
**A:** SuperClaude の統合処理（Claude Code への登録）が実行されていない可能性があります。

**手動で統合処理を実行:**
```bash
# Windows (PowerShell)
SuperClaude install --force --yes

# macOS / Linux
SuperClaude install --force --yes
```

**確認方法:**
1. Claude Code を起動: `claude`
2. `/` を入力すると `/sc:` で始まるコマンドが表示されるはず

**それでもダメな場合:**
1. PowerShell/ターミナルを再起動
2. 再度 `SuperClaude install --force --yes` を実行
3. Claude Code を再起動

### Q31. このマニュアルの最新版はどこで入手できますか？
**A:** 現在は配布時点のバージョンが最新です。将来的には GitHub リポジトリで公開予定です。

---

## お問い合わせ

上記で解決しない問題や、追加の質問がある場合は、以下の方法でお問い合わせください：

1. **マニュアル内の該当章を再確認**
2. **公式ドキュメントを参照**:
   - Claude Code: https://docs.claude.com/ja/docs/claude-code/setup
   - Cursor: https://cursor.sh/docs
   - GitHub CLI: https://cli.github.com/manual/
3. **エラーメッセージをそのまま検索**（多くの場合、解決策が見つかります）

---

**最終更新**: 2025-10-14
