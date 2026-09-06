# Requirements Document

## Project Description (Input)
以下の要件でPowerShell製CLIツールを作りたい。

【目的】
指定フォルダ(サブフォルダ含む)配下のMarkdown(.md)ファイルから、# と ## の見出し(2階層まで)を対象にキーワード検索を行うツール。

【機能要件】
- 検索対象: # および ## の見出しテキストにキーワードが含まれる箇所を検索する(見出し配下の本文は検索対象外、見出し自体の文字列に対する検索)
- 検索範囲: 指定したフォルダとそのサブフォルダすべての.mdファイル
- パラメータ: PowerShellスクリプトのパラメータとして毎回指定する
  - -Path: 検索対象フォルダのパス(必須)
  - -Keyword: 検索キーワード(必須)
- 出力形式: CLI画面上にのみ表示(ファイル出力は不要)
  - ファイルパス
  - ヒットした見出し(#/##の階層とテキスト)
  - 見出しの該当行のテキスト
- 実行環境: Windows PowerShell / PowerShell CLI上で実行できること

【非機能要件】
- 外部ライブラリへの依存はできるだけ避け、PowerShell標準機能で完結させる
- 大文字小文字を区別しない検索とする
- ファイル数が多い場合でも実用的な速度で動作すること

この内容でrequirementsフェーズから開始してください。

## Introduction
本機能は、指定フォルダ配下(サブフォルダを含む)のMarkdown(.md)ファイルを対象に、`#`および`##`の見出し(2階層まで)のテキストに対してキーワード検索を行うPowerShell製CLIツールである。ユーザーは`-Path`と`-Keyword`パラメータを指定してスクリプトを実行し、該当する見出しを含むファイルパス・見出し階層・見出しテキスト・該当行を画面上に一覧表示する。外部ライブラリに依存せず、PowerShell標準機能のみで動作することを前提とする。

## Boundary Context (Optional)
- **In scope**: `#`および`##`見出し行そのものの文字列に対する大文字小文字を区別しないキーワード部分一致検索、指定フォルダ配下の再帰的な`.md`ファイル探索、検索結果のコンソール画面への表示
- **Out of scope**: 見出し配下の本文(段落・リスト・コードブロック等)に対する検索、`###`以降の3階層目以降の見出しの検索、検索結果のファイル出力(CSV/JSON等)、正規表現や完全一致など複数の検索モードの切り替え、Markdown以外のファイル形式の検索
- **Adjacent expectations**: 実行環境はWindows PowerShellおよびPowerShell(Core) CLIの両方を想定し、外部モジュールのインストールを前提としない

## Requirements

### Requirement 1: コマンドラインパラメータの受け付けと検証
**Objective:** As a ツール利用者, I want 検索対象フォルダと検索キーワードをパラメータとして指定できること, so that 実行のたびに検索条件を柔軟に指定できる

#### Acceptance Criteria
1. The MdHeadingSearchツール shall `-Path`パラメータ(検索対象フォルダのパス、必須)と`-Keyword`パラメータ(検索キーワード、必須)を受け付ける
2. If `-Path`または`-Keyword`パラメータが指定されずにスクリプトが実行された場合, then the MdHeadingSearchツール shall パラメータ不足を示すエラーメッセージを表示し、検索処理を実行しない
3. If `-Path`で指定されたフォルダが存在しない場合, then the MdHeadingSearchツール shall フォルダが存在しない旨のエラーメッセージを表示し、検索処理を実行しない
4. If `-Keyword`パラメータに空文字列が指定された場合, then the MdHeadingSearchツール shall キーワードが不正である旨のエラーメッセージを表示し、検索処理を実行しない

### Requirement 2: 検索対象ファイルの探索
**Objective:** As a ツール利用者, I want 指定フォルダとそのサブフォルダ配下すべての.mdファイルを検索対象にできること, so that フォルダ構成を意識せず網羅的に見出しを検索できる

#### Acceptance Criteria
1. When 検索処理が開始された場合, the MdHeadingSearchツール shall `-Path`で指定されたフォルダ配下を再帰的に走査し、拡張子が`.md`であるすべてのファイルを検索対象として収集する
2. While ファイル探索を行っている間, the MdHeadingSearchツール shall サブフォルダの階層数によらずすべての`.md`ファイルを収集対象に含める
3. If `-Path`配下に`.md`ファイルが1件も存在しない場合, then the MdHeadingSearchツール shall 該当ファイルが見つからない旨のメッセージを表示する

### Requirement 3: 見出しに対するキーワード検索
**Objective:** As a ツール利用者, I want `#`および`##`の見出しテキストのみを対象にキーワード検索できること, so that 見出し配下の本文に惑わされず、見出し単位で目的の情報へ素早くたどり着ける

#### Acceptance Criteria
1. The MdHeadingSearchツール shall 各`.md`ファイルの各行のうち、行頭が`#`(レベル1)または`##`(レベル2)で始まる見出し行のみを検索対象と判定する
2. The MdHeadingSearchツール shall `###`以降(3階層目以降)の見出し行、および見出し行以外の本文行を検索対象から除外する
3. When 見出し行のテキスト部分(先頭の`#`/`##`記号と直後の空白を除いた文字列)に`-Keyword`で指定した文字列が部分一致した場合, the MdHeadingSearchツール shall その見出し行を検索結果としてヒット扱いにする
4. The MdHeadingSearchツール shall キーワード比較を大文字小文字を区別せずに行う
5. If 見出し行のテキスト部分にキーワードが含まれない場合, then the MdHeadingSearchツール shall その見出し行を検索結果に含めない

### Requirement 4: 検索結果のコンソール表示
**Objective:** As a ツール利用者, I want 検索結果をCLI画面上で確認できること, so that 追加のファイル操作なしに検索対象箇所をすぐに把握できる

#### Acceptance Criteria
1. When 見出し行がキーワードにヒットした場合, the MdHeadingSearchツール shall そのファイルのファイルパス、見出しの階層(`#`または`##`)とテキスト、および見出し該当行のテキストをコンソール画面に表示する
2. The MdHeadingSearchツール shall 検索結果をファイルへ出力せず、標準出力(コンソール画面)のみに表示する
3. If 検索対象となったすべての`.md`ファイルの中でキーワードにヒットする見出しが1件も存在しない場合, then the MdHeadingSearchツール shall ヒットする見出しが見つからなかった旨のメッセージを画面に表示する
4. While 複数ファイルにまたがる検索結果を表示している間, the MdHeadingSearchツール shall どのヒットがどのファイルに属するかを判別できる形式で結果を表示する

### Requirement 5: 実行環境および非機能要件
**Objective:** As a ツール利用者, I want 追加の外部ライブラリなしにWindows PowerShellおよびPowerShell CLI上で動作するツールを使えること, so that 環境構築の手間なくどのマシンでもすぐに利用できる

#### Acceptance Criteria
1. The MdHeadingSearchツール shall Windows PowerShellおよびPowerShell(Core) CLI上で追加の外部モジュールをインストールすることなく実行できる
2. The MdHeadingSearchツール shall PowerShell標準のコマンドレットおよび言語機能のみを用いて実装される
3. While 検索対象フォルダ配下に多数の`.md`ファイルが存在する間, the MdHeadingSearchツール shall 実用的な時間内に検索結果を表示し終える
