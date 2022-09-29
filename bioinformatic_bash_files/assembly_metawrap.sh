#!/bin/sh
#SBATCH
#SBATCH --job-name=ASSEMBLY-MW
#SBATCH --time=72:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=48
#SBATCH --partition=lrgmem

export PATH="~/.conda/envs/metawrap-env/bin:$PATH"
source ~/.bashrc

CLEAN_READS=../CLEAN_READS
ASSEMBLY=../ASSEMBLY

mkdir -p $ASSEMBLY

metawrap assembly -1 $CLEAN_READS/all_rawreads_1.fastq -2 $CLEAN_READS/all_rawreads_2.fastq -m 1000 -t 48 --metaspades -o $ASSEMBLY

