## Slurm Cheat Sheet

https://slurm.schedmd.com/pdfs/summary.pdf

```bash
alias sq='squeue -u muchenli -o "%.18i %.9P %.25j %.8u %.8T %.10M %.9l %.6D %R"'
alias sqp='squeue -p edith -o "%.18i %.9P %.25j %.8u %.10T %.15M %.15l %5D %12R %b"'
alias si='sinfo -O "NodeHost:10","StateCompact:6","CPUsState:14","Memory:7","AllocMem:9","FreeMem:9","GresUsed:55","Gres:55" -p edith'
```