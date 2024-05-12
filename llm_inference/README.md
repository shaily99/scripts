# Notes from hosting LLMs and running inference on Babel

> Note to self: You are not dumb, it can indeed be tricky!

### Preliminaries
LLM inference here refers hosting your own copy of model on Babel and querying it. This is useful for relatively large sizes of inference (order of a few 1000s). Anything less than that, you can simply get away by [offline batched inference using vllm](https://docs.vllm.ai/en/latest/getting_started/quickstart.html) in reasonable amounts of time.

Methods:
1. [vLLM](https://blog.vllm.ai/2023/06/20/vllm.html)
2. [LTI-TGI](https://github.com/CoderPat/text-generation-inference/tree/main): A fork of HuggingFace Text Generation Inference library created and maintained by Patrick.

## vLLM

### Installation
[Docs](https://docs.vllm.ai/en/latest/getting_started/installation.html)

Steps:
- Run an interactive session on a GPU node
- Create new environment (make sure to check docs for latest python version recommendation: `conda create -n vllm python=3.9` 
- *Switch to created env - dont install in base by mistake!*
- Install pip: `conda install pip`
- Load Cuda (check docs for recommneded cuda version): `module load cuda-12.1` 
- Install pytorch: `conda install pytorch pytorch-cuda=12.1 -c pytorch -c nvidia`
- Install [flash-attn](https://github.com/Dao-AILab/flash-attention?tab=readme-ov-file#installation-and-features)
    - `pip install packaging`
    - `pip uninstall -y ninja && pip install ninja`
    - `MAX_JOBS=4 pip install flash-attn --no-build-isolation`
      > Make sure to run with MAX_JOBS=4
- Install vllm: `pip install vllm`

### Serving model using vLLM:

Model serving script: 
- `-—download_dir` = where the model weights will be downloaded. This can be set to shared model cache on babel.
- Further information: [Command line args for deploying](https://docs.vllm.ai/en/latest/serving/openai_compatible_server.html#command-line-arguments-for-the-server)

### Information sources
- [A random blog I found on reddit](https://ploomber.io/blog/vllm-deploy/)
- [Sotopia repo](https://github.com/sotopia-lab/sotopia-pi/tree/main/llm_deploy#deploy-models-on-babel-via-vllm-api-server)

#### Pros:
1. Pretty fast
2. Inference is through OpenAI compatible server - which means you can use the same code for querying other models that you use for bulk-querying OpenAI API
3. Large numbers of models are seamlessly supported
   
#### Cons:
1. AFAIK they do not support getting log probabilities
2. (LMK if you know any others)

## TGI



#### Pros:
1. Supports getting log probs

#### Cons:
1. Can be clunky to setup
2. The LTI-TGI fork is at the moment slighlty behind, which means as yet support for newer models (mistral / gemma) has not been added.
3. Slower than vLLM




