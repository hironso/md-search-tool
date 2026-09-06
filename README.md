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

<!-- タスク2以降で、パラメータ検証・ファイル探索・見出し検索・結果表示・エラーケースの実行例をここに追記する -->
