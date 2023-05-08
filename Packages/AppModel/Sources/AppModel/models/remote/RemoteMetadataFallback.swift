//
//  RemoteMetadataFallback.swift
//  
//
//  Created by Alex Rozanski on 08/05/2023.
//

import Foundation
import ModelMetadata

func remoteFallbackModels() -> [Model] {
  return [
    llamaModel(),
    alpacaModel(),
    legacyGPT4AllModel()
  ]
}

fileprivate func llamaModel() -> Model {
  return Model(
    id: "llama",
    name: "LLaMA",
    description: "The original LLaMA Large Language Model from Meta",
    source: .local,
    sourcingDescription: "The LLaMA model checkpoints and tokenizer are required to add this chat source. Learn more and request access to these on the [LLaMA GitHub repo](https://github.com/facebookresearch/llama).",
    format: ["ggml", "pth"],
    legacy: false,
    languages: ["en"],
    publisher: ModelPublisher(name: "Meta, Inc."),
    variants: [
      ModelVariant(id: "7B", name: "7B", description: nil, parameters: "7B", engine: "camellm-llama", downloadUrl: nil),
      ModelVariant(id: "13B", name: "13B", description: nil, parameters: "13B", engine: "camellm-llama", downloadUrl: nil),
      ModelVariant(id: "13B", name: "13B", description: nil, parameters: "13B", engine: "camellm-llama", downloadUrl: nil),
      ModelVariant(id: "13B", name: "13B", description: nil, parameters: "13B", engine: "camellm-llama", downloadUrl: nil)
    ]
  )
}

fileprivate func alpacaModel() -> Model {
  return Model(
    id: "alpaca",
    name: "Alpaca",
    description: "A fine-tuned instruction-following LLaMA model",
    source: .local,
    sourcingDescription: "The Alpaca model checkpoints and tokenizer are required to add this chat source. Learn more on the [Alpaca GitHub repo](https://github.com/tatsu-lab/stanford_alpaca).",
    format: ["ggml", "pth"],
    legacy: false,
    languages: ["en"],
    publisher: ModelPublisher(name: "Stanford"),
    variants: [
      ModelVariant(id: "13B", name: "13B", description: nil, parameters: "13B", engine: "camellm-llama", downloadUrl: nil)
    ]
  )
}

fileprivate func legacyGPT4AllModel() -> Model {
  return Model(
    id: "gpt4all-legacy",
    name: "GPT4All",
    description: "Nomic AI's assistant-style LLM based on LLaMA",
    source: .local,
    sourcingDescription: "The GPT4All .ggml model file is required to add this chat source. Learn more on the [llama.cpp GitHub repo](https://github.com/ggerganov/llama.cpp/blob/a0caa34/README.md#using-gpt4all).",
    format: ["ggml", "pth"],
    legacy: true,
    languages: ["en"],
    publisher: ModelPublisher(name: "Nomic AI"),
    variants: [
      ModelVariant(id: "7B", name: "7B", description: nil, parameters: "7B", engine: "camellm-llama", downloadUrl: nil)
    ]
  )
}
