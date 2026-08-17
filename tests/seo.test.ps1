$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$pages = @(
  @{ Path = 'index.html'; Canonical = 'https://lanternarc.github.io/' },
  @{ Path = 'deafaccess\index.html'; Canonical = 'https://lanternarc.github.io/deafaccess/' },
  @{ Path = 'deafbench\index.html'; Canonical = 'https://lanternarc.github.io/deafbench/' },
  @{ Path = 'about\index.html'; Canonical = 'https://lanternarc.github.io/about/' }
)

foreach ($page in $pages) {
  $path = Join-Path $root $page.Path
  $html = Get-Content -LiteralPath $path -Raw
  $canonicalTag = '<link rel="canonical" href="{0}">' -f $page.Canonical
  $requirements = @(
    $canonicalTag,
    '<meta property="og:title"',
    '<meta property="og:description"',
    '<meta property="og:url"',
    '<meta property="og:image" content="https://lanternarc.github.io/assets/social-card.png">',
    '<meta name="twitter:card" content="summary_large_image">',
    '<meta name="twitter:image" content="https://lanternarc.github.io/assets/social-card.png">',
    '<link rel="manifest" href="/site.webmanifest">',
    '<link rel="icon" type="image/png" href="/assets/lantern-arc-logo.png">',
    '<script type="application/ld+json">'
  )
  foreach ($requirement in $requirements) {
    if (-not $html.Contains($requirement)) {
      throw "Missing SEO requirement in $($page.Path): $requirement"
    }
  }
}

$robots = Join-Path $root 'robots.txt'
$sitemap = Join-Path $root 'sitemap.xml'
$manifest = Join-Path $root 'site.webmanifest'
$noJekyll = Join-Path $root '.nojekyll'
$notFound = Join-Path $root '404.html'
$socialCard = Join-Path $root 'assets\social-card.png'

foreach ($path in @($robots, $sitemap, $manifest, $noJekyll, $notFound, $socialCard)) {
  if (-not (Test-Path -LiteralPath $path)) {
    throw "Missing SEO/deployment file: $(Split-Path -Leaf $path)"
  }
}

$robotsText = Get-Content -LiteralPath $robots -Raw
if (-not $robotsText.Contains('Sitemap: https://lanternarc.github.io/sitemap.xml')) {
  throw 'robots.txt does not advertise the canonical sitemap.'
}

$sitemapText = Get-Content -LiteralPath $sitemap -Raw
foreach ($page in $pages) {
  $sitemapUrl = '<loc>{0}</loc>' -f $page.Canonical
  if (-not $sitemapText.Contains($sitemapUrl)) {
    throw "Sitemap missing URL: $($page.Canonical)"
  }
}

Write-Host 'PASS: SEO metadata, structured data, sitemap, robots, manifest, favicon, and 404 support are present.'
