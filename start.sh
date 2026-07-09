#!/bin/bash

CONTAINER_NAME="$(whoami)_vllm"

if [ "$(docker ps -aq -f name=^${CONTAINER_NAME}$)" ]; then
    echo "Container ${CONTAINER_NAME} was found, removing..."
    docker rm -f ${CONTAINER_NAME}
fi

echo "Starting ${CONTAINER_NAME}..."

source .env


docker run --gpus all \
  --name ${CONTAINER_NAME} \
  -e HUGGING_FACE_HUB_TOKEN=${HUGGING_FACE_HUB_TOKEN} \
  -e PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True \
  -p 8086:8000 \
  -v ~/.cache/huggingface:/root/.cache/huggingface \
  vllm/vllm-openai \
  --model ${MODEL_NAME} \
  --trust-remote-code \
  --dtype auto \
  --gpu-memory-utilization 0.98 \
  --max-model-len ${MODEL_LEN} \
  --enable-auto-tool-choice \
  --tool-call-parser hermes