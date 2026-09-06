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

function Get-MdFile {
    <#
    .SYNOPSIS
        検証済みの$Path配下を再帰的に走査し、拡張子が.mdであるファイルを収集する。
    #>
    param(
        [string] $Path
    )

    return @(Get-ChildItem -LiteralPath $Path -Recurse -File -Filter '*.md')
}

function Find-MatchingHeading {
    <#
    .SYNOPSIS
        $File内の#/##見出し行のうち、$Keywordに大文字小文字を区別せず部分一致するものを抽出する。
    #>
    param(
        [System.IO.FileInfo] $File,
        [string] $Keyword
    )

    $escapedKeyword = [regex]::Escape($Keyword)
    $pattern = "^\s{0,3}(?<hashes>#{1,2})(?!#)\s+(?<text>.*$escapedKeyword.*)$"

    $lineMatches = @($File | Select-String -Pattern $pattern)

    return @($lineMatches | ForEach-Object {
        [PSCustomObject]@{
            FilePath     = $File.FullName
            HeadingLevel = $_.Matches[0].Groups['hashes'].Value.Length
            HeadingText  = $_.Matches[0].Groups['text'].Value
            LineText     = $_.Line
        }
    })
}

function Write-SearchResult {
    <#
    .SYNOPSIS
        検索結果をFilePathでグループ化してコンソールへ表示する。0件の場合はヒットなしメッセージを表示する。
    #>
    param(
        [PSCustomObject[]] $Result
    )

    if ($Result.Count -eq 0) {
        Write-Output "キーワードにヒットする見出しが見つかりませんでした。"
        return
    }

    foreach ($group in @($Result | Group-Object -Property FilePath)) {
        Write-Output $group.Name
        foreach ($item in $group.Group) {
            $headingMark = '#' * $item.HeadingLevel
            Write-Output "  $headingMark $($item.HeadingText)"
            Write-Output "    > $($item.LineText)"
        }
    }
}

try {
    Test-SearchParameter -Path $Path -Keyword $Keyword
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}

$mdFiles = @(Get-MdFile -Path $Path)

if ($mdFiles.Count -eq 0) {
    Write-Output "指定されたフォルダ配下に.mdファイルが見つかりませんでした。"
    exit 0
}

$searchResults = @()
foreach ($mdFile in $mdFiles) {
    $searchResults += @(Find-MatchingHeading -File $mdFile -Keyword $Keyword)
}

Write-SearchResult -Result $searchResults
