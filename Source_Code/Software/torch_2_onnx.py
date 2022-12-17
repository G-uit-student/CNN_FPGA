import torch
import onnxruntime as onnxrt
import numpy as np
from PIL import Image
import matplotlib.pyplot as plt
from torch.quantization.observer import MovingAverageMinMaxObserver
from model import Network

def convert_cnn_part(img, save_path, model): 
    with torch.no_grad(): 
        src = model.cnn(img)
        torch.onnx.export(model.cnn, img, save_path, export_params=True, opset_version=12, do_constant_folding=True, verbose=True, input_names=['img'], output_names=['output'], dynamic_axes={'img': {3: 'lenght'}, 'output': {0: 'channel'}})
    
    return src


if __name__ == "__main__":
    # initialize model
    model = Network()
    model.load_state_dict(torch.load("./model.pth", map_location="cpu"))

    model.eval()
    model.fuse_model()
    model.qconfig = torch.quantization.QConfig(
        activation=MovingAverageMinMaxObserver.with_args(qscheme=torch.per_tensor_symmetric, dtype=torch.quint8),
        weight=MovingAverageMinMaxObserver.with_args(qscheme=torch.per_tensor_symmetric, dtype=torch.qint8)
    )

    torch.quantization.prepare(model, inplace=True)
    torch.quantization.convert(model, inplace=True)

    model.load_state_dict(torch.load("./weights/model_quantized.pth"))
    model.eval()

    dummy_input = torch.randn(1, 1, 28, 28)
    input_names = [ "actual_input" ]
    output_names = [ "output" ]

    dynamic_axes_dict = {
        'actual_input': {
            0: 'channel_input',
        },
        'Output': {
            0: 'channel_output'
        }
    } 
 
    torch.onnx.export(  model,
                        dummy_input, "./weights/model_quantized.onnx",
                        verbose=False,
                        input_names=input_names,
                        output_names=output_names,
                        dynamic_axes=dynamic_axes_dict,
                        export_params=True,
    )
