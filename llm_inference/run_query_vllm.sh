#!/bin/bash

#SBATCH --job-name=name
#SBATCH --output=/logs/name.out
#SBATCH --error=/logs/name.err
#SBATCH --nodes=1
#SBATCH --mem=16GB
#SBATCH --time 0-12:55:00
#SBATCH --partition=cpu
#SBATCH --mail-type=END
#SBATCH --mail-user=shailyjb@andrew.cmu.edu
#SBATCH --exclude=shire-1-6,inst-0-35,shire-1-10


echo $SLURM_JOB_ID

source ~/.bashrc
conda init bash
conda activate pc2


MAX_TOKENS=50

MODEL_ADDRESS="http://babel-4-23:8081/v1"
MODEL="google/gemma-2b-it"
MODEL_NAME="gemma2B_it"

PROMPTS="FILE"
OUTPUT="FILE"

python query_vllm.py \
    --prompts="${PROMPTS}" \
    --output="${OUTPUT}" \
    --model=${MODEL} \
    --base_url=${MODEL_ADDRESS} \
    --max_response_tokens=${MAX_TOKENS} \
    --requests_per_minute=100 \
    --num_responses_per_prompt=1
