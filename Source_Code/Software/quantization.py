import torch
import torch.nn as nn
import torchvision
from model import Network
from torch.quantization.observer import MovingAverageMinMaxObserver


def evaluate (model, criterion, data_loader):
    loss = 0.0
    accuracy = 0.0

    model.eval()
    with torch.no_grad():
        for data, label in data_loader:
            out = model(data)

            loss += criterion(out, label).item()
            pred = out.data.max(1, keepdim=True)[1]
            accuracy += pred.eq(label.data.view_as(pred)).sum()

    loss /= len(data_loader.dataset)
    accuracy /= len(data_loader.dataset)

    return loss, accuracy


if __name__ == "__main__":
    batch_size_train = 32
    batch_size_test = 1000
    learning_rate = 0.001

    # initialize model
    model = Network()
    model.load_state_dict(torch.load("./model.pth", map_location="cpu"))

    transform = torchvision.transforms.Compose([
        torchvision.transforms.ToTensor(),
    ])

    criterion = nn.CrossEntropyLoss()

    # load dataset
    train_dataset = torchvision.datasets.MNIST("./dataset", train=True, download=True, transform=transform)
    train_loader = torch.utils.data.DataLoader(train_dataset, batch_size=batch_size_train, shuffle=True)

    test_dataset = torchvision.datasets.MNIST("./dataset", train=False, download=True, transform=transform)
    test_loader = torch.utils.data.DataLoader(test_dataset, batch_size=batch_size_test, shuffle=True)

    model.eval()
    model.fuse_model()
    model.qconfig = torch.quantization.QConfig(
        activation=MovingAverageMinMaxObserver.with_args(qscheme=torch.per_tensor_symmetric, dtype=torch.quint8),
        weight=MovingAverageMinMaxObserver.with_args(qscheme=torch.per_tensor_symmetric, dtype=torch.qint8)
    )

    print(model.qconfig)

    torch.quantization.prepare(model, inplace=True)
    print('Post Training Quantization Prepare')

    evaluate(model, criterion, train_loader)
    print('Post Training Quantization: Calibration done')

    torch.quantization.convert(model, inplace=True)
    print('Post Training Quantization: Convert done')

    loss, accuracy = evaluate(model, criterion, test_loader)
    print("Test set: Avg. loss: {:.4f}, Accuracy: {}/{} ({:.0f}%)".format(loss, accuracy, len(test_loader.dataset), 100.*accuracy))

    torch.save(model.state_dict(), "./model_quantized.pth")