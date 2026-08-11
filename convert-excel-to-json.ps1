param(
    [Parameter(Mandatory=$true)]
    [string]$ExcelFile
)

$ErrorActionPreference = "Stop"
$required = @("Candidate Name","Candidate ID","Sector Name","QP Name","QP Code","QP Version","Grade","Document ID","Issuance Date","Valid Upto","Type")

function Get-ColumnNumber([string]$cellReference) {
    $letters = ($cellReference -replace '[^A-Z]', '')
    $number = 0
    foreach ($character in $letters.ToCharArray()) {
        $number = ($number * 26) + ([int][char]$character - [int][char]'A' + 1)
    }
    return $number
}

function Read-ZipXml($archive, [string]$entryName) {
    $entry = $archive.GetEntry($entryName)
    if (-not $entry) { return $null }
    $reader = New-Object IO.StreamReader($entry.Open())
    try { [xml]$reader.ReadToEnd() } finally { $reader.Dispose() }
}

$resolved = (Resolve-Path -LiteralPath $ExcelFile).Path
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [IO.Compression.ZipFile]::OpenRead($resolved)

try {
    $shared = @()
    $sharedXml = Read-ZipXml $archive "xl/sharedStrings.xml"
    if ($sharedXml) {
        foreach ($item in $sharedXml.GetElementsByTagName("si")) {
            $textParts = @($item.GetElementsByTagName("t") | ForEach-Object { $_.InnerText })
            $shared += ($textParts -join '')
        }
    }

    $sheetXml = Read-ZipXml $archive "xl/worksheets/sheet1.xml"
    if (-not $sheetXml) { throw "First worksheet could not be read." }

    $rows = @()
    foreach ($row in $sheetXml.GetElementsByTagName("row")) {
        $values = @{}
        foreach ($cell in $row.GetElementsByTagName("c")) {
            $column = Get-ColumnNumber $cell.GetAttribute("r")
            $type = $cell.GetAttribute("t")
            $valueNodes = $cell.GetElementsByTagName("v")
            $rawValue = if ($valueNodes.Count) { $valueNodes.Item(0).InnerText } else { "" }
            if ($type -eq "s") { $value = $shared[[int]$rawValue] }
            elseif ($type -eq "inlineStr") { $value = (($cell.GetElementsByTagName("t") | ForEach-Object { $_.InnerText }) -join '') }
            else { $value = $rawValue }
            $values[$column] = $value
        }
        $rows += ,$values
    }
    if ($rows.Count -lt 2) { throw "Workbook does not contain candidate rows." }

    $headers = @{}
    foreach ($column in $rows[0].Keys) {
        $heading = ([string]$rows[0][$column]).Trim()
        if ($heading) { $headers[$heading] = $column }
    }
    foreach ($heading in $required) {
        if (-not $headers.ContainsKey($heading)) { throw "Missing column: $heading" }
    }

    $records = [ordered]@{}
    for ($index = 1; $index -lt $rows.Count; $index++) {
        $row = $rows[$index]
        $candidateId = ([string]$row[$headers["Candidate ID"]]).Trim().ToUpperInvariant()
        if (-not $candidateId) { continue }
        if ($records.Contains($candidateId)) { throw "Duplicate Candidate ID: $candidateId" }

        $issuedRaw = ([string]$row[$headers["Issuance Date"]]).Trim()
        $validRaw = ([string]$row[$headers["Valid Upto"]]).Trim()
        $issued = if ($issuedRaw -match '^\d+(\.\d+)?$') { [DateTime]::FromOADate([double]$issuedRaw).ToString("dd-MMM-yyyy", [Globalization.CultureInfo]::InvariantCulture) } else { $issuedRaw }
        $valid = if ($validRaw -match '^\d+(\.\d+)?$') { [DateTime]::FromOADate([double]$validRaw).ToString("dd-MMM-yyyy", [Globalization.CultureInfo]::InvariantCulture) } else { $validRaw }

        $records[$candidateId] = [ordered]@{
            name = ([string]$row[$headers["Candidate Name"]]).Trim()
            sector = ([string]$row[$headers["Sector Name"]]).Trim()
            qpName = ([string]$row[$headers["QP Name"]]).Trim()
            qpCode = ([string]$row[$headers["QP Code"]]).Trim()
            version = ([string]$row[$headers["QP Version"]]).Trim()
            grade = ([string]$row[$headers["Grade"]]).Trim()
            documentId = ([string]$row[$headers["Document ID"]]).Trim()
            issued = $issued
            valid = $valid
            type = ([string]$row[$headers["Type"]]).Trim()
        }
    }

    $output = Join-Path $PSScriptRoot "candidates.json"
    $records | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $output -Encoding UTF8
    Write-Host "Created $output with $($records.Count) demo records."
}
finally {
    $archive.Dispose()
}
