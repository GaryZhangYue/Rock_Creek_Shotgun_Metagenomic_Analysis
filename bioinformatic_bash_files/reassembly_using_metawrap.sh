#!/bin/sh
#SBATCH
#SBATCH --job-name=reassembly_metawrap
#SBATCH --time=72:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=48
#SBATCH --partition=lrgmem

echo "starting reassembly"
date

ml anaconda
conda activate metawrap-env
#make sure mkdir reassembly

OUT_DIR=../REASSEMBLY
CLEAN_READS_1=../CLEAN_READS/all_rawreads_1.fastq
CLEAN_READS_2=../CLEAN_READS/all_rawreads_2.fastq
BIN=../BIN_REFINEMENT/metawrap_70_5_bins

mkdir -p ${OUT_DIR}
metawrap reassemble_bins -o $OUT_DIR -1 $CLEAN_READS_1 -2 $CLEAN_READS_2 -t 48 -m 1000 -c 70 -x 5 -b $BIN

echo"end"
date
