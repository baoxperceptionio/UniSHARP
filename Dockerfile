FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG PYTORCH_INDEX_URL=https://download.pytorch.org/whl/cu128
ARG TORCH_VERSION=2.10.0+cu128
ARG TORCHVISION_VERSION=0.25.0+cu128
ARG TORCHAUDIO_VERSION=2.10.0+cu128

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        git \
        libglib2.0-0 \
        libgl1 \
        libgomp1 \
        pkg-config \
        python3 \
        python3-dev \
        python3-pip \
        python3-venv \
        python-is-python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv ${VIRTUAL_ENV}
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}" \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/workspace \
    PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python

RUN python -m pip install --upgrade pip "setuptools<81" wheel

COPY requirements.txt ./
RUN pip install --no-cache-dir \
        --index-url "${PYTORCH_INDEX_URL}" \
        --extra-index-url https://pypi.org/simple \
        "torch==${TORCH_VERSION}" \
        "torchvision==${TORCHVISION_VERSION}" \
        "torchaudio==${TORCHAUDIO_VERSION}" \
    && sed '/^torch==/d;/^torchvision==/d;/^torchaudio==/d' requirements.txt > /tmp/requirements-no-torch.txt \
    && pip install --no-cache-dir -r /tmp/requirements-no-torch.txt \
    && pip install --no-cache-dir wandb

COPY . .

ENV PYTHONDONTWRITEBYTECODE=1

CMD ["bash"]
