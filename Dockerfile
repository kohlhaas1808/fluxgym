# Use the NVIDIA CUDA base image
FROM nvidia/cuda:12.2.2-base-ubuntu22.04

# Set the working directory in the container
WORKDIR /fluxgym

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    python3 \
    python3-venv \
    python3-pip \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Clone the necessary repositories
RUN git clone https://github.com/cocktailpeanut/fluxgym . \
    && git clone -b sd3 https://github.com/kohya-ss/sd-scripts sd-scripts

# Create and activate the virtual environment
RUN python3 -m venv env && \
    /bin/bash -c "source env/bin/activate && pip install --upgrade pip"

# Install dependencies for sd-scripts, Fluxgym, and JupyterLab
RUN /bin/bash -c "source env/bin/activate && \
    pip install -r requirements.txt && \
    cd sd-scripts && pip install -r requirements.txt && \
    cd .. && \
    pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu121 && \
    pip install jupyterlab"

# Create directories for models
RUN mkdir -p /models/clip /models/vae /models/unet /outputs

# Expose ports for JupyterLab and the app
EXPOSE 7860 8888

# Start JupyterLab and the app
CMD ["/bin/bash", "-c", "source env/bin/activate && \
    curl -L -o /models/clip/clip_l.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors && \
    curl -L -o /models/clip/t5xxl_fp16.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors && \
    curl -L -o /models/vae/ae.sft https://huggingface.co/cocktailpeanut/xulf-dev/resolve/main/ae.sft && \
    curl -L -o /models/unet/flux1-dev.sft https://huggingface.co/cocktailpeanut/xulf-dev/resolve/main/flux1-dev.sft && \
    jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root & python app.py"]
