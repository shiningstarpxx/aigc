#### 1. 安装comfyui

```bash
# 因为有minicoda，所以需要有root权限
> sudo bash install_comfyui.sh

# 按照指引一步步操作即可，安装完成后，默认安装目录是
> cd ~/comfyui

# 这个时候我们还没有基础模型，页面可以打开，但是会找不到模型
```



#### 2. 获取镜像

```bash
# 页面安装，浏览器打开链接
# https://huggingface.co/runwayml/stable-diffusion-v1-5/blob/main/v1-5-pruned-emaonly.safetensors
# 点击下载

> mv ~/Downloads/v1-5-pruned-emaonly.safetensors ~/comfyui/models/checkpoints/
```



#### 3. 重新启动comfyui

```bash
# kill python， 找到之前的comfy ui 任务，kill掉

# 启动conda
> conda env list 

# 找到comfyui
> conda activate comfyui_v1

# 进入到目录，启动comfyui
> cd ~/comfyui/ComfyUI/
> python main.py
```

