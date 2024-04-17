#!/bin/bash

# 确保脚本以 root 权限运行
if [ "$(id -u)" != "0" ]; then
   echo "此脚本需要 root 权限，请使用 sudo 运行。" 1>&2
   exit 1
fi

# 检查 git 和 curl 是否已安装
for cmd in git curl; do
    if ! command -v $cmd &> /dev/null; then
        echo "错误：$cmd 命令未找到。请确保已安装 $cmd。"
        exit 1
    fi
done

# 1. 安装 Conda
echo "安装 Conda..."
CONDA_INSTALLER=""
case "$(uname -s)-$(uname -m)" in
    Darwin-x86_64) CONDA_INSTALLER="Miniconda3-latest-MacOSX-x86_64.sh" ;;
    Darwin-arm64) CONDA_INSTALLER="Miniconda3-latest-MacOSX-arm64.sh" ;;
    *)
        echo "错误：不支持的操作系统或架构。"
        exit 1
        ;;
esac
curl -O "https://repo.anaconda.com/miniconda/$CONDA_INSTALLER"
sh "$CONDA_INSTALLER"
rm "$CONDA_INSTALLER"

# 将 Conda 添加到环境变量
echo "将 Conda 添加到环境变量..."
CONDA_PATH="$(conda info --base)/bin"
SHELL_CONFIG_FILE="$HOME/.bashrc"
if [ "$SHELL" = "/bin/zsh" ] || [ "$SHELL" = "/usr/bin/zsh" ]; then
    SHELL_CONFIG_FILE="$HOME/.zshrc"
fi

if [[ ":$PATH:" != *":$CONDA_PATH:"* ]]; then
    echo "export PATH=\"$CONDA_PATH:\$PATH\"" >> "$SHELL_CONFIG_FILE"
    source "$SHELL_CONFIG_FILE"
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

#
