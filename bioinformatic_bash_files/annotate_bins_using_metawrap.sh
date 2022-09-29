#!/bin/sh
#SBATCH
#SBATCH --job-name=annotate_metawrap
#SBATCH --time=6:00:00
#SBATCH --nodes=1
#SBATCH --partition=lrgmem
#SBATCH --ntasks-per-node=48

#I couldn't get the prokka program in metawrap-env to run. Instead, I installed prokka by myself into a new virtual env, called Prokka. prokka is the only program required by this metawrap module, and the rest of the module justuses some python scripts, whose path has been configured by metawrap-config (its path is already in .bashrc during installation). So we can just conda activate Prokka to run this module.
#Note that prokka still hits the the perl path of the system: to be specific, it hits the perl path pointed by a pre-loaded module called centos7. To resolve this, run the following line.

ml -centos7 
ml anaconda
conda activate Prokka
#export PATH="~/.conda/envs/metawrap-env/bin:$PATH"
#source ~/.bashrc

IN=../REASSEMBLY/reassembled_bins
OUT=../BIN_ANNOTATION
metaWRAP annotate_bins -o $OUT -t 48 -b $IN


