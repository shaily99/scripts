#!/bin/sh 
#SBATCH --gres=gpu:A6000:1
#SBATCH --partition=debug
#SBATCH --mem=64GB
#SBATCH -t 0-00:30:00              # time limit: (D-HH:MM) 
#SBATCH --job-name=quantized-vicuna-7b-noshard-nocache
#SBATCH --error=logs/quantized-vicuna-7b-noshard-nocache.err
#SBATCH --output=logs/quantized-vicuna-7b-noshard-nocache.out

mkdir -p /scratch/shailyjb
source ~/miniconda3/etc/profile.d/conda.sh

conda activate /data/tir/projects/tir6/general/pfernand/conda/envs/tgi-env-public

cd /home/shailyjb/text-generation-inference
text-generation-launcher \
    --model-id lmsys/vicuna-7b-v1.5 \
    --port 8080 \
    --quantize bitsandbytes # Don't pass if you don't want to quantize
    # --shard-uds-path /scratch/shailyjb \
    # --huggingface-hub-cache /data/datasets/models/hf_cache

