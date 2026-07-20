FROM rocm/pytorch:rocm7.14_ubuntu24.04_py3.12_pytorch_release_2.12.0

LABEL maintainer="caloutw"
LABEL org.opencontainers.image.title="ROCm-Stable-Diffusion-WebUI-gfx1151"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.authors="calou code platform"
LABEL org.opencontainers.image.description="[CCP] A stable diffusion webui container for gfx1151."

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

ENV HSA_OVERRIDE_GFX_VERSION=11.5.1

USER root
WORKDIR /spc

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
    curl \
    sudo \
    git \
    wget \
    ca-certificates \
    gnupg \
    tmux \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    openssh-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY requirements_versions.txt /spc/requirements_versions.txt
RUN pip install --no-cache-dir -r requirements_versions.txt

# Install CLIP first.
RUN pip install --no-cache-dir --no-build-isolation \
    https://github.com/openai/CLIP/archive/d50d76daa670286dd6cacf3bcd80b5e4823fc8e1.zip

RUN git clone https://github.com/lllyasviel/stable-diffusion-webui-forge.git

RUN mv /spc/requirements_versions.txt /spc/stable-diffusion-webui-forge/requirements_versions.txt

RUN sed -i 's|https://github.com/Stability-AI/stablediffusion.git|https://github.com/w-e-w/stablediffusion.git|' \
    stable-diffusion-webui-forge/modules/launch_utils.py 2>/dev/null || true

# Default open VAE tiled.
RUN echo '{\n\
  "customscript/forge_never_oom.py/txt2img/Enabled for VAE (always tiled)/value": true,\n\
  "customscript/forge_never_oom.py/img2img/Enabled for VAE (always tiled)/value": true\n\
}' > /spc/stable-diffusion-webui-forge/ui-config.json

EXPOSE 7860

CMD ["python3", "stable-diffusion-webui-forge/launch.py", "--listen", "--port", "7860", "--skip-python-version-check", "--skip-torch-cuda-test", "--opt-sdp-attention", "--no-half", "--enable-insecure-extension-access"]
