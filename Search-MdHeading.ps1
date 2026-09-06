<#
.SYNOPSIS
    指定フォルダ配下のMarkdown(.md)ファイルから、#/##見出し(2階層まで)を対象にキーワード検索を行うCLIツール。

.DESCRIPTION
    詳細仕様は .kiro/specs/md-heading-keyword-search/ 配下の requirements.md / design.md を参照。

.PARAMETER Path
    検索対象フォルダのパス(必須)。

.PARAMETER Keyword
    検索キーワード(必須、大文字小文字を区別しない部分一致)。

.EXAMPLE
    pwsh ./Search-MdHeading.ps1 -Path ./fixtures/docs -Keyword Search
#>
param(
    [string] $Path,
    [string] $Keyword
)
