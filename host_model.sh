#!/bin/sh 
#SBATCH --gres=gpu:A6000:1
#SBATCH --partition=general
#SBATCH --mem=64GB
#SBATCH --time 0-03:00:00              # time limit: (D-HH:MM) 
#SBATCH --job-name=llama_chat_7b
#SBATCH --error=/home/shailyjb/logs/llama_chat_7b.err
#SBATCH --output=/home/shailyjb/logs/llama_chat_7b.out
#SBATCH --mail-type=END
#SBATCH --mail-user=shailyjb@andrew.cmu.edu

mkdir -p /scratch/shailyjb
source ~/miniconda3/etc/profile.d/conda.sh

conda activate /data/tir/projects/tir6/general/pfernand/conda/envs/tgi-env-public

cd /home/shailyjb/text-generation-inference

MODEL_ID="meta-llama/Llama-2-7b-chat-hf"
# MODEL_ID="lmsys/vicuna-7b-v1.5"

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
        --huggingface-hub-cache /data/datasets/models/hf_cache
fi