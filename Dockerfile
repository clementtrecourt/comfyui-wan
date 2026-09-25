FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# 1. Dépendances système C / vidéo
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# 2. Cloner ComfyUI dans le conteneur (sur le SSD local !)
WORKDIR /app
RUN git clone --depth 1 https://github.com/comfyanonymous/ComfyUI.git /app/ComfyUI

# 3. Installer les dépendances du core ComfyUI
WORKDIR /app/ComfyUI
RUN pip install --no-cache-dir -r requirements.txt

# 4. Cloner les 13 custom nodes indispensables
WORKDIR /app/ComfyUI/custom_nodes
RUN git clone --depth 1 https://github.com/kijai/ComfyUI-WanVideoWrapper.git && \
    git clone --depth 1 https://github.com/kijai/ComfyUI-KJNodes.git && \
    git clone --depth 1 https://github.com/kijai/ComfyUI-WanAnimatePreprocess.git && \
    git clone --depth 1 --recursive https://github.com/kijai/ComfyUI-segment-anything-2.git && \
    git clone --depth 1 https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git && \
    git clone --depth 1 https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git && \
    git clone --depth 1 https://github.com/rgthree/rgthree-comfy.git && \
    git clone --depth 1 https://github.com/yolain/ComfyUI-Easy-Use.git && \
    git clone --depth 1 https://github.com/evanspearman/ComfyMath.git && \
    git clone --depth 1 https://github.com/digitaljohn/comfyui-propost.git && \
    git clone --depth 1 https://github.com/robgon-ai/CRT-Nodes.git && \
    git clone --depth 1 https://github.com/aining2022/ComfyUI_Swwan.git && \
    git clone --depth 1 --recursive https://github.com/Fannovel16/ComfyUI-Frame-Interpolation.git

# 5. Patch pour ComfyUI-Custom-Scripts (pysssss)
RUN cd ComfyUI-Custom-Scripts && \
    sed -i 's/shutil\.copy(/shutil.copyfile(/g' pysssss.py || true

# 6. Installer TOUTES les bibliothèques Python
RUN pip install --no-cache-dir \
    onnx \
    onnxruntime-gpu \
    einops \
    scipy \
    rich \
    timm \
    cupy-cuda12x \
    accelerate \
    diffusers \
    sentencepiece \
    av \
    imageio \
    imageio-ffmpeg \
    sageattention \
    comfyui-manager \
    opencv-python-headless \
    matplotlib \
    gguf \
    colour-science

# 7. Script d'entrée
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8888 8188

ENTRYPOINT ["/entrypoint.sh"]
