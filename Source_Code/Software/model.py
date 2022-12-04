import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.ao.quantization import QuantStub, DeQuantStub


class ConvBN(nn.Sequential):
    def __init__(self, in_channels=1, out_channels=32, kernel_size=3, stride=1, padding=1):
        super(ConvBN, self).__init__(
            nn.Conv2d(in_channels=in_channels, out_channels=out_channels, kernel_size=kernel_size, stride=stride, padding=padding, dilation=1, bias=True, padding_mode='zeros'),
            nn.BatchNorm2d(out_channels, momentum=0.1)
        )


class Network(nn.Module):
    def __init__(self):
        super(Network, self).__init__()
        self.conv1 = ConvBN(in_channels=1, out_channels=32, kernel_size=3, stride=1, padding=1)
        self.conv2 = ConvBN(in_channels=32, out_channels=32, kernel_size=3, stride=1, padding=1)
        self.pool = nn.MaxPool2d((2, 2))
        self.flatten = nn.Flatten()
        self.fc1 = nn.Linear(32*14*14, 128)
        self.fc2 = nn.Linear(128, 10)
        self.sigmoid = nn.Sigmoid()
        self.softmax = nn.Softmax(dim=1)
        self.drop = nn.Dropout(p=0.2)
        self.quant = QuantStub()
        self.dequant = DeQuantStub()

    def forward(self, x):
        x = self.quant(x)
        x = self.conv1(x)
        x = self.sigmoid(x)
        x = self.conv2(x)
        x = self.sigmoid(x)
        x = self.pool(x)
        x = self.flatten(x)
        x = self.drop(x)
        x = self.fc1(x)
        x = self.sigmoid(x)
        x = self.drop(x)
        x = self.fc2(x)
        x = self.dequant(x)
        x = self.softmax(x)
        return x

    def fuse_model(self):
        self.eval()
        for m in self.modules():
            if type(m) == ConvBN:
                torch.ao.quantization.fuse_modules(m, ['0', '1'], inplace=True)

