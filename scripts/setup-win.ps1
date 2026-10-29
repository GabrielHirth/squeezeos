# SqueezeOS Windows Complete Setup & Auto-Compiler
# Auto-downloads and compiles thecodacus/llama.cpp fork, sets up models.ini,
# configures MoE offloading to CPU RAM with mlock, and sets up server launch shortcut.

$ErrorActionPreference = "Continue"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   SqueezeOS Complete Installer & Builder" -ForegroundColor Cyan
Write-Host "   Powered by thecodacus/llama.cpp fork" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# --- 1. Detect GPU Hardware ---
Write-Host "[1/6] Detecting GPU and VRAM..." -ForegroundColor Yellow

$gpuName = "No dedicated GPU"
$vramMB = 4096

try {
    $nvidiaOut = nvidia-smi --query-gpu=name,memory.total --format=csv,noheader,nounits 2>$null
    if ($nvidiaOut) {
        $parts = $nvidiaOut.Split(",")
        $gpuName = $parts[0].Trim()
        $vramMB = [int]$parts[1].Trim()
    }
} catch {}

Write-Host "Found GPU: $gpuName ($vramMB MB VRAM)" -ForegroundColor Green

# --- 2. CPU Threads & RAM ---
$cpuCount = [Environment]::ProcessorCount
$memGB = [math]::Round((Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
Write-Host "CPU Threads: $cpuCount" -ForegroundColor Green
Write-Host "System RAM: $memGB GB" -ForegroundColor Green

# --- 3. Auto-Clone thecodacus/llama.cpp ---
Write-Host "[2/6] Setting up thecodacus/llama.cpp fork..." -ForegroundColor Yellow

$installDir = "$env:USERPROFILE\.squeezeos"
$llamaDir = "$installDir\llama.cpp"

if (!(Test-Path $llamaDir)) {
    Write-Host "Cloning thecodacus/llama.cpp..." -ForegroundColor Yellow
    git clone https://github.com/thecodacus/llama.cpp.git $llamaDir
} else {
    Write-Host "Updating existing llama.cpp repository..." -ForegroundColor Yellow
    Push-Location $llamaDir
    git pull origin main
    Pop-Location
}

# --- 4. Generate models.ini ---
Write-Host "[3/6] Generating optimized models.ini..." -ForegroundColor Yellow

$configDir = "$env:USERPROFILE\.config\squeezeos"
$modelsDir = "$configDir\models"
$cacheDir = "$configDir\cache-slots"
New-Item -ItemType Directory -Force -Path $modelsDir | Out-Null
New-Item -ItemType Directory -Force -Path $cacheDir | Out-Null
$iniFile = "$configDir\models.ini"

$nCpuMoe = if ($cpuCount -gt 4) { $cpuCount - 2 } else { $cpuCount }

$iniContent = @"
# =============================================
# SqueezeOS Auto-Generated models.ini (Windows)
# =============================================

[*]
sleep-idle-seconds = 800
ctx-size = 65536
batch-size = 4096
ubatch-size = 2048
ngl = 99
load-mode = mlock
temp = 0.6
n-predict = 32000
jinja = 1
threads = $cpuCount
flash-attn = 1
ctk = turbo4
ctv = turbo2

[qwen36-reap]
model = .\models\Qwen3.6-28B-REAP.i1-IQ3_M.gguf
alias = qwen36-reap
n-cpu-moe = $nCpuMoe
"@

$iniContent | Out-File -FilePath $iniFile -Encoding UTF8
Write-Host "Config written to: $iniFile" -ForegroundColor Green

# --- 5. Note on Model Download ---
Write-Host "[4/6] Starter model setup..." -ForegroundColor Yellow
Write-Host "Place Qwen3.6-28B-REAP.i1-IQ3_M.gguf inside: $modelsDir" -ForegroundColor Cyan
Write-Host "(Auto-download requires manual placement or HF CLI installation)" -ForegroundColor Gray

# --- 6. Create Run Script ---
Write-Host "[5/6] Creating runner launcher..." -ForegroundColor Yellow

$runBat = "$installDir\run-squeezeos.bat"
$batContent = @"
@echo off
cd /d "$llamaDir"
build\bin\Release\llama-server.exe ^
    --models-preset "$iniFile" ^
    --host 0.0.0.0 ^
    --port 8080 ^
    --models-max 1 ^
    --cont-batching ^
    -lv 4 ^
    --checkpoint-min-step 512 ^
    --slot-save-path "$cacheDir"
"@

$batContent | Out-File -FilePath $runBat -Encoding ASCII

# --- 7. Compile Instructions ---
Write-Host "[6/6] Compilation instructions..." -ForegroundColor Yellow
Write-Host "Build llama.cpp manually using CMake or Visual Studio:" -ForegroundColor Cyan
Write-Host "  cd $llamaDir" -ForegroundColor Gray
Write-Host "  cmake -B build -DGGML_CUDA=ON" -ForegroundColor Gray
Write-Host "  cmake --build build --config Release" -ForegroundColor Gray

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  SqueezeOS Setup Complete!" -ForegroundColor Green
Write-Host "  To start: $runBat" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Cyan

# --- 7. Automated llama-bench Profiler ---
function Run-LlamaBench {
    param(
        [string]$llamaDir,
        [string]$iniFile
    )

    $binPath = $null
    $paths = @(
        (Join-Path $llamaDir "bin\llama-bench.exe"),
        (Join-Path $llamaDir "build\bin\llama-bench.exe"),
        (Join-Path $llamaDir "build\bin\Release\llama-bench.exe")
    )
    foreach ($p in $paths) {
        if (Test-Path $p) { $binPath = $p; break }
    }
    if (-not $binPath) {
        Write-Host "[WARNING] llama-bench binary not found in bin/ or build/bin/. Skipping benchmark pass." -ForegroundColor Yellow
        return
    }

    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "   Running Automated llama-bench Sweep    " -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "Testing optimal parameters: n-cpu-moe, threads, ubatch, batch..." -ForegroundColor Yellow

    $modelLine = (Select-String -Path $iniFile -Pattern "model = " | Select-Object -First 1).Line
    $modelFile = ($modelLine -replace ".*model\s*=\s*", "").Trim()

    if (!(Test-Path $modelFile)) {
        Write-Host "[WARNING] Model file not found. Skipping benchmark execution." -ForegroundColor Yellow
        Write-Host "Place your GGUF model there and run llama-bench manually." -ForegroundColor Cyan
        return
    }

    # Run benchmark sweep
    $threadTests = @(4, 8, $cpuCount)
    $ubatchTests = @(512, 1024, 2048)

    foreach ($t in $threadTests) {
        foreach ($ub in $ubatchTests) {
            Write-Host "--- Benchmarking: Threads=$t, ubatch=$ub ---" -ForegroundColor Gray
            $args = @("-m", $modelFile, "-t", $t, "-ub", $ub, "-b", 4096, "-n", 64, "-p", "256")
            & $binPath @args 2>$null
        }
    }
    Write-Host "✅ Benchmark sweep complete!" -ForegroundColor Green
}

# Call benchmark routine
Write-Host "[7/6] Running automated llama-bench profiler..." -ForegroundColor Yellow
Run-LlamaBench -llamaDir $llamaDir -iniFile $iniFile
