#!/bin/sh 
#SBATCH --gres=gpu:A6000:1
#SBATCH --partition=general
#SBATCH --mem=32GB
#SBATCH --time 1-23:55:00 
#SBATCH --job-name=llama2chat_7B
#SBATCH --error=/home/shailyjb/logs/llama2chat_7B.err
#SBATCH --output=/home/shailyjb/logs/llama2chat_7B.out
#SBATCH --mail-type=END
#SBATCH --mail-user=shailyjb@andrew.cmu.edu

mkdir -p /scratch/shailyjb
source ~/miniconda3/etc/profile.d/conda.sh


HUGGINGFACE_TOKEN="HF LOGIN TOKEN HERE"
huggingface-cli login --token "${HUGGINGFACE_TOKEN}"

conda activate /home/shailyjb/miniconda3/envs/tgi-env

cd /home/shailyjb/text-generation-inference


MODEL_ID="meta-llama/Llama-2-7b-chat-hf"

PORT=8081
if ss -tulwn | grep -q ":$PORT "; then
    echo "Port $PORT is already in use. Exiting..."
    exit 1
else
    text-generation-launcher \
        --model-id $MODEL_ID \
        --port $PORT \
        --quantize bitsandbytes \
        --shard-uds-path /scratch/shailyjb \
        --huggingface-hub-cache /data/tir/projects/tir5/users/shailyjb/hf_cache
fi
echo $PORT
