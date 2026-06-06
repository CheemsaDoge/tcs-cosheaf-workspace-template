param(
    [string]$TargetPath = ".cosheaf/public-kb/tcs-kb-public",
    [switch]$Update
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptDir "..")
$repoUrl = if ($env:PUBLIC_KB_REPO_URL) {
    $env:PUBLIC_KB_REPO_URL
} else {
    "https://github.com/CheemsaDoge/tcs-kb-public.git"
}

if ([System.IO.Path]::IsPathRooted($TargetPath)) {
    $resolvedTarget = $TargetPath
} else {
    $resolvedTarget = Join-Path $repoRoot $TargetPath
}

if (Test-Path -LiteralPath $resolvedTarget) {
    $gitDir = Join-Path $resolvedTarget ".git"
    if (Test-Path -LiteralPath $gitDir) {
        if (-not $Update) {
            Write-Error @"
Public KB checkout already exists:
  $resolvedTarget

Refusing to modify it without explicit confirmation.
Run again with -Update to fetch and fast-forward this checkout:
  .\scripts\bootstrap_public_kb.ps1 -TargetPath "$TargetPath" -Update
"@
        }

        $currentBranch = git -C $resolvedTarget branch --show-current
        if (-not $currentBranch) {
            Write-Error "Target checkout is not on a branch: $resolvedTarget"
        }

        git -C $resolvedTarget fetch --tags origin $currentBranch
        git -C $resolvedTarget merge --ff-only "origin/$currentBranch"
        Write-Host ""
        Write-Host "Updated public KB checkout: $resolvedTarget"
        exit 0
    }

    Write-Error @"
Target path already exists and is not a git checkout:
  $resolvedTarget

Refusing to overwrite user work. Choose a different target path or move the
existing directory yourself after checking its contents.
"@
}

$parent = Split-Path -Parent $resolvedTarget
New-Item -ItemType Directory -Force -Path $parent | Out-Null
git clone $repoUrl $resolvedTarget

Write-Host ""
Write-Host "Cloned public KB checkout:"
Write-Host "  $resolvedTarget"
Write-Host ""
Write-Host "This script did not modify kb/public and did not copy private artifacts."
Write-Host "Use this checkout as a readonly reference, or explicitly edit cosheaf.toml"
Write-Host "if you want this workspace to point at a different public KB root."
