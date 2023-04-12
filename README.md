![LlamaChat banner](./Resources/banner.png)

**LlamaChat** is a macOS app that allows you to chat with [LLaMa](http://github.com/facebookresearch/llama), [Alpaca](https://github.com/tatsu-lab/stanford_alpaca) and [GPT4All](https://github.com/nomic-ai/gpt4all) models all running locally on your Mac.

<img src="https://github.com/alexrozanski/LlamaChat/raw/main/Resources/screenshot.png" width="100%">

## 🚀 Getting Started

LlamaChat requires macOS 13 Ventura, and either an Intel or Apple Silicon processor.

### Direct Download

Download a `.dmg` containing the latest version [👉 here 👈](https://github.com/alexrozanski/LlamaChat/releases/download/1.0/LlamaChat.dmg).

### Building from Source

```bash
git clone https://github.com/alexrozanski/LlamaChat.git
cd LlamaChat
open LlamaChat.xcodeproj
```

**NOTE:** model inference runs really slowly in Debug builds, so if building from source make sure that the `Build Configuration` in `LlamaChat > Edit Scheme... > Run` is set to `Release`.

## 🔮 Models

**NOTE:** LlamaChat doesn't ship with any model files and requires that you obtain these from the respective sources in accordance with their respective terms and conditions.

- LlamaChat allows you to use the LLaMA family of models in either their raw Python checkpoint form (`.pth`) or pre-converted to `.ggml` files (the format used by [llama.cpp](https://github.com/ggerganov/llama.cpp), which powers LlamaChat).
- **Troubleshooting:** If using `.ggml` files, make sure these are up-to-date. If you run into problems, you may need to use the conversion scripts from [llama.cpp](https://github.com/ggerganov/llama.cpp):
  - For the GPT4All model, you may need to use [convert-gpt4all-to-ggml.py](https://github.com/ggerganov/llama.cpp/blob/master/convert-gpt4all-to-ggml.py)
  - For the Alpaca model, you may need to use [convert-unversioned-ggml-to-ggml.py](https://github.com/ggerganov/llama.cpp/blob/master/convert-unversioned-ggml-to-ggml.py)
  - You may also need to use [migrate-ggml-2023-03-30-pr613.py](https://github.com/ggerganov/llama.cpp/blob/master/migrate-ggml-2023-03-30-pr613.py) as well. For more information check out the [llama.cpp](https://github.com/ggerganov/llama.cpp) repo.

## ✨ Features

- **Supported Models:** LlamaChat supports LLaMA, Alpaca and GPT4All models out of the box. Support for other models including [Vicuna](https://vicuna.lmsys.org/) and [Koala](https://bair.berkeley.edu/blog/2023/04/03/koala/) is coming soon. We are also looking for Chinese and French speakers to add support for [Chinese LLaMA/Alpaca](https://github.com/ymcui/Chinese-LLaMA-Alpaca) and [Vigogne](https://github.com/bofenghuang/vigogne).
- **Flexible Model Formats:** LLamaChat is built on top of [llama.cpp](https://github.com/ggerganov/llama.cpp) and [llama.swift](https://github.com/alexrozanski/llama.swift). The app supports adding LLaMA models in either their raw `.pth` PyTorch checkpoints form or the `.ggml` format.
- **Model Conversion:** If raw PyTorch checkpoints are added these can be converted to `.ggml` files compatible with LlamaChat and llama.cpp within the app.
- **Chat History:** Chat history is persisted within the app. Both chat history and model context can be cleared at any time.
- **Funky Avatars:** LlamaChat ships with [7 funky avatars](https://github.com/alexrozanski/LlamaChat/tree/main/LlamaChat/Assets.xcassets/avatars) that can be used with your chat sources.
- **Advanced Source Naming:** LlamaChat uses Special Magic™ to generate playful names for your chat sources.
- **Context Debugging:** For the keen ML enthusiasts, the current model context can be viewed for a chat in the info popover.

## 👩‍💻 Contributing

Pull Requests and Issues are welcome and much appreciated. Please make sure to adhere to the [Code of Conduct](CODE_OF_CONDUCT.md) at all times.

LlamaChat is fully built using Swift and SwiftUI, and makes use of [llama.swift](https://github.com/alexrozanski/llama.swift) under the hood to run inference and perform model operations.

The project is mostly built using MVVM and makes heavy use of Combine and Swift Concurrency.

## ⚖️ License

LlamaChat is licensed under the [MIT license](LICENSE).
