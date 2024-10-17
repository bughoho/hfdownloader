# hfdownloader

This project contains two scripts:

1. `hfd.sh`, forked from [Huggingface Model Downloader](https://gist.github.com/padeoe/697678ab8e528b85a2a7bddafea1fa4f), is a command-line downloader for Huggingface models based on `aria2/wget`.

2. `aria2.sh` is a download script for `aria2c`.

## `cloudflare workers`

Please refer to [this link]() for instructions on how to build a Cloudflare Workers reverse proxy server.

## `hfd.sh`

### `Features`

1. ⏯️ Support for Resuming Downloads: Resume interrupted downloads anytime or pause with Ctrl+C.
2. 🚀 Multi-threaded Downloads: Speed up downloads using multiple threads.
3. 🚫 File Exclusion: Use `--exclude` or `--include` to skip or specify files, saving time.
4. 🔐 Authentication Support: Use `--hf_username` and `--hf_token` for models that require login.
5. 🪞 Mirror Site Support: Set mirror sites via the `HF_ENDPOINT` environment variable.
6. 🌍 Proxy Support: Set proxies via the `HTTPS_PROXY` environment variable.
7. 📦 Simple Dependencies: Only requires `git` and `aria2c/wget`.
8. ⏬ Skip Already Downloaded Files: Automatically identifies the download status of the target file using Git LFS.

### `Why not use huggingface-cli and ht-transfer`

Downloading large models on Huggingface is generally faster with `huggingface-cli`. However, in my tests, it only utilizes 10%~20% of the download bandwidth. Additionally, Huggingface's CDN server is not very stable, because the assigned edge node can be slow, which affects the download speed of `huggingface-cli`. This script aims to address this by proxying the Huggingface server through a self-built Cloudflare Worker for parallel downloading.

`ht-transfer` downloads much faster than the original `huggingface-cli`, but it often gets stuck and cannot be interrupted. Forcing an interruption will result in data loss and restarting from scratch.

### `Modifications`

This script builds upon the `Huggingface Model Downloader` by adding a reverse proxy list (`proxy_list.txt`) where users can add their own Cloudflare reverse proxy servers for multi-server parallel downloading. Theoretically, adding more servers allows for greater utilization of your full download bandwidth. I have tested it with a 1000Mbps connection and achieved a full 100MB/s download speed.

### `Usage`

OpenSUSE:
```bash
sudo zypper install -y aria2 git git-lfs && git lfs install
```

Ubuntu:
```bash
sudo apt update
sudo apt install aria2 git git-lfs
```

For other systems, please search for how to install `aria2`, `git`, and `git-lfs`.

#### `Parameter Description`

- `repo_id`: Hugging Face repository ID, in the format of `org/repo_name`.
- `--include`: (Optional) Specifies file patterns to include for download; supports multiple patterns.
- `--exclude`: (Optional) Specifies file patterns to exclude from download; supports multiple patterns.
- `--hf_username`: (Optional) Hugging Face username for authentication (not email).
- `--hf_token`: (Optional) Hugging Face token for authentication.
- `--tool`: (Optional) Download tool, can be `aria2c` (default) or `wget`.
- `-x`: (Optional) Number of download threads for `aria2c`, default is 4.
- `--dataset`: (Optional) Flag indicating dataset download.
- `--local_dir`: (Optional) Local directory path to store the model or dataset.

#### `Example`

Download a model:

```bash
hfd.sh bigscience/bloom-560m --local_dir=./
```

Download a model that requires login:

```bash
hfd.sh meta-llama/Llama-2-7b --hf_username YOUR_HF_USERNAME_NOT_EMAIL --hf_token YOUR_HF_TOKEN --local_dir=./
```

#### `Note`

This script requires users to set up their own Cloudflare reverse proxy server (or one from another provider). Copy the project's `worker.js` file to your cloud service. For guidance on setting this up, refer to [this link](). Once built, add your reverse proxy domain name to the `proxy_list.txt` file as follows:

```text
https://r1.yourdomain.com
https://r2.yourdomain.com
...
```

Ensure that there are no trailing spaces at the end of each domain name in the file.

While the script can be used without setting up a reverse proxy server, download speeds will be comparable to the original script.

## `aria2.sh`

This script provides a single-file download functionality similar to `hfd.sh`, but only requires `aria2` to be installed (no need for `git` or `git-lfs`).

### `Usage`

```bash
./aria.sh url .
```

The first parameter is the download link, and the second parameter is the save location. By default, it downloads to the current directory.

### Acknowledgements

Thanks to [padeoe](https://gist.github.com/padeoe/697678ab8e528b85a2a7bddafea1fa4f) for providing the `hfd.sh` script as the basis for development.

Thanks to ChatGPT for enhancing the development process.
