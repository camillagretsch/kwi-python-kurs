FROM codercom/enterprise-base:ubuntu

USER root

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
  python3 \
  python3-tk \
  python3-pip \
  git \
  curl \
  sudo \
  locales \
  && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir \
  jupyter \
  ipykernel \
  notebook \
  jupyterlab \
  ipyturtle3

RUN mkdir -p /vsix
ADD ./ms-toolsai.jupyter-2023.8.1002501831.vsix /vsix/
ADD ./ms-python.python-2024.8.1.vsix /vsix/

RUN useradd -ms /bin/bash coder && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers || true

USER coder
WORKDIR /home/coder

RUN mkdir -p /home/coder/project
RUN python3 -m ipykernel install --user --name "python3" --display-name "Python 3"
