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
RUN git clone https://github.com/cocktailpeanut/fluxgym fluxgym && \
    cd fluxgym && \
    git clone -b sd3 https://github.com/kohya-ss/sd-scripts sd-scripts

# Create the virtual environment and install dependencies
RUN cd fluxgym && \
    python -m venv env && \
    source env/bin/activate && \
    cd sd-scripts
    python pip install --no-cache-dir -r requirements.txt && \
    cd .. && \
    python pip install --no-cache-dir -r requirements.txt && \
    python -m pip install --no-cache-dir --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu121

# Create directories for models
RUN mkdir -p fluxgym/models/clip fluxgym/models/vae fluxgym/models/unet fluxgym/outputs

# Expose ports for JupyterLab and the app
EXPOSE 7860 8888

# Start JupyterLab and the app
CMD ["/bin/bash", "-c", "cd fluxgym && env/bin/python -m pip install --upgrade pip && \
    curl -L -o models/clip/clip_l.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors && \
    curl -L -o models/clip/t5xxl_fp16.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors && \
    curl -L -o models/vae/ae.sft https://huggingface.co/cocktailpeanut/xulf-dev/resolve/main/ae.sft && \
    curl -L -o models/unet/flux1-dev.sft https://huggingface.co/cocktailpeanut/xulf-dev/resolve/main/flux1-dev.sft && \
    jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root & \
    env/bin/python app.py"]
