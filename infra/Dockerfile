FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Basic tools and Python
RUN apt-get update \
 && apt-get install -y \
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
      jupyterlab

# Create non root user "coder"
RUN useradd -ms /bin/bash coder \
 && echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER coder

RUN mkdir "/home/coder/project"

WORKDIR /home/coder

# Register default Python kernel for Jupyter / VS Code
RUN python3 -m ipykernel install --user --name "python3" --display-name "Python 3"
