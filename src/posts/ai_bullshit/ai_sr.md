---
date: 2023-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: ai bullshit
  key: super-resolution
layout: layouts/post.njk
---
# Note: I'm experimenting with generating tutorials from deepseek r1. That's where this comes from.

# Diffusion-Based Super-Resolution Tutorial with Code References

This tutorial explains a simplified implementation of a diffusion-based super-resolution model, with explicit references to where each mathematical concept appears in the code.

## Complete Python Implementation

```python
import torch
import torch.nn as nn
import torch.nn.functional as F
import numpy as np
from torch.utils.data import DataLoader
from torchvision import datasets, transforms
import matplotlib.pyplot as plt

# Set device
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# Define the U-Net model for noise prediction
class UNet(nn.Module):
    def __init__(self, in_channels=3, out_channels=3, base_channels=32):
        super(UNet, self).__init__()
        
        # Encoder (downsampling)
        self.enc1 = self._block(in_channels, base_channels)
        self.enc2 = self._block(base_channels, base_channels*2)
        self.pool = nn.MaxPool2d(2)
        
        # Bottleneck
        self.bottleneck = self._block(base_channels*2, base_channels*4)
        
        # Decoder (upsampling)
        self.upconv2 = nn.ConvTranspose2d(base_channels*4, base_channels*2, kernel_size=2, stride=2)
        self.dec2 = self._block(base_channels*4, base_channels*2)  # Skip connection doubles channels
        self.upconv1 = nn.ConvTranspose2d(base_channels*2, base_channels, kernel_size=2, stride=2)
        self.dec1 = self._block(base_channels*2, base_channels)  # Skip connection doubles channels
        
        # Final output layer
        self.out = nn.Conv2d(base_channels, out_channels, kernel_size=1)
        
    def _block(self, in_channels, out_channels):
        return nn.Sequential(
            nn.Conv2d(in_channels, out_channels, 3, padding=1),
            nn.ReLU(inplace=True),
            nn.Conv2d(out_channels, out_channels, 3, padding=1),
            nn.ReLU(inplace=True)
        )
    
    def forward(self, x, t):
        # Add time embedding (simplified)
        # REF: Time embedding implementation
        t_embed = t.view(-1, 1, 1, 1).expand(x.size(0), 1, x.size(2), x.size(3))
        x = torch.cat([x, t_embed], dim=1)
        
        # Encoder
        enc1 = self.enc1(x)
        enc2 = self.enc2(self.pool(enc1))
        
        # Bottleneck
        bottleneck = self.bottleneck(self.pool(enc2))
        
        # Decoder with skip connections
        dec2 = self.upconv2(bottleneck)
        dec2 = torch.cat([dec2, enc2], dim=1)
        dec2 = self.dec2(dec2)
        
        dec1 = self.upconv1(dec2)
        dec1 = torch.cat([dec1, enc1], dim=1)
        dec1 = self.dec1(dec1)
        
        return self.out(dec1)

# Define the diffusion process
class DiffusionProcess:
    def __init__(self, T=1000, beta_start=1e-4, beta_end=0.02):
        self.T = T
        
        # Linear noise schedule
        # REF: Equation for beta schedule
        self.betas = torch.linspace(beta_start, beta_end, T)
        # REF: α_t = 1 - β_t
        self.alphas = 1 - self.betas
        # REF: ᾱ_t = ∏_{s=1}^t α_s
        self.alpha_bars = torch.cumprod(self.alphas, dim=0)
        
    def forward_process(self, x0, t):
        """Add noise to image at timestep t"""
        # REF: √(ᾱ_t)
        sqrt_alpha_bar = torch.sqrt(self.alpha_bars[t]).view(-1, 1, 1, 1).to(x0.device)
        # REF: √(1 - ᾱ_t)
        sqrt_one_minus_alpha_bar = torch.sqrt(1 - self.alpha_bars[t]).view(-1, 1, 1, 1).to(x0.device)
        epsilon = torch.randn_like(x0)
        
        # REF: Equation x_t = √(ᾱ_t) * x_0 + √(1 - ᾱ_t) * ε
        xt = sqrt_alpha_bar * x0 + sqrt_one_minus_alpha_bar * epsilon
        return xt, epsilon
    
    def reverse_process(self, model, x, t, condition=None):
        """Remove noise from image at timestep t using the model"""
        with torch.no_grad():
            # Predict the noise
            # REF: ε_θ(x_t, t, y) where y is the condition
            epsilon_pred = model(x, t)
            
            # Calculate coefficients for reverse process
            # REF: α_t
            alpha_t = self.alphas[t].view(-1, 1, 1, 1).to(x.device)
            # REF: ᾱ_t
            alpha_bar_t = self.alpha_bars[t].view(-1, 1, 1, 1).to(x.device)
            # REF: β_t
            beta_t = self.betas[t].view(-1, 1, 1, 1).to(x.device)
            
            # REF: Equation for reverse process
            # x_{t-1} = (1/√(α_t)) * (x_t - (β_t/√(1-ᾱ_t)) * ε_θ) + σ_t * z
            if t > 0:
                z = torch.randn_like(x)
            else:
                z = 0
                
            sigma_t = torch.sqrt(beta_t)
            x_prev = (1 / torch.sqrt(alpha_t)) * (x - (beta_t / torch.sqrt(1 - alpha_bar_t)) * epsilon_pred) + sigma_t * z
            
            return x_prev

# Training function
def train_diffusion(model, diffusion, dataloader, optimizer, epochs=10):
    model.train()
    for epoch in range(epochs):
        total_loss = 0
        for i, (hr_imgs, _) in enumerate(dataloader):
            hr_imgs = hr_imgs.to(device)
            
            # Create low-resolution version (condition)
            # REF: y = low-resolution condition
            lr_imgs = F.interpolate(hr_imgs, scale_factor=0.25, mode='bilinear')
            lr_imgs = F.interpolate(lr_imgs, size=hr_imgs.shape[2:], mode='bilinear')
            
            # Random timestep
            # REF: t ~ Uniform(1, T)
            t = torch.randint(0, diffusion.T, (hr_imgs.size(0),), device=device)
            
            # Add noise to high-resolution images
            # REF: Forward process q(x_t|x_0)
            noisy_imgs, true_noise = diffusion.forward_process(hr_imgs, t)
            
            # Concatenate low-resolution condition with noisy image
            # REF: Conditioning the model on y
            model_input = torch.cat([noisy_imgs, lr_imgs], dim=1)
            
            # Predict noise
            # REF: ε_θ(x_t, t, y)
            pred_noise = model(model_input, t)
            
            # Calculate loss
            # REF: Loss function L = E[||ε - ε_θ(x_t, t, y)||^2]
            loss = F.mse_loss(pred_noise, true_noise)
            
            # Backward pass
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()
            
            total_loss += loss.item()
            
            if i % 100 == 0:
                print(f"Epoch {epoch+1}/{epochs}, Batch {i}, Loss: {loss.item():.4f}")
        
        print(f"Epoch {epoch+1}/{epochs}, Average Loss: {total_loss/len(dataloader):.4f}")

# Sampling function
def sample_diffusion(model, diffusion, lr_img, img_size=(32, 32)):
    model.eval()
    
    # Start from random noise
    # REF: x_T ~ N(0, I)
    x = torch.randn(1, 3, *img_size).to(device)
    
    # Upsample low-resolution image to target size
    # REF: Prepare condition y
    lr_img = F.interpolate(lr_img, size=img_size, mode='bilinear')
    
    # Reverse process
    # REF: p_θ(x_{0:T}|y) = p(x_T) ∏_{t=1}^T p_θ(x_{t-1}|x_t, y)
    for t in range(diffusion.T-1, -1, -1):
        # Create tensor of current timestep
        t_tensor = torch.tensor([t], device=device)
        
        # Concatenate with condition
        model_input = torch.cat([x, lr_img], dim=1)
        
        # Reverse process step
        # REF: p_θ(x_{t-1}|x_t, y)
        x = diffusion.reverse_process(model, model_input, t_tensor)
        
        # Clamp values to valid range
        x = torch.clamp(x, -1.0, 1.0)
        
    return x

# Main execution
if __name__ == "__main__":
    # Hyperparameters
    batch_size = 32
    learning_rate = 1e-4
    epochs = 5
    T = 1000  # Number of diffusion steps
    
    # Load and preprocess data
    transform = transforms.Compose([
        transforms.Resize((32, 32)),
        transforms.ToTensor(),
        transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5))
    ])
    
    train_dataset = datasets.CIFAR10(root='./data', train=True, download=True, transform=transform)
    train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
    
    # Initialize model and diffusion process
    model = UNet(in_channels=6, out_channels=3).to(device)  # 6 channels: 3 for noisy image + 3 for LR condition
    diffusion = DiffusionProcess(T=T)
    optimizer = torch.optim.Adam(model.parameters(), lr=learning_rate)
    
    # Train the model
    print("Starting training...")
    train_diffusion(model, diffusion, train_loader, optimizer, epochs=epochs)
    
    # Test with a sample image
    test_img, _ = next(iter(train_loader))
    test_img = test_img[0:1].to(device)  # Take one image
    
    # Create low-resolution version
    lr_img = F.interpolate(test_img, scale_factor=0.25, mode='bilinear')
    lr_img = F.interpolate(lr_img, size=test_img.shape[2:], mode='bilinear')
    
    # Generate super-resolution image
    print("Generating super-resolution image...")
    sr_img = sample_diffusion(model, diffusion, lr_img, img_size=test_img.shape[2:])
    
    # Visualize results
    fig, axes = plt.subplots(1, 3, figsize=(12, 4))
    
    axes[0].imshow(test_img[0].cpu().permute(1, 2, 0) * 0.5 + 0.5)
    axes[0].set_title("Original HR Image")
    axes[0].axis('off')
    
    axes[1].imshow(lr_img[0].cpu().permute(1, 2, 0) * 0.5 + 0.5)
    axes[1].set_title("LR Input")
    axes[1].axis('off')
    
    axes[2].imshow(sr_img[0].cpu().permute(1, 2, 0) * 0.5 + 0.5)
    axes[2].set_title("Generated SR Image")
    axes[2].axis('off')
    
    plt.tight_layout()
    plt.savefig('super_resolution_result.png')
    plt.show()
```

## Tutorial: How Diffusion-Based Super-Resolution Works

### 1. Introduction to Diffusion Models

Diffusion models are a class of generative models that work by gradually adding noise to data (forward process) and then learning to reverse this process (reverse process). For super-resolution, we condition this process on a low-resolution image to generate a high-resolution version.

### 2. Mathematical Foundation

#### Forward Process (Adding Noise)

The forward process is defined as a Markov chain that gradually adds Gaussian noise to the data:

`$$$
q(\mathbf{x}_t|\mathbf{x}_{t-1}) = \mathcal{N}(\mathbf{x}_t; \sqrt{1-\beta_t}\mathbf{x}_{t-1}, \beta_t\mathbf{I})
$$$`

Where:
- `$$\mathbf{x}_0$$` is the original high-resolution image
- `$$\beta_t$$` is the noise schedule at timestep `$$t$$`
- `$$T$$` is the total number of diffusion steps

**Code Reference**: In the `DiffusionProcess.__init__` method, we define the linear noise schedule:
```python
self.betas = torch.linspace(beta_start, beta_end, T)
```

After applying the forward process for `$$t$$` steps, we can directly sample `$$\mathbf{x}_t$$` from `$$\mathbf{x}_0$$`:

`$$$
q(\mathbf{x}_t|\mathbf{x}_0) = \mathcal{N}(\mathbf{x}_t; \sqrt{\bar{\alpha}_t}\mathbf{x}_0, (1-\bar{\alpha}_t)\mathbf{I})
$$$`

Where:
- `$$\alpha_t = 1 - \beta_t$$`
- `$$\bar{\alpha}_t = \prod_{s=1}^{t} \alpha_s$$`

**Code Reference**: In the `DiffusionProcess.__init__` method, we compute these values:
```python
self.alphas = 1 - self.betas
self.alpha_bars = torch.cumprod(self.alphas, dim=0)
```

**Code Reference**: In the `forward_process` method, we implement the equation:
```python
xt = sqrt_alpha_bar * x0 + sqrt_one_minus_alpha_bar * epsilon
```

#### Reverse Process (Denoising)

The reverse process learns to denoise the image:

`$$$
p_\theta(\mathbf{x}_{t-1}|\mathbf{x}_t, \mathbf{y}) = \mathcal{N}(\mathbf{x}_{t-1}; \mu_\theta(\mathbf{x}_t, t, \mathbf{y}), \Sigma_\theta(\mathbf{x}_t, t, \mathbf{y}))
$$$`

Where:
- `$$\mathbf{y}$$` is the low-resolution conditioning image
- `$$\theta$$` represents the model parameters

In practice, we train a model `$$\epsilon_\theta$$` to predict the noise `$$\epsilon$$` that was added:

`$$$
\mathcal{L} = \mathbb{E}_{t,\mathbf{x}_0,\epsilon}[\|\epsilon - \epsilon_\theta(\sqrt{\bar{\alpha}_t}\mathbf{x}_0 + \sqrt{1-\bar{\alpha}_t}\epsilon, t, \mathbf{y})\|^2]
$$$`

**Code Reference**: In the `train_diffusion` function, we implement this loss:
```python
loss = F.mse_loss(pred_noise, true_noise)
```

### 3. Key Components Explained

#### U-Net Architecture

The U-Net is used to predict the noise at each timestep. It has:
1. **Encoder**: Downsampling path that captures context
2. **Bottleneck**: Bridge between encoder and decoder
3. **Decoder**: Upsampling path that enables precise localization
4. **Skip connections**: Preserve spatial information

**Code Reference**: The U-Net architecture is implemented in the `UNet` class.

For conditional generation, we concatenate the low-resolution image with the noisy input at each timestep.

**Code Reference**: In the `train_diffusion` and `sample_diffusion` functions:
```python
model_input = torch.cat([noisy_imgs, lr_imgs], dim=1)
```

#### Noise Schedule

The noise schedule controls how much noise is added at each step. We use a linear schedule:
- `$$\beta$$` starts small (`$$10^{-4}$$`) and increases linearly to a maximum value (0.02)
- This ensures a smooth transition from data to noise

**Code Reference**: In the `DiffusionProcess.__init__` method:
```python
self.betas = torch.linspace(beta_start, beta_end, T)
```

#### Training Process

1. Sample a clean image `$$\mathbf{x}_0$$` from the dataset
2. Create a low-resolution version `$$\mathbf{y}$$` by downsampling
3. Sample a random timestep `$$t \sim \text{Uniform}(1, T)$$`
4. Sample noise `$$\epsilon \sim \mathcal{N}(0, \mathbf{I})$$`
5. Create a noisy image `$$\mathbf{x}_t = \sqrt{\bar{\alpha}_t}\mathbf{x}_0 + \sqrt{1-\bar{\alpha}_t}\epsilon$$`
6. Train the model to predict `$$\epsilon$$` from `$$\mathbf{x}_t$$`, `$$t$$`, and `$$\mathbf{y}$$`

**Code Reference**: In the `train_diffusion` function, we implement these steps:
```python
# Steps 1-2: Get HR image and create LR version
hr_imgs = hr_imgs.to(device)
lr_imgs = F.interpolate(hr_imgs, scale_factor=0.25, mode='bilinear')

# Step 3: Random timestep
t = torch.randint(0, diffusion.T, (hr_imgs.size(0),), device=device)

# Steps 4-5: Add noise
noisy_imgs, true_noise = diffusion.forward_process(hr_imgs, t)

# Step 6: Train model to predict noise
pred_noise = model(model_input, t)
loss = F.mse_loss(pred_noise, true_noise)
```

#### Sampling Process

1. Start with pure noise `$$\mathbf{x}_T \sim \mathcal{N}(0, \mathbf{I})$$`
2. For `$$t = T, T-1, \ldots, 1$$`:
   - Predict the noise `$$\epsilon_\theta(\mathbf{x}_t, t, \mathbf{y})$$`
   - Use the reverse process to obtain `$$\mathbf{x}_{t-1}$$`
3. The final result `$$\mathbf{x}_0$$` is the super-resolved image

**Code Reference**: In the `sample_diffusion` function, we implement these steps:
```python
# Step 1: Start from random noise
x = torch.randn(1, 3, *img_size).to(device)

# Step 2: Reverse process loop
for t in range(diffusion.T-1, -1, -1):
    # Predict noise and reverse the process
    x = diffusion.reverse_process(model, model_input, t_tensor)
```

### 4. Implementation Details

- **Conditioning**: We concatenate the low-resolution image with the noisy image at each step
- **Time embedding**: We add information about the current timestep to the model

**Code Reference**: In the `UNet.forward` method:
```python
t_embed = t.view(-1, 1, 1, 1).expand(x.size(0), 1, x.size(2), x.size(3))
x = torch.cat([x, t_embed], dim=1)
```

- **Loss function**: Mean squared error between predicted and actual noise

**Code Reference**: In the `train_diffusion` function:
```python
loss = F.mse_loss(pred_noise, true_noise)
```

### 5. Practical Considerations

- This implementation is simplified for educational purposes
- Real-world implementations would use more sophisticated architectures (e.g., with attention mechanisms)
- Training diffusion models requires significant computational resources
- The number of diffusion steps `$$T$$` affects both quality and sampling time

### 6. Extensions and Improvements

1. **Classifier-free guidance**: Improves sample quality by randomly dropping the condition during training
2. **Progressive distillation**: Reduces the number of sampling steps
3. **Improved noise schedules**: Cosine schedule often works better than linear
4. **Architectural improvements**: Transformer components, adaptive normalization

This tutorial provides a foundation for understanding diffusion-based super-resolution with explicit references to where each mathematical concept is implemented in the code. For state-of-the-art results, researchers combine these concepts with more advanced techniques and larger-scale training.


