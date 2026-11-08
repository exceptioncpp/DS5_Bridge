# GitHub-hosted Windows runners occasionally receive 504 responses while
# Electron's postinstall downloads its binary. npm's registry retry flags do
# not cover this separate network request.
$ErrorActionPreference = 'Stop'
$attempts = 4
for ($attempt = 1; $attempt -le $attempts; $attempt++) {
  Write-Host "npm ci attempt $attempt/$attempts"
  if ($attempt -ge 3) {
    # Fallback CDN for electron's install.js. Earlier attempts use the official URL.
    $env:ELECTRON_MIRROR = 'https://npmmirror.com/mirrors/electron/'
    Write-Host 'Using Electron binary download mirror for retry'
  } else {
    Remove-Item Env:ELECTRON_MIRROR -ErrorAction SilentlyContinue
  }

  & npm.cmd ci --no-audit --no-fund
  if ($LASTEXITCODE -eq 0) {
    Write-Host 'npm ci succeeded'
    exit 0
  }
  Write-Warning "npm ci failed with exit code $LASTEXITCODE"
  if ($attempt -lt $attempts) {
    # npm ci removes node_modules itself. A transient EPERM during cleanup
    # should not suppress further retries, but don't mask the original error.
    $delay = 15 * $attempt
    Write-Host "Retrying after $delay seconds"
    Start-Sleep -Seconds $delay
  }
}
throw "npm ci failed after $attempts attempts (including Electron mirror retries)"
