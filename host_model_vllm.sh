#!/bin/sh 
#SBATCH --gres=gpu:A6000:1
#SBATCH --partition=general
#SBATCH --mem=32GB
#SBATCH --time 1-23:55:00 
#SBATCH --job-name=a6_llama38b_instruct
#SBATCH --error=/home/shailyjb/pref_cult/logs/a6_llama38b_instruct.err
#SBATCH --output=/home/shailyjb/pref_cult/logs/a6_llama38b_instruct.out
#SBATCH --mail-type=END
#SBATCH --mail-user=shailyjb@andrew.cmu.edu
#SBATCH --exclude=shire-1-6,inst-0-35,shire-1-10

mkdir -p /scratch/shailyjb
source ~/miniconda3/etc/profile.d/conda.sh

export HF_HOME=/data/tir/projects/tir5/users/shailyjb/hf_cache
source ~/.bashrc

HUGGINGFACE_TOKEN="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"
huggingface-cli login --token "${HUGGINGFACE_TOKEN}"

conda activate /home/shailyjb/miniconda3/envs/vllm

MODEL="meta-llama/Meta-Llama-3-8B-Instruct"


PORT=8081
if ss -tulwn | grep -q ":$PORT "; then
    echo "Port $PORT is already in use. Exiting..."
    exit 1
else
    python -m vllm.entrypoints.openai.api_server \
        --model $MODEL \
        --port $PORT \
        --download-dir "/data/tir/projects/tir5/users/shailyjb/hf_cache"
fi
echo $PORT
