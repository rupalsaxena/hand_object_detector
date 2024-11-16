# Use the official CUDA base image with Ubuntu 20.04
FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TORCH_CUDA_ARCH_LIST="6.0 6.1 6.2 7.0 7.2 7.5 8.0 8.6"
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=$CUDA_HOME/bin:$PATH
ENV FORCE_CUDA=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    ca-certificates \
    libopenblas-dev \
    cmake \
    build-essential \
    libffi-dev \
    libgl1-mesa-glx \
    libgl1-mesa-dev \
    libglu1-mesa \
    libglu1-mesa-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda init && \
    /opt/conda/bin/conda install -y python=3.8 conda && \
    /opt/conda/bin/conda clean -ya
ENV PATH=/opt/conda/bin:$PATH

RUN conda create --name handobj_new python=3.8
RUN conda run -n handobj_new python --version

# Install PyTorch, torchvision, torchaudio with cudatoolkit 11.3
RUN pip3 install --no-cache-dir \
    torch==1.12.1+cu113 \
    torchvision==0.13.1+cu113 \
    torchaudio==0.12.1 \
    -f https://download.pytorch.org/whl/cu113/torch_stable.html

RUN apt-get update
RUN apt-get install -y software-properties-common
RUN apt-get update
RUN apt-get install -y libglib2.0-0 libsm6 libxext6 libxrender1
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
RUN pip install openai==0.28

RUN pip install git+https://github.com/openai/CLIP.git

WORKDIR /workspace
# Default command
CMD ["python3"]
