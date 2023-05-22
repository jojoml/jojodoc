## Before start
* Vector's document is a bit of out-dataed, but is a still useful reference: [Vector Computing](https://support.vectorinstitute.ai/Computing)
Please note you have to use your login credential.
* If you are affiliated with vector, consider to join vector's slack channel where you can reachout to IT over(#Computing Channel)
* Learn how to login and which cluster to use, now you need to setup duo-factor credentials, you should find email sent to you if you are affiliated.

## Storage and Compute Resources
As indicated here: https://support.vectorinstitute.ai/HomeDirectories-ScratchSpace-Vaughan
All new users will have their SSD scratch space in "/scratch/ssd004/scratch/$USER/" with a quota of 100 GB.

Pls consider reach out to IT over SLACK

## Environment Setting
Use conda provided by vector or install your own ones
```bash
export PATH=/pkgs/anaconda3/bin:$PATH
which Conda
```
https://support.vectorinstitute.ai/SetComputingEnvironment

## Submitting Jobs
[Available Compute Nodes](https://support.vectorinstitute.ai/Vaughan_slurm_changes)

[Submit Jobs](https://support.vectorinstitute.ai/UsingSlurm)

## Vaughan preemption and checkpointing
Vanughan use a preemption policy to make sure every job has a chance of being runned.
Please see details here:
[**Policy details**](https://support.vectorinstitute.ai/AboutVaughan2#Checkpoint.2FRestart)

Important: Since any job can be preempted, please make sure your running jobs can auto resume it self if it's rerunned

## Easy Script for submitting jobs (Integrated with Compute Canand)
Please refer https://jojoml.github.io/jojodoc/coding/cheatsheets/slurm/


