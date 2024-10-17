#!/bin/bash

# 定义代理列表
readarray -t proxies < <(grep -v '^\s*$' proxy_list.txt | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

echo "proxy url:"
for proxy in "${proxies[@]}"; do
    echo "$proxy"
done

# 获取脚本参数
download_url=$1
output_dir=${2:-$(pwd)} # 如果没有传递第二个参数，默认使用当前目录

# 检查是否提供了下载 URL
if [ -z "$download_url" ]; then
  echo "Usage: $0 <download_url> [output_dir]"
  exit 1
fi

# 从URL中提取文件名
filename=$(basename "$download_url")

# 构建代理 URL
proxy_urls=()
for proxy in "${proxies[@]}"; do
  proxy_urls+=("$proxy/$download_url")
done

# 构建最终的 aria2c 参数
aria2_cmd="aria2c --continue=true --split=10 --allow-overwrite=false --max-connection-per-server=10 --out=\"$filename\" $download_url ${proxy_urls[@]} --dir=\"$output_dir\""

# 打印并执行命令
echo "Running command: $aria2_cmd"
eval $aria2_cmd