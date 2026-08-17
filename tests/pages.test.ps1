$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$expectations = @(
  @{ Path = 'deafaccess\index.html'; Title = 'DeafAccess'; H1 = 'Test whether critical information stays accessible.' },
  @{ Path = 'deafbench\index.html'; Title = 'DeafBench'; H1 = 'Benchmark speech AI by what actually matters.' },
  @{ Path = 'about\index.html'; Title = 'About Lantern Arc'; H1 = 'Accessibility engineering that starts with what people actually receive.' }
)

foreach ($item in $expectations) {
  $path = Join-Path $root $item.Path
  if (-not (Test-Path -LiteralPath $path)) {
    throw "Missing page: $($item.Path)"
  }
  $html = Get-Content -LiteralPath $path -Raw
  if ($html -notmatch [regex]::Escape("<title>$($item.Title)")) {
    throw "Unexpected title for $($item.Path)"
  }
  if ($html -notmatch [regex]::Escape("<h1>$($item.H1)</h1>")) {
    throw "Unexpected H1 for $($item.Path)"
  }
  if ($html -notmatch 'class="skip-link"') {
    throw "Missing skip link: $($item.Path)"
  }
  if ($html -notmatch 'aria-label="Primary navigation"') {
    throw "Missing primary navigation label: $($item.Path)"
  }
}

Write-Host 'PASS: product and company pages exist with expected headings and navigation.'
