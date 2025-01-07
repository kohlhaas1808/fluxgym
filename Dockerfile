# Use the NVIDIA CUDA base image
FROM nvidia/cuda:12.2.2-base-ubuntu22.04

# Set the working directory in the container
WORKDIR /workspace

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    python3 \
    python3-venv \
    python3-pip \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add alias for python -> python3
RUN ln -s /usr/bin/python3 /usr/bin/python

# Clone the necessary repositories
RUN mkdir -p fluxgym && \
    git clone https://github.com/cocktailpeanut/fluxgym fluxgym && \
    git clone -b sd3 https://github.com/kohya-ss/sd-scripts fluxgym/sd-scripts

# Create and activate the virtual environment in fluxgym
RUN python -m venv fluxgym/env && \
    /bin/bash -c "source fluxgym/env/bin/activate && pip install --upgrade pip"

# Install dependencies for sd-scripts, Fluxgym, and Torch
RUN /bin/bash -c "source fluxgym/env/bin/activate && \
    pip install -r fluxgym/sd-scripts/requirements.txt && \
    pip install -r fluxgym/requirements.txt && \
    pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu121"

# Create directories for models
RUN mkdir -p fluxgym/models/clip fluxgym/models/vae fluxgym/models/unet fluxgym/outputs

# Expose ports for JupyterLab and the app
EXPOSE 7860 8888

# Start JupyterLab and the app
CMD ["/bin/bash", "-c", "source fluxgym/env/bin/activate && \
    curl -L -o fluxgym/models/clip/clip_l.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors && \
    curl -L -o fluxgym/models/clip/t5xxl_fp16.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors && \
    curl -L -o fluxgym/models/vae/ae.sft https://huggingface.co/cocktailpeanut/xulf-dev/resolve/main/ae.sft && \
    curl -L -o fluxgym/models/unet/flux1-dev.sft https://huggingface.co/cocktailpeanut/xulf-dev/resolve/main/flux1-dev.sft && \
    jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root & python fluxgym/app.py"]
    
