#!/bin/bash

# 确保脚本以 root 权限运行
if [ "$(id -u)" != "0" ]; then
   echo "此脚本需要 root 权限，请使用 sudo 运行。" 1>&2
   exit 1
fi

# 1. 安装 Conda
echo "安装 Conda..."
curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
sh Miniconda3-latest-MacOSX-x86_64.sh
rm Miniconda3-latest-MacOSX-x86_64.sh

# 将 Conda 添加到环境变量
echo "将 Conda 添加到环境变量..."
CONDA_PATH="$(conda info --base)/bin"
if [[ ":$PATH:" != *":$CONDA_PATH:"* ]]; then
    echo "export PATH=\"$CONDA_PATH:\$PATH\"" >> "$HOME/.bashrc"
    source "$HOME/.bashrc"
fi

# 2. 创建并激活 Conda 虚拟环境
echo "创建并激活 Conda 虚拟环境..."
source $(conda info --base)/etc/profile.d/conda.sh
conda create --name comfyui_v1 python=3.10 -y
conda activate comfyui_v1

# 3. 进入 ComfyUI 存放目录
COMFYUI_DIR="$HOME/comfyui"
mkdir -p "$COMFYUI_DIR"
cd "$COMFYUI_DIR"

# 4. 克隆 ComfyUI 代码库
echo "克隆 ComfyUI 代码库..."
git clone https://github.com/comfyanonymous/ComfyUI.git

# 5. 安装 ComfyUI 依赖
echo "安装依赖..."
pip install torch torchvision torchaudio
pip install -r "$COMFYUI_DIR/ComfyUI/requirements.txt"

# 6. 下载模型
MODEL_URL="https://huggingface.co/runwayml/stable-diffusion-v1-5/blob/main/v1-5-pruned-emaonly.safetensors"
MODEL_FILE="v1-5-pruned-emaonly.safetensors"

# 确保模型文件的下载链接是直接可下载的链接
if curl --head --silent --fail "$MODEL_URL"; then
    echo "下载模型文件..."
    curl -L -o "$MODEL_FILE" "$MODEL_URL"
else
    echo "错误：无法下载模型文件。请检查模型的下载链接。"
    exit 1
fi

# 7. 将模型文件放到正确的路径
mkdir -p "$COMFYUI_DIR/models/checkpoints"
mv "$MODEL_FILE" "$COMFYUI_DIR/models/checkpoints/"

# 8. 启动 ComfyUI
echo "启动 ComfyUI..."
python "$COMFYUI_DIR/ComfyUI/main.py" &

# 9. 打开浏览器
echo "请在浏览器中打开 http://127.0.0.1:8188 来使用 ComfyUI。"
open "http://127.0.0.1:8188"

# 脚本执行完毕
echo "ComfyUI 安装完成。"
