# SqueezeOS 🚀

> **Run 35B+ LLMs on budget & legacy GPUs (like the GTX 1650 Super) with aggressive memory offloading, custom quantization, and extreme llama.cpp tuning.**

[![GitHub stars](https://img.shields.io/github/stars/gabrielhirth/squeezeos?style=flat-square&color=emerald)](https://github.com/gabrielhirth/squeezeos/stargazers)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy%2520Me%2520A%2520Coffee-F70000?style=flat-square&logo=buy-me-a-coffee&logoColor=white)](https://www.buymeacoffee.com/gabrielhirth)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](LICENSE)

---

## ⚡️ The Problem

Stock local AI runners (like Ollama) take one look at a 4GB/6GB VRAM budget card, throw an `insufficient VRAM` error, and give up. 

**SqueezeOS** bypasses these limits by combining aggressive quantization, precise memory offloading, KV-cache optimizations, and hardware-tailored tuning to squeeze heavy open-weight models (up to 35B parameters) onto hardware everyone else considers obsolete.

---

## 📊 Benchmark Proof

* **Hardware**: NVIDIA GTX 1650 Super (4GB VRAM)
* **Model**: 35B GGUF Quant (e.g., Qwen/Llama variants)
* **Result**: Smooth, usable token streaming on constrained hardware without crashing.
* **Secret Sauce**: Custom hardware profiling + optimized `llama.cpp` parameters.

---

## 🛠️ Quick-Start Guide

### 🐧 Linux / WSL (Ubuntu / Debian / Arch)
```bash
git clone https://github.com/gabrielhirth/squeezeos.git
cd squeezeos
chmod +x ./scripts/setup-linux.sh
./scripts/setup-linux.sh
```

*(Windows native PowerShell script is currently in a refactor branch — WSL is fully supported and recommended).*

The automated script will:
1. **Detect** your exact GPU, VRAM, CPU cores, and RAM.
2. **Classify** your hardware into a performance tier.
3. **Generate** an optimized config tailored to your system constraints.
4. **Advise** you on the best model weights for your specific setup.

---

## 🧠 How It Works (VRAM Tiers)

| Tier | Target Hardware | Recommended Model Size | Key Optimizations |
|:---|:---|:---|:---|
| **Ultra-Low** | GTX 1650 Super, RTX 3050 (4-6GB) | Up to 35B (Heavy offload) | Aggressive KV compression (`ctk=turbo4`), reduced batch sizes |
| **Low** | GTX 1660 Ti, RTX 3060 (6-8GB) | Up to 35B / 70B (Balanced) | Optimized GPU/CPU layer split |
| **Mid/High** | RTX 3090, 4080, 4090 (>12GB) | 70B+ | Maximum GPU layer utilization, ultra-long context |

---

## ☕ Support the Project & Custom Setups

If SqueezeOS saved your budget GPU from collecting dust, consider supporting further development:

* ☕ **Buy me a coffee**: [buymeacoffee.com/gabrielhirth](https://www.buymeacoffee.com/gabrielhirth)
* 💼 **Need custom setup/consulting?** If you want to deploy local AI infrastructure for your business or personal homelab without the headache, reach out via Telegram/Twitter (@gabrielhirth) for a 1-on-1 session.

---

## 🤝 Contributing

Pull requests, issues, and benchmark results on other budget cards (GTX 1060, RX 580, etc.) are extremely welcome!
