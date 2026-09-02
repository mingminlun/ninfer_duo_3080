@echo off
chcp 65001 > nul
setlocal

set "PATH=E:\anaconda\envs\cuda_build\Library\bin;E:\anaconda\envs\cuda_build\bin;%PATH%"
set "MODEL_PATH=E:\ninfer\model\qwen3_8_27b.ninfer"
set "EXE_PATH=build\apps\ninfer-serve.exe"
set "HOST=0.0.0.0"
set "PORT=8000"
set "DRAFT_TOKENS=2"
set "MAX_CONTEXT=262144"
set "KV_DTYPE=int8"
set "MAX_CONCURRENCY=4"
set "PENDING_TIMEOUT_MS=600000"

if not exist "%EXE_PATH%" (
    echo [ERROR] %EXE_PATH% not found.
    pause
    exit /b 1
)

if not exist "%MODEL_PATH%" (
    echo [ERROR] Model file %MODEL_PATH% not found.
    pause
    exit /b 1
)

echo ===============================================================
echo   NInfer TP2 API Server (Dual RTX 3080 20GB + MTP 256K Context)
echo ===============================================================
echo  Model       : %MODEL_PATH%
echo  Host/Port   : http://%HOST%:%PORT%
echo  Endpoints   : /v1/chat/completions , /v1/messages , /v1/models
echo  Parallelism : Tensor Parallel TP=2 (Devices: 0, 1)
echo  Speculative : MTP (Draft Tokens: %DRAFT_TOKENS%)
echo  Max Context : %MAX_CONTEXT% (256K Full Context)
echo  KV Cache    : %KV_DTYPE% (8.38 GiB / GPU)
echo  Concurrency : %MAX_CONCURRENCY% active requests (Timeout: 600s)
echo  Real-Time   : Prefill ^& Decode tok/s metrics enabled
echo ===============================================================
echo.

"%EXE_PATH%" "%MODEL_PATH%" ^
    --host %HOST% ^
    --port %PORT% ^
    --tp 2 ^
    --devices 0,1 ^
    --spec mtp ^
    --draft-tokens %DRAFT_TOKENS% ^
    --max-context %MAX_CONTEXT% ^
    --kv-dtype %KV_DTYPE% ^
    --max-concurrency %MAX_CONCURRENCY% ^
    --pending-timeout-ms %PENDING_TIMEOUT_MS% ^
    --max-pending-requests 64 ^
    --log-stats-interval-ms 2000 ^
    --cors

if %ERRORLEVEL% neq 0 (
    echo.
    echo Server exited with error code %ERRORLEVEL%.
    pause
)
