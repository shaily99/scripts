#!/bin/sh 
#SBATCH --gres=gpu:A6000:1
#SBATCH --partition=general
#SBATCH --mem=32GB
#SBATCH --time 1-23:55:00 
#SBATCH --job-name=llama2chat_7B
#SBATCH --error=<LOG DIR>/llama2chat_7B.err
#SBATCH --output=<LOG DIR>/llama2chat_7B.out
#SBATCH --mail-type=END
#SBATCH --mail-user=<EMAIL>

mkdir -p /scratch/<ID>
source ~/miniconda3/etc/profile.d/conda.sh


HUGGINGFACE_TOKEN="HF LOGIN TOKEN HERE"
huggingface-cli login --token "${HUGGINGFACE_TOKEN}"

conda activate /home/<ID>/miniconda3/envs/tgi-env

cd /home/<ID>/text-generation-inference


MODEL_ID="meta-llama/Llama-2-7b-chat-hf" # Same as model ID on HF

PORT=8081
if ss -tulwn | grep -q ":$PORT "; then
    echo "Port $PORT is already in use. Exiting..."
    exit 1
else
    text-generation-launcher \
        --model-id $MODEL_ID \
        --port $PORT \
        --quantize bitsandbytes \
        --shard-uds-path <SCRATCH DIR> \
        --huggingface-hub-cache <DIR TO DOWNLOAD WEIGHTS> # Shared model cache on babel or your own, ideally in /data/..
fi
echo $PORT
