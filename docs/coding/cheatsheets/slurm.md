## Slurm Cheat Sheet

https://slurm.schedmd.com/pdfs/summary.pdf

```bash
alias sq='squeue -u muchenli -o "%.18i %.9P %.25j %.8u %.8T %.10M %.9l %.6D %R"'
alias sqp='squeue -p edith -o "%.18i %.9P %.25j %.8u %.10T %.15M %.15l %5D %12R %b"'
alias si='sinfo -O "NodeHost:10","StateCompact:6","CPUsState:14","Memory:7","AllocMem:9","FreeMem:9","GresUsed:55","Gres:55" -p edith'
```

## Slurm Submission script
Submission script for computecananda, vector, and Leon's server.
Runing this script will automatically generate sbatch submission file and submit the job to slurm system.
```python
#!/usr/bin/env python3
# by muchenli
# modified from https://github.com/ubc-vision/compute-canada-goodies/blob/master/python/queue_cc.py

import argparse
import getpass
import os
import shutil
import time
import socket
import subprocess
import datetime

CLUSTER_CONFIG = {
    "cedar":
        {
            "gpu_model": "v100l",
            "gpus_per_node": 4,
            "cpu_cores_per_node": 24,
            "threads_per_node": 48,
            "cpu_cores_per_gpu": 6,
            "threads_per_gpu": 12,
            "ram_per_node": 120,
            "ram_per_gpu": 24,
            "job_system": "slurm",
            "partition": None,
            "nodelist": None,
            "default_account": "rrg-lsigal",
        },
    # "sockeye":
    #     {
    #         "gpu_model": "v100",
    #         "gpus_per_node": 4,
    #         "cpu_cores_per_node": 24,
    #         "threads_per_node": None,
    #         "cpu_cores_per_gpu": 6,
    #         "threads_per_gpu": None,
    #         "ram_per_node": 191000,
    #         "ram_per_gpu": 47750,
    #         "job_system": "PBS",
    #         "partition": None,
    #         "nodelist": None,
    #         "default_account": "pr-kmyi-1",
    #         "default_gpu_account": "pr-kmyi-1-gpu",
    #     },
    "edith":
        {
            "cpu_cores_per_gpu": 2,
            "ram_per_gpu": 8,
            "job_system": "slurm",
            "partition": "edith",
            "nodelist": None,
            "default_account": None
        },
    "vector":
        {
            "cpu_cores_per_gpu": 8,
            "ram_per_gpu": 40,
            "job_system": "slurm",
            "partition": "a40",
            "nodelist": None,
            "default_account": None
        }
}

# User NOTE: Add python environment init command here
ENV_INIT_COMMAND = {
    "vector": "source ~/setup.sh\n"
              "conda activate pt\n"
              "export PYTHONPATH=./\n",
    "edith": "conda activate nni\n"
             "export GLOO_SOCKET_IFNAME='eno1'\n" # https://pytorch.org/docs/stable/distributed.html#common-environment-variables
             "export TP_SOCKET_IFNAME='eno1'",  # This is required to make sure rpc works correctly on Edith
    "cedar": "source ~/torch/bin/activate\n"
             "export PYTHONPATH=./",
}

# DIST_INIT_COMMAND = "export MASTER_ADDR=$(hostname)"

DATA_INIT_COMMAND = {
    "tiny-imagenet": "mkdir $SLURM_TMPDIR/tiny-imagenet\n"
    "cp ~/projects/def-lsigal/muchenli/DATASET/tiny-imagenet-200/tiny-imagenet.hdf5 $SLURM_TMPDIR/tiny-imagenet/"
}

# User NOTE: customize your commands here:
# here I add command line exp_name to my output path
def customize_command(commands):
    # exp_name = os.getenv("SID", "DEFAULT")
    # for i, c in enumerate(commands):
    #     if c == '--config-file':
    #         config_path = commands[i+1].split('config/', 1)[-1].rsplit('.', 1)[0]
    # commands.append('OUTPUT_DIR')
    # commands.append(os.path.join('.exps', config_path, exp_name))
    return commands

def customize_script(script_lines):
    # if args.load_data == 'tiny-imagenet' and cluster in ['cedar', 'narval']:
    #     script_lines.append(DATA_INIT_COMMAND[args.load_data])
    return script_lines

def get_slurm_script(args, cluster_name, dep_str=None):
    d = {}
    default_cfg = CLUSTER_CONFIG[cluster_name]

    num_gpu = args.num_gpu
    # Set options which could be None
    d["account"] = default_cfg["default_account"] if args.account is None else args.account
    d["partition"] = default_cfg["partition"] if args.partition is None else args.partition
    d["nodelist"] = default_cfg["nodelist"] if args.nodelist is None else args.nodelist
    # Set options or automatically infer CPU and MEM
    num_cpu = default_cfg["cpu_cores_per_gpu"] * num_gpu if args.num_cpu < 0 else args.num_cpu
    d["cpus-per-task"] = max(num_cpu // args.ntasks_per_node, 1)
    mem = default_cfg["ram_per_gpu"] * num_gpu if args.mem < 0 else args.mem        
    d["mem"] = str(max(mem, default_cfg["ram_per_gpu"]))+'G'
    # Set universal needed options
    d["nodes"] = args.nodes
    d["ntasks-per-node"] = args.ntasks_per_node
    d["time"] = args.time_limit
    d["output"] = f"{args.log_dir}/{time.strftime('%m%d')}_%x_%j.out"
    d["mail-user"] = "jojo23333.code@gmail.com"
    d["mail-type"] = "BEGIN,FAIL"
    d["export"] = "ALL"

    if cluster_name == 'vector':
        d["qos"] = "normal"
        # d["qos"] = "deadline"
        # d["account"] = "deadline"
        if num_gpu == 1 and args.nodes == 1:
            d['partition'] = 'rtx6000'

    # Generate script
    script_lines=["#!/bin/bash"]
    if num_gpu > 0:
        if cluster_name == 'cedar':
            script_lines.append(f"#SBATCH --gres=gpu:v100l:{num_gpu}")
        else:
            script_lines.append(f"#SBATCH --gres=gpu:{num_gpu}")
    for key, value in d.items():
        if value is not None:
            script_lines.append(f"#SBATCH --{key}={str(value)}")
    # if run with dependency
    if dep_str is not None:
        script_lines.append(f"#SBATCH --dependency=afterany:{dep_str}")
    if args.exclude is not None:
        script_lines.append(f"#SBATCH --exclude={args.exclude}")
    script_lines.append("")
    return d, script_lines


def main(args):
    if not os.path.exists(args.log_dir):
        os.makedirs(args.log_dir)

    if not os.path.exists(args.script_dir):
        os.makedirs(args.script_dir)

    # Get hostname and user name
    username = getpass.getuser()
    hostname = socket.gethostname()

    # Identify cluster
    if config.cluster is None:
        if hostname.startswith("gra"):
            cluster = "graham"
        elif hostname.startswith("cedar") or hostname.startswith("cdr"):
            cluster = "cedar"
        elif hostname.startswith("beluga") or hostname.startswith("blg"):
            cluster = "beluga"
        # elif hostname.startswith("se"):
        #     cluster = "sockeye"
        elif hostname.startswith("narval"):
            cluster = "narval"
        elif hostname.startswith("borg"):
            cluster = "edith"
        elif hostname.startswith("vremote"):
            cluster = "vector"
        else:
            raise ValueError("Unknown cluster {}".format(hostname))
    else:
        cluster = config.cluster

    dep_str = None
    for i in range(args.repeat):
        # set time limit
        config_d, script_lines = get_slurm_script(args, cluster, dep_str)
        script_lines.append(ENV_INIT_COMMAND[cluster])
        # script_lines.append(DIST_INIT_COMMAND)
        script_lines = customize_script(script_lines)
        command = customize_command(list(args.command))

        exp_name = os.getenv("SID", default='test') + (f'_{i+1}.sh' if i > 0 else '.sh')
        bash_file_path = os.path.join(args.script_dir, exp_name)

        with open(bash_file_path, 'w') as f:
            for line in script_lines:
                f.write(line + '\n')
            f.write('srun ')
            if cluster == 'vector':
                f.write(f'--mem={config_d["mem"]} ')
            f.write(' '.join(command))
            f.close()

        # legacy code to run 1 job
        # bash_file_path = os.path.abspath(bash_file_path)
        # print(f"sbatch {bash_file_path}", os.path.exists(bash_file_path))
        # os.system(f"sbatch {bash_file_path}")

        # run command with subprocess
        slurm_res = subprocess.run(["sbatch", f"{bash_file_path}"], stdout=subprocess.PIPE)
        print(slurm_res.stdout.decode())
        # get job ID, potentially use it for conditional job submitting
        if slurm_res.returncode != 0:
            raise RuntimeError("Slurm/PBS error!")
        job_id = slurm_res.stdout.decode().split()[-1]
        dep_str = str(job_id)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--account", type=str, default=None, help="Slurm account to use. ")
    parser.add_argument("--cluster", type=str, default=None, help="Name of the cluster.")
    parser.add_argument("--log_dir", type=str, default=".exps/slurm_log", help="")
    parser.add_argument("--script_dir", type=str, default=".exps/cc_scripts", help="")
    parser.add_argument("--load_data", type=str, default="", help="Some customize op to pre-load data")
    # Per job Arguments
    parser.add_argument("--num_runs", type=int, default=5, help="Number of times this shell script will be executed. This is useful when running 3 hour jobs that run multiple times.")
    parser.add_argument("--nodes", type=int, default=1)
    parser.add_argument("--ntasks_per_node", type=int, default=1)
    parser.add_argument("--num_gpu", type=int, default=1, help="Number of GPUs Per Node. Set zero to not use the gpu node.")
    parser.add_argument("--num_cpu", type=int, default=-1, help="Number of CPU cores to use. Set -1 for auto inference.")
    parser.add_argument("--mem", type=int, default=-1, help="Amount of memory to use. See compute canada wiki. Typically, <= 8G per CPU core. Set -1 for auto inference.")
    parser.add_argument("--time_limit", type=str, default="02-23:59", help="Time limit on the jobs.  Day-time-minutes")
    parser.add_argument("--partition", type=str, default=None, help="Partition to be used.")
    parser.add_argument("--nodelist", type=str, default=None, help="List of nodes to be used.")
    parser.add_argument("--exclude", type=str, default=None, help="List of nodes to be excluded.")
    parser.add_argument("--repeat", type=int, default=1, help="Number of times to repeat the job, add dependency auotomatically")

    parser.add_argument("command", default=None, nargs=argparse.REMAINDER)

    config, unparsed = parser.parse_known_args()
    assert config.command is not None
    # If we have unparsed arguments, print usage and exit
    if len(unparsed) > 0:
        parser.print_usage()()
        exit(1)

    main(config)
```


use case
```bash
# SID=exp_name python scripts/submit.py --nodes 2 --num_gpu 4 --ntasks_per_node 1 --time_limit ...
```
it will automatically detect your cluster.
