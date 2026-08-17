$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$homeHtml = Get-Content -LiteralPath (Join-Path $root 'index.html') -Raw
$deafAccessHtml = Get-Content -LiteralPath (Join-Path $root 'deafaccess\index.html') -Raw
$css = Get-Content -LiteralPath (Join-Path $root 'assets\site.css') -Raw

$labs = @(
  'DeafBench',
  'CaptionLab',
  'CommLab',
  'RTTLab',
  'UXLab',
  'MediaLab',
  'ScenarioLab',
  'AlertLab',
  'EmergencyLab',
  'SignLab',
  'InterpreterLab',
  'SoundCueLab',
  'HapticLab',
  'HearingDeviceLab',
  'AuracastLab',
  'DeafBlindLab',
  'AgentLab',
  'MultimodalParityLab',
  'CriticalInfoLab',
  'ContextLab',
  'RecoveryLab',
  'NoiseLab',
  'CaptionPersonalizationLab',
  'GamingAccessibilityLab',
  'AutomotiveAccessibilityLab',
  'PublicSpaceLab',
  'VendorLab',
  'RegressionLab',
  'HumanReviewLab',
  'DataTrustLab'
)

$missingLabs = @($labs | Where-Object { $homeHtml -notmatch [regex]::Escape("<h4>$_</h4>") })
if ($missingLabs.Count -gt 0) {
  throw "Missing Lab cards: $($missingLabs -join ', ')"
}

$expectedGroups = @(
  'AI &amp; Communication',
  'Safety &amp; Emergency',
  'Devices &amp; Hardware',
  'Media &amp; Experience'
)
foreach ($group in $expectedGroups) {
  if ($homeHtml -notmatch [regex]::Escape($group)) {
    throw "Missing Lab group heading: $group"
  }
}

$palette = @(
  '--navy-950: #031c37;',
  '--gold-500: #fbbd3d;',
  '--gold-300: #fbe1b3;',
  '--gold-100: #f7f2e3;',
  '--purple-700: #502478;',
  '--teal-500: #12a8b1;',
  '--teal-100: #e4f4f0;',
  '--danger: #d22126;',
  '--success: #2e8c36;'
)
foreach ($token in $palette) {
  if (-not $css.Contains($token)) {
    throw "Missing approved palette token: $token"
  }
}

if ($homeHtml -match 'id="lab-groups"[^>]*>\s*</div>') {
  throw 'Lab network placeholder is still empty.'
}

if (-not $homeHtml.Contains('DeafAccess is in development')) {
  throw 'Homepage must identify DeafAccess as in development.'
}

if (-not $deafAccessHtml.Contains('DeafAccess is in development')) {
  throw 'DeafAccess page must identify the platform as in development.'
}

Write-Host "PASS: 30 Labs, 4 groups, brand palette, and product maturity copy are present."
