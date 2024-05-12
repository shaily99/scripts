#!/bin/sh 
#SBATCH --gres=gpu:A6000:1
#SBATCH --partition=general
#SBATCH --mem=32GB
#SBATCH --time 1-23:55:00 
#SBATCH --job-name=a6_llama3_8b_instruct
#SBATCH --error=<LOG DIRECTORY>/a6_llama3_8b_instruct.err
#SBATCH --output=<LOG DIRECTORY>/a6_llama38b_instruct.out
#SBATCH --mail-type=END
#SBATCH --mail-user=<EMAIL>

mkdir -p /scratch/<YOUR ID>/<NAME OF SCRATCH DIR>
source ~/miniconda3/etc/profile.d/conda.sh

export HF_HOME=<DIR>/hf_cache # Ideally it helps to have <DIR> in `/data/..` on Babel to not overcrowd /home/.. directory
source ~/.bashrc

HUGGINGFACE_TOKEN="<YOUR HF TOKEN>"
huggingface-cli login --token "${HUGGINGFACE_TOKEN}"

conda activate <ENV-NAME>

MODEL="meta-llama/Meta-Llama-3-8B-Instruct" # This is same as the model ID on HF


PORT=8081
if ss -tulwn | grep -q ":$PORT "; then
    echo "Port $PORT is already in use. Exiting..."
    exit 1
else
    python -m vllm.entrypoints.openai.api_server \
        --model $MODEL \
        --port $PORT \
        --download-dir <DIR> # Either shared model cache on babel or your own directory
fi
echo $PORT
