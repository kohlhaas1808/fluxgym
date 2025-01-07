#!/bin/bash

# Update pip
cd fluxgym

# Download models
# curl -L -o models/clip/clip_l.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors
# curl -L -o models/clip/t5xxl_fp16.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors
# curl -L -o models/vae/ae.sft https://huggingface.co/cocktailpeanut/xulf-dev/resolve/main/ae.sft
# curl -L -o models/unet/flux1-dev.sft https://huggingface.co/cocktailpeanut/xulf-dev/resolve/main/flux1-dev.sft

# Start JupyterLab and the app
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root &
env/bin/python app.py
