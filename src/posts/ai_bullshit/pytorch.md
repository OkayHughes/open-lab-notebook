---
date: 2023-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: ai bullshit
  key: pytorch crash course
layout: layouts/post.njk
---


# PyTorch Tutorial for Applied and Computational Mathematicians

## Introduction

This tutorial is designed for someone with a background in applied/computational mathematics and solid Python skills. We'll focus on how PyTorch implements mathematical concepts you're already familiar with, particularly focusing on tensors, automatic differentiation, and optimization.

## 1. Tensors: The Fundamental Data Structure

Tensors are PyTorch's fundamental data structure - generalized matrices with N dimensions.

```python
import torch
import numpy as np

# Creating tensors (similar to numpy arrays)
x = torch.tensor([1.0, 2.0, 3.0])          # 1D tensor (vector)
A = torch.tensor([[1, 2], [3, 4]])         # 2D tensor (matrix)
T = torch.randn(2, 3, 4)                   # 3D tensor

# Tensor operations (familiar from linear algebra)
v = torch.tensor([1.0, 2.0, 3.0])
w = torch.tensor([4.0, 5.0, 6.0])

dot_product = torch.dot(v, w)              # Dot product
matrix_vector = A @ v[:2]                  # Matrix-vector multiplication
matrix_matrix = A @ A.T                    # Matrix multiplication

# Special tensor types
identity = torch.eye(3)                    # Identity matrix
zeros = torch.zeros(2, 3)                  # Zero matrix
ones = torch.ones(2, 3)                    # Matrix of ones

# Converting between numpy and torch (shared memory)
np_array = np.array([1, 2, 3])
torch_tensor = torch.from_numpy(np_array)  # Convert numpy to torch
back_to_numpy = torch_tensor.numpy()       # Convert torch to numpy
```

## 2. Automatic Differentiation: The Mathematical Core

PyTorch's autograd system automatically computes gradients, which is essential for optimization.

```python
# Variables for which we want to compute gradients
x = torch.tensor(2.0, requires_grad=True)
y = torch.tensor(3.0, requires_grad=True)

# Define a function (e.g., f(x,y) = x²y + y + 2)
z = x**2 * y + y + 2

# Compute gradients (∇z = [∂z/∂x, ∂z/∂y])
z.backward()

# Access gradients
print(x.grad)  # ∂z/∂x = 2xy = 12.0
print(y.grad)  # ∂z/∂y = x² + 1 = 5.0
```

### More complex example: Gradient of a vector function

```python
# Jacobian-vector product example
x = torch.tensor([1.0, 2.0], requires_grad=True)
y = torch.tensor([x[0]**2 + x[1], x[0] * x[1]])

# If we want dy/dx, we need to provide a vector for v in v^T * J
v = torch.tensor([1.0, 1.0])
y.backward(v)  # Computes v^T * J

print(x.grad)  # [∂(y1+y2)/∂x1, ∂(y1+y2)/∂x2] = [2x1 + x2, 1 + x1] = [4, 2]
```

## 3. Solving Optimization Problems

Let's implement gradient descent to solve a simple minimization problem.

```python
# Minimize f(x) = x^4 - 3x^3 + 2
def f(x):
    return x**4 - 3*x**3 + 2

# Gradient descent
x = torch.tensor(0.0, requires_grad=True)  # Initial guess
learning_rate = 0.01
iterations = 1000

for i in range(iterations):
    # Compute function value and gradient
    loss = f(x)
    loss.backward()  # Compute gradient ∇f(x)
    
    # Update x (gradient descent step)
    with torch.no_grad():  # Temporarily disable gradient tracking
        x -= learning_rate * x.grad
        
    # Zero the gradient for the next iteration
    x.grad.zero_()
    
    if i % 100 == 0:
        print(f"Iteration {i}: x = {x.item():.4f}, f(x) = {loss.item():.4f}")

print(f"Minimum at x = {x.item():.4f}, f(x) = {f(x).item():.4f}")
```

## 4. Linear Algebra Operations

PyTorch includes a comprehensive linear algebra module.

```python
# Matrix operations
A = torch.tensor([[3., 1.], [1., 2.]])
b = torch.tensor([9., 8.])

# Solve linear system Ax = b (like numpy.linalg.solve)
x = torch.linalg.solve(A, b)
print(f"Solution to Ax=b: {x}")

# Eigen decomposition
eigenvalues, eigenvectors = torch.linalg.eig(A)
print(f"Eigenvalues: {eigenvalues}")
print(f"Eigenvectors: {eigenvectors}")

# Singular Value Decomposition (SVD)
U, S, V = torch.svd(A)
print(f"Singular values: {S}")

# Matrix inversion
A_inv = torch.inverse(A)
print(f"Inverse of A: {A_inv}")
```

## 5. Solving Differential Equations

Let's solve a simple ODE using PyTorch's autograd.

```python
# Solve u'' + u = 0 with u(0)=0, u(π/2)=1
# This is a boundary value problem

import torch.nn as nn

class NeuralNetwork(nn.Module):
    def __init__(self):
        super().__init__()
        self.layers = nn.Sequential(
            nn.Linear(1, 10),
            nn.Tanh(),
            nn.Linear(10, 10),
            nn.Tanh(),
            nn.Linear(10, 1)
        )
    
    def forward(self, x):
        return self.layers(x)

# Create model and optimizer
model = NeuralNetwork()
optimizer = torch.optim.Adam(model.parameters(), lr=0.01)

# Training to satisfy the ODE and boundary conditions
for step in range(10000):
    optimizer.zero_grad()
    
    # Sample points in the domain [0, π/2]
    x_internal = torch.rand(100, 1) * (torch.pi/2)
    x_internal.requires_grad = True
    
    # Compute solution and its derivatives
    u = model(x_internal)
    u_x = torch.autograd.grad(u, x_internal, grad_outputs=torch.ones_like(u), 
                             create_graph=True)[0]
    u_xx = torch.autograd.grad(u_x, x_internal, grad_outputs=torch.ones_like(u_x), 
                              create_graph=True)[0]
    
    # ODE residual: u'' + u
    residual = u_xx + u
    
    # Boundary conditions
    u0 = model(torch.tensor([[0.0]]))
    u_pi_half = model(torch.tensor([[torch.pi/2]]))
    
    # Loss = MSE of residual + boundary condition penalties
    loss = (residual**2).mean() + (u0 - 0)**2 + (u_pi_half - 1)**2
    
    loss.backward()
    optimizer.step()
    
    if step % 1000 == 0:
        print(f"Step {step}, Loss: {loss.item()}")

# Analytical solution is sin(x), let's compare
test_x = torch.linspace(0, torch.pi/2, 100).reshape(-1, 1)
with torch.no_grad():
    predicted = model(test_x)
    analytical = torch.sin(test_x)

print("Max error:", torch.max(torch.abs(predicted - analytical)).item())
```

## 6. Fourier Transforms and Signal Processing

```python
# Signal processing operations
t = torch.linspace(0, 1, 1000)
signal = torch.sin(2 * torch.pi * 5 * t) + 0.5 * torch.sin(2 * torch.pi * 10 * t)

# Fourier transform
freq_domain = torch.fft.fft(signal)
frequencies = torch.fft.fftfreq(len(signal))

# Power spectrum
power_spectrum = torch.abs(freq_domain)**2

# Find dominant frequencies
dominant_freq_idx = torch.argsort(power_spectrum, descending=True)
print("Dominant frequencies (Hz):", frequencies[dominant_freq_idx[:5]] * 1000)
```

## 7. Custom Autograd Functions

For implementing custom mathematical operations with automatic differentiation.

```python
# Custom function: f(x) = x^3 if x >= 0, 0 otherwise
class CustomCubic(torch.autograd.Function):
    @staticmethod
    def forward(ctx, x):
        ctx.save_for_backward(x)  # Save for backward pass
        return torch.where(x >= 0, x**3, torch.zeros_like(x))
    
    @staticmethod
    def backward(ctx, grad_output):
        x, = ctx.saved_tensors
        # Derivative: 3x^2 if x >= 0, 0 otherwise
        grad_input = grad_output * torch.where(x >= 0, 3*x**2, torch.zeros_like(x))
        return grad_input

# Use our custom function
x = torch.tensor([-2.0, -1.0, 0.0, 1.0, 2.0], requires_grad=True)
y = CustomCubic.apply(x)

# Compute gradient
y.sum().backward()
print("x:", x)
print("f(x):", y)
print("f'(x):", x.grad)
```

## 8. Performance: GPU Acceleration

One of PyTorch's key advantages is seamless GPU acceleration.

```python
# Check if GPU is available
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f"Using device: {device}")

# Move tensors to GPU
x = torch.randn(1000, 1000).to(device)
y = torch.randn(1000, 1000).to(device)

# Matrix multiplication on GPU (much faster for large matrices)
z = x @ y

# Move back to CPU if needed
z_cpu = z.cpu()
```

## 9. Solving a Linear System with Constraints

Let's solve a quadratic programming problem: minimize ½xᵀQx + cᵀx subject to Ax = b.

```python
# Example: min ½xᵀQx + cᵀx subject to Ax = b
Q = torch.tensor([[2., 0.], [0., 4.]])
c = torch.tensor([1., 1.])
A = torch.tensor([[1., 1.]])
b = torch.tensor([1.])

# Using Lagrange multipliers: [Q, Aᵀ; A, 0] [x; λ] = [-c; b]
M = torch.zeros(3, 3)
M[:2, :2] = Q
M[:2, 2] = A.T
M[2, :2] = A

rhs = torch.cat([-c, b])

solution = torch.linalg.solve(M, rhs)
x_opt = solution[:2]
lambda_opt = solution[2]

print(f"Optimal x: {x_opt}")
print(f"Lagrange multiplier: {lambda_opt}")
```

## Conclusion

This tutorial covered the core mathematical aspects of PyTorch:

1. **Tensors** as generalized matrices with efficient operations
2. **Automatic differentiation** for computing gradients
3. **Optimization algorithms** for solving minimization problems
4. **Linear algebra operations** for matrix computations
5. **Solving differential equations** with neural networks
6. **Signal processing** with Fourier transforms
7. **Custom mathematical operations** with autograd support
8. **GPU acceleration** for performance

PyTorch provides a powerful framework for mathematical computing that combines the flexibility of Python with the performance of optimized native code. Its automatic differentiation capabilities make it particularly valuable for solving optimization problems and differential equations that are common in applied mathematics.

For further learning, explore:
- PyTorch's `torch.linalg` module for advanced linear algebra
- The `torch.optim` module for optimization algorithms
- PyTorch's neural network capabilities for solving PDEs
- GPU programming patterns for high-performance computing

# PyTorch Tutorial: Neural Network Architectures

## Introduction

This augmentation to the PyTorch tutorial focuses on implementing two fundamental neural network architectures: a Multi-Layer Perceptron (MLP) for image classification and a Convolutional Neural Network (CNN) for more advanced image recognition tasks. We'll use common datasets (MNIST and CIFAR-10) and cover the complete training pipeline.

## Prerequisites

```python
import torch
import torch.nn as nn
import torch.optim as optim
import torchvision
import torchvision.transforms as transforms
from torch.utils.data import DataLoader
import matplotlib.pyplot as plt
import numpy as np
```

## 10. Multi-Layer Perceptron (MLP) for MNIST Classification

### Data Preparation

```python
# Transform to normalize data and convert to tensor
transform = transforms.Compose([
    transforms.ToTensor(),
    transforms.Normalize((0.5,), (0.5,))
])

# Download and load the MNIST dataset
train_dataset = torchvision.datasets.MNIST(
    root='./data', 
    train=True, 
    download=True, 
    transform=transform
)

test_dataset = torchvision.datasets.MNIST(
    root='./data', 
    train=False, 
    download=True, 
    transform=transform
)

# Create data loaders
batch_size = 64
train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
test_loader = DataLoader(test_dataset, batch_size=batch_size, shuffle=False)
```

### Model Architecture

```python
class MLP(nn.Module):
    def __init__(self, input_size, hidden_size, num_classes):
        super(MLP, self).__init__()
        self.fc1 = nn.Linear(input_size, hidden_size)
        self.relu = nn.ReLU()
        self.fc2 = nn.Linear(hidden_size, hidden_size)
        self.fc3 = nn.Linear(hidden_size, num_classes)
        
    def forward(self, x):
        # Flatten the input images
        x = x.view(x.size(0), -1)
        out = self.fc1(x)
        out = self.relu(out)
        out = self.fc2(out)
        out = self.relu(out)
        out = self.fc3(out)
        return out

# Initialize model
input_size = 28 * 28  # MNIST images are 28x28
hidden_size = 128
num_classes = 10
model = MLP(input_size, hidden_size, num_classes)
```

### Training Loop

```python
# Loss and optimizer
criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.parameters(), lr=0.001)

# Training function
def train_model(model, train_loader, criterion, optimizer, num_epochs=5):
    model.train()
    total_step = len(train_loader)
    loss_history = []
    
    for epoch in range(num_epochs):
        for i, (images, labels) in enumerate(train_loader):
            # Forward pass
            outputs = model(images)
            loss = criterion(outputs, labels)
            
            # Backward and optimize
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()
            
            # Record loss
            loss_history.append(loss.item())
            
            if (i+1) % 100 == 0:
                print(f'Epoch [{epoch+1}/{num_epochs}], Step [{i+1}/{total_step}], Loss: {loss.item():.4f}')
    
    return loss_history

# Train the model
loss_history = train_model(model, train_loader, criterion, optimizer, num_epochs=5)
```

### Evaluation

```python
def evaluate_model(model, test_loader):
    model.eval()
    with torch.no_grad():
        correct = 0
        total = 0
        for images, labels in test_loader:
            outputs = model(images)
            _, predicted = torch.max(outputs.data, 1)
            total += labels.size(0)
            correct += (predicted == labels).sum().item()
        
        accuracy = 100 * correct / total
        print(f'Test Accuracy: {accuracy:.2f}%')
    return accuracy

# Evaluate the model
accuracy = evaluate_model(model, test_loader)
```

### Visualization

```python
# Plot training loss
plt.plot(loss_history)
plt.title('Training Loss History')
plt.xlabel('Iterations')
plt.ylabel('Loss')
plt.show()

# Display some test results
def visualize_predictions(model, test_loader, num_images=6):
    model.eval()
    images_so_far = 0
    fig = plt.figure(figsize=(10, 8))
    
    with torch.no_grad():
        for images, labels in test_loader:
            outputs = model(images)
            _, preds = torch.max(outputs, 1)
            
            for j in range(images.size()[0]):
                images_so_far += 1
                ax = plt.subplot(num_images//2, 2, images_so_far)
                ax.axis('off')
                ax.set_title(f'Predicted: {preds[j].item()}, True: {labels[j].item()}')
                
                # Convert image back to display format
                img = images[j].numpy().transpose((1, 2, 0))
                img = np.clip(img * 0.5 + 0.5, 0, 1)  # Unnormalize
                
                plt.imshow(img.squeeze(), cmap='gray')
                
                if images_so_far == num_images:
                    return
                
visualize_predictions(model, test_loader)
```

## 11. Convolutional Neural Network (CNN) for CIFAR-10

### Data Preparation

```python
# Data augmentation and normalization for training
# Just normalization for validation
transform_train = transforms.Compose([
    transforms.RandomHorizontalFlip(),
    transforms.RandomCrop(32, padding=4),
    transforms.ToTensor(),
    transforms.Normalize((0.4914, 0.4822, 0.4465), (0.2023, 0.1994, 0.2010)),
])

transform_test = transforms.Compose([
    transforms.ToTensor(),
    transforms.Normalize((0.4914, 0.4822, 0.4465), (0.2023, 0.1994, 0.2010)),
])

# Download and load CIFAR-10 dataset
train_dataset = torchvision.datasets.CIFAR10(
    root='./data', 
    train=True, 
    download=True, 
    transform=transform_train
)

test_dataset = torchvision.datasets.CIFAR10(
    root='./data', 
    train=False, 
    download=True, 
    transform=transform_test
)

# Create data loaders
batch_size = 128
train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
test_loader = DataLoader(test_dataset, batch_size=batch_size, shuffle=False)

# Class names for CIFAR-10
classes = ('plane', 'car', 'bird', 'cat', 'deer', 'dog', 'frog', 'horse', 'ship', 'truck')
```

### CNN Architecture

```python
class CNN(nn.Module):
    def __init__(self, num_classes=10):
        super(CNN, self).__init__()
        self.conv1 = nn.Conv2d(3, 32, 3, padding=1)
        self.conv2 = nn.Conv2d(32, 64, 3, padding=1)
        self.conv3 = nn.Conv2d(64, 128, 3, padding=1)
        self.pool = nn.MaxPool2d(2, 2)
        self.fc1 = nn.Linear(128 * 4 * 4, 512)
        self.fc2 = nn.Linear(512, num_classes)
        self.dropout = nn.Dropout(0.5)
        self.relu = nn.ReLU()
        
    def forward(self, x):
        # Convolutional layers
        x = self.pool(self.relu(self.conv1(x)))
        x = self.pool(self.relu(self.conv2(x)))
        x = self.pool(self.relu(self.conv3(x)))
        
        # Flatten
        x = x.view(-1, 128 * 4 * 4)
        
        # Fully connected layers
        x = self.dropout(self.relu(self.fc1(x)))
        x = self.fc2(x)
        return x

# Initialize model
model_cnn = CNN()
```

### Training with Learning Rate Scheduling

```python
# Loss and optimizer
criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model_cnn.parameters(), lr=0.001)
scheduler = optim.lr_scheduler.StepLR(optimizer, step_size=5, gamma=0.1)

# Training function with validation
def train_cnn(model, train_loader, test_loader, criterion, optimizer, scheduler, num_epochs=10):
    train_loss_history = []
    val_accuracy_history = []
    
    for epoch in range(num_epochs):
        # Training phase
        model.train()
        running_loss = 0.0
        for i, (images, labels) in enumerate(train_loader):
            # Forward pass
            outputs = model(images)
            loss = criterion(outputs, labels)
            
            # Backward and optimize
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()
            
            running_loss += loss.item()
            
            if (i+1) % 100 == 0:
                print(f'Epoch [{epoch+1}/{num_epochs}], Step [{i+1}/{len(train_loader)}], Loss: {loss.item():.4f}')
        
        # Calculate average training loss
        avg_train_loss = running_loss / len(train_loader)
        train_loss_history.append(avg_train_loss)
        
        # Validation phase
        model.eval()
        correct = 0
        total = 0
        with torch.no_grad():
            for images, labels in test_loader:
                outputs = model(images)
                _, predicted = torch.max(outputs.data, 1)
                total += labels.size(0)
                correct += (predicted == labels).sum().item()
        
        accuracy = 100 * correct / total
        val_accuracy_history.append(accuracy)
        
        print(f'Epoch [{epoch+1}/{num_epochs}], Train Loss: {avg_train_loss:.4f}, Val Accuracy: {accuracy:.2f}%')
        
        # Step the scheduler
        scheduler.step()
    
    return train_loss_history, val_accuracy_history

# Train the CNN
train_loss, val_accuracy = train_cnn(model_cnn, train_loader, test_loader, criterion, optimizer, scheduler, num_epochs=10)
```

### Advanced Evaluation

```python
# Plot training and validation results
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 4))

ax1.plot(train_loss)
ax1.set_title('Training Loss')
ax1.set_xlabel('Epoch')
ax1.set_ylabel('Loss')

ax2.plot(val_accuracy)
ax2.set_title('Validation Accuracy')
ax2.set_xlabel('Epoch')
ax2.set_ylabel('Accuracy (%)')

plt.tight_layout()
plt.show()

# Per-class accuracy
def class_accuracy(model, test_loader, classes):
    model.eval()
    class_correct = list(0. for i in range(10))
    class_total = list(0. for i in range(10))
    
    with torch.no_grad():
        for images, labels in test_loader:
            outputs = model(images)
            _, predicted = torch.max(outputs, 1)
            c = (predicted == labels).squeeze()
            
            for i in range(labels.size(0)):
                label = labels[i]
                class_correct[label] += c[i].item()
                class_total[label] += 1
    
    for i in range(10):
        print(f'Accuracy of {classes[i]}: {100 * class_correct[i] / class_total[i]:.2f}%')

class_accuracy(model_cnn, test_loader, classes)

# Confusion matrix
from sklearn.metrics import confusion_matrix
import seaborn as sns

def plot_confusion_matrix(model, test_loader):
    model.eval()
    all_preds = []
    all_labels = []
    
    with torch.no_grad():
        for images, labels in test_loader:
            outputs = model(images)
            _, predicted = torch.max(outputs, 1)
            all_preds.extend(predicted.numpy())
            all_labels.extend(labels.numpy())
    
    cm = confusion_matrix(all_labels, all_preds)
    plt.figure(figsize=(10, 8))
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', 
                xticklabels=classes, yticklabels=classes)
    plt.title('Confusion Matrix')
    plt.ylabel('True Label')
    plt.xlabel('Predicted Label')
    plt.show()

plot_confusion_matrix(model_cnn, test_loader)
```

### Saving and Loading Models

```python
# Save the trained model
torch.save(model_cnn.state_dict(), 'cifar10_cnn.pth')

# Load the model (for later use)
loaded_model = CNN()
loaded_model.load_state_dict(torch.load('cifar10_cnn.pth'))
loaded_model.eval()

# Test the loaded model
loaded_accuracy = evaluate_model(loaded_model, test_loader)
print(f'Loaded model accuracy: {loaded_accuracy:.2f}%')
```

## 12. Using GPU Acceleration

```python
# Check if GPU is available
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f'Using device: {device}')

# Modify models to use GPU
model_mlp = MLP(input_size, hidden_size, num_classes).to(device)
model_cnn = CNN().to(device)

# Modify training functions to move data to GPU
def train_gpu(model, train_loader, criterion, optimizer, num_epochs=5):
    model.train()
    for epoch in range(num_epochs):
        for i, (images, labels) in enumerate(train_loader):
            # Move data to GPU
            images = images.to(device)
            labels = labels.to(device)
            
            # Forward pass
            outputs = model(images)
            loss = criterion(outputs, labels)
            
            # Backward and optimize
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()
            
            if (i+1) % 100 == 0:
                print(f'Epoch [{epoch+1}/{num_epochs}], Step [{i+1}/{len(train_loader)}], Loss: {loss.item():.4f}')

# Train on GPU
train_gpu(model_cnn, train_loader, criterion, optimizer, num_epochs=5)
```

## Conclusion

This tutorial extension has covered:

1. **MLP Implementation**: Built a fully connected network for MNIST digit classification
2. **CNN Implementation**: Created a convolutional neural network for CIFAR-10 image classification
3. **Data Handling**: Downloaded and preprocessed standard datasets
4. **Training Pipelines**: Implemented complete training loops with validation
5. **Evaluation**: Analyzed model performance with accuracy metrics and visualizations
6. **Model Persistence**: Saved and loaded trained models
7. **GPU Acceleration**: Utilized GPU resources for faster training

These implementations demonstrate fundamental concepts in deep learning with PyTorch. You can extend these architectures by:
- Adding more layers for increased capacity
- Experimenting with different optimization algorithms
- Implementing regularization techniques like dropout and batch normalization
- Trying more advanced architectures like ResNet or Transformer networks

The mathematical foundation provided in the first part of the tutorial combined with these practical implementations gives you a comprehensive understanding of PyTorch for both mathematical computing and deep learning applications.