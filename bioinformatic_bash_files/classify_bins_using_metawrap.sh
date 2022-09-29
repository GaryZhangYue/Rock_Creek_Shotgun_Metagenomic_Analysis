#!/bin/sh
#SBATCH
#SBATCH --job-name=classify_metawrap
#SBATCH --time=6:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=48
#SBATCH --partition=lrgmem

echo "starting classifying bins"
date

ml anaconda
conda activate metawrap-env
#make sure mkdir reassembly

IN=../REASSEMBLY/reassembled_bins
OUT=../BIN_CLASSIFICATION
metawrap classify_bins -b $IN -o $OUT -t 48

echo "end"
date
