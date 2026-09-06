# md-search-tool

指定フォルダ(サブフォルダ含む)配下のMarkdown(`.md`)ファイルから、`#`および`##`の見出し(2階層まで)を対象にキーワード検索を行うPowerShell製CLIツールです。

詳細な要件・設計は以下を参照してください。

- 要件: `.kiro/specs/md-heading-keyword-search/requirements.md`
- 設計: `.kiro/specs/md-heading-keyword-search/design.md`
- タスク: `.kiro/specs/md-heading-keyword-search/tasks.md`

## 使い方

```powershell
pwsh ./Search-MdHeading.ps1 -Path <検索対象フォルダ> -Keyword <検索キーワード>
```

- `-Path`(必須): 検索対象フォルダのパス
- `-Keyword`(必須): 検索キーワード(大文字小文字を区別しない部分一致)

## 動作確認手順について

この開発環境ではネットワークポリシー上、PowerShell Gallery等からPesterモジュールをインストールできないため、自動テスト(Pester)はこの環境では作成・実行していません。代わりに、`fixtures/`配下のサンプルMarkdownファイルを使い、以下の実行例を`pwsh`で手動実行することでスクリプトの動作を確認します。

Pesterによる自動テストスイートの整備・実行は、ユーザーのローカルPowerShell環境で後日行うことを推奨します(`fixtures/`配下のファイルはそのままPesterテストのフィクスチャとしても再利用できます)。

### フィクスチャ構成

```
fixtures/
├── docs/
│   ├── getting-started.md   # #/##/###混在、キーワードを含む見出し・含まない見出し
│   ├── case-test.md         # 大文字小文字違いのキーワード一致確認用
│   ├── special-chars.md     # 正規表現特殊文字([, ], . 等)を含むキーワードのリテラル一致確認用
│   ├── indented.md          # 見出し前のインデント(3文字まで許容/4文字以上はコードブロック扱い)確認用
│   ├── not-markdown.txt     # .md以外の拡張子が検索対象から除外されることの確認用
│   └── guides/
│       ├── advanced.md      # サブフォルダ(1階層)の再帰探索確認用
│       └── archive/
│           └── old-notes.md # サブフォルダ(2階層)の再帰探索確認用
└── empty-folder/
    └── placeholder.txt      # .mdファイルが1件も存在しないフォルダ(要件2.3)の確認用
```

### 実行例と期待される出力

> 各タスクの実装が進むごとに、このセクションへ実行例と期待される出力を追記していきます。

#### パラメータ検証(タスク2)

```powershell
# 1. -Pathを省略 -> パラメータ不足のエラーが表示され、検索は実行されない
pwsh ./Search-MdHeading.ps1 -Keyword Search
# => Write-Error: パラメータが不足しています。-Pathを指定してください。

# 2. -Keywordを省略 -> キーワード不正のエラーが表示され、検索は実行されない
pwsh ./Search-MdHeading.ps1 -Path ./fixtures/docs
# => Write-Error: -Keywordに空の文字列は指定できません。検索キーワードを指定してください。

# 3. -Keywordに空文字列を指定 -> 2と同じエラーが表示され、検索は実行されない
pwsh ./Search-MdHeading.ps1 -Path ./fixtures/docs -Keyword ""
# => Write-Error: -Keywordに空の文字列は指定できません。検索キーワードを指定してください。

# 4. -Pathに存在しないフォルダを指定 -> パス不存在のエラーが表示され、検索は実行されない
pwsh ./Search-MdHeading.ps1 -Path ./fixtures/does-not-exist -Keyword Search
# => Write-Error: 指定されたフォルダ './fixtures/does-not-exist' が見つかりません。

# 5. 有効な入力 -> 検証を通過する(現時点ではファイル探索以降が未実装のため、出力なしで正常終了)
pwsh ./Search-MdHeading.ps1 -Path ./fixtures/docs -Keyword Search
```

> 補足: PowerShellの`[string]`型パラメータは省略時も`$null`ではなく空文字列にバインドされるため、「-Keyword未指定」と「-Keywordに空文字列を指定」は実行時には区別できず、同じエラーメッセージになります(詳細は`research.md`参照)。

#### Markdownファイル探索(タスク3)

`Get-MdFile`関数単体の動作は、スクリプトをドットソース化して直接呼び出すことで確認できます。

```powershell
# スクリプトをドットソース化(パラメータ検証を通過させるため有効な値を指定)
. ./Search-MdHeading.ps1 -Path ./fixtures/docs -Keyword Search

# 1. サブフォルダを含む再帰探索 -> 6件の.mdファイルが取得できる(.txtファイルは除外される)
@(Get-MdFile -Path "./fixtures/docs") | ForEach-Object { $_.Name }
# => advanced.md, case-test.md, getting-started.md, indented.md, old-notes.md, special-chars.md

# 2. .mdファイルが存在しないフォルダ -> 0件(空配列)
@(Get-MdFile -Path "./fixtures/empty-folder").Count
# => 0
```

> 補足: PowerShellは関数境界を越えるとパイプライン出力が「展開」されるため、`Get-MdFile`の戻り値が0件のときは`$null`に、1件のときは配列ではなく単一の値になってしまいます。呼び出し側は必ず`@(Get-MdFile ...)`のように**呼び出し時点で`@(...)`により再ラップ**し、0件・1件・複数件のいずれでも配列として扱ってください(詳細は`research.md`参照)。

#### 見出し検索・キーワード一致(タスク4)

`Find-MatchingHeading`関数単体の動作は、ドットソース化後に個々のファイルへ対して直接呼び出すことで確認できます。

```powershell
. ./Search-MdHeading.ps1 -Path ./fixtures/docs -Keyword Search

# 1. keyword=Search を複数ファイルに対して実行 -> #/##(レベル1)見出しのみが4件ヒットする(###見出しは対象外)
$files = @(Get-MdFile -Path "./fixtures/docs")
$all = @()
foreach ($f in $files) { $all += @(Find-MatchingHeading -File $f -Keyword "Search") }
$all | ForEach-Object { "[$($_.HeadingLevel)] $($_.HeadingText)  <= $(Split-Path $_.FilePath -Leaf)" }
# => [1] SEARCH in different case  <= case-test.md
# => [1] Search Tool 概要  <= getting-started.md
# => [1] インデント見出しのSearchテスト  <= indented.md(先頭3スペースインデントも見出しとして検出される)
# => [1] 過去のSearch履歴  <= old-notes.md

# 2. keyword=実装 (getting-started.mdの###見出しにのみ存在) -> 0件(レベル3以降は除外される)
$r2 = @()
foreach ($f in $files) { $r2 += @(Find-MatchingHeading -File $f -Keyword "実装") }
$r2.Count
# => 0

# 3. keyword=スペース (indented.mdの4スペースインデント行にのみ存在) -> 0件(4スペース以上はコードブロック扱いで除外)
$r3 = @()
foreach ($f in $files) { $r3 += @(Find-MatchingHeading -File $f -Keyword "スペース") }
$r3.Count
# => 0

# 4. keyword=search (小文字) -> 大文字小文字を区別せず "SEARCH in different case" にヒットする
@(Find-MatchingHeading -File (Get-Item ./fixtures/docs/case-test.md) -Keyword "search") |
    ForEach-Object { "[$($_.HeadingLevel)] $($_.HeadingText)" }
# => [1] SEARCH in different case

# 5. keyword=[要確認] (正規表現特殊文字を含むキーワードのリテラル一致)
@(Find-MatchingHeading -File (Get-Item ./fixtures/docs/special-chars.md) -Keyword "[要確認]") |
    ForEach-Object { "[$($_.HeadingLevel)] $($_.HeadingText)" }
# => [1] 価格は[要確認]です

# 6. keyword=a.b ("."がワイルドカードとして誤解釈されずリテラルの"."として一致することを確認)
@(Find-MatchingHeading -File (Get-Item ./fixtures/docs/special-chars.md) -Keyword "a.b") |
    ForEach-Object { "[$($_.HeadingLevel)] $($_.HeadingText)" }
# => [2] a.b.cの表記について
```

> 補足(否定的検証): `a.b`というキーワードが、もし正規表現として解釈されていた場合に誤って一致してしまう`aXbXc`のような見出しに対しては、実際には一致しない(0件)ことを一時ファイルで確認済みです。`[regex]::Escape`によるエスケープが機能しています。

<!-- タスク5以降で、結果表示・エンドツーエンドの実行例をここに追記する -->
