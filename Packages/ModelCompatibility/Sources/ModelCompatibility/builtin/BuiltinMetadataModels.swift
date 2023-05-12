//
//  BuiltinMetadataModels.swift
//  
//
//  Created by Alex Rozanski on 08/05/2023.
//

import Foundation
import DataModel

public struct BuiltinLlamaModel {
  public let id = "llama"

  public let variant7BId = "7B"
  public let variant13BId = "13B"
  public let variant30BId = "30B"
  public let variant65BId = "65B"
}

public struct BuiltinAlpacaModel {
  public let id = "alpaca"
  public let variantId = "13B"
}

public struct BuiltinGpt4AllModel {
  public let id = "gpt4all-legacy"
  public let variantId = "7B"
}

public struct BuiltinMetadataModels {
  public static let llama = BuiltinLlamaModel()
  public static let alpaca = BuiltinAlpacaModel()
  public static let gpt4all = BuiltinGpt4AllModel()

  public static var all: [Model] {
    return [
      llamaModel(),
      alpacaModel(),
      legacyGPT4AllModel()
    ]
  }
}

fileprivate func llamaModel() -> Model {
  return Model(
    id: BuiltinMetadataModels.llama.id,
    name: "LLaMA",
    description: "The original LLaMA Large Language Model from Meta",
    sourcingDescription: "The LLaMA model checkpoints and tokenizer are required to add this chat source. Learn more and request access to these on the [LLaMA GitHub repo](https://github.com/facebookresearch/llama).",
    format: ["ggml", "pth"],
    languages: ["en"],
    legacy: false,
    publisher: ModelPublisher(name: "Meta, Inc."),
    defaultParameters: [
      "mode": "regular",
      "numTokens": 128
    ],
    variants: [
      ModelVariant(id: "7B", name: "7B", description: nil, parameters: .billions(Decimal(7)), engine: "camellm-llama", downloadUrl: nil),
      ModelVariant(id: "13B", name: "13B", description: nil, parameters: .billions(Decimal(13)), engine: "camellm-llama", downloadUrl: nil),
      ModelVariant(id: "30B", name: "30B", description: nil, parameters: .billions(Decimal(30)), engine: "camellm-llama", downloadUrl: nil),
      ModelVariant(id: "65B", name: "65B", description: nil, parameters: .billions(Decimal(65)), engine: "camellm-llama", downloadUrl: nil)
    ]
  )
}

fileprivate func alpacaModel() -> Model {
  return Model(
    id: BuiltinMetadataModels.alpaca.id,
    name: "Alpaca",
    description: "A fine-tuned instruction-following LLaMA model",
    sourcingDescription: "The Alpaca model checkpoints and tokenizer are required to add this chat source. Learn more on the [Alpaca GitHub repo](https://github.com/tatsu-lab/stanford_alpaca).",
    format: ["ggml", "pth"],
    languages: ["en"],
    legacy: false,
    publisher: ModelPublisher(name: "Stanford"),
    defaultParameters: [
      "mode": "instructional",
      "numTokens": 512,
      "contextSize": 2048,
      "batchSize": 256,
      "topK": 10000,
      "temperature": 0.2,
      "repeatPenalty": 1,
      "initialPrompt": "Below is an instruction that describes a task. Write a response that appropriately completes the request.",
      "promptPrefix": "\n\n### Instruction:\n\n",
      "promptSuffix": "\n\n### Response:\n\n",
      "antiprompt": "### Instruction:\n\n"
    ],
    variants: [
      ModelVariant(id: "7B", name: "7B", description: nil, parameters: .billions(Decimal(7)), engine: "camellm-llama", downloadUrl: nil)
    ]
  )
}

fileprivate func legacyGPT4AllModel() -> Model {
  return Model(
    id: BuiltinMetadataModels.gpt4all.id,
    name: "GPT4All",
    description: "Nomic AI's assistant-style LLM based on LLaMA",
    sourcingDescription: "The GPT4All .ggml model file is required to add this chat source. Learn more on the [llama.cpp GitHub repo](https://github.com/ggerganov/llama.cpp/blob/a0caa34/README.md#using-gpt4all).",
    format: ["ggml", "pth"],
    languages: ["en"],
    legacy: true,
    publisher: ModelPublisher(name: "Nomic AI"),
    defaultParameters: [
      "mode": "instructional",
      "numTokens": 128,
      "contextSize": 2048,
      "batchSize": 8,
      "lastNTokensToPenalize": 64,
      "topK": 40,
      "topP": 0.95,
      "temperature": 0.1,
      "repeatPenalty": 1.3,
      "initialPrompt": "Below is an instruction that describes a task. Write a response that appropriately completes the request.",
      "promptPrefix": "\n\n### Instruction:\n\n",
      "promptSuffix": "\n\n### Response:\n\n",
      "antiprompt": "### Instruction:\n\n"
    ],
    variants: [
      ModelVariant(id: "7B", name: "7B", description: nil, parameters: .billions(Decimal(7)), engine: "camellm-llama", downloadUrl: nil)
    ]
  )
}
