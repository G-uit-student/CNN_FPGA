import torch
import torch.nn as nn
import torchvision
from model import Network
from torch.optim import Adam
from tqdm import tqdm


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


def train (model, optimizer, criterion, train_loader, test_loader, epochs):
    for epoch in range(epochs):

        # train
        model.train()
        with tqdm  (train_loader, unit="batch") as tepoch:
            for data, target in tepoch:
                tepoch.set_description(f"Epoch {epoch+1}")

                optimizer.zero_grad()

                out = model(data)
                loss = criterion(out, target)

                loss.backward()
                optimizer.step()

                tepoch.set_postfix(loss=loss.item())

        # evaluate
        loss, accuracy = evaluate(model, criterion, test_loader)

        print("Test set: Avg. loss: {:.4f}, Accuracy: {}/{} ({:.0f}%)".format(loss, accuracy, len(test_loader.dataset), 100.*accuracy))

    return model


if __name__ == "__main__":
    batch_size_train = 32
    batch_size_test = 1000
    learning_rate = 0.001

    # initialize model
    model = Network()
    model.load_state_dict(torch.load("./model.pth"))
    model.to("cpu")

    transform = torchvision.transforms.Compose([
        torchvision.transforms.ToTensor(),
    ])

    optimizer = Adam(model.parameters(), lr=learning_rate)
    criterion = nn.CrossEntropyLoss()

    # load dataset
    train_dataset = torchvision.datasets.MNIST("./dataset", train=True, download=True, transform=transform)
    train_loader = torch.utils.data.DataLoader(train_dataset, batch_size=batch_size_train, shuffle=True)

    test_dataset = torchvision.datasets.MNIST("./dataset", train=False, download=True, transform=transform)
    test_loader = torch.utils.data.DataLoader(test_dataset, batch_size=batch_size_test, shuffle=True)

    model.fuse_model()
    model.qconfig = torch.quantization.get_default_qconfig("qnnpack")

    model.train()
    torch.quantization.prepare_qat(model, inplace=True)

    print('Training Quantization model...')
    train(model, optimizer, criterion, train_loader, test_loader, 5)

    torch.quantization.convert(model, inplace=True)

    loss, accuracy = evaluate(model, criterion, test_loader)
    print("Test set: Avg. loss: {:.4f}, Accuracy: {}/{} ({:.0f}%)".format(loss, accuracy, len(test_loader.dataset), 100.*accuracy))

    torch.save(model.state_dict(), "./model_quantized.pth")