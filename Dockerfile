# # Use the official Python 3.8 image as a base
FROM python:3.8-slim

# Set environment variables to avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install build-essential only
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libgl1-mesa-glx \
    libglib2.0-0 \
    build-essential \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PyTorch, torchvision, torchaudio with cudatoolkit 11.3
RUN pip install --no-cache-dir \
    torch==1.12.1+cu113 \
    torchvision==0.13.1+cu113 \
    torchaudio==0.12.1 \
    -f https://download.pytorch.org/whl/cu113/torch_stable.html

# Set the working directory
WORKDIR /workspace

# Copy all necessary folders to /workspace in the container
COPY . .

# Change directory to install projectaria_tools
WORKDIR /workspace/projectaria_tools
RUN python3 -m pip install projectaria-tools'[all]'

# Set the working directory
WORKDIR /workspace
RUN pip install -r requirements.txt

WORKDIR /workspace/lib
RUN python setup.py build develop

RUN pip install torch_geometric
WORKDIR /workspace
# Default command
CMD ["python3"]
