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
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Define environment variables for UID and GID and local timezone
ENV PUID=${PUID:-1000}
ENV PGID=${PGID:-1000}

# Create a group with the specified GID
RUN groupadd -g "${PGID}" appuser
# Create a user with the specified UID and GID
RUN useradd -m -s /bin/sh -u "${PUID}" -g "${PGID}" appuser


# Add alias for python -> python3
RUN ln -s /usr/bin/python3 /usr/bin/python

# Add Jupyter Notebook
RUN pip install jupyterlab

# Clone the necessary repositories
RUN git clone https://github.com/cocktailpeanut/fluxgym fluxgym && \
    cd fluxgym && \
    git clone -b sd3 https://github.com/kohya-ss/sd-scripts sd-scripts

# Create the virtual environment and install dependencies
RUN cd fluxgym && \
    python -m venv env && \
    cd sd-scripts && \
    /workspace/fluxgym/env/bin/pip install --no-cache-dir -r requirements.txt && \
    cd .. && \
    /workspace/fluxgym/env/bin/pip install --no-cache-dir -r requirements.txt && \
    /workspace/fluxgym/env/bin/pip install --no-cache-dir --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu121

# Create directories for models
RUN mkdir -p fluxgym/models/clip fluxgym/models/vae fluxgym/models/unet fluxgym/outputs


RUN chown -R appuser:appuser /workspace

#Run application as non-root
USER appuser

# Expose ports for JupyterLab and the app
EXPOSE 7860 8888

ENV GRADIO_SERVER_NAME="0.0.0.0"


COPY start.sh /workspace/start.sh
RUN chmod +x /workspace/start.sh
CMD ["/bin/bash", "/workspace/start.sh"]

