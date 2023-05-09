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
    source: .local,
    sourcingDescription: "The LLaMA model checkpoints and tokenizer are required to add this chat source. Learn more and request access to these on the [LLaMA GitHub repo](https://github.com/facebookresearch/llama).",
    family: .llama,
    format: ["ggml", "pth"],
    languages: ["en"],
    legacy: false,
    publisher: ModelPublisher(name: "Meta, Inc."),
    variants: [
      ModelVariant(id: "7B", name: "7B", description: nil, parameters: "7B", engine: "camellm-llama", downloadUrl: nil),
      ModelVariant(id: "13B", name: "13B", description: nil, parameters: "13B", engine: "camellm-llama", downloadUrl: nil),
      ModelVariant(id: "30B", name: "30B", description: nil, parameters: "30B", engine: "camellm-llama", downloadUrl: nil),
      ModelVariant(id: "65B", name: "65B", description: nil, parameters: "65B", engine: "camellm-llama", downloadUrl: nil)
    ]
  )
}

fileprivate func alpacaModel() -> Model {
  return Model(
    id: BuiltinMetadataModels.alpaca.id,
    name: "Alpaca",
    description: "A fine-tuned instruction-following LLaMA model",
    source: .local,
    sourcingDescription: "The Alpaca model checkpoints and tokenizer are required to add this chat source. Learn more on the [Alpaca GitHub repo](https://github.com/tatsu-lab/stanford_alpaca).",
    family: .llama,
    format: ["ggml", "pth"],
    languages: ["en"],
    legacy: false,
    publisher: ModelPublisher(name: "Stanford"),
    variants: [
      ModelVariant(id: "7B", name: "7B", description: nil, parameters: "7B", engine: "camellm-llama", downloadUrl: nil)
    ]
  )
}

fileprivate func legacyGPT4AllModel() -> Model {
  return Model(
    id: BuiltinMetadataModels.gpt4all.id,
    name: "GPT4All",
    description: "Nomic AI's assistant-style LLM based on LLaMA",
    source: .local,
    sourcingDescription: "The GPT4All .ggml model file is required to add this chat source. Learn more on the [llama.cpp GitHub repo](https://github.com/ggerganov/llama.cpp/blob/a0caa34/README.md#using-gpt4all).",
    family: .llama,
    format: ["ggml", "pth"],
    languages: ["en"],
    legacy: true,
    publisher: ModelPublisher(name: "Nomic AI"),
    variants: [
      ModelVariant(id: "7B", name: "7B", description: nil, parameters: "7B", engine: "camellm-llama", downloadUrl: nil)
    ]
  )
}
