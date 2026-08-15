[CmdletBinding()]
param(
  [string]$Adb = 'D:\Android\Sdk\platform-tools\adb.exe',
  [string]$Serial = 'emulator-5554',
  [string]$Flutter = 'flutter',
  [string]$ArtifactParent = 'D:\Hermes\cognote-agent-artifacts\cng-109-e5-o3',
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string]$ExpectedBranch,
  [Parameter(Mandatory = $true)]
  [ValidatePattern('^[0-9a-fA-F]{40}$')]
  [string]$ExpectedHead,
  [ValidateSet('emulator', 'physical')]
  [string]$ExpectedDeviceType = 'emulator',
  [ValidatePattern('^\d+$')]
  [string]$ExpectedApi = '35',
  [string]$ExpectedAbi = '',
  [ValidatePattern('^[0-9A-Za-z.-]+$')]
  [string]$NetworkProbeHost = '223.5.5.5',
  [ValidateRange(1, 10)]
  [int]$NetworkProbeTimeoutSeconds = 3,
  [ValidatePattern('^https://[^\s/]+(?:/.*)?$')]
  [string]$ExpectedPubHostedUrl = 'https://pub.flutter-io.cn',
  [ValidatePattern('^https://[^\s/]+(?:/.*)?$')]
  [string]$FlutterStorageBaseUrl = 'https://storage.flutter-io.cn',
  [string]$JavaHome = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$package = 'com.cognote.cognote.cng109'
$activity = 'com.cognote.cognote.cng109/com.cognote.cognote.MainActivity'
$runId = 'cng109-{0}-{1}' -f (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ'), ([guid]::NewGuid().ToString('N').Substring(0, 4))
$artifactRoot = Join-Path $ArtifactParent $runId
$primaryFailure = $null
$cleanupFailure = @()
$adbReady = $false
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
$finalBranch = $null
$finalHead = $null
$repoRoot = $null
$deviceType = $null
$deviceMetadata = $null
$networkOfflinePrepare = $null
$networkOfflineForceStop = $null
$networkOfflineVerify = $null
$apkHashInitial = $null
$apkHashAfterPrepareTest = $null
$apkHashAfterVerifyTest = $null
$runnerPath = [IO.Path]::GetFullPath($MyInvocation.MyCommand.Path)
$runnerSha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $runnerPath).Hash.ToLowerInvariant()

$repoRoot = ((& git rev-parse --show-toplevel) | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($repoRoot)) {
  throw 'could not resolve the Git worktree root'
}
$repoRootFull = [IO.Path]::GetFullPath($repoRoot).TrimEnd('\')
$artifactParentFull = [IO.Path]::GetFullPath($ArtifactParent).TrimEnd('\')
$worktreeLines = @(& git worktree list --porcelain)
if ($LASTEXITCODE -ne 0) { throw 'could not enumerate Git worktrees' }
$gitWorktrees = @(
  $worktreeLines |
    Where-Object { $_ -like 'worktree *' } |
    ForEach-Object { [IO.Path]::GetFullPath($_.Substring(9)).TrimEnd('\') }
)
foreach ($gitWorktree in $gitWorktrees) {
  if (
    $artifactParentFull.Equals($gitWorktree, [StringComparison]::OrdinalIgnoreCase) -or
    $artifactParentFull.StartsWith("$gitWorktree\", [StringComparison]::OrdinalIgnoreCase)
  ) {
    throw "ArtifactParent must be outside every Git worktree: $gitWorktree"
  }
}

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

function Set-AirplaneMode([bool]$Enabled, [string]$LogName) {
  $state = if ($Enabled) { 'enable' } else { 'disable' }
  $output = (Invoke-Adb shell cmd connectivity airplane-mode $state | Out-String).Trim()
  $output | Set-Content -Encoding utf8 (Join-Path $artifactRoot $LogName)
}

function Set-NetworkRadiosOffline {
  $wifiOutput = (Invoke-Adb shell svc wifi disable | Out-String).Trim()
  $dataOutput = (Invoke-Adb shell svc data disable | Out-String).Trim()
  Write-Json 'network-control-offline.json' ([ordered]@{
    wifiCommand = 'svc wifi disable'
    wifiOutput = $wifiOutput
    dataCommand = 'svc data disable'
    dataOutput = $dataOutput
  })
}

function Wait-NetworkSettings(
  [string]$ExpectedAirplane,
  [string]$ExpectedWifi,
  [string]$Stage,
  [string]$ExpectedMobile = ''
) {
  for ($i = 0; $i -lt 40; $i++) {
    $airplane = Read-Setting 'airplane_mode_on'
    $wifi = Read-Setting 'wifi_on'
    $mobile = Read-Setting 'mobile_data'
    if (
      $airplane -eq $ExpectedAirplane -and
      $wifi -eq $ExpectedWifi -and
      (
        [string]::IsNullOrWhiteSpace($ExpectedMobile) -or
        $mobile -eq $ExpectedMobile
      )
    ) {
      return
    }
    Start-Sleep -Milliseconds 500
  }
  $mobileExpectation = if ([string]::IsNullOrWhiteSpace($ExpectedMobile)) {
    'advisory'
  } else {
    $ExpectedMobile
  }
  throw "network settings did not converge at ${Stage}: expected airplane=$ExpectedAirplane wifi=$ExpectedWifi mobile=$mobileExpectation; actual airplane=$airplane wifi=$wifi mobile=$mobile"
}

function Get-ActiveDefaultNetwork([string]$EvidenceName) {
  $connectivity = (Invoke-Adb shell dumpsys connectivity | Out-String)
  $connectivity | Set-Content -Encoding utf8 (Join-Path $artifactRoot $EvidenceName)
  $match = [regex]::Match(
    $connectivity,
    '(?im)^\s*Active default network:\s*(.*?)\s*$'
  )
  if (-not $match.Success) {
    throw "dumpsys connectivity did not expose Active default network ($EvidenceName)"
  }
  return $match.Groups[1].Value.Trim()
}

function Assert-OfflineNetworkState([string]$Stage) {
  $airplane = Read-Setting 'airplane_mode_on'
  $wifi = Read-Setting 'wifi_on'
  $mobile = Read-Setting 'mobile_data'
  $airplaneCommand = (
    Invoke-Adb shell cmd connectivity airplane-mode | Out-String
  ).Trim()
  $activeDefaultNetwork = Get-ActiveDefaultNetwork "connectivity-$Stage.log"
  $pingPath = (Invoke-Adb shell which ping | Out-String).Trim()
  if ([string]::IsNullOrWhiteSpace($pingPath)) {
    throw "ping executable was not available at stage: $Stage"
  }

  $previousErrorActionPreference = $ErrorActionPreference
  try {
    $ErrorActionPreference = 'Continue'
    $probeOutput = (
      & $Adb -s $Serial shell ping -c 1 -W $NetworkProbeTimeoutSeconds $NetworkProbeHost 2>&1 |
        Out-String
    ).Trim()
    $probeExit = $LASTEXITCODE
  } finally {
    $ErrorActionPreference = $previousErrorActionPreference
  }
  $probeOutput | Set-Content -Encoding utf8 (Join-Path $artifactRoot "network-probe-$Stage.log")

  $state = [ordered]@{
    stage = $Stage
    airplane = $airplane
    airplaneCommand = $airplaneCommand
    wifi = $wifi
    mobile = $mobile
    mobileSettingRole = 'advisory; svc data disable must succeed'
    activeDefaultNetwork = $activeDefaultNetwork
    probeHost = $NetworkProbeHost
    probeTimeoutSeconds = $NetworkProbeTimeoutSeconds
    pingPath = $pingPath
    probeExit = $probeExit
  }
  Write-Json "network-offline-$Stage.json" $state

  $failures = @()
  if ($airplane -ne '1') { $failures += "airplane_mode_on=$airplane" }
  if ($airplaneCommand -notmatch '(?i)\b(enabled|true|1)\b') {
    $failures += "cmd connectivity airplane-mode=$airplaneCommand"
  }
  if ($wifi -ne '0') { $failures += "wifi_on=$wifi" }
  if ($activeDefaultNetwork -notmatch '^(?i:none|null|-1)$') {
    $failures += "activeDefaultNetwork=$activeDefaultNetwork"
  }
  if ($probeExit -eq 0) { $failures += "ping $NetworkProbeHost unexpectedly succeeded" }
  if ($failures.Count -gt 0) {
    throw "offline network assertion failed at ${Stage}: $($failures -join '; ')"
  }
  return $state
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
  $branchOutput = ((git branch --show-current) | Out-String).Trim()
  Assert-LastExitCode 'git branch --show-current'
  $branch = if ([string]::IsNullOrWhiteSpace($branchOutput)) {
    '(detached)'
  } else {
    $branchOutput
  }
  if ([string]::IsNullOrWhiteSpace($ExpectedBranch)) {
    throw 'ExpectedBranch must not be empty'
  }
  if ($branch -ne $ExpectedBranch) {
    throw "unexpected Git branch: expected=$ExpectedBranch actual=$branch"
  }
  if ($head -ne $ExpectedHead.ToLowerInvariant()) {
    throw "unexpected Git HEAD: expected=$ExpectedHead actual=$head"
  }
  $stagedPaths = @(git diff --cached --name-only)
  Assert-LastExitCode 'git diff --cached --name-only'
  if ($stagedPaths.Count -gt 0) {
    throw "staged files are not allowed: $($stagedPaths -join ', ')"
  }
  $changed = @(git status --porcelain=v1 --untracked-files=all | ForEach-Object { $_.Substring(3).Replace('\', '/') })
  Assert-LastExitCode 'git status --porcelain'
  if ($changed.Count -gt 0) {
    throw "CNG-109 evidence requires a clean worktree; changed paths: $($changed -join ', ')"
  }

  $deviceStatePreflight = ((& $Adb -s $Serial get-state) | Out-String).Trim()
  if ($LASTEXITCODE -ne 0 -or $deviceStatePreflight -ne 'device') {
    throw "Android device was not ready: serial=$Serial state=$deviceStatePreflight exit=$LASTEXITCODE"
  }
  $adbReady = $true

  $qemu = (Invoke-Adb shell getprop ro.kernel.qemu | Out-String).Trim()
  $api = (Invoke-Adb shell getprop ro.build.version.sdk | Out-String).Trim()
  $abi = (Invoke-Adb shell getprop ro.product.cpu.abi | Out-String).Trim()
  $deviceType = if ($qemu -eq '1') { 'emulator' } else { 'physical' }
  $deviceMetadata = [ordered]@{
    serial = $Serial
    type = $deviceType
    qemu = $qemu
    api = $api
    abi = $abi
    manufacturer = (Invoke-Adb shell getprop ro.product.manufacturer | Out-String).Trim()
    model = (Invoke-Adb shell getprop ro.product.model | Out-String).Trim()
    device = (Invoke-Adb shell getprop ro.product.device | Out-String).Trim()
    buildFingerprint = (Invoke-Adb shell getprop ro.build.fingerprint | Out-String).Trim()
    securityPatch = (Invoke-Adb shell getprop ro.build.version.security_patch | Out-String).Trim()
  }
  if ($deviceType -ne $ExpectedDeviceType) {
    throw "unexpected device type: expected=$ExpectedDeviceType actual=$deviceType qemu=$qemu"
  }
  if ($api -ne $ExpectedApi) {
    throw "unexpected Android API: expected=$ExpectedApi actual=$api"
  }
  if (-not [string]::IsNullOrWhiteSpace($ExpectedAbi) -and $abi -ne $ExpectedAbi) {
    throw "unexpected device ABI: expected=$ExpectedAbi actual=$abi"
  }

  $lockPath = Join-Path (Get-Location) 'pubspec.lock'
  $lockBlobAtHead = (git rev-parse "${head}:pubspec.lock").Trim()
  Assert-LastExitCode 'git rev-parse HEAD:pubspec.lock'
  $lockContent = Get-Content -Raw -Encoding UTF8 -LiteralPath $lockPath
  $lockHostedUrls = @(
    [regex]::Matches($lockContent, '(?m)^\s+url:\s+"([^"]+)"\s*$') |
      ForEach-Object { $_.Groups[1].Value } |
      Sort-Object -Unique
  )
  if ($lockHostedUrls.Count -ne 1) {
    throw "pubspec.lock must contain exactly one hosted package URL; actual=$($lockHostedUrls -join ', ')"
  }
  if ($lockHostedUrls[0] -ne $ExpectedPubHostedUrl) {
    throw "unexpected pubspec.lock hosted URL: expected=$ExpectedPubHostedUrl actual=$($lockHostedUrls[0])"
  }
  $lockHashBeforePubGet = (Get-FileHash $lockPath -Algorithm SHA256).Hash.ToLowerInvariant()
  $env:PUB_HOSTED_URL = $ExpectedPubHostedUrl
  $env:FLUTTER_STORAGE_BASE_URL = $FlutterStorageBaseUrl
  if (-not [string]::IsNullOrWhiteSpace($JavaHome)) {
    $javaExecutable = Join-Path $JavaHome 'bin\java.exe'
    if (-not (Test-Path -LiteralPath $javaExecutable)) {
      throw "JavaHome does not contain bin\java.exe: $JavaHome"
    }
    $env:JAVA_HOME = $JavaHome
  }
  $pubGetStartedAt = (Get-Date).ToUniversalTime().ToString('o')
  $previousErrorActionPreference = $ErrorActionPreference
  try {
    $ErrorActionPreference = 'Continue'
    & $Flutter pub get --offline --enforce-lockfile *> (Join-Path $artifactRoot 'pub-get.log')
    $pubGetExit = $LASTEXITCODE
  } finally {
    $ErrorActionPreference = $previousErrorActionPreference
  }
  if ($pubGetExit -ne 0) { throw "flutter pub get failed: $pubGetExit" }
  $pubGetFinishedAt = (Get-Date).ToUniversalTime().ToString('o')
  $lockHashAfterPubGet = (Get-FileHash $lockPath -Algorithm SHA256).Hash.ToLowerInvariant()
  if ($lockHashAfterPubGet -ne $lockHashBeforePubGet) {
    throw "flutter pub get changed pubspec.lock: $lockHashBeforePubGet -> $lockHashAfterPubGet"
  }

  & $Flutter build apk --debug --no-pub
  Assert-LastExitCode 'APK build'
  $apk = Join-Path (Get-Location) 'build\app\outputs\flutter-apk\app-debug.apk'
  if (-not (Test-Path $apk) -or (Get-Item $apk).Length -le 0) {
    throw 'debug APK missing or empty'
  }
  $apkHashInitial = (Get-FileHash $apk -Algorithm SHA256).Hash.ToLowerInvariant()
  Write-Json 'run-metadata.json' @{
    runId = $runId
    artifactDir = $artifactRoot
    deviceArtifactProtocol = 'application-support-export-via-run-as'
    runnerProtocol = 'cng109-android-e2e-v2'
    runnerPath = $runnerPath
    runnerSha256 = $runnerSha256
    networkControlProtocol = 'cmd-connectivity-svc-dumpsys-ping'
    device = $deviceMetadata
    expectedDeviceType = $ExpectedDeviceType
    expectedApi = $ExpectedApi
    expectedAbi = $ExpectedAbi
    gitHead = $head
    gitWorktreeRoot = $repoRootFull
    expectedBranch = $ExpectedBranch
    expectedHead = $ExpectedHead.ToLowerInvariant()
    actualBranch = $branch
    actualHead = $head
    package = $package
    activity = $activity
    strictMode = 'Latest'
    javaHome = $env:JAVA_HOME
    pubGetMode = 'offline-enforce-lockfile'
    pubHostedUrl = $ExpectedPubHostedUrl
    lockHostedUrls = $lockHostedUrls
    flutterStorageBaseUrl = $FlutterStorageBaseUrl
    pubGetExit = $pubGetExit
    pubGetStartedAt = $pubGetStartedAt
    pubGetFinishedAt = $pubGetFinishedAt
    lockBlobAtHead = $lockBlobAtHead
    lockHashBeforePubGet = $lockHashBeforePubGet
    lockHashAfterPubGet = $lockHashAfterPubGet
    apkSha256 = $apkHashInitial
    apkSha256Initial = $apkHashInitial
  }
  Write-Json 'adb-capability.log' @{ adb = $Adb; apk = $apk; apkSha256 = $apkHashInitial; activity = $activity }
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
  foreach ($savedValue in @($airplaneBefore, $wifiBefore, $mobileBefore)) {
    if ($savedValue -notin @('0', '1')) {
      throw "network setting was not restorable as a boolean: $savedValue"
    }
  }
  $networkSaved = $true
  Write-Json 'network-before.json' ([ordered]@{
    airplane = $airplaneBefore
    wifi = $wifiBefore
    mobile = $mobileBefore
  })

  Set-AirplaneMode $true 'airplane-enable.log'
  Set-NetworkRadiosOffline
  Wait-NetworkSettings '1' '0' 'offline enable'
  $networkOfflinePrepare = Assert-OfflineNetworkState 'prepare'
  Write-Json 'network-airplane.json' $networkOfflinePrepare

  & $Flutter test -d $Serial --no-uninstall --no-pub --dart-define="CNG109_RUN_ID=$runId" --dart-define="CNG109_ARTIFACT_DIR=$artifactRoot" integration_test/cng109_prepare_test.dart
  Assert-LastExitCode 'prepare integration test'
  $apkHashAfterPrepareTest = (Get-FileHash $apk -Algorithm SHA256).Hash.ToLowerInvariant()
  Copy-AppEvidence 'prepare-result.json' 'prepare-result.json'
  $prepareResult = Get-Content (Join-Path $artifactRoot 'prepare-result.json') -Raw | ConvertFrom-Json
  $beforeOutbox = @($prepareResult.outbox)
  if ($beforeOutbox.Count -ne 6) { throw "prepare outbox count was $($beforeOutbox.Count), expected 6" }
  $beforeOutbox | ConvertTo-Json -Depth 12 | Set-Content -Encoding utf8 (Join-Path $artifactRoot 'outbox-before.json')

  $networkOfflineForceStop = Assert-OfflineNetworkState 'force-stop'
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
    networkOffline = $networkOfflineForceStop
    pidBeforeForceStop = $pidBefore
    forceStopExit = $forceStopExit
    pidAfterStop = $pidAfterStop
    pidAfterRestart = $pidAfterRestart
  }

  $networkOfflineVerify = Assert-OfflineNetworkState 'verify'
  & $Flutter test -d $Serial --no-uninstall --no-pub --dart-define="CNG109_RUN_ID=$runId" --dart-define="CNG109_ARTIFACT_DIR=$artifactRoot" integration_test/cng109_verify_test.dart
  Assert-LastExitCode 'verify integration test'
  $apkHashAfterVerifyTest = (Get-FileHash $apk -Algorithm SHA256).Hash.ToLowerInvariant()
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
  Write-Json 'apk-hashes.json' @{
    gitHead = $head
    cleanWorktreeRequired = $true
    integrationTestsRebuildApk = $true
    initial = $apkHashInitial
    afterPrepareTest = $apkHashAfterPrepareTest
    afterVerifyTest = $apkHashAfterVerifyTest
  }
  Write-Json 'airplane-stages.json' @{
    prepare = $networkOfflinePrepare
    forceStop = $networkOfflineForceStop
    verify = $networkOfflineVerify
  }
}
catch {
  $primaryFailure = $_
  Write-Error $_
}
finally {
  if ($installed) {
    try {
      & $Adb -s $Serial shell am force-stop $package | Out-Null
      $forceStopCleanupExit = $LASTEXITCODE
      if ($forceStopCleanupExit -ne 0) { Add-CleanupFailure 'force-stop cleanup' "exit=$forceStopCleanupExit" }
    } catch { Add-CleanupFailure 'force-stop cleanup' $_ }
  }

  if ($networkSaved) {
    try {
      Set-AirplaneMode ($airplaneBefore -eq '1') 'airplane-restore.log'
      if ($wifiBefore -eq '1') {
        Invoke-Adb shell svc wifi enable | Out-Null
      } else {
        Invoke-Adb shell svc wifi disable | Out-Null
      }
      if ($mobileBefore -eq '1') {
        Invoke-Adb shell svc data enable | Out-Null
      } else {
        Invoke-Adb shell svc data disable | Out-Null
      }
      Wait-NetworkSettings $airplaneBefore $wifiBefore 'network restore' $mobileBefore
      $airplaneAfter = Read-Setting 'airplane_mode_on'
      $wifiAfter = Read-Setting 'wifi_on'
      $mobileAfter = Read-Setting 'mobile_data'
      $airplaneCommandAfter = (
        Invoke-Adb shell cmd connectivity airplane-mode | Out-String
      ).Trim()
      $airplaneCommandExpected = if ($airplaneBefore -eq '1') {
        '(?i)\b(enabled|true|1)\b'
      } else {
        '(?i)\b(disabled|false|0)\b'
      }
      $networkRestored = (
        $airplaneAfter -eq $airplaneBefore -and
        $wifiAfter -eq $wifiBefore -and
        $mobileAfter -eq $mobileBefore -and
        $airplaneCommandAfter -match $airplaneCommandExpected
      )
      if (-not $networkRestored) { Add-CleanupFailure 'network restore' "expected airplane=$airplaneBefore wifi=$wifiBefore mobile=$mobileBefore; actual airplane=$airplaneAfter wifi=$wifiAfter mobile=$mobileAfter" }
      Write-Json 'network-after.json' @{
        airplane = $airplaneAfter
        airplaneCommand = $airplaneCommandAfter
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

  if ($adbReady) {
    try { $deviceState = ((& $Adb -s $Serial get-state) | Out-String).Trim() } catch { Add-CleanupFailure 'device state' $_ }
    if ($deviceState -ne 'device') { Add-CleanupFailure 'device state' "expected device, actual $deviceState" }
  }

  try {
    $finalStaged = @(git diff --cached --name-only)
    if ($LASTEXITCODE -ne 0) { throw 'could not inspect final staged files' }
    $finalChanged = @(git status --porcelain=v1 --untracked-files=all | ForEach-Object { $_.Substring(3).Replace('\', '/') })
    if ($LASTEXITCODE -ne 0) { throw 'could not inspect final worktree state' }
    $finalUnexpected = @($finalChanged)
    git diff --check
    $finalDiffCheckExit = $LASTEXITCODE
    $finalHead = (git rev-parse HEAD).Trim()
    $finalBranchOutput = ((git branch --show-current) | Out-String).Trim()
    $finalBranch = if ([string]::IsNullOrWhiteSpace($finalBranchOutput)) {
      '(detached)'
    } else {
      $finalBranchOutput
    }
    if ($finalStaged.Count -gt 0) { Add-CleanupFailure 'final git' "staged files: $($finalStaged -join ', ')" }
    if ($finalUnexpected.Count -gt 0) { Add-CleanupFailure 'final git' "unexpected files: $($finalUnexpected -join ', ')" }
    if ($finalDiffCheckExit -ne 0) { Add-CleanupFailure 'final git' "git diff --check exit=$finalDiffCheckExit" }
    if (
      $finalHead -ne $ExpectedHead.ToLowerInvariant() -or
      $finalBranch -ne $ExpectedBranch
    ) {
      Add-CleanupFailure 'final git' (
        "expected branch=$ExpectedBranch head=$($ExpectedHead.ToLowerInvariant()); " +
        "actual branch=$finalBranch head=$finalHead"
      )
    }
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
      finalBranch = $finalBranch
      finalHead = $finalHead
      expectedBranch = $ExpectedBranch
      expectedHead = $ExpectedHead.ToLowerInvariant()
      expectedDeviceType = $ExpectedDeviceType
      actualDeviceType = $deviceType
      networkOfflinePrepare = $networkOfflinePrepare
      networkOfflineForceStop = $networkOfflineForceStop
      networkOfflineVerify = $networkOfflineVerify
      apkSha256Initial = $apkHashInitial
      apkSha256AfterPrepareTest = $apkHashAfterPrepareTest
      apkSha256AfterVerifyTest = $apkHashAfterVerifyTest
    }
  } catch { Add-CleanupFailure 'cleanup evidence' $_ }
  Stop-Transcript | Out-Null
}

if ($primaryFailure -or $cleanupFailure.Count -gt 0) { exit 1 }
exit 0
