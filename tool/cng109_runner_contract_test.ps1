[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$runner = Join-Path $PSScriptRoot 'cng109_android_e2e.ps1'
if (-not (Test-Path -LiteralPath $runner)) {
  throw "CNG-109 runner not found: $runner"
}

$tokens = $null
$parseErrors = $null
[System.Management.Automation.Language.Parser]::ParseFile(
  $runner,
  [ref]$tokens,
  [ref]$parseErrors
) | Out-Null
if ($parseErrors.Count -gt 0) {
  $messages = @(
    $parseErrors |
      ForEach-Object { "line $($_.Extent.StartLineNumber): $($_.Message)" }
  )
  throw "CNG-109 runner has PowerShell parse errors: $($messages -join '; ')"
}

$content = Get-Content -Raw -Encoding UTF8 -LiteralPath $runner

$requiredPatterns = [ordered]@{
  'explicit expected branch' = '\[Parameter\(Mandatory = \$true\)\][\s\S]*?\$ExpectedBranch'
  'explicit 40-character expected head' = "ValidatePattern\('\^\[0-9a-fA-F\]\{40\}\$'\)"
  'explicit detached worktree label' = "'\(detached\)'"
  'null-safe branch reads' = '\(git branch --show-current\) \| Out-String'
  'clean worktree gate' = 'CNG-109 evidence requires a clean worktree'
  'artifact path outside all worktrees' = 'ArtifactParent must be outside every Git worktree'
  'runner hash evidence' = 'runnerSha256 = \$runnerSha256'
  'initial APK hash evidence' = 'apkSha256Initial = \$apkHashInitial'
  'prepare APK hash evidence' = 'apkSha256AfterPrepareTest = \$apkHashAfterPrepareTest'
  'verify APK hash evidence' = 'apkSha256AfterVerifyTest = \$apkHashAfterVerifyTest'
  'offline enforced lockfile' = 'pub get --offline --enforce-lockfile'
  'lockfile hosted URL gate' = 'pubspec\.lock must contain exactly one hosted package URL'
  'expected hosted URL gate' = 'unexpected pubspec\.lock hosted URL'
  'explicit pub hosted source' = '\$env:PUB_HOSTED_URL = \$ExpectedPubHostedUrl'
  'build without implicit pub get' = 'build apk --debug --no-pub'
  'integration tests without implicit pub get' = 'test -d \$Serial --no-uninstall --no-pub'
  'supported airplane command' = 'cmd connectivity airplane-mode'
  'wifi radio disabled' = 'svc wifi disable'
  'mobile radio disabled' = 'svc data disable'
  'mobile setting is advisory' = 'mobileSettingRole = ''advisory; svc data disable must succeed'''
  'active default network assertion' = 'Active default network'
  'network reachability probe' = 'shell ping -c 1 -W \$NetworkProbeTimeoutSeconds \$NetworkProbeHost'
  'successful ping rejected' = '\$probeExit -eq 0'
  'three offline checkpoints' = "Assert-OfflineNetworkState 'prepare'[\s\S]*Assert-OfflineNetworkState 'force-stop'[\s\S]*Assert-OfflineNetworkState 'verify'"
  'network restoration is a cleanup gate' = "Add-CleanupFailure 'network restore'"
}

foreach ($entry in $requiredPatterns.GetEnumerator()) {
  if ($content -notmatch $entry.Value) {
    throw "CNG-109 runner contract missing: $($entry.Key)"
  }
}

$nullSafeBranchReadCount = [regex]::Matches(
  $content,
  '\(git branch --show-current\) \| Out-String'
).Count
if ($nullSafeBranchReadCount -ne 2) {
  throw "CNG-109 runner must use exactly two null-safe branch reads; actual=$nullSafeBranchReadCount"
}

$forbiddenPatterns = [ordered]@{
  'protected airplane broadcast' = 'am broadcast -a android\.intent\.action\.AIRPLANE_MODE'
  'settings-only airplane toggle' = 'settings put global airplane_mode_on'
  'hard-coded qemu-only device gate' = '\$qemu -ne ''1'' -or'
  'dirty pubspec.lock allowance' = "'pubspec\.lock',[\r\n]"
  'unreliable mobile setting hard gate' = "if \(\`$mobile -ne '0'\)"
  'unparenthesized ordered JSON value' = "Write-Json[^\r\n]+(?<!\()\[ordered\]@\{"
}

foreach ($entry in $forbiddenPatterns.GetEnumerator()) {
  if ($content -match $entry.Value) {
    throw "CNG-109 runner contract forbids: $($entry.Key)"
  }
}

Write-Output 'CNG-109 runner contract: PASS'
