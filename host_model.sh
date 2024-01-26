#!/bin/sh 
#SBATCH --gres=gpu:A6000:1
#SBATCH --partition=babel-shared
#SBATCH --mem=64Gb
#SBATCH -t 2-00:00:00              # time limit: (D-HH:MM) 
#SBATCH --job-name=llama7b
#SBATCH --error=logs/llama7b.err
#SBATCH --output=logs/llama7b.out

mkdir -p /scratch/shailyjb
source ~/miniconda3/etc/profile.d/conda.sh

conda activate /data/tir/projects/tir6/general/pfernand/conda/envs/tgi-env-public

cd /home/shailyjb/text-generation-inference
text-generation-launcher \
    --model-id meta-llama/Llama-2-7b-hf \
    --port 9865 \
    --quantize bitsandbytes \
    --shard-uds-path /scratch/shailyjb \
    --huggingface-hub-cache /data/tir/projects/tir5/users/shailyjb/tgi_cache/hub