# hfdownloader

[中文](README_CN.md)

This project contains two scripts:

1. `hfd.sh`, forked from [Huggingface Model Downloader](https://gist.github.com/padeoe/697678ab8e528b85a2a7bddafea1fa4f), is a command-line downloader for Huggingface based on `aria2/wget`.

2. `aria2.sh`, a download script for aria2c.

## `cloudflare workers`

For instructions on setting up a cloudflare worker proxy server, please refer to the provided [link](https://en.sirtech.cc/2024/10/17/setting-up-a-cloudflare-worker-to-freely-download-large-hugging-face-models/).

## `hfd.sh`

### `Features`

1. ⏯️ Resumable Downloads: Downloads can be resumed at any time by rerunning the script or interrupting with Ctrl+C.
2. 🚀 Multi-threaded Downloads: Utilizes multiple threads to accelerate the download process.
3. 🚫 File Exclusion: Use `--exclude` or `--include` to skip or specify files, saving time.
4. 🔐 Authentication Support: For models that require login, use `--hf_username` and `--hf_token` for authentication.
5. 🪞 Mirror Site Support: Set the mirror site through the `HF_ENDPOINT` environment variable.
6. 🌍 Proxy Support: Set the proxy through the `HTTPS_PROXY` environment variable.
7. 📦 Simple Dependencies: Only depends on `git` and `aria2c/wget`.
8. ⏬ Skip Downloaded Files: Automatically identifies the download status of target files using Git LFS.

### `Why not use huggingface-cli and HF-Ttransfer`

1. Downloading large models on Huggingface generally uses `huggingface-cli` for faster downloads, but in my testing, it can only utilize 10%~20% of the download bandwidth. However, Huggingface's CDN server is not very stable (because sometimes the assigned edge node is slow), which affects the download speed of `huggingface-cli`. This script aims to address this by enabling parallel downloads through a user-configured Cloudflare Worker acting as a proxy for the Huggingface server.

2. `HF-Ttransfer` downloads much faster than the original `huggingface-cli`, but it often gets stuck and cannot be interrupted. Forcing an interruption will result in data loss and restart from scratch.

### `Modifications`

Based on `Huggingface Model Downloader`, it introduces a reverse proxy list (`proxy_list.txt`) allowing users to specify their own Cloudflare reverse proxy servers for multi-server parallel downloads. Theoretically, utilizing more servers can maximize download bandwidth utilization. I personally tested it with a 1000Mbps connection and achieved a full 100MB/s download speed.

### `Usage`

opensuse:

```bash
sudo zypper install -y aria2 git git-lfs && git lfs install
```

ubuntu:

```bash
sudo apt update
sudo apt install aria2 git git-lfs
```

For other systems, please search for how to install `aria2`, `git`, and `git-lfs`.

#### `Parameter Description`

- `repo_id`: Hugging Face repository ID, in the format of `org/repo_name`.
- `--include`: (Optional) Specifies the file pattern to include in the download, supports multiple patterns.
- `--exclude`: (Optional) Specifies the file pattern to exclude from the download, supports multiple patterns.
- `--hf_username`: (Optional) Hugging Face username for authentication (not email).
- `--hf_token`: (Optional) Hugging Face token for authentication.
- `--tool`: (Optional) Download tool, can be `aria2c` (default) or `wget`.
- `-x`: (Optional) Number of download threads for `aria2c`, defaults to 4.
- `--dataset`: (Optional) Flag indicating dataset download.
- `--local_dir`: (Optional) Local directory path to store the model or dataset.

#### `Examples`

Download a model:

```bash
hfd.sh bigscience/bloom-560m --local_dir=./
```

Download a model that requires login:

```bash
hfd.sh meta-llama/Llama-2-7b --hf_username YOUR_HF_USERNAME_NOT_EMAIL --hf_token YOUR_HF_TOKEN --local_dir=./
```

#### `Note`

This script requires a user-configured Cloudflare reverse proxy server (or a similar service). Copy the provided `worker.js` file to your cloud service environment. Once configured, add the proxy domain name to the `proxy_list.txt` file as follows:

```text
https://r1.yourdomain.com
https://r2.yourdomain.com
...
```

Note that there should be no spaces at the end of each domain name. The script does not currently check for this.

If you're unsure how to set it up, you can refer to this [guide](https://en.sirtech.cc/2024/10/17/setting-up-a-cloudflare-worker-for-unrestricted-huggingface-large-model-downloads/).

Additionally, you can use the script without setting up a proxy server, but the download speed will be similar to the original script.

## `aria2.sh`

This script provides a single-file download functionality similar to `hfd.sh` but only requires `aria2` (no `git` or `git-lfs` dependency).

### `Usage`

```bash
./aria.sh url .
```

The first argument specifies the download link, and the second argument indicates the desired save location. If no save location is provided, the file will be downloaded to the current directory.

### Acknowledgements

Thanks to [padeoe](https://gist.github.com/padeoe/697678ab8e528b85a2a7bddafea1fa4f) for providing the `hfd.sh` script as the basis for development.

This project benefited from AI-powered assistance during development.
