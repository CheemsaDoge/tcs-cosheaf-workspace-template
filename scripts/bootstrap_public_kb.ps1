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

function Write-ManualSetupInstructions {
    param(
        [string]$ResolvedTarget
    )

    [Console]::Error.WriteLine(@"

Manual public KB setup:
  1. Ensure Git and network access are available, then clone:
       git clone "$repoUrl" "$ResolvedTarget"
  2. Keep the checkout readonly from this workspace.
  3. Do not copy private artifacts into the public KB.
  4. If you want this workspace to use that checkout directly, edit
     cosheaf.toml so the public KB root points at the checkout path.

This script did not modify kb/public.
"@)
    exit 1
}

if ([System.IO.Path]::IsPathRooted($TargetPath)) {
    $resolvedTarget = $TargetPath
} else {
    $resolvedTarget = Join-Path $repoRoot $TargetPath
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    [Console]::Error.WriteLine("Git is required to clone or update tcs-kb-public, but git was not found on PATH.")
    Write-ManualSetupInstructions -ResolvedTarget $resolvedTarget
}

if (Test-Path -LiteralPath $resolvedTarget) {
    $gitDir = Join-Path $resolvedTarget ".git"
    if (Test-Path -LiteralPath $gitDir) {
        if (-not $Update) {
            [Console]::Error.WriteLine(@"
Public KB checkout already exists:
  $resolvedTarget

Refusing to modify it without explicit confirmation.
Run again with -Update to fetch and fast-forward this checkout:
  .\scripts\bootstrap_public_kb.ps1 -TargetPath "$TargetPath" -Update
"@)
            exit 1
        }

        $currentBranch = git -C $resolvedTarget branch --show-current
        if (-not $currentBranch) {
            [Console]::Error.WriteLine("Target checkout is not on a branch: $resolvedTarget")
            exit 1
        }

        git -C $resolvedTarget fetch --tags origin $currentBranch
        if ($LASTEXITCODE -ne 0) {
            [Console]::Error.WriteLine("Failed to fetch public KB updates for: $resolvedTarget")
            Write-ManualSetupInstructions -ResolvedTarget $resolvedTarget
        }

        git -C $resolvedTarget merge --ff-only "origin/$currentBranch"
        if ($LASTEXITCODE -ne 0) {
            [Console]::Error.WriteLine("Failed to fast-forward public KB checkout: $resolvedTarget")
            Write-ManualSetupInstructions -ResolvedTarget $resolvedTarget
        }

        Write-Host ""
        Write-Host "Updated public KB checkout: $resolvedTarget"
        exit 0
    }

    [Console]::Error.WriteLine(@"
Target path already exists and is not a git checkout:
  $resolvedTarget

Refusing to overwrite user work. Choose a different target path or move the
existing directory yourself after checking its contents.
"@)
    exit 1
}

$parent = Split-Path -Parent $resolvedTarget
New-Item -ItemType Directory -Force -Path $parent | Out-Null
git clone $repoUrl $resolvedTarget
if ($LASTEXITCODE -ne 0) {
    [Console]::Error.WriteLine("Failed to clone public KB into: $resolvedTarget")
    Write-ManualSetupInstructions -ResolvedTarget $resolvedTarget
}

Write-Host ""
Write-Host "Cloned public KB checkout:"
Write-Host "  $resolvedTarget"
Write-Host ""
Write-Host "This script did not modify kb/public and did not copy private artifacts."
Write-Host "Use this checkout as a readonly reference, or explicitly edit cosheaf.toml"
Write-Host "if you want this workspace to point at a different public KB root."
