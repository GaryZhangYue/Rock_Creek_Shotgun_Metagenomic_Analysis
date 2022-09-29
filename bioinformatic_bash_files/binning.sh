#!/bin/sh
#SBATCH
#SBATCH --job-name=binning
#SBATCH --time=72:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=48
#SBATCH --partition=lrgmem

date
echo "starting binning"

export PATH="~/.conda/envs/metawrap-env/bin:$PATH"
source ~/.bashrc

OUTDIR=../BINNING

mkdir -p $OUTDIR

ASSEMBLY=../ASSEMBLY/final_assembly.fasta
IN=../CLEAN_READS

metawrap binning -o ${OUTDIR} -t 48 -a $ASSEMBLY --metabat2 --maxbin2 --concoct ${IN}/all_rawreads_1.fastq ${IN}/all_rawreads_2.fastq

echo "end"
date
