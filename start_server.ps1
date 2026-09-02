param (
    [string]$ModelPath = "E:\ninfer\model\qwen3_8_27b.ninfer",
    [string]$HostIp = "0.0.0.0",
    [int]$Port = 8000,
    [int]$DraftTokens = 3,
    [int]$MaxContext = 262144,
    [string]$KvDtype = "int8",
    [int]$MaxConcurrency = 4,
    [int]$PendingTimeoutMs = 600000,
    [string]$ApiKey = "",
    [switch]$NoThinking = $false
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

$env:PATH = "E:\anaconda\envs\cuda_build\Library\bin;E:\anaconda\envs\cuda_build\bin;$env:PATH"
$ExePath = Join-Path $PSScriptRoot "build\apps\ninfer-serve.exe"

if (-not (Test-Path $ExePath)) {
    Write-Host "[ERROR] ninfer-serve.exe not found at $ExePath" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $ModelPath)) {
    Write-Host "[ERROR] Model file not found at $ModelPath" -ForegroundColor Red
    exit 1
}

Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "  NInfer TP2 API Server (Dual RTX 3080 20GB + MTP 256K Context) " -ForegroundColor Green
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host " Model       : $ModelPath" -ForegroundColor Yellow
Write-Host " Host/Port   : http://${HostIp}:${Port}" -ForegroundColor Yellow
Write-Host " Endpoints   : /v1/chat/completions , /v1/messages , /v1/models" -ForegroundColor Yellow
Write-Host " Parallelism : Tensor Parallel TP=2 (Devices: 0, 1)" -ForegroundColor Yellow
Write-Host " Speculative : MTP (Draft Tokens: $DraftTokens)" -ForegroundColor Yellow
Write-Host " Max Context : $MaxContext (256K Full Context)" -ForegroundColor Yellow
Write-Host " KV Cache    : $KvDtype (8.38 GiB / GPU)" -ForegroundColor Yellow
Write-Host " Concurrency : $MaxConcurrency active requests (Timeout: 600s)" -ForegroundColor Yellow
Write-Host " Real-Time   : Prefill & Decode tok/s metrics enabled" -ForegroundColor Yellow
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host ""

$argsList = @(
    $ModelPath,
    "--host", $HostIp,
    "--port", $Port,
    "--tp", "2",
    "--devices", "0,1",
    "--spec", "mtp",
    "--draft-tokens", "$DraftTokens",
    "--max-context", "$MaxContext",
    "--kv-dtype", "$KvDtype",
    "--max-concurrency", "$MaxConcurrency",
    "--pending-timeout-ms", "$PendingTimeoutMs",
    "--max-pending-requests", "64",
    "--log-stats-interval-ms", "2000",
    "--cors"
)

if ($ApiKey -ne "") {
    $argsList += @("--api-key", $ApiKey)
}

if ($NoThinking) {
    $argsList += @("--no-thinking")
}

& $ExePath $argsList
