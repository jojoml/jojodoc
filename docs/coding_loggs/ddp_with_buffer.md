## Use ddp with module buffer goes run
Running MDM with ddp version, https://github.com/GuyTevet/motion-diffusion-model

Runs into 
```
RuntimeError: unsupported operation: some elements of the input tensor and the written-to tensor refer to a single memory location
```
Related to DDP should not use buffer, but use parameter with require_grad=False

See https://github.com/Lightning-AI/lightning/discussions/14377