$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$pages = @('index.html', 'deafaccess\index.html', 'deafbench\index.html', 'about\index.html', '404.html')

foreach ($relativePath in $pages) {
  $path = Join-Path $root $relativePath
  $html = Get-Content -LiteralPath $path -Raw

  if ($html -notmatch '<html lang="en">') {
    throw "Missing document language: $relativePath"
  }

  $h1Count = ([regex]::Matches($html, '<h1(?:\s[^>]*)?>')).Count
  if ($h1Count -ne 1) {
    throw "Expected exactly one H1 in $relativePath, found $h1Count"
  }

  if ($html -notmatch '<a class="skip-link" href="#main">') {
    throw "Missing skip link: $relativePath"
  }

  foreach ($imgMatch in [regex]::Matches($html, '<img\b[^>]*>')) {
    if ($imgMatch.Value -notmatch '\balt="[^"]*"') {
      throw "Image without alt attribute in ${relativePath}: $($imgMatch.Value)"
    }
  }
}

$cssPath = Join-Path $root 'assets\site.css'
$css = Get-Content -LiteralPath $cssPath -Raw

foreach ($match in [regex]::Matches($css, 'font-size:\s*(0\.\d+)rem')) {
  $value = [double]::Parse($match.Groups[1].Value, [Globalization.CultureInfo]::InvariantCulture)
  if ($value -lt 0.875) {
    throw "Font size below 14px minimum: $($match.Value)"
  }
}

if ($css -notmatch '@media \(prefers-reduced-motion: reduce\)') {
  throw 'Missing prefers-reduced-motion handling.'
}

if ($css -notmatch ':focus-visible') {
  throw 'Missing visible focus treatment.'
}

Write-Host 'PASS: structural accessibility checks and 14px minimum text rule pass.'
