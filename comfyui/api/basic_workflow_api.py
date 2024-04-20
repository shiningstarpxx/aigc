import json
import random
from urllib import request, parse

def find_node_by_class_type(workflow, class_type):
    for key, value in workflow.items():
        if value["class_type"] == class_type:
            return key, value
    return None, None

def find_node_by_meta_title(workflow, title):
    for key, value in workflow.items():
        if value["_meta"]["title"] == title:
            return key, value
    return None, None

def queue_prompt(prompt_workflow):
    p = {"prompt": prompt_workflow}
    data = json.dumps(p).encode('utf-8')
    req = request.Request("http://127.0.0.1:8188/prompt", data=data)
    request.urlopen(req)

# @todo: michael, 所有的工作流都需要标准化，才可以用通用的代码处理
def configure_prompt_workflow(prompt_workflow, checkpoint_path, prompt, img_width, img_height, batch_size, seed, fileprefix):
    # Find nodes by class_type and _meta
    _, chkpoint_loader_node = find_node_by_class_type(prompt_workflow, "CheckpointLoaderSimple")
    _, prompt_neg_node = find_node_by_meta_title(prompt_workflow, "CLIP Text Encode (Prompt) 反向")
    _, prompt_pos_node = find_node_by_meta_title(prompt_workflow, "CLIP Text Encode (Prompt) 正向")
    _, ksampler_node = find_node_by_class_type(prompt_workflow, "KSampler")
    _, save_image_node = find_node_by_class_type(prompt_workflow, "SaveImage")
    _, empty_latent_img_node = find_node_by_class_type(prompt_workflow, "EmptyLatentImage")

    # Configure nodes
    chkpoint_loader_node["inputs"]["ckpt_name"] = checkpoint_path
    empty_latent_img_node["inputs"]["width"] = img_width
    empty_latent_img_node["inputs"]["height"] = img_height
    empty_latent_img_node["inputs"]["batch_size"] = batch_size
    prompt_neg_node["inputs"]["text"] = ""
    prompt_pos_node["inputs"]["text"] = prompt
    ksampler_node["inputs"]["seed"] = seed
    save_image_node["inputs"]["filename_prefix"] = fileprefix

# Load workflow api data from file and convert it into dictionary
prompt_workflow = json.load(open('workflow_api.json'))

# Create a list of prompts
prompt_list = [
    "photo of a man sitting in a cafe",
    "photo of a woman standing in the middle of a busy street",
    "drawing of a cat sitting in a tree",
    "beautiful scenery nature glass bottle landscape, purple galaxy bottle"
]

# Configuration
# checkpoint_path = "SD1-5/sd_v1-5_vae.ckpt"
checkpoint_path = "v1-5-pruned-emaonly.ckpt"
img_width = 512
img_height = 640
batch_size = 4

# For every prompt in prompt_list...
for index, prompt in enumerate(prompt_list):
    # Set a random seed
    seed = random.randint(1, 18446744073709551614)

    # Truncate the file prefix to the first 100 characters if necessary
    fileprefix = prompt[:100]

    # If it is the last prompt, set latent image height to 768
    if index == len(prompt_list) - 1:
        img_height = 768

    # Configure the prompt workflow
    configure_prompt_workflow(prompt_workflow, checkpoint_path, prompt, img_width, img_height, batch_size, seed, fileprefix)

    # Everything set, add entire workflow to queue.
    queue_prompt(prompt_workflow)