[CmdletBinding()]
param(
  [string]$Adb = 'D:\Android\Sdk\platform-tools\adb.exe',
  [string]$Serial = 'emulator-5554',
  [string]$Flutter = 'flutter',
  [string]$ArtifactParent = 'D:\Hermes\cognote-agent-artifacts\cng-109-e5-o3'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$package = 'com.cognote.cognote.cng109'
$activity = 'com.cognote.cognote.cng109/com.cognote.cognote.MainActivity'
$expectedHead = '60a113a4811a041a1eef0fc2108be02610d508bb'
$runId = 'cng109-{0}-{1}' -f (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ'), ([guid]::NewGuid().ToString('N').Substring(0, 4))
$artifactRoot = Join-Path $ArtifactParent $runId
$primaryFailure = $null
$cleanupFailure = @()
$installed = $false
$networkSaved = $false
$airplaneBefore = $null
$wifiBefore = $null
$mobileBefore = $null
$forceStopCleanupExit = $null
$uninstallExit = $null
$uninstallOutput = $null
$packageAfterCleanup = $null
$packageRemoved = $null
$networkRestored = $null
$deviceState = $null
$finalStaged = @()
$finalChanged = @()
$finalUnexpected = @()
$finalDiffCheckExit = $null
$allowedChanges = @(
  'android/app/build.gradle.kts',
  'pubspec.yaml',
  'pubspec.lock',
  'integration_test/cng109_prepare_test.dart',
  'integration_test/cng109_verify_test.dart',
  'tool/cng109_android_e2e.ps1'
)

New-Item -ItemType Directory -Force -Path $artifactRoot | Out-Null
$fullLog = Join-Path $artifactRoot 'full-run.log'
Start-Transcript -Path $fullLog | Out-Null

function Invoke-Adb {
  param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Arguments)
  & $Adb -s $Serial @Arguments
  if ($LASTEXITCODE -ne 0) { throw "adb failed ($LASTEXITCODE): $($Arguments -join ' ')" }
}

function Read-Setting([string]$Name) {
  return ((Invoke-Adb shell settings get global $Name) | Out-String).Trim()
}

function Write-Json([string]$Name, [object]$Value) {
  $Value | ConvertTo-Json -Depth 12 | Set-Content -Encoding utf8 (Join-Path $artifactRoot $Name)
}

function Assert-LastExitCode([string]$Command) {
  if ($LASTEXITCODE -ne 0) {
    throw "$Command failed: $LASTEXITCODE"
  }
}

function Assert-AirplaneMode([string]$Stage) {
  $value = Read-Setting 'airplane_mode_on'
  if ($value -ne '1') {
    throw "airplane_mode_on was $value at stage: $Stage"
  }
  return $value
}

function Add-CleanupFailure([string]$Stage, [object]$Error) {
  $script:cleanupFailure += "${Stage}: $Error"
}

function Copy-AppEvidence([string]$RemoteName, [string]$LocalName) {
  $remote = "files/cng109/$runId/$RemoteName"
  $content = & $Adb -s $Serial shell run-as $package cat $remote
  if ($LASTEXITCODE -ne 0) { throw "could not copy app evidence: $RemoteName" }
  $content | Set-Content -Encoding utf8 (Join-Path $artifactRoot $LocalName)
}

function Wait-Pid([bool]$WantPid) {
  for ($i = 0; $i -lt 40; $i++) {
    $processId = ((& $Adb -s $Serial shell pidof $package) | Out-String).Trim()
    if ($WantPid -and $processId) { return $processId }
    if (-not $WantPid -and -not $processId) { return '' }
    Start-Sleep -Milliseconds 500
  }
  throw "PID state did not converge to WantPid=$WantPid"
}

try {
  if (-not (Test-Path $Adb)) { throw "adb not found: $Adb" }
  $head = (git rev-parse HEAD).Trim()
  Assert-LastExitCode 'git rev-parse HEAD'
  $branch = (git branch --show-current).Trim()
  Assert-LastExitCode 'git branch --show-current'
  if ($branch -ne 'feat/cng-109' -or $head -ne $expectedHead) {
    throw "unexpected Git baseline: $branch $head"
  }
  $stagedPaths = @(git diff --cached --name-only)
  Assert-LastExitCode 'git diff --cached --name-only'
  if ($stagedPaths.Count -gt 0) {
    throw "staged files are not allowed: $($stagedPaths -join ', ')"
  }
  $changed = @(git status --porcelain=v1 --untracked-files=all | ForEach-Object { $_.Substring(3).Replace('\', '/') })
  Assert-LastExitCode 'git status --porcelain'
  $unexpected = @($changed | Where-Object { $_ -notin $allowedChanges })
  if ($unexpected.Count -gt 0) {
    throw "unexpected worktree paths: $($unexpected -join ', ')"
  }

  $qemu = (Invoke-Adb shell getprop ro.kernel.qemu | Out-String).Trim()
  $api = (Invoke-Adb shell getprop ro.build.version.sdk | Out-String).Trim()
  $abi = (Invoke-Adb shell getprop ro.product.cpu.abi | Out-String).Trim()
  if ($qemu -ne '1' -or $api -ne '35' -or $abi -ne 'x86_64') {
    throw "unexpected device: qemu=$qemu api=$api abi=$abi"
  }

  $lockPath = Join-Path (Get-Location) 'pubspec.lock'
  $lockHashBeforePubGet = (Get-FileHash $lockPath -Algorithm SHA256).Hash.ToLowerInvariant()
  $pubGetStartedAt = (Get-Date).ToUniversalTime().ToString('o')
  Remove-Item Env:HTTP_PROXY -ErrorAction SilentlyContinue
  Remove-Item Env:HTTPS_PROXY -ErrorAction SilentlyContinue
  Remove-Item Env:ALL_PROXY -ErrorAction SilentlyContinue
  $env:PUB_HOSTED_URL = 'https://pub.flutter-io.cn'
  $env:FLUTTER_STORAGE_BASE_URL = 'https://storage.flutter-io.cn'
  $previousErrorActionPreference = $ErrorActionPreference
  try {
    $ErrorActionPreference = 'Continue'
    & $Flutter pub get *> (Join-Path $artifactRoot 'pub-get.log')
    $pubGetExit = $LASTEXITCODE
  } finally {
    $ErrorActionPreference = $previousErrorActionPreference
  }
  Assert-LastExitCode 'flutter pub get'
  $pubGetFinishedAt = (Get-Date).ToUniversalTime().ToString('o')
  $lockHashAfterPubGet = (Get-FileHash $lockPath -Algorithm SHA256).Hash.ToLowerInvariant()
  if ($lockHashAfterPubGet -ne $lockHashBeforePubGet) {
    throw "flutter pub get changed pubspec.lock: $lockHashBeforePubGet -> $lockHashAfterPubGet"
  }

  & $Flutter build apk --debug
  Assert-LastExitCode 'APK build'
  $apk = Join-Path (Get-Location) 'build\app\outputs\flutter-apk\app-debug.apk'
  if (-not (Test-Path $apk) -or (Get-Item $apk).Length -le 0) {
    throw 'debug APK missing or empty'
  }
  $apkHash = (Get-FileHash $apk -Algorithm SHA256).Hash.ToLowerInvariant()
  Write-Json 'run-metadata.json' @{
    runId = $runId
    artifactDir = $artifactRoot
    deviceArtifactProtocol = 'application-support-export-via-run-as'
    serial = $Serial
    qemu = $qemu
    api = $api
    abi = $abi
    gitHead = $head
    package = $package
    activity = $activity
    strictMode = 'Latest'
    pubGetExit = $pubGetExit
    pubGetStartedAt = $pubGetStartedAt
    pubGetFinishedAt = $pubGetFinishedAt
    lockHashBeforePubGet = $lockHashBeforePubGet
    lockHashAfterPubGet = $lockHashAfterPubGet
    apkSha256 = $apkHash
  }
  Write-Json 'adb-capability.log' @{ adb = $Adb; apk = $apk; apkSha256 = $apkHash; activity = $activity }
  $sourceBytes = [Convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAYAAABytg0kAAAAEUlEQVR4nGP4z8DwH4QZYAwAR8oH+WdZbrcAAAAASUVORK5CYII=')
  [IO.File]::WriteAllBytes((Join-Path $artifactRoot 'image-source.png'), $sourceBytes)
  (Get-FileHash (Join-Path $artifactRoot 'image-source.png') -Algorithm SHA256).Hash.ToLowerInvariant() | Set-Content -Encoding ascii (Join-Path $artifactRoot 'image-source.sha256')

  $existing = ((Invoke-Adb shell pm list packages $package) | Out-String).Trim()
  if ($existing) { throw "isolated package already exists: $existing" }
  Invoke-Adb install $apk
  $installed = $true
  Invoke-Adb shell pm clear $package
  $resolved = ((Invoke-Adb shell cmd package resolve-activity --brief $package) | Out-String).Trim()
  if ($resolved -notmatch 'com\.cognote\.cognote\.MainActivity') {
    throw "launcher did not resolve: $resolved"
  }

  $airplaneBefore = Read-Setting 'airplane_mode_on'
  $wifiBefore = Read-Setting 'wifi_on'
  $mobileBefore = Read-Setting 'mobile_data'
  $networkSaved = $true
  Write-Json 'network-before.json' @{ airplane = $airplaneBefore; wifi = $wifiBefore; mobile = $mobileBefore }

  Invoke-Adb shell settings put global airplane_mode_on 1
  & $Adb -s $Serial shell am broadcast -a android.intent.action.AIRPLANE_MODE --ez state true | Out-File (Join-Path $artifactRoot 'airplane-broadcast.log')
  $broadcastEnableExit = $LASTEXITCODE
  for ($i = 0; $i -lt 20 -and (Read-Setting 'airplane_mode_on') -ne '1'; $i++) {
    Start-Sleep -Milliseconds 500
  }
  $airplaneBeforePrepare = Assert-AirplaneMode 'prepare integration test'
  Write-Json 'network-airplane.json' @{
    airplane = $airplaneBeforePrepare
    wifi = (Read-Setting 'wifi_on')
    mobile = (Read-Setting 'mobile_data')
    broadcastExit = $broadcastEnableExit
  }

  & $Flutter test -d $Serial --no-uninstall --dart-define="CNG109_RUN_ID=$runId" --dart-define="CNG109_ARTIFACT_DIR=$artifactRoot" integration_test/cng109_prepare_test.dart
  Assert-LastExitCode 'prepare integration test'
  Copy-AppEvidence 'prepare-result.json' 'prepare-result.json'
  $prepareResult = Get-Content (Join-Path $artifactRoot 'prepare-result.json') -Raw | ConvertFrom-Json
  $beforeOutbox = @($prepareResult.outbox)
  if ($beforeOutbox.Count -ne 6) { throw "prepare outbox count was $($beforeOutbox.Count), expected 6" }
  $beforeOutbox | ConvertTo-Json -Depth 12 | Set-Content -Encoding utf8 (Join-Path $artifactRoot 'outbox-before.json')

  $airplaneBeforeForceStop = Assert-AirplaneMode 'am force-stop'
  & $Adb -s $Serial shell am start -W -n $activity | Out-File (Join-Path $artifactRoot 'start-before-force-stop.log')
  Assert-LastExitCode 'launch before force-stop'
  $pidBefore = Wait-Pid $true
  & $Adb -s $Serial shell am force-stop $package
  $forceStopExit = $LASTEXITCODE
  if ($forceStopExit -ne 0) { throw "force-stop failed: $forceStopExit" }
  $pidAfterStop = Wait-Pid $false
  & $Adb -s $Serial shell am start -W -n $activity | Out-File (Join-Path $artifactRoot 'start-after-force-stop.log')
  Assert-LastExitCode 'launch after force-stop'
  $pidAfterRestart = Wait-Pid $true
  Write-Json 'force-stop.log' @{
    airplaneBeforeForceStop = $airplaneBeforeForceStop
    pidBeforeForceStop = $pidBefore
    forceStopExit = $forceStopExit
    pidAfterStop = $pidAfterStop
    pidAfterRestart = $pidAfterRestart
  }

  $airplaneBeforeVerify = Assert-AirplaneMode 'verify integration test'
  & $Flutter test -d $Serial --no-uninstall --dart-define="CNG109_RUN_ID=$runId" --dart-define="CNG109_ARTIFACT_DIR=$artifactRoot" integration_test/cng109_verify_test.dart
  Assert-LastExitCode 'verify integration test'
  Copy-AppEvidence 'verify-result.json' 'verify-result.json'
  $verifyResult = Get-Content (Join-Path $artifactRoot 'verify-result.json') -Raw | ConvertFrom-Json
  $afterOutbox = @($verifyResult.outbox)
  if ($afterOutbox.Count -ne 6) { throw "verify outbox count was $($afterOutbox.Count), expected 6" }
  $afterOutbox | ConvertTo-Json -Depth 12 | Set-Content -Encoding utf8 (Join-Path $artifactRoot 'outbox-after.json')
  $beforeOutboxRows = @($beforeOutbox | ForEach-Object { $_ | ConvertTo-Json -Depth 12 -Compress })
  $afterOutboxRows = @($afterOutbox | ForEach-Object { $_ | ConvertTo-Json -Depth 12 -Compress })
  if (Compare-Object $beforeOutboxRows $afterOutboxRows) {
    throw 'outbox before and after differed'
  }
  Write-Json 'airplane-stages.json' @{
    airplaneBeforePrepare = $airplaneBeforePrepare
    airplaneBeforeForceStop = $airplaneBeforeForceStop
    airplaneBeforeVerify = $airplaneBeforeVerify
  }
}
catch {
  $primaryFailure = $_
  Write-Error $_
}
finally {
  try {
    & $Adb -s $Serial shell am force-stop $package | Out-Null
    $forceStopCleanupExit = $LASTEXITCODE
    if ($forceStopCleanupExit -ne 0) { Add-CleanupFailure 'force-stop cleanup' "exit=$forceStopCleanupExit" }
  } catch { Add-CleanupFailure 'force-stop cleanup' $_ }

  if ($networkSaved) {
    try {
      & $Adb -s $Serial shell settings put global airplane_mode_on $airplaneBefore | Out-Null
      if ($LASTEXITCODE -ne 0) { throw "restore airplane exit=$LASTEXITCODE" }
      $airBool = if ($airplaneBefore -eq '1') { 'true' } else { 'false' }
      & $Adb -s $Serial shell am broadcast -a android.intent.action.AIRPLANE_MODE --ez state $airBool | Out-File (Join-Path $artifactRoot 'restore-broadcast.log')
      if ($wifiBefore -eq '1') { & $Adb -s $Serial shell svc wifi enable | Out-Null } elseif ($wifiBefore -eq '0') { & $Adb -s $Serial shell svc wifi disable | Out-Null }
      if ($LASTEXITCODE -ne 0) { throw "restore wifi exit=$LASTEXITCODE" }
      if ($mobileBefore -eq '1') { & $Adb -s $Serial shell svc data enable | Out-Null } elseif ($mobileBefore -eq '0') { & $Adb -s $Serial shell svc data disable | Out-Null }
      if ($LASTEXITCODE -ne 0) { throw "restore mobile exit=$LASTEXITCODE" }
      for ($i = 0; $i -lt 40; $i++) {
        $airplaneAfter = Read-Setting 'airplane_mode_on'
        $wifiAfter = Read-Setting 'wifi_on'
        $mobileAfter = Read-Setting 'mobile_data'
        if ($airplaneAfter -eq $airplaneBefore -and $wifiAfter -eq $wifiBefore -and $mobileAfter -eq $mobileBefore) { break }
        Start-Sleep -Milliseconds 500
      }
      $airplaneAfter = Read-Setting 'airplane_mode_on'
      $wifiAfter = Read-Setting 'wifi_on'
      $mobileAfter = Read-Setting 'mobile_data'
      $networkRestored = $airplaneAfter -eq $airplaneBefore -and $wifiAfter -eq $wifiBefore -and $mobileAfter -eq $mobileBefore
      if (-not $networkRestored) { Add-CleanupFailure 'network restore' "expected airplane=$airplaneBefore wifi=$wifiBefore mobile=$mobileBefore; actual airplane=$airplaneAfter wifi=$wifiAfter mobile=$mobileAfter" }
      Write-Json 'network-after.json' @{
        airplane = $airplaneAfter
        wifi = $wifiAfter
        mobile = $mobileAfter
        expectedAirplane = $airplaneBefore
        expectedWifi = $wifiBefore
        expectedMobile = $mobileBefore
        networkRestored = $networkRestored
      }
    } catch { Add-CleanupFailure 'network restore' $_ }
  }

  if ($installed) {
    try {
      $uninstallOutput = & $Adb -s $Serial uninstall $package
      $uninstallExit = $LASTEXITCODE
      $packageAfterCleanup = ((& $Adb -s $Serial shell pm list packages $package) | Out-String).Trim()
      $packageRemoved = $uninstallExit -eq 0 -and -not $packageAfterCleanup
      if (-not $packageRemoved) { Add-CleanupFailure 'uninstall' "exit=$uninstallExit packageAfterCleanup=$packageAfterCleanup" }
    } catch { Add-CleanupFailure 'uninstall' $_ }
  }

  try { $deviceState = ((& $Adb -s $Serial get-state) | Out-String).Trim() } catch { Add-CleanupFailure 'device state' $_ }
  if ($deviceState -ne 'device') { Add-CleanupFailure 'device state' "expected device, actual $deviceState" }

  try {
    $finalStaged = @(git diff --cached --name-only)
    if ($LASTEXITCODE -ne 0) { throw 'could not inspect final staged files' }
    $finalChanged = @(git status --porcelain=v1 --untracked-files=all | ForEach-Object { $_.Substring(3).Replace('\', '/') })
    if ($LASTEXITCODE -ne 0) { throw 'could not inspect final worktree state' }
    $finalUnexpected = @($finalChanged | Where-Object { $_ -notin $allowedChanges })
    git diff --check
    $finalDiffCheckExit = $LASTEXITCODE
    $finalHead = (git rev-parse HEAD).Trim()
    $finalBranch = (git branch --show-current).Trim()
    if ($finalStaged.Count -gt 0) { Add-CleanupFailure 'final git' "staged files: $($finalStaged -join ', ')" }
    if ($finalUnexpected.Count -gt 0) { Add-CleanupFailure 'final git' "unexpected files: $($finalUnexpected -join ', ')" }
    if ($finalDiffCheckExit -ne 0) { Add-CleanupFailure 'final git' "git diff --check exit=$finalDiffCheckExit" }
    if ($finalHead -ne $expectedHead -or $finalBranch -ne 'feat/cng-109') { Add-CleanupFailure 'final git' "branch=$finalBranch head=$finalHead" }
  } catch { Add-CleanupFailure 'final git' $_ }

  try {
    Write-Json 'cleanup-result.json' @{
      forceStopCleanupExit = $forceStopCleanupExit
      networkRestored = $networkRestored
      uninstallExit = $uninstallExit
      uninstallOutput = $uninstallOutput
      packageAfterCleanup = $packageAfterCleanup
      packageRemoved = $packageRemoved
      primaryFailure = if ($null -eq $primaryFailure) { $null } else { $primaryFailure.Exception.Message }
      cleanupFailure = $cleanupFailure
      deviceState = $deviceState
      finalStaged = $finalStaged
      finalChanged = $finalChanged
      finalUnexpected = $finalUnexpected
      finalDiffCheckExit = $finalDiffCheckExit
    }
  } catch { Add-CleanupFailure 'cleanup evidence' $_ }
  Stop-Transcript | Out-Null
}

if ($primaryFailure -or $cleanupFailure.Count -gt 0) { exit 1 }
exit 0
