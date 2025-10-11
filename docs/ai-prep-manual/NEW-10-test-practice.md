# 10章: テストを書く

⏱️ **所要時間**: 実践45分

## 📋 この章の目標

- [ ] 実際にテストコードを生成できる
- [ ] テストを実行して結果を確認できる
- [ ] テスト駆動で開発する感覚を掴む

---

## 🎯 今回やること

経費精算アプリに **テストコードを追加** します。

### 追加するテスト
1. 金額計算のテスト（ユニットテスト）
2. 経費追加機能のテスト（統合テスト）
3. localStorage保存のテスト
4. エラーハンドリングのテスト

---

## 🚀 ハンズオン（45分）

### ステップ1: テスト環境のセットアップ（8分）

```bash
cd expense-tracker
claude
```

テスト環境をセットアップします：

```
💬 「このプロジェクトにJestを使ったテスト環境をセットアップしてください。

必要なもの:
- package.json作成
- Jestインストール
- テスト用のHTMLファイル（jest.config.js）
- テスト実行コマンド設定

ブラウザ環境のテストなので、jest-environmentはjsdomを使用してください。」
```

**Claude Codeがやること**:
1. `package.json` を作成
2. Jest設定ファイルを作成
3. テスト実行スクリプトを設定

**確認**:
```bash
npm install
npm test
```

### ステップ2: 金額計算のテスト（10分）

まず、テスト対象のコードを確認します：

```javascript
// 経費の合計を計算する関数
function calculateTotal(expenses) {
  return expenses.reduce((sum, exp) => sum + exp.amount, 0);
}
```

テストを生成:

```
💬 「calculateTotal関数のテストコードを書いてください。

テストファイル名: calculate.test.js

テストケース:
1. 正常ケース: 複数の経費の合計が正しく計算される
2. 空配列: 0が返される
3. 1件のみ: その金額が返される
4. 負の金額を含む: 正しく計算される（返金のケース）
5. 小数点を含む: 四捨五入される

各テストケースで複数のアサーションを書いてください。」
```

**生成されるテスト例**:
```javascript
// calculate.test.js
describe('calculateTotal', () => {
  test('複数の経費の合計を計算', () => {
    const expenses = [
      { amount: 1000 },
      { amount: 2000 },
      { amount: 3000 }
    ];
    expect(calculateTotal(expenses)).toBe(6000);
  });

  test('空配列は0を返す', () => {
    expect(calculateTotal([])).toBe(0);
  });

  test('1件のみの場合', () => {
    const expenses = [{ amount: 1500 }];
    expect(calculateTotal(expenses)).toBe(1500);
  });

  test('負の金額を含む（返金）', () => {
    const expenses = [
      { amount: 1000 },
      { amount: -500 },
      { amount: 2000 }
    ];
    expect(calculateTotal(expenses)).toBe(2500);
  });
});
```

**テスト実行**:
```bash
npm test calculate.test.js
```

**結果確認**:
```
PASS  calculate.test.js
  calculateTotal
    ✓ 複数の経費の合計を計算 (3ms)
    ✓ 空配列は0を返す (1ms)
    ✓ 1件のみの場合 (1ms)
    ✓ 負の金額を含む（返金） (2ms)

Tests: 4 passed, 4 total
```

### ステップ3: 経費追加機能のテスト（12分）

より複雑な機能のテストを生成:

```
💬 「経費追加機能のテストを書いてください。

テストファイル名: addExpense.test.js

テスト対象の関数:
function addExpense(date, category, description, amount) {
  // バリデーション
  if (!date || !category || !description || !amount) {
    throw new Error('すべての項目を入力してください');
  }
  if (amount <= 0) {
    throw new Error('金額は正の数を入力してください');
  }
  if (amount > 1000000) {
    throw new Error('金額が大きすぎます');
  }

  // 経費オブジェクトを作成
  const expense = {
    id: Date.now(),
    date,
    category,
    description,
    amount: Number(amount)
  };

  // 保存
  saveExpense(expense);
  return expense;
}

テストケース:
【正常系】
1. 正しい入力で経費が追加される
2. 金額が数値に変換される

【異常系】
3. 必須項目が空の場合はエラー
4. 金額が0以下の場合はエラー
5. 金額が100万円超の場合はエラー

【境界値】
6. 金額が1円（最小値）
7. 金額が100万円（最大値）」
```

**テスト実行**:
```bash
npm test addExpense.test.js
```

### ステップ4: localStorage保存のテスト（10分）

```
💬 「localStorage保存機能のテストを書いてください。

テストファイル名: storage.test.js

テスト対象:
function saveExpenses(expenses) {
  try {
    localStorage.setItem('expenses', JSON.stringify(expenses));
    return true;
  } catch (error) {
    console.error('保存エラー:', error);
    return false;
  }
}

function loadExpenses() {
  try {
    const data = localStorage.getItem('expenses');
    return data ? JSON.parse(data) : [];
  } catch (error) {
    console.error('読み込みエラー:', error);
    return [];
  }
}

テストケース:
1. 保存と読み込みが正しく動作する
2. 複数件のデータを保存・読み込み
3. データがない場合は空配列を返す
4. 不正なJSONの場合は空配列を返す（エラーハンドリング）

各テストの前にlocalStorageをクリアしてください。」
```

**テスト実行**:
```bash
npm test storage.test.js
```

### ステップ5: テストカバレッジ確認（5分）

全テストを実行してカバレッジを確認:

```bash
npm test -- --coverage
```

**カバレッジレポート**:
```
---------------------------|---------|----------|---------|---------|
File                       | % Stmts | % Branch | % Funcs | % Lines |
---------------------------|---------|----------|---------|---------|
All files                  |   85.71 |    83.33 |   88.88 |   85.71 |
 calculate.js              |     100 |      100 |     100 |     100 |
 addExpense.js             |   91.66 |    87.50 |     100 |   91.66 |
 storage.js                |   77.77 |    75.00 |   75.00 |   77.77 |
---------------------------|---------|----------|---------|---------|
```

**カバレッジ向上**:
```
💬 「storage.jsのカバレッジが77%です。
テストされていない部分を教えてください。
その部分のテストケースを追加してください。」
```

---

## 🎯 テスト駆動開発（TDD）を体験

### TDDの流れ

```
Red（失敗） → Green（成功） → Refactor（改善）
```

**実践してみよう**:

#### ステップ1: Red（失敗するテストを書く）

```
💬 「フィルター機能のテストを先に書いてください。

テスト対象（まだ実装していない機能）:
function filterExpensesByCategory(expenses, category) {
  // カテゴリでフィルタリング
}

テストケース:
1. '交通費'でフィルター → 交通費のみ返す
2. '全て'でフィルター → 全件返す
3. 該当なし → 空配列を返す」
```

**テスト実行**:
```bash
npm test filter.test.js
```

**結果**: ❌ FAIL（関数が実装されていないため）

#### ステップ2: Green（テストが通る最小限の実装）

```
💬 「filter.test.jsのテストが通るように、
filterExpensesByCategory関数を実装してください。」
```

**テスト実行**:
```bash
npm test filter.test.js
```

**結果**: ✅ PASS

#### ステップ3: Refactor（コードを改善）

```
💬 「filterExpensesByCategory関数を、
より効率的でわかりやすいコードに改善してください。
テストが通ることを確認しながら改善してください。」
```

**テスト実行して確認**:
```bash
npm test filter.test.js
```

**結果**: ✅ PASS（動作は変わらず、コードが改善された）

---

## 💼 実務での活用

### ケース1: バグ修正時

```
状況: 「金額が正しく計算されない」バグ報告

対応手順:
1. バグを再現するテストを書く
   test('バグ: 小数点の丸め誤差', () => {
     // 現在は失敗する
   });

2. テストが失敗することを確認（Red）

3. バグを修正（Green）

4. テストが成功することを確認

5. 同じバグが二度と起きない
```

### ケース2: リファクタリング時

```
状況: コードが読みにくいので改善したい

対応手順:
1. 現在の動作をテストで記録
   test('現在の動作', () => {
     // すべてのパターンをテスト
   });

2. テストが通ることを確認

3. 安心してリファクタリング

4. テストで動作保証
```

### ケース3: チーム開発時

```
状況: 他の人がコードを変更

保護策:
1. すべての機能にテストを用意

2. Pull Request時に自動テスト実行
   → CIで npm test を実行

3. 全部通過でマージ許可

4. デグレ（機能劣化）を防止
```

---

## 📊 テストの効果測定

### 導入前 vs 導入後

| 項目 | 導入前 | 導入後 |
|------|--------|--------|
| バグ発生率 | 10件/月 | 2件/月（80%減） |
| バグ修正時間 | 2時間/件 | 30分/件 |
| リファクタリング頻度 | 年1回 | 月1回 |
| 安心感 | ⚠️ 不安 | ✅ 安心 |

### 時間投資と効果

```
テスト作成時間: +20%
バグ修正時間: -60%
手動テスト時間: -80%

総合: 開発時間 -30%短縮
```

---

## ✅ 完了チェック

この章を終えたら、以下を確認してください：

- [ ] テスト環境をセットアップできた
- [ ] ユニットテストを書けた
- [ ] 統合テストを書けた
- [ ] テストを実行して結果を確認できた
- [ ] TDDの流れを体験できた

**すべてチェックできたら、セッション2完了です！**

---

## 💡 よくある質問

**Q: テストを書くのに時間がかかる**
A: 最初は時間がかかりますが、AIが生成してくれるので従来の1/5の時間で済みます。バグ修正時間の短縮を考えれば十分ペイします。

**Q: 100%カバレッジを目指すべき？**
A: いいえ。重要な部分を80%カバーすれば十分です。UIの細かい表示ロジックなどは無理にテストしなくてOK。

**Q: テストが壊れやすい**
A: 実装の詳細ではなく、動作（what）をテストしましょう。内部実装（how）に依存しないテストを書くことが大切です。

---

## 🔗 次のステップ

次は **11章: リファクタリング技法** で、テストに守られながらコードを改善する方法を学びます！
