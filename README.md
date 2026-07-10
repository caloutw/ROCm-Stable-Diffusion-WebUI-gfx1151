# ROCm-Stable-Diffusion-WebUI-gfx1151

Stable Diffusion WebUI (Forge) for AMD Strix Halo (gfx1151), built on the official ROCm 7.2 PyTorch image.

## Prerequisites

- **GPU**: AMD Strix Halo (gfx1151)
- **Kernel**: Tested on `6.18.38-061838-generic`.
- **Docker**: must be **Docker Engine (`docker-ce`)**, not Docker Desktop. Docker Desktop runs containers inside a VM and cannot see the host's `/dev/kfd` / `/dev/dri` GPU devices, so device passthrough will fail.

## Build

Create folders at home for persistent storage:

```bash
mkdir -p ~/stable-diffusion-webui/models
mkdir -p ~/stable-diffusion-webui/outputs
```

## Run

```bash
docker run -d \
    --name rocm-stable-diffusion-webui-gfx1151 \
    --device=/dev/kfd \
    --device=/dev/dri \
    --security-opt seccomp=unconfined \
    -p 7860:7860 \
    -v ~/stable-diffusion-webui/models:/spc/stable-diffusion-webui-forge/models \
    -v ~/stable-diffusion-webui/outputs:/spc/stable-diffusion-webui-forge/outputs \
    ghcr.io/caloutw/rocm-stable-diffusion-webui-gfx1151:latest
```

## Use

Open `http://localhost:7860` in your browser.

## What's different from a stock Forge build?

1. Built on the [official ROCm PyTorch image](https://hub.docker.com/r/rocm/pytorch) (`rocm7.2.4`) instead of a community nightly build — gfx1151 has Preview-level support starting in ROCm 7.2.
2. Fixed the Stable Diffusion repo reference (`Stability-AI/stablediffusion` → `w-e-w/stablediffusion`), since the original repo was taken down.
3. Refreshed `requirements_versions.txt` to fix a NumPy 2.0 incompatibility (`scikit-image` upgraded, since `launch.py` re-installs its bundled requirements on every startup and would otherwise overwrite the fix).
4. VAE tiling is enabled by default — without it, generation segfaults on this hardware.

## Result

Generated a 1536×960 image with `AnythingXL`, taking about 41 seconds.

Note: the **first** generation takes ~20 minutes, because MIOpen has to JIT-compile GPU kernels for your specific shapes on first use. Subsequent generations reuse the cache and are fast.
