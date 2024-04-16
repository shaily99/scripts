import argparse
import asyncio
import logging

import aiolimiter
import pandas as pd
import utils
from text_generation import AsyncClient as c
from tqdm.asyncio import tqdm_asyncio


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--model_address",
        type=str,
        default="",
        required=True,
        help="Address where model is hosted. Eg: 'babel-4-28:8081'"
    )
    parser.add_argument(
        "--prompts",
        type=str,
        default="",
        help="Path to prompts"
    )
    parser.add_argument(
        "--output",
        type=str,
        default="",
    )
    parser.add_argument("--rpm", type=int, default=100)
    parser.add_argument("--max_tokens", type=int, default=100)
    args = parser.parse_args()
    return args


def get_model(model_address):
    model = c("http://" + model_address)
    return model


def format_prompt(prompt_input):
    prompt = prompt_input.split("\t")[-1].strip()
    return prompt


async def _generate(model, prompt, limiter, max_tokens):
    prompt = format_prompt(prompt)
    async with limiter:
        for _ in range(10):
            try:
                return await model.generate(
                    prompt=prompt,
                    max_new_tokens=max_tokens,
                )
            except Exception as e:
                logging.warning(e)
                await asyncio.sleep(20)
            await asyncio.sleep(20)
    return None


async def generate(model, prompts, rpm, max_tokens):
    limiter = aiolimiter.AsyncLimiter(rpm)
    async_responses = [
        _generate(
            model=model,
            prompt=prompt,
            limiter=limiter,
            max_tokens=max_tokens,
        )
        for prompt in prompts
    ]
    responses = await tqdm_asyncio.gather(*async_responses)
    return responses


def main(model_address, prompts, rpm, max_tokens):
    model = get_model(model_address)
    responses = asyncio.run(
        generate(
            model=model,
            prompts=prompts,
            rpm=rpm,
            max_tokens=max_tokens,
        )
    )
    results = []
    for prompt, response in zip(prompts, responses):
        if response is None:
            response = "ERROR"
        else:
            response = response.generated_text.replace("\n", "~| ").replace("\t", " ")
        prompt = prompt.split("\t")
        prompt.append(response)
        results.append(tuple(prompt))
    return results


if __name__ == "__main__":
    args = parse_args()
    header, prompts = utils.get_prompts(args.prompts)
    header = header.append("response")
    results = main(
        args.model_address,
        prompts,
        args.rpm,
        args.max_tokens,
    )
    pd.DataFrame(results).to_csv(args.output, sep="\t", header=header, index=None)
