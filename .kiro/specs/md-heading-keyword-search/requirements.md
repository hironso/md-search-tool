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

## Requirements
<!-- Will be generated in /kiro-spec-requirements phase -->

