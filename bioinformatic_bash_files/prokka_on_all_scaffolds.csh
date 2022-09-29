#!/bin/sh
#SBATCH
#SBATCH --job-name=prokka
#SBATCH --time=72:00:00
#SBATCH --nodes=1
#SBATCH --partition=lrgmem
#SBATCH --ntasks-per-node=24

IN_FILE=../ASSEMBLY/final_assembly.fasta
TMP_IN=../ASSEMBLY/final_assembly_shortname.fasta
OUT_DIR=../Prokka_all_scaffolds

#python shorten_contig_names.py $IN_FILE > $TMP_IN
#echo "contig names have been shortened"

ml anaconda
ml -centos7
conda activate Prokka
echo "prokka module successfully loaded"
#note that the $OUT_DIR must not exist, otherwise next line will not run
prokka --cpus 24 --outdir $OUT_DIR $TMP_IN
echo "prokka is done"
date

