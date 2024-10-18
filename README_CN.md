# hfdownloader

本项目包含两个脚本:

1.hfd.sh,forked from [Huggingface Model Downloader](https://gist.github.com/padeoe/697678ab8e528b85a2a7bddafea1fa4f),是一个基于`aira2/wget`的Huggingface的命令行下载器，

2.aria2.sh,aria2c的下载脚本

## `cloudflare workers`

cloudflare worker代理服务器的搭建方法参考 [这里](https://sirtech.cc/2024/10/17/da-jian-cloudflare-worker-shi-xian-zi-you-xia-zai-huggingface-da-mo-xing/)。

## `hfd.sh`

### `特性`

1. ⏯️ 断点续传: 可以随时重新运行或使用 Ctrl+C 中断下载。
2. 🚀 多线程下载: 利用多线程加速下载过程。
3. 🚫 文件排除: 使用 --exclude 或 --include 跳过或指定文件，节省时间。
4. 🔐 认证支持: 对于需要登录的模型，使用 --hf_username 和 --hf_token 进行认证。
5. 🪞 镜像站支持: 通过 HF_ENDPOINT 环境变量设置镜像站。
6. 🌍 代理支持: 通过 HTTPS_PROXY 环境变量设置代理。
7. 📦 简单依赖: 仅依赖 git 和 aria2c/wget。
8. ⏬ 跳过已下载: 使用 Git LFS 自动区分目标文件的下载状态

### `为什么不使用huggingface-cli和HF-Ttransfer`


1. 下载huggingface上的大模型一般用`huggingface-cli`可以较快的下载，但是经过自测也只能占满下行带宽的10%~20%，但是`huggingface`的CDN服务器不是太稳定(因为有时你分配到的边缘节点很慢)，这会影响`huggingface-cli`的下载速度。所以本脚本的目的是通过自建cloudflare workers来代理huggingface服务器进行并行下载。

2. `HF-Ttransfer`的下载速度比原版`huggingface-cli`要快很多，但是经常会卡住、且无法中断，如果强行中断会丢失数据从零开始。

修改内容：

在`Huggingface Model Downloader`的基础上增加了反代列表`proxy_list.txt`,可在其中添加自己搭建的cloudflare反代服务器，来实现多服务器并行下载。搭建的服务器越多，理论上可以榨干你的全部下行带宽。我自测1000M宽带实现了跑满100M下行带宽。

### `使用方法`

opensuse:

```bash
sudo zypper install -y aria2 git git-lfs && git lfs install
```

ubuntu:

```bash
sudo apt update
sudo apt install aria2 git git-lfs
```

其他系统请自行搜索安装`aria2` `git` `git-lfs`的方法。

#### `参数说明`

- `repo_id`: Hugging Face 仓库 ID，格式为 `org/repo_name`。
- `--include`: (可选) 指定包含下载的文件模式，支持多个模式。
- `--exclude`: (可选) 指定排除下载的文件模式，支持多个模式。
- `--hf_username`: (可选) Hugging Face 用户名，用于认证（不是邮箱）。
- `--hf_token`: (可选) Hugging Face 令牌，用于认证。
- `--tool`: (可选) 下载工具，可以是 `aria2c`（默认）或 `wget`。
- `-x`: (可选) `aria2c` 的下载线程数，默认为 4。
- `--dataset`: (可选) 标志，表示下载数据集。
- `--local_dir`: (可选) 本地存储模型或数据集的目录路径。

#### `示例`

下载模型：

```bash
hfd.sh bigscience/bloom-560m --local_dir=./
```

下载需要登录的模型：

```bash
hfd.sh meta-llama/Llama-2-7b --hf_username YOUR_HF_USERNAME_NOT_EMAIL --hf_token YOUR_HF_TOKEN --local_dir=./
```

#### `注意`

使用本脚本要自行搭建cloudflare反代服务器（或者其他服务商的也可以），将项目中的`worker.js`复制到你的云服务中去即可，如果不会搭建可以参考[这里](https://sirtech.cc/2024/10/17/da-jian-cloudflare-worker-shi-xian-zi-you-xia-zai-huggingface-da-mo-xing/)。
搭建好后，把代理域名放进`proxy_list.txt`,像这样：

```text
https://r1.yourdomain.com
https://r2.yourdomain.com
...
```

注意每一行域名的最后面不要空格，我没有做检查。

另外：当然不搭建也能使用，那样下载速度就和原脚本差不多了。

## `aria2.sh`

这个是`hfd.sh`的单文件下载版本，不需要`git` `git-lfs`,只需要安装aria2即可使用。

### `使用方法`

```bash
./aria.sh url .
```

第一个参数是下载的链接，第二个参数是保存的位置，默认下载在当前目录。

### 致谢

感谢 [padeoe](https://gist.github.com/padeoe/697678ab8e528b85a2a7bddafea1fa4f) 提供的 `hfd.sh` 脚本做为基础开发。

感谢`Chatgpt`提升了开发效率。
