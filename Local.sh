docker run --rm -it \
    --name rocm-stable-diffusion-webui-gfx1151 \
    --device=/dev/kfd \
    --device=/dev/dri \
    --security-opt seccomp=unconfined \
    -p 7860:7860 \
    -v ~/stable-diffusion-webui/models:/spc/stable-diffusion-webui-forge/models \
    -v ~/stable-diffusion-webui/outputs:/spc/stable-diffusion-webui-forge/outputs \
    rocm-stable-diffusion-webui-gfx1151:latest