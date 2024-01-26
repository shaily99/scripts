#!/bin/sh 
#SBATCH --gres=gpu:A6000:1
#SBATCH --partition=babel-shared
#SBATCH --mem=64Gb
#SBATCH -t 2-00:00:00              # time limit: (D-HH:MM) 
#SBATCH --job-name=llama7b
#SBATCH --error=logs/llama7b.%j.err
#SBATCH --output=logs/llama7b.%j.out

mkdir -p /scratch/ayerukol
source ~/miniconda3/etc/profile.d/conda.sh
conda activate /home/ltjuatja/miniconda3/envs/tgi-env-test

cd /home/ayerukol/text-generation-inference
text-generation-launcher --model-id meta-llama/Llama-2-7b-hf --port 9865 --quantize bitsandbytes --shard-uds-path /scratch/ayerukol/tgi-uds-socket-2 --huggingface-hub-cache /data/tir/projects/tir2/models/tgi_cache/hub/