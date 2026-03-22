FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Basic tools and Python
RUN apt-get update \
 && apt-get install -y \
    python3 \
    python3-tk \
    python3-pip \
    git \
    curl \
    sudo \
    locales \
 && rm -rf /var/lib/apt/lists/*

# Jupyter + ipykernel   
RUN pip3 install --no-cache-dir \
    jupyter \
    ipykernel \
    notebook \
    jupyterlab \
    ipyturtle3

# Create non root user "coder"
RUN useradd -ms /bin/bash coder \
 && echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# VSIX-Dateien ins Image legen
COPY ms-python.python.vsix /opt/extensions/
COPY ms-toolsai.jupyter.vsix /opt/extensions/

USER coder

WORKDIR /home/coder

RUN mkdir -p /home/coder/project

RUN python3 -m ipykernel install --user --name "python3" --display-name "Python 3"

# Register default Python kernel for Jupyter / VS Code
RUN python3 -m ipykernel install --user --name "python3" --display-name "Python 3"
