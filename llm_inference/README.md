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
- Create new environment (make sure to check docs for latest python version recommendation: `conda create -n vllm python=3.9`)
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

Model serving script: [llm_inference/host_model_vllm.sh](https://github.com/shaily99/scripts/blob/c4d46ffa7e505f9186dc8d429693f87af8ef4da4/llm_inference/host_model_vllm.sh)

- `-—download_dir` = where the model weights will be downloaded. This can be set to shared model cache on babel.
- Further information: [Other command line args that can be set when deploying](https://docs.vllm.ai/en/latest/serving/openai_compatible_server.html#command-line-arguments-for-the-server)
- Note the node and port you end up running on, as this will create the URL to query. It does get output in the logs once the model is connected

### Running Inference:
This is essentially similar to running inference on the OpenAI API. Simply instantiate the Client with an psuedo key and base URL of hosted model: `client = AsyncOpenAI(api_key="EMPTY", base_url=args.base_url)` 

- Both OpenAI client or AsyncOpenAI clients work, but Async client is faster when running larger number of queries
- Don’t pass “” (empty string) as key or it wont work
- Here `base_url` is address of type: `http://babel-x-x:PORT/v1`

Code example to run async inference: [llm_inference/query_vllm.py](https://github.com/shaily99/scripts/blob/195abe1b68153010cb6c44bed85b67c972b3e49f/llm_querying/query_vllm.py)



### Compute / RPM Configurations

Typically depends on size of model. The RPM rate is trial and error, and depends on the number of output tokens generated per prompt and also number of prompt tokens. Some configurations that have worked for me in the past:

1. Llama 2/3 8/13 B: one A6000 (46G vRAM) to host; rpm = 300 for 100 tokens and 5 responses per prompt, 10-15 input tokens
2. Llama 70B: haven't tried properly, but needs multi-GPU hosting.
3. Gemma 2B: one A5000 (24G vRAM), RPM = 50-100 (dont remember), 10-15 input tokens, 1000 output tokens and 5 responses per prompt.
4. Gemma 7B: one A100_80G (80G vRAM), RPM = 50, with 1000 output tokens and 5 responses per prompt with 10-15 input tokens. Note: Gemma’s repo says that 7B should work with 24G+ vRAM but it failed on A6000 for me for anything more than 5 RPM

### Information sources
- [A random blog I found on reddit](https://ploomber.io/blog/vllm-deploy/)
- [Sotopia repo](https://github.com/sotopia-lab/sotopia-pi/tree/main/llm_deploy#deploy-models-on-babel-via-vllm-api-server)


### Pros:
1. Pretty fast
2. Inference is through OpenAI compatible server - which means you can use the same code for querying other models that you use for bulk-querying OpenAI API
3. Large numbers of models are seamlessly supported
   
### Cons:
1. AFAIK they do not support getting log probabilities
2. (LMK if you know any others)

## TGI

### Installation
[Installation instructions](https://github.com/CoderPat/text-generation-inference/tree/main?tab=readme-ov-file#running-your-own-servers) on the repo readme are pretty detailed; and following them would work.

It is long and sometimes tricky. Some notes that I took along the way:
- Run the installation an interactive session on a GPU node.
- Takes a few hrs; dont let machine sleep and terminal disconnect
    - Alternatively: put the commands and run it in a sbatch script (I think I tied this but I dont remember if it worked).
- Never touch the env from a different project code. Only activate it in model hosting script.

### Hosting Models

Script: [llm_inference/host_model_lti_tgi.sh](https://github.com/shaily99/scripts/blob/1addd2102f369c1a3ad37f3b793966e850c52008/llm_inference/host_model_lti_tgi.sh)

Steps:
- Run an interactive session
- Fork the github repo: `git cone https://github.com/CoderPat/text-generation-inference.git` (only once)
- cd into the above repo and [Install client](https://github.com/CoderPat/text-generation-inference/tree/main?tab=readme-ov-file#getting-started): `cd clients/python` and `pip install .`
- Launch model with this script: [llm_inference/host_model_lti_tgi.sh](https://github.com/shaily99/scripts/blob/1addd2102f369c1a3ad37f3b793966e850c52008/llm_inference/host_model_lti_tgi.sh)
- Once this is done, the model should show up on Central


#### Pros:
1. Supports getting log probs

#### Cons:
1. Can be clunky to setup
2. The LTI-TGI fork is at the moment slighlty behind, which means as yet support for newer models (mistral / gemma) has not been added.
3. Slower than vLLM




