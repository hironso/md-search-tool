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

function Test-SearchParameter {
    <#
    .SYNOPSIS
        -Path/-Keywordパラメータを検証する。検証に失敗した場合は終了エラーを送出する。
    #>
    param(
        [string] $Path,
        [string] $Keyword
    )

    if ([string]::IsNullOrEmpty($Path)) {
        throw "パラメータが不足しています。-Pathを指定してください。"
    }

    if ([string]::IsNullOrEmpty($Keyword)) {
        throw "-Keywordに空の文字列は指定できません。検索キーワードを指定してください。"
    }

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "指定されたフォルダ '$Path' が見つかりません。"
    }
}

try {
    Test-SearchParameter -Path $Path -Keyword $Keyword
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
