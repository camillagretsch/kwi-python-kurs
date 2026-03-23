FROM codercom/example-base:ubuntu

# Run below commands as root user
USER root

ENV DEBIAN_FRONTEND=noninteractive

# Basic tools and Python
RUN apt-get update && apt-get install -y \
  python3 \
  python3-venv \
  python3-pip \
  python3-tk \
  git \
  curl \
  sudo \
  locales \
  && rm -rf /var/lib/apt/lists/*
  
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Jupyter + ipykernel 
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
      jupyter \
      ipykernel \
      notebook \
      jupyterlab \
      ipyturtle3

RUN mkdir -p /vsix
ADD ./ms-toolsai.jupyter-2023.8.1002501831.vsix /vsix
ADD ./ms-python.python-2024.8.1.vsix /vsix

USER coder
RUN code-server --install-extension eamodio.gitlens

WORKDIR /home/coder

RUN mkdir -p /home/coder/project

RUN python3 -m ipykernel install --user --name "python3" --display-name "Python 3"
