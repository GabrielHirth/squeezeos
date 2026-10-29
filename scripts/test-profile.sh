#!/bin/bash
# Test script to demonstrate the dynamic hardware profiling
# Simulate different VRAM tiers and show the optimized configs

echo "=========================================="
echo "  SqueezeOS Hardware Profiler - Demo Mode"
echo "=========================================="
echo ""

# Simulate different VRAM configurations
for test_vram in 4096 6144 8192 12288 24576; do
    echo "--- Simulating GPU with ${test_vram}MB VRAM ---"
    
    if [ "$test_vram" -lt 4000 ]; then
        tier="ultra-low"
    elif [ "$test_vram" -lt 8000 ]; then
        tier="low"
    elif [ "$test_vram" -lt 12000 ]; then
        tier="mid"
    else
        tier="high"
    fi
    
    echo "Tier: $tier"
    echo "Recommended ngl: $(( test_vram >= 12000 ? 99 : (test_vram >= 8000 ? 85 : (test_vram >= 4000 ? 68 : 45)) ))"
    echo ""
done

echo "=========================================="
echo "  Real profiling requires GPU detection."  
echo "  Run setup-linux.sh or setup-win.ps1 on"
echo "  a system with an NVIDIA GPU installed."
echo "=========================================="
